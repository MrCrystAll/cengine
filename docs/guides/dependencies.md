# Dependencies {#dependencies}

All third-party code comes through **vcpkg in manifest mode**. Nothing is vendored, nothing is
fetched ad-hoc with `FetchContent` (the docs theme is the one exception: it is not code).

## Files

| File | Role |
|---|---|
| `vcpkg.json` | what we depend on (and optional *features*) |
| `vcpkg-configuration.json` | where ports come from: default registry + **baseline commit**, extra registries, overlays |
| `vcpkg/ports/` | overlay ports: private or patched libraries |
| `vcpkg/triplets/` | custom triplets |

The baseline pins every port version: two machines with the same files get the same libraries.

## Adding a dependency

1. Add it to `vcpkg.json`:
   - always needed by the library code -> top-level `"dependencies"`;
   - only for tests/tools -> inside a feature (e.g. `"tests"`).
   Use `"version>="` for a minimum version; the baseline decides the exact one.
2. In the module's `skel_add_library(...)`: `PACKAGES <find_package name>` and the imported
   target in `PUBLIC_DEPS` or `PRIVATE_DEPS`.
3. Re-configure. vcpkg installs into `build/<preset>/vcpkg_installed`.

```json
"dependencies": [ { "name": "fmt", "version>=": "11.0.0" } ]
```

## Upgrading

Change `baseline` in `vcpkg-configuration.json` to a newer commit of microsoft/vcpkg
(`git ls-remote https://github.com/microsoft/vcpkg HEAD`), re-configure, run all tests. One PR
per baseline bump.

## Features

The root `CMakeLists.txt` maps CMake options to vcpkg features **before** `project()`:
`SKEL_BUILD_TESTS=ON` adds the `tests` feature. Follow the same pattern for future optional
parts (benchmarks, a GUI app...), so that consumers never download what they do not build.

## Internal dependencies (between modules)

Not managed by vcpkg: modules link to each other through `skel::<module>` targets. The
generated per-module package files reproduce that graph for installed consumers.

## Sharing modules outside this repo later

Options, in order of effort: consume the installed package via `CMAKE_PREFIX_PATH`; write an
overlay port that builds this repo; publish a private vcpkg git registry and list it in
`vcpkg-configuration.json` → `"registries"`.
