# ADR 0004: std::expected for recoverable errors {#adr_0004}

- **Status**: Accepted
- **Date**: 2026-11-05

## Context

A consistent error-handling policy across many modules makes APIs predictable and testable.

## Decision

- Recoverable failures are returned as `skel::core::result<T>` (`std::expected<T, error>`),
  built with `skel::core::make_error(errc, message)`.
- Exceptions are reserved for programming errors and truly exceptional states (allocation
  failure, broken invariants). They must not cross module boundaries as a normal control path.
- Functions that cannot fail are `noexcept` where meaningful.
- Results are `[[nodiscard]]`.

## Consequences

- Error paths are visible in signatures and trivially unit-tested.
- `errc` will grow; modules may define their own codes later (via a new ADR if the shared
  `error` type needs to become extensible).
