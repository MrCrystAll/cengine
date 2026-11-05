# ADR 0008: Configurable scalar precision, double by default {#adr_0008}

- **Status**: Accepted
- **Date**: 2026-11-05

## Context

A physics engine must pick a floating-point type. `float` is faster and smaller; `double` gives
headroom for large worlds and long simulations. Different users need different trade-offs, but
mixing precisions between the library and its consumers breaks the ABI.

## Decision

- The engine scalar is `cengine::real`, defined in the generated, installed header
  `<cengine/core/config.hpp>`.
- The CMake option `CENGINE_DOUBLE_PRECISION` (default **ON**) selects `double`; OFF selects `float`.
- It is a generated header rather than a `-D` compile definition, so an installed package always
  carries the precision it was built with. Consumers can't pick a mismatching type, and
  `find_package(cengine)` exposes it as `cengine_DOUBLE_PRECISION`.
- `real` must be an IEEE 754 type (`static_assert` in `config.hpp`).
- Engine code uses `real`, never raw `float`/`double`. Exception: the math library may be written as
  templates (`basic_vec3<T>`) with `real` aliases, so both precisions can be tested in one build.
- Literals: `static_cast<real>(0.1)` (exact and deterministic). No user-defined literal is
  provided, because UDLs take `long double`, and its double rounding differs between platforms.
- CI builds and tests both precisions. Package names include the precision.

## Consequences

- Choosing the precision is a build-time choice for the whole engine, not per object.
- Every API touching scalars must use `real`, which code review and tests enforce.
