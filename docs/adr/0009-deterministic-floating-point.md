# ADR 0009: Bit-identical floating-point results across platforms {#adr_0009}

- **Status**: Accepted
- **Date**: 2026-11-05

## Context

We want the same inputs to produce bit-identical simulation results on every supported platform
and compiler (Windows/MSVC/clang-cl, Linux/GCC/Clang, macOS/Apple Clang on x86-64 and ARM64).
That enables lockstep networking, replays and golden-value tests. IEEE 754 makes `+ - * /` and
`sqrt` exactly specified, but compilers may legally break that in several ways.

## Decision

**Compiler flags**, applied to `cengine::core` as **PUBLIC** options so that every module and every
consumer's inline (header) code gets them:

| Compiler | Flags | Why |
|---|---|---|
| MSVC | `/fp:precise` | forbid `/fp:fast`; MSVC doesn't contract to FMA unless `/fp:contract` |
| clang-cl | `/clang:-ffp-contract=off` | precise by default, but contracts to FMA unless told not to |
| GCC, Clang, Apple Clang | `-ffp-contract=off` | no fused multiply-add (the main ARM64 divergence) |

Configuring with `-ffast-math`, `-Ofast` or `/fp:fast` in `CMAKE_CXX_FLAGS` is a hard error.
Only x86-64 (SSE2) and ARM64 are supported, so there's no x87 excess precision.

**Code rules** for anything on the simulation path:

1. Use only `+ - * /`, `sqrt`, `abs`, `min`/`max`, `floor`/`ceil`/`trunc`/`round` and `fma` (when
   called explicitly). These are exactly specified by IEEE 754 / C++.
2. **No** `std::sin`, `cos`, `tan`, `exp`, `log`, `pow`, `atan2`, ... Their results differ between C
   runtime implementations. The math module will provide deterministic versions.
3. No `long double`. No iteration over `std::unordered_*` containers when the order affects
   results (the order differs between standard libraries).
4. Parallel code must combine results in a fixed order (no reductions in arrival order).
5. Don't change rounding mode or denormal handling (FTZ/DAZ) at runtime.

**Verification**: a "determinism canary" unit test checks that `a*b + c` isn't fused, in both
precisions, on every CI platform. Later physics modules add golden-value tests that compare
bit patterns of simulation results across all CI platforms.

## Consequences

- Some performance is lost: no FMA contraction and no fast-math reassociation. Explicit
  `std::fma` remains available where it's beneficial and deterministic.
- Consumers inherit the FP flags through `cengine::core`. That's intentional: inline engine code
  compiled in their translation units has to follow the same rules.
- Transcendental functions must be implemented in-house before physics code needs them.
