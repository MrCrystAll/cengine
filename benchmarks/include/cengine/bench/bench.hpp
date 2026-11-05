#pragma once

// Benchmark registration for cengine modules (nanobench based).
//
//   CENGINE_BENCHMARK(result_success, "core: result<int> success path") {
//       bench.run("make value", [] {
//           ankerl::nanobench::doNotOptimizeAway(cengine::core::result<int>{42});
//       });
//   }
//
// Each module's benchmarks executable gets main() from the runner. Run it with
// --help to see the options (filter, JSON output, smoke mode).

#include <nanobench.h>

#include <string_view>

namespace cengine::bench {

using bench_fn = void (*)(ankerl::nanobench::Bench& bench);

/// Registers a benchmark at static-initialisation time (use CENGINE_BENCHMARK).
struct registration {
    registration(std::string_view title, bench_fn fn);
};

} // namespace cengine::bench

// NOLINTBEGIN(cppcoreguidelines-macro-usage): registration needs a unique static object.
#define CENGINE_BENCHMARK(id, title)                                                               \
    static void id(ankerl::nanobench::Bench& bench);                                               \
    static const ::cengine::bench::registration id##_registration{(title), &id};                   \
    static void id([[maybe_unused]] ankerl::nanobench::Bench& bench)
// NOLINTEND(cppcoreguidelines-macro-usage)
