#include <cengine/bench/bench.hpp>
#include <cengine/core/result.hpp>

#include <nanobench.h>

namespace {

cengine::core::result<int> checked_half(int value) {
    if (value % 2 != 0) {
        return cengine::core::make_error(cengine::core::errc::invalid_argument, "odd value");
    }
    return value / 2;
}

} // namespace

CENGINE_BENCHMARK(result_paths, "core: result<int> success and error paths") {
    int input = 42;
    bench.run("success path", [&] { ankerl::nanobench::doNotOptimizeAway(checked_half(input)); });
    input = 43;
    bench.run("error path (allocates the message)",
              [&] { ankerl::nanobench::doNotOptimizeAway(checked_half(input)); });
}
