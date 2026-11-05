# Shared benchmark runner: main(), the registry and command-line handling. Each module's
# benchmarks executable (cengine_add_benchmarks) links it; see docs/guides/benchmarking.md.
add_library(cengine_bench_runner STATIC src/runner.cpp)
target_include_directories(cengine_bench_runner PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_compile_features(cengine_bench_runner PUBLIC cxx_std_23)
target_link_libraries(cengine_bench_runner
  PUBLIC nanobench::nanobench
  PRIVATE $<BUILD_INTERFACE:cengine_project_options>)
