## What and why

<!-- One or two sentences. The PR title becomes the squashed commit message on main:
     imperative mood, e.g. "Add sweep-and-prune broadphase". -->

## How it was tested

<!-- Tests added/changed, preset(s) run locally, e.g. `ctest --preset msvc-debug -L broadphase`. -->

## Checklist

- [ ] Tests written first (red), then code (green), then refactor
- [ ] `ctest` passes locally on at least one preset
- [ ] Public API documented (`///`), module README updated if needed
- [ ] No new third-party dependency, or it was agreed and added to `vcpkg.json`
- [ ] Changes to install/export/CMake interface were checked with `cmake --workflow --preset ci-<compiler>`
- [ ] An ADR was added for any significant or irreversible decision
