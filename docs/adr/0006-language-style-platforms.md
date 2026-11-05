# ADR 0006: C++23, snake_case, Windows/Linux/macOS {#adr_0006}

- **Status**: Accepted
- **Date**: 2026-11-05

## Decision

- **Standard**: C++23 (`cxx_std_23` on every target, extensions off).
- **Platforms**: Windows (MSVC, clang-cl), Linux (GCC, Clang), macOS (Apple Clang). Code must be
  portable; platform-specific code is isolated behind an interface in its own source file.
- **Style**: standard-library-like `snake_case` for everything except template parameters
  (`CamelCase`) and macros (`UPPER_CASE`); private/protected data members end with `_`.
  Enforced by `.clang-tidy` (readability-identifier-naming) and `.clang-format`.
- **Libraries**: static by default, `BUILD_SHARED_LIBS=ON` supported (export headers, hidden
  visibility, a shared CI job).
- **Quality gates in CI**: warnings as errors, clang-tidy, clang-format, coverage report,
  Doxygen warnings as errors.

## Consequences

- Compilers older than GCC 13 / Clang 19 / MSVC 19.40 are not supported. (Amended 2026-11-05:
  the original Clang 17 floor was wrong. Clang 18 reports `__cpp_concepts < 202002`, so
  libstdc++ hides `std::expected`. CI installs Clang 20 on Ubuntu 24.04.)
- Library features unevenly supported across vendors (e.g. `std::print` on older Apple libc++)
  must be checked against all three CI platforms before use.
