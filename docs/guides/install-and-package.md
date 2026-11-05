# Install and package {#install_and_package}

## Install

```bash
cmake --build --preset msvc-release
cmake --install build/msvc-release                       # -> install/msvc-release
cmake --install build/msvc-release --prefix C:/opt/cengine  # anywhere
```

Installed layout:

```
<prefix>/
├── bin/cengine-cli(.exe)             applications (+ DLLs in shared builds)
├── include/cengine/<module>/...      public headers (+ generated export.hpp, version.hpp)
├── lib/cengine_<module>.{lib,a,so}   libraries
├── lib/cmake/cengine/                CMake package (cengine-config.cmake, per-module files)
└── share/doc/cengine/                README, LICENSE (+ html/ if docs were built)
```

### Components

Install only what you need:

| Component | Content |
|---|---|
| `cengine_<module>` | runtime (shared lib / DLL) |
| `cengine_<module>_dev` | headers, static/import lib, CMake files |
| `cengine_<app>` | an application |
| `cengine_dev` | top-level package config, README, LICENSE |
| `cengine_docs` | HTML docs |

```bash
cmake --install build/msvc-release --component cengine_cli
```

## Package (CPack)

```bash
cpack --preset ci-msvc        # or: cd build/<preset> && cpack
```

Produces `cengine-<version>-<os>-<arch>-<static|shared>.zip` (Windows) / `.tar.gz` (Linux, macOS).
The release workflow attaches these to the GitHub Release when a `vX.Y.Z` tag is pushed.

## Consume

```cmake
find_package(cengine 0.1 CONFIG REQUIRED COMPONENTS core)
target_link_libraries(my_app PRIVATE cengine::core)
```

Configure your project with `-DCMAKE_PREFIX_PATH=<prefix>`. `tests/package/` is a complete,
CI-tested example.

Also possible:

- `add_subdirectory(cengine)` / `FetchContent`: options default to "library only" when cengine is
  not the top-level project (no tests, no install rules imposed on you).
- a vcpkg overlay port pointing to this repository.
