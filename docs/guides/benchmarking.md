# Benchmarking {#benchmarking}

Benchmarks use [nanobench](https://nanobench.ankerl.com) through the vcpkg `benchmarks`
feature. They are off by default (`CENGINE_BUILD_BENCHMARKS`).

## Run

```bash
cmake --preset msvc-bench            # gcc-bench / clang-bench: Release + benchmarks
cmake --build --preset msvc-bench
build/msvc-bench/bin/cengine_core_benchmarks                      # all benchmarks of core
build/msvc-bench/bin/cengine_core_benchmarks --filter result      # by title
build/msvc-bench/bin/cengine_core_benchmarks --json before.json   # machine-readable report
```

To compare a change, save `--json` before and after on the **same machine**, with nothing
else running. Benchmark numbers from shared CI runners are too noisy to catch regressions, so CI
only runs a **smoke** pass (`--smoke`, one iteration each) to check that the benchmarks build and
run. It is the `<module>.benchmarks.smoke` CTest, label `benchmark`, in the `ci-gcc` job.

## Write

```
libs/<module>/benchmarks/
├── CMakeLists.txt     cengine_add_benchmarks(<module> SOURCES bench_foo.cpp)
└── bench_foo.cpp
```

```cpp
#include <cengine/bench/bench.hpp>

CENGINE_BENCHMARK(vec3_dot, "math: vec3 dot product") {
    const cengine::math::vec3 a{1, 2, 3}, b{4, 5, 6};
    bench.run("dot", [&] { ankerl::nanobench::doNotOptimizeAway(dot(a, b)); });
}
```

- One `CENGINE_BENCHMARK` per group. Use one `bench.run(...)` per case to compare variants
  side by side.
- Always pass results to `doNotOptimizeAway`, or the compiler may delete the work.
- Use `bench.batch(n)` or `bench.complexityN(n)` for per-element or scaling measurements.
- `cengine_add_benchmarks(<module> INTERNAL ...)` benchmarks `src/` details, like INTERNAL tests.
- Add `add_subdirectory(benchmarks)` to the module's CMakeLists.
