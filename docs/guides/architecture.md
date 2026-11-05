# Architecture {#architecture}

## Repository layout

```
.
├── CMakeLists.txt          root: options, includes cmake/*, add_subdirectory(libs|apps|tests)
├── CMakePresets.json       every supported configuration (dev, CI, docs)
├── vcpkg.json              third-party dependencies (+ "tests" feature)
├── vcpkg-configuration.json  registry baseline, overlay ports/triplets
├── cmake/                  build system helpers (CengineModule.cmake is the heart)
├── libs/<module>/          one folder per microproject (library)
│   ├── CMakeLists.txt      cengine_add_library(<module> ...) + add_subdirectory(tests)
│   ├── README.md           module page (pulled into the docs)
│   ├── include/cengine/<module>/   public headers
│   ├── src/                private implementation
│   ├── tests/              unit tests (Catch2), optionally INTERNAL tests of src/
│   └── benchmarks/         nanobench benchmarks (CENGINE_BUILD_BENCHMARKS)
├── apps/<app>/             thin executables wiring libraries together
├── benchmarks/             shared benchmark runner (main, registry, CLI)
├── tests/                  cross-module tests + install/package consumer test
├── docs/                   guides + ADRs (Doxygen Markdown pages)
├── vcpkg/{ports,triplets}  overlay ports and triplets
└── tools/                  repo maintenance scripts
```

## Module graph

Generated from the `cengine_add_library` / `cengine_add_executable` declarations every time the
docs are built. Boxes are libraries, ellipses are applications, and dashed grey boxes are
third-party packages. Arrows point from a target to what it depends on.

@if MODULE_GRAPH
@dotfile modules.dot
@else
Build the docs with Graphviz (`dot`) installed to see the module graph here.
@endif

## Rules

1. **All logic lives in libraries.** Applications only parse input, wire modules, and do I/O.
2. **A module only sees another module's public headers**, via `PUBLIC_DEPS`/`PRIVATE_DEPS`
   on `cengine::<other>`. Never `#include` across `src/` folders, never use relative `../` includes.
3. **Dependencies point downwards.** `core` depends on nothing. No cycles (CMake will reject them
   for static libs only at link time, so review this).
4. **Public headers are the API.** Everything under `include/` is installed and documented;
   everything in `src/` is private and may change freely.
5. **Every module is installable on its own** as a component of the `cengine` package:
   `find_package(cengine COMPONENTS <module>)`.
6. **Shared-library safe.** Public non-inline functions/classes are marked
   `CENGINE_<MODULE>_EXPORT` (from the generated `<cengine/<module>/export.hpp>`); symbols are hidden
   by default. CI builds a shared variant to catch omissions.

## Naming

| Thing | Convention | Example |
|---|---|---|
| CMake target | `cengine_<module>` / alias `cengine::<module>` | `cengine::core` |
| Namespace | `cengine::<module>` | `cengine::core` |
| Include path | `<cengine/<module>/<file>.hpp>` | `<cengine/core/result.hpp>` |
| Executable | `cengine-<app>` | `cengine-cli` |
| Test executable | `cengine_<module>_tests` | `cengine_core_tests` |
| CTest names | `<module>.<test case>` | `core.result carries a value on success` |
