// main() shared by every cengine benchmarks executable.
//
//   cengine_<module>_benchmarks [--filter <text>] [--json <file>] [--smoke] [--help]
//
// --smoke runs every benchmark once with minimal iterations: CI uses it to check that the
// benchmarks build and run. It doesn't measure anything (shared CI runners are too noisy).

#include <cengine/bench/bench.hpp>

#include <cstdlib>
#include <fstream>
#include <iostream>
#include <span>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

namespace cengine::bench {

namespace {

struct entry {
    std::string title;
    bench_fn fn;
};

std::vector<entry>& registry() {
    static std::vector<entry> entries;
    return entries;
}

struct options {
    std::string filter;
    std::string json_path;
    bool smoke = false;
    bool help = false;
};

options parse(std::span<char*> args) {
    options opts;
    for (std::size_t i = 1; i < args.size(); ++i) {
        const std::string_view arg{args[i]};
        if (arg == "--smoke") {
            opts.smoke = true;
        } else if (arg == "--filter" && i + 1 < args.size()) {
            opts.filter = args[++i];
        } else if (arg == "--json" && i + 1 < args.size()) {
            opts.json_path = args[++i];
        } else {
            opts.help = true;
        }
    }
    return opts;
}

} // namespace

registration::registration(std::string_view title, bench_fn fn) {
    registry().push_back(entry{std::string{title}, fn});
}

} // namespace cengine::bench

int main(int argc, char** argv) {
    using namespace cengine::bench;
    const options opts = parse(std::span{argv, static_cast<std::size_t>(argc)});
    if (opts.help) {
        std::cout << "usage: " << argv[0] << " [--filter <text>] [--json <file>] [--smoke]\n";
        return EXIT_FAILURE;
    }

    std::vector<ankerl::nanobench::Result> results;
    int executed = 0;
    for (const entry& e : registry()) {
        if (!opts.filter.empty() && e.title.find(opts.filter) == std::string::npos) {
            continue;
        }
        ankerl::nanobench::Bench bench;
        bench.title(e.title);
        if (opts.smoke) {
            bench.epochs(1).epochIterations(1).warmup(0).output(nullptr);
        }
        e.fn(bench);
        for (const auto& result : bench.results()) {
            results.push_back(result);
        }
        ++executed;
    }

    if (executed == 0) {
        std::cerr << "no benchmark matches '" << opts.filter << "'\n";
        return EXIT_FAILURE;
    }
    if (!opts.json_path.empty()) {
        std::ofstream out{opts.json_path};
        ankerl::nanobench::render(ankerl::nanobench::templates::json(), results, out);
    }
    if (opts.smoke) {
        std::cout << "smoke: " << executed << " benchmark group(s) ran\n";
    }
    return EXIT_SUCCESS;
}
