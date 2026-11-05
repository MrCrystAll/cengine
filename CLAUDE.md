# CLAUDE.md

Guidance for Claude Code sessions working in this repository. Read this first, and keep it up to
date when a convention changes. Record *why* in an ADR under `docs/adr/`.

## Project in one paragraph

`cengine` is a **physics engine**, built as a **C++23 monorepo of many small modules
("microprojects")**. Each library lives in `libs/<module>/`, and
apps in `apps/` are thin front-ends. The project is **test-driven** (Catch2 v3 + CTest). It uses **vcpkg
manifest mode** for third-party code, **Doxygen** for docs, and **GitHub Actions** CI on Windows, Linux and macOS.
License: MIT.

## Commands

`VCPKG_ROOT` must point to a vcpkg clone. On Windows, commands need the MSVC environment (a VS
Developer shell, or `vcvars64.bat` called first). Machine-specific details (VS install path,
vcpkg location, how to call vcvars from Claude's shell) live in the untracked `CLAUDE.local.md`;
create it from the template in `docs/guides/getting-started.md` if it's missing.

The project version is defined **only** in `project(VERSION ...)` in the root `CMakeLists.txt`
(the release workflow checks the git tag against it). Don't add a version to `vcpkg.json`.

| Goal | Command |
|---|---|
| configure / build / test (dev) | `cmake --preset msvc-debug` · `cmake --build --preset msvc-debug` · `ctest --preset msvc-debug` |
| one module's tests | `ctest --preset msvc-debug -L <module>` |
| fast loop (skip install test) | `ctest --preset msvc-debug -LE package` |
| full CI pipeline locally | `cmake --workflow --preset ci-msvc` (Linux: `ci-gcc`, `ci-clang`) |
| shared-lib variant | `cmake --workflow --preset ci-msvc-shared` |
| clang-tidy | `cmake --workflow --preset ci-tidy` (Linux/macOS presets) |
| coverage | `cmake --workflow --preset ci-coverage` then `--target coverage` (GCC, Linux) |
| docs | `cmake --workflow --preset docs` → `build/docs/docs/html/index.html` |
| format | `clang-format -i <files>` with **clang-format 20** (CI pins 20.1.0 and fails on unformatted code) |
| install | `cmake --install build/<preset> --prefix <dir>` |

Build trees are `build/<preset>/` and default installs go to `install/<preset>/`. Never edit them, and
never commit them.

## Workflow rules (TDD)

1. **Test first.** For any behaviour change, write or extend a failing Catch2 test in
   `libs/<module>/tests/`, build, and confirm it fails for the right reason.
2. Write the minimal code to pass. Then refactor with the suite green.
3. Before saying a task is done, build and run `ctest` for the affected preset and report the
   result honestly. If the change touches CMake/install/export, also run the full
   `cmake --workflow --preset ci-msvc` (it includes the install + `find_package` consumer test).
4. Bug fix = a regression test that reproduces it first.
5. Don't weaken or delete a test to make it pass. Ask instead.

## Architecture rules

- **Logic lives in `libs/`.** `apps/` only parse input, wire modules, and do I/O.
- Create every target through the helpers in `cmake/CengineModule.cmake`:
  `cengine_add_library`, `cengine_add_executable`, `cengine_add_tests`. Don't call `add_library` /
  `install` by hand for project code; extend the helper instead, so every module stays uniform.
- A module uses another only via `cengine::<other>` in `PUBLIC_DEPS` (appears in its public headers)
  or `PRIVATE_DEPS` (implementation only). No includes into another module's `src/`, no `../` includes.
- Dependencies point downwards (`core` depends on nothing). No cycles.
- Public headers: `libs/<m>/include/cengine/<m>/*.hpp`, included as `<cengine/<m>/x.hpp>`. Everything
  there is installed API: keep it minimal, and put details in `src/`.
- Shared-lib safety: non-inline public functions/classes get `CENGINE_<M>_EXPORT` from
  `<cengine/<m>/export.hpp>` (generated). Symbols are hidden by default. The `ci-msvc-shared` preset
  catches missing exports.
- New module: follow `docs/guides/adding-a-module.md` exactly (CMake, tests, README, add it to
  `libs/CMakeLists.txt`, and add rows to the module tables in `README.md` and `docs/index.md`).

## C++ conventions

- **C++23**, no compiler extensions, portable across MSVC / GCC / Clang / Apple Clang. Check that a
  library feature works on all three CI platforms before relying on it (e.g. `std::print`
  isn't used yet because of older Apple libc++).
- **Naming**: std-like `snake_case` for types, functions, variables, namespaces, enums and enumerators.
  Template parameters are `CamelCase`, macros are `UPPER_CASE` with a `CENGINE_` prefix, and private/protected data
  members end in `_`. Enforced by `.clang-tidy`.
- Namespace is `cengine::<module>`. Files are `snake_case.hpp` / `.cpp`; tests are `test_<header>.cpp`.
- **Errors**: recoverable failures return `cengine::core::result<T>` (`std::expected<T, error>`),
  built with `make_error(errc, msg)`. Exceptions are only for programming errors and truly
  exceptional states. Mark results `[[nodiscard]]` and use `noexcept` where it's meaningful.
- Formatting: `.clang-format` (4 spaces, 100 columns, braces always). Include order: project,
  third-party, std.
- Warnings: the high warning set lives in `cmake/CengineCompilerOptions.cmake`, and CI treats warnings as errors.
  Fix warnings; don't suppress them. If a suppression is unavoidable, make it local and add a comment
  explaining why.

## Documentation rules

- Every public declaration gets a `///` Doxygen comment (`@brief`, `@param`, `@return`). The
  docs CI job fails on any Doxygen warning, including undocumented members.
- Every module has a `README.md` (its docs page, with anchor `{#module_<name>}`).
- Guides go in `docs/guides/`. A significant or irreversible decision gets a new ADR in `docs/adr/`
  (copy `0000-template.md` and add it to `docs/adr/README.md`).

## Dependencies

- Third-party code comes **only** through `vcpkg.json` (pinned by the baseline in
  `vcpkg-configuration.json`). No vendored code, and no `FetchContent` for libraries.
- Test-only or optional deps go in a vcpkg *feature*, mapped from a CMake option before
  `project()` in the root `CMakeLists.txt` (see `CENGINE_BUILD_TESTS` → `tests`).
- In the module: `PACKAGES <find_package name>` + the imported target in `PUBLIC_DEPS`/`PRIVATE_DEPS`.
  This makes installed consumers re-find it automatically.
- **Ask the user before adding any new third-party dependency** or bumping the baseline.

## Things to ask the user about rather than guess

- Adding a dependency, a new module boundary, or a public API in `core`.
- Anything that changes the public CMake interface (target names, options, package layout).
- Renaming the project or its modules. Don't rename on your own.

## Map of the build system

| File | Role |
|---|---|
| `CMakeLists.txt` | top level: pre-`project()` vcpkg features, includes, subdirectories |
| `cmake/CengineOptions.cmake` | all `CENGINE_*` options |
| `cmake/CengineProjectSettings.cmake` | output dirs, RPATH, install dirs (top-level only) |
| `cmake/CengineCompilerOptions.cmake` | `cengine_project_options` (warnings, coverage), clang-tidy |
| `cmake/CengineModule.cmake` | **the module helpers**, plus per-module install/export files |
| `cmake/CengineInstall.cmake`, `cengine-config.cmake.in` | the `cengine` CMake package (components = modules) |
| `cmake/CengineDocs.cmake` | Doxygen + doxygen-awesome-css |
| `cmake/CenginePackaging.cmake` | CPack |
| `tests/CMakeLists.txt`, `tests/package/` | install + `find_package` consumer test |
| `.github/workflows/` | `ci.yml`, `docs.yml` (Pages), `release.yml` (tags `vX.Y.Z`) |
