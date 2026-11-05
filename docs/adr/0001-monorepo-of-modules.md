# ADR 0001: Monorepo of small modules built with CMake {#adr_0001}

- **Status**: Accepted
- **Date**: 2026-11-05

## Context

The project will be made of many microprojects that share code and evolve together. We want
strong separation of concerns, a core usable by several front-ends (executables, other libraries),
and cheap creation of new modules.

## Decision

One repository. Each microproject is a library module in `libs/<name>/`, declared through
`skel_add_library()` (cmake/SkelModule.cmake), with its own tests, docs page, install component
and exported target `skel::<name>`. Executables live in `apps/` and contain no business logic.

## Consequences

- Atomic changes across modules, one CI, one dependency baseline.
- Consistency is enforced by the helper functions rather than by convention.
- Module boundaries must be guarded in review (no reaching into another module's `src/`).
- A module can still be consumed individually: `find_package(skel COMPONENTS <name>)`.
