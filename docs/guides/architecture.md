# Architecture {#architecture}

## Repository layout

```
.
├── CMakeLists.txt          root: options, includes cmake/*, add_subdirectory(libs|apps|tests)
├── CMakePresets.json       every supported configuration (dev, CI, docs)
├── vcpkg.json              third-party dependencies (+ "tests" feature)
├── vcpkg-configuration.json  registry baseline, overlay ports/triplets
├── cmake/                  build system helpers (SkelModule.cmake is the heart)
├── libs/<module>/          one folder per microproject (library)
│   ├── CMakeLists.txt      skel_add_library(<module> ...) + add_subdirectory(tests)
│   ├── README.md           module page (pulled into the docs)
│   ├── include/skel/<module>/   public headers
│   ├── src/                private implementation
│   └── tests/              unit tests (Catch2)
├── apps/<app>/             thin executables wiring libraries together
├── tests/                  cross-module tests + install/package consumer test
├── docs/                   guides + ADRs (Doxygen Markdown pages)
├── vcpkg/{ports,triplets}  overlay ports and triplets
└── tools/                  repo maintenance scripts
```

## Rules

1. **All logic lives in libraries.** Applications only parse input, wire modules, and do I/O.
2. **A module only sees another module's public headers**, via `PUBLIC_DEPS`/`PRIVATE_DEPS`
   on `skel::<other>`. Never `#include` across `src/` folders, never use relative `../` includes.
3. **Dependencies point downwards.** `core` depends on nothing. No cycles (CMake will reject them
   for static libs only at link time, so review this).
4. **Public headers are the API.** Everything under `include/` is installed and documented;
   everything in `src/` is private and may change freely.
5. **Every module is installable on its own** as a component of the `skel` package:
   `find_package(skel COMPONENTS <module>)`.
6. **Shared-library safe.** Public non-inline functions/classes are marked
   `SKEL_<MODULE>_EXPORT` (from the generated `<skel/<module>/export.hpp>`); symbols are hidden
   by default. CI builds a shared variant to catch omissions.

## Naming

| Thing | Convention | Example |
|---|---|---|
| CMake target | `skel_<module>` / alias `skel::<module>` | `skel::core` |
| Namespace | `skel::<module>` | `skel::core` |
| Include path | `<skel/<module>/<file>.hpp>` | `<skel/core/result.hpp>` |
| Executable | `skel-<app>` | `skel-cli` |
| Test executable | `skel_<module>_tests` | `skel_core_tests` |
| CTest names | `<module>.<test case>` | `core.result carries a value on success` |
