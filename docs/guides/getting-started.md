# Getting started {#getting_started}

## Prerequisites

| Tool | Version | Notes |
|---|---|---|
| CMake | >= 3.25 | presets v6, workflow presets |
| Ninja | any recent | generator used by every preset |
| C++23 compiler | MSVC 19.40+ (VS 2022 17.10+), GCC 13+, Clang 17+ | |
| vcpkg | recent | `VCPKG_ROOT` must point to the clone |
| Doxygen | >= 1.9.5 | only for docs; Graphviz optional |
| gcovr | any | only for coverage reports |

```bash
git clone https://github.com/microsoft/vcpkg.git <somewhere>/vcpkg
<somewhere>/vcpkg/bootstrap-vcpkg.sh -disableMetrics      # .bat on Windows
export VCPKG_ROOT=<somewhere>/vcpkg                      # setx VCPKG_ROOT ... on Windows
```

On Windows, run CMake from a **Developer PowerShell / x64 Native Tools prompt** so `cl` and the
Windows SDK are on `PATH` (the presets use Ninja, not the Visual Studio generator).
IDEs (VS, VS Code CMake Tools, CLion) handle this automatically.

## Build, test, install

```bash
cmake --list-presets            # what is available on this OS
cmake --preset msvc-debug       # or gcc-debug / clang-debug
cmake --build --preset msvc-debug
ctest --preset msvc-debug
cmake --install build/msvc-debug          # -> install/msvc-debug
```

Run the whole CI pipeline locally in one command:

```bash
cmake --workflow --preset ci-msvc   # ci-gcc / ci-clang / ci-tidy / ci-coverage / docs
```

## Presets cheat-sheet

| Preset | Purpose |
|---|---|
| `<compiler>-debug` / `<compiler>-release` | day-to-day development |
| `ci-<compiler>` | Release + warnings-as-errors + package (what CI runs) |
| `ci-msvc-shared` | same, with `BUILD_SHARED_LIBS=ON` (catches missing exports) |
| `ci-tidy` | clang-tidy on every library/app source |
| `ci-coverage` | GCC + `--coverage`; then `cmake --build --preset ci-coverage --target coverage` |
| `docs` | Doxygen site in `build/docs/docs/html` |

Machine-specific tweaks go in an untracked `CMakeUserPresets.json` that inherits from these.
