# ADR 0010: CENGINE_ASSERT for invariants {#adr_0010}

- **Status**: Accepted
- **Date**: 2026-11-05

## Context

Physics code relies on many invariants: no NaN, unit quaternions, positive mass, valid inertia
tensors. Violations are programming errors, not recoverable failures, so `result<T>`
(ADR 0004) is the wrong tool. Checks in hot loops must cost nothing in Release.

## Decision

`<cengine/core/assert.hpp>` provides:

- `CENGINE_ASSERT(condition, "message")`: enabled when `NDEBUG` isn't defined (Debug builds).
  In Release it compiles to nothing, and the condition isn't evaluated.
- `CENGINE_ASSERT_SLOW(condition, "message")`: for expensive checks, such as validating a whole
  contact manifold. Opt-in with `-DCENGINE_ENABLE_SLOW_ASSERTS=1`, and only active when asserts are.
- Either can be forced with `-DCENGINE_ENABLE_ASSERTS=0|1` (for example, asserts in a
  profiling build). The default follows `NDEBUG`.
- On failure, the macros call `cengine::core::report_assertion_failure()`, which invokes a
  **replaceable handler** (`set_assert_handler`). It receives the expression, the message and the
  `std::source_location`. The default handler prints them to `stderr` and calls `std::abort()`. A
  handler must not return; if it does, the program aborts anyway. A handler may throw, which is how
  the unit tests check that an assert fires.

## Consequences

- Never put side effects in an assert condition; Release won't evaluate it.
- Asserts are tested: tests install a throwing handler and use `REQUIRE_THROWS_AS`.
- `result<T>` stays for recoverable errors, and asserts are for bugs.
