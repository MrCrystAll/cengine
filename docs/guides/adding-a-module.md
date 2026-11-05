# Adding a module {#adding_a_module}

Example: a new library `geometry` that depends on `core`.

## 1. Files

```
libs/geometry/
├── CMakeLists.txt
├── README.md
├── include/skel/geometry/vector.hpp
├── src/vector.cpp
└── tests/
    ├── CMakeLists.txt
    └── test_vector.cpp
```

## 2. `libs/geometry/CMakeLists.txt`

```cmake
skel_add_library(geometry
  HEADERS      include/skel/geometry/vector.hpp
  SOURCES      src/vector.cpp
  PUBLIC_DEPS  skel::core          # appears in public headers
  # PRIVATE_DEPS fmt::fmt          # implementation only
  # PACKAGES     fmt               # find_package() names for third-party deps
)
add_subdirectory(tests)
```

Header-only module: add `HEADER_ONLY` and omit `SOURCES`.

## 3. `libs/geometry/tests/CMakeLists.txt`

```cmake
skel_add_tests(geometry
  SOURCES test_vector.cpp
)
```

## 4. Register it

Add `add_subdirectory(geometry)` to `libs/CMakeLists.txt`, and a row in the module table of
`docs/index.md` and `README.md`.

## 5. Write the first failing test, then the code

See @ref testing. Public API must carry Doxygen comments (`///`), and exported symbols need
`SKEL_GEOMETRY_EXPORT` from `<skel/geometry/export.hpp>`.

## 6. Third-party dependency?

Add it to `vcpkg.json` (see @ref dependencies), list the target in `PUBLIC_DEPS`/`PRIVATE_DEPS`
and the package name in `PACKAGES`. The generated package config re-finds it for consumers.

## What you get for free

- target `skel_geometry`, alias `skel::geometry`, export header, `cxx_std_23`, warnings, tidy
- install rules (component `skel_geometry` / `skel_geometry_dev`) and
  `find_package(skel COMPONENTS geometry)` support
- CTest registration with label `geometry` (`ctest --preset <p> -L geometry`)
- docs: headers and `README.md` are added to the Doxygen site
