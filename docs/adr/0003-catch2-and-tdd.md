# ADR 0003: Catch2 v3 and test-driven development {#adr_0003}

- **Status**: Accepted
- **Date**: 2026-11-05

## Context

The project is TDD-driven: tests are written first and must be cheap to write and run.

## Decision

Catch2 v3 (via the vcpkg `tests` feature), discovered by CTest through `catch_discover_tests`
so each `TEST_CASE` is an individual CTest test. Every module has a `tests/` folder registered
with `skel_add_tests()`. A package test verifies the installed CMake package.

## Consequences

- Natural-language test names, `SECTION`s and generators; built-in micro-benchmarks if needed.
- No mocking library: favour designs with injected interfaces/fakes. Add a mocking library
  (e.g. trompeloeil) through a new ADR if needed.
- CI runs all tests on all platforms, plus coverage on Linux.
