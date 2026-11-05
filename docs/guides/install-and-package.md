# Install and package {#install_and_package}

## Install

```bash
cmake --build --preset msvc-release
cmake --install build/msvc-release                       # -> install/msvc-release
cmake --install build/msvc-release --prefix C:/opt/skel  # anywhere
```

Installed layout:

```
<prefix>/
├── bin/skel-cli(.exe)             applications (+ DLLs in shared builds)
├── include/skel/<module>/...      public headers (+ generated export.hpp, version.hpp)
├── lib/skel_<module>.{lib,a,so}   libraries
├── lib/cmake/skel/                CMake package (skel-config.cmake, per-module files)
└── share/doc/skel/                README, LICENSE (+ html/ if docs were built)
```

### Components

Install only what you need:

| Component | Content |
|---|---|
| `skel_<module>` | runtime (shared lib / DLL) |
| `skel_<module>_dev` | headers, static/import lib, CMake files |
| `skel_<app>` | an application |
| `skel_dev` | top-level package config, README, LICENSE |
| `skel_docs` | HTML docs |

```bash
cmake --install build/msvc-release --component skel_cli
```

## Package (CPack)

```bash
cpack --preset ci-msvc        # or: cd build/<preset> && cpack
```

Produces `skel-<version>-<os>-<arch>-<static|shared>.zip` (Windows) / `.tar.gz` (Linux, macOS).
The release workflow attaches these to the GitHub Release when a `vX.Y.Z` tag is pushed.

## Consume

```cmake
find_package(skel 0.1 CONFIG REQUIRED COMPONENTS core)
target_link_libraries(my_app PRIVATE skel::core)
```

Configure your project with `-DCMAKE_PREFIX_PATH=<prefix>`. `tests/package/` is a complete,
CI-tested example.

Also possible:

- `add_subdirectory(skel)` / `FetchContent`: options default to "library only" when skel is
  not the top-level project (no tests, no install rules imposed on you).
- a vcpkg overlay port pointing to this repository.
