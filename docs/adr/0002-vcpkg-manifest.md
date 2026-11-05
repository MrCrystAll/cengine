# ADR 0002: vcpkg (manifest mode) for third-party dependencies {#adr_0002}

- **Status**: Accepted
- **Date**: 2026-11-05

## Context

Dependency management is a priority: many modules, three platforms, reproducible builds.
Alternatives considered: Conan 2 (powerful, extra Python tooling), CPM/FetchContent (no
binary caching, rebuilds from source, weak version resolution).

## Decision

vcpkg in manifest mode: `vcpkg.json` lists dependencies, `vcpkg-configuration.json` pins the
registry baseline. Optional dependencies are grouped in vcpkg *features* toggled from CMake
options. Overlay ports/triplets live in `vcpkg/`.

## Consequences

- `VCPKG_ROOT` must be set on every dev machine; presets use it for the toolchain file.
- Native `find_package()` everywhere; consumers of the installed package re-find deps through
  the generated config files.
- CI caches vcpkg binary archives per job.
- Upgrading = bumping one baseline commit.
