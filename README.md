# skel

> **Placeholder name.** The project theme isn't chosen yet. Once you have a name, run
> `python tools/rename_project.py <newname>` to rename everything in one go (see [Renaming](#renaming)).

skel is a modular **C++23** monorepo. It is a set of small, independently tested and
installable libraries (*modules*) plus thin applications that use them.

- **Separation of concerns**: all logic lives in libraries under `libs/`. Apps under `apps/` only wire them together.
- **Test-driven**: Catch2 v3 and CTest. Every module has unit tests, the apps have smoke tests,
  and a package test installs the project and builds an external consumer.
- **Dependencies**: vcpkg manifest mode, pinned baseline, optional features, overlay ports.
- **Install and package**: a CMake package with one component per module (`find_package(skel COMPONENTS core)`),
  plus CPack archives for every platform.
- **Docs**: Doxygen with the doxygen-awesome-css theme, published to GitHub Pages.
- **CI** (GitHub Actions): Windows (MSVC static and shared), Linux (GCC, Clang), and macOS (Clang).
  It also runs clang-tidy, a clang-format check, and coverage, and treats warnings and Doxygen warnings as errors.
  Tagged releases are published automatically.

---

## Quick start

**Prerequisites:** CMake ≥ 3.25, Ninja, a C++23 compiler (MSVC 19.40+, GCC 13+, Clang 17+),
and [vcpkg](https://github.com/microsoft/vcpkg) with `VCPKG_ROOT` set.
On Windows, use a *Developer PowerShell for VS* (or an IDE) so `cl` is on `PATH`.

```bash
cmake --preset msvc-debug            # Linux: gcc-debug / clang-debug, macOS: clang-debug
cmake --build --preset msvc-debug
ctest --preset msvc-debug
build/msvc-debug/bin/skel-cli        # -> "skel-cli 0.1.0"
```

To run the full CI pipeline locally (configure, build, test, package):

```bash
cmake --workflow --preset ci-msvc    # ci-gcc, ci-clang, ci-tidy, ci-coverage, docs
```

`cmake --list-presets` lists the presets available on your OS.

## Repository layout

```
libs/<module>/      a microproject: include/skel/<module>/ (public), src/ (private), tests/, README.md
apps/<app>/         thin executables (currently: cli -> skel-cli)
tests/              cross-module tests + package consumer (tests/package)
cmake/              build helpers: SkelModule.cmake (skel_add_library/executable/tests), install, docs, packaging
docs/               guides, ADRs (architecture decisions), Doxygen main page
vcpkg.json          third-party dependencies; vcpkg-configuration.json pins the baseline
vcpkg/              overlay ports and triplets
.github/            CI, docs and release workflows
```

## Modules

| Module | Target | Description |
|---|---|---|
| [core](libs/core/README.md) | `skel::core` | Foundation: version info, `result<T>` / error policy |

Adding a module takes about 10 lines of CMake. See [docs/guides/adding-a-module.md](docs/guides/adding-a-module.md).

## Integrating skel in another project

### Option 1: installed package (recommended)

```bash
cmake --preset msvc-release && cmake --build --preset msvc-release
cmake --install build/msvc-release --prefix <prefix>
```

```cmake
# your CMakeLists.txt
find_package(skel 0.1 CONFIG REQUIRED COMPONENTS core)   # omit COMPONENTS to load every module
target_link_libraries(your_target PRIVATE skel::core)
```

Configure your project with `-DCMAKE_PREFIX_PATH=<prefix>`. [tests/package](tests/package) is a
complete consumer that CI checks.

### Option 2: as a subdirectory / FetchContent

```cmake
include(FetchContent)
FetchContent_Declare(skel GIT_REPOSITORY https://github.com/OWNER/skel.git GIT_TAG v0.1.0)
FetchContent_MakeAvailable(skel)
target_link_libraries(your_target PRIVATE skel::core)
```

When skel isn't the top-level project, it builds only the libraries. Tests and install rules stay off,
and it sets no global flags. The third-party dependencies in `vcpkg.json` must still be findable by your project.

### Option 3: binary archive

Download `skel-<version>-<os>-<arch>-<static|shared>.{zip,tar.gz}` from the GitHub Releases page,
extract it, and point `CMAKE_PREFIX_PATH` at it.

## Install and package

```bash
cmake --install build/<preset> [--prefix <dir>] [--component skel_cli]
cpack --preset ci-msvc                           # ZIP on Windows, TGZ elsewhere
```

| Component | Content |
|---|---|
| `skel_<module>` / `skel_<module>_dev` | runtime library / headers + CMake files |
| `skel_<app>` | an application |
| `skel_dev`, `skel_docs` | package config + README/LICENSE, HTML docs |

Details: [docs/guides/install-and-package.md](docs/guides/install-and-package.md).

## Build options

| Option | Default | Effect |
|---|---|---|
| `SKEL_BUILD_TESTS` | ON if top-level | unit/smoke tests; enables the vcpkg `tests` feature |
| `SKEL_BUILD_APPS` | ON | build `apps/` |
| `SKEL_BUILD_PACKAGE_TEST` | = tests | CTest that installs and builds `tests/package` (label `package`) |
| `SKEL_INSTALL` | ON if top-level | install rules + CMake package |
| `SKEL_BUILD_DOCS` | OFF | `docs` target (Doxygen) |
| `SKEL_ENABLE_CLANG_TIDY` | OFF | clang-tidy while compiling libs/apps |
| `SKEL_ENABLE_COVERAGE` | OFF | `--coverage` + `coverage` target (gcovr) |
| `BUILD_SHARED_LIBS` | OFF | shared libraries (exports handled by generated headers) |

Put personal overrides in an untracked `CMakeUserPresets.json`.

## Testing

```bash
ctest --preset <p>                 # everything
ctest --preset <p> -L core         # one module
ctest --preset <p> -LE package     # skip the slower install/package test
```

The workflow is TDD (red, green, refactor). See [docs/guides/testing.md](docs/guides/testing.md).

## Documentation

```bash
cmake --workflow --preset docs     # -> build/docs/docs/html/index.html
```

Guides live in [docs/guides](docs/guides) and architecture decisions in [docs/adr](docs/adr).

## CI/CD

| Workflow | Trigger | What it does |
|---|---|---|
| `ci.yml` | push to main, PRs | build/test/package matrix, clang-tidy, clang-format, coverage, docs |
| `docs.yml` | push to main | publishes the docs to GitHub Pages (enable Pages with source "GitHub Actions") |
| `release.yml` | tag `vX.Y.Z` | checks the tag matches `project(VERSION)`, runs CI, attaches packages to a GitHub Release |

## Renaming

```bash
python tools/rename_project.py <newname>      # e.g. "orbit" -> orbit::core, ORBIT_BUILD_TESTS, orbit-cli
```

This rewrites identifiers (`skel`, `Skel`, `SKEL`) in tracked text files and renames paths such as
`include/skel/` and `cmake/Skel*.cmake`. Words like "skeleton" aren't touched. Delete your `build/`
folder afterwards. Also replace `OWNER` in the URLs (`CMakeLists.txt`, this README) with your GitHub account.

## License

[MIT](LICENSE)
