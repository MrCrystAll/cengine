# Testing (TDD) {#testing}

This project is test-driven. No production code is written without a failing test first.

## The loop

1. **Red**: write the smallest test describing the next behaviour. Build, run, watch it fail
   (for the right reason: an assertion, not a typo).
2. **Green**: write the simplest code that makes it pass.
3. **Refactor**: clean up code *and* tests with the suite green.
4. Repeat. Commit at green.

```bash
cmake --build --preset msvc-debug && ctest --preset msvc-debug -L core
```

## Test levels

| Level | Where | Label | Notes |
|---|---|---|---|
| Unit | `libs/<module>/tests/` | `<module>`, `unit` | through the public API only, fast, no I/O |
| Smoke | `apps/<app>/CMakeLists.txt` | `<app>`, `smoke` | the binary starts and behaves |
| Package | `tests/` | `package` | installs, then builds `tests/package` with `find_package` |

```bash
ctest --preset <p> -L unit          # only unit tests
ctest --preset <p> -LE package      # everything except the (slower) package test
ctest --preset <p> -R "core\\.result"   # by name
```

## Conventions (Catch2 v3)

- One test file per header under test: `include/cengine/x/foo.hpp` -> `tests/test_foo.cpp`.
- `TEST_CASE("<behaviour in plain English>", "[<module>][<topic>]")`.
- Use `SECTION` for variants sharing setup, `GENERATE` for tables of inputs.
- `REQUIRE` when continuing makes no sense, `CHECK` otherwise; `STATIC_REQUIRE` for `constexpr`.
- Test failures returned as `result<T>` explicitly: check `has_value()` *and* the `errc`.
- Include only the Catch2 headers you need (`<catch2/catch_test_macros.hpp>`, ...).

## Testing internals

Regular tests link to the module like any consumer and only see public headers. Prefer that.

For implementation details that must stay private but deserve their own tests (GJK, EPA, the
contact solver...), use an **internal** test target:

```cmake
# libs/collision/tests/CMakeLists.txt
cengine_add_tests(collision SOURCES test_shapes.cpp)                 # public API
cengine_add_tests(collision INTERNAL SOURCES test_gjk_internal.cpp)  # src/ details
```

```cpp
#include "gjk.hpp"   // from libs/collision/src/
```

`INTERNAL` builds `cengine_<module>_internal_tests` against a private static copy of the
module, compiled from the same sources and flags with `src/` on the include path. Hidden
symbols in shared builds don't matter. CTest names are prefixed `<module>.internal.`, with
label `internal`. Don't put an internal test and a public test in the same executable.

## Sanitizers

```bash
cmake --workflow --preset ci-sanitize    # Linux/macOS, Clang: ASan + UBSan, all tests
```

AddressSanitizer catches out-of-bounds accesses, use-after-free and leaks. UndefinedBehaviorSanitizer
catches signed overflow, misaligned access, invalid shifts and more. Any finding fails the test
(`halt_on_error` / `abort_on_error`), with a stack trace. Only cengine targets are instrumented
(`CENGINE_SANITIZERS`), and the install/package test is disabled in this configuration. A CI job
runs it on every PR.

## Coverage

```bash
cmake --workflow --preset ci-coverage
cmake --build --preset ci-coverage --target coverage   # needs gcovr
```

Report: `build/ci-coverage/coverage/index.html`.
