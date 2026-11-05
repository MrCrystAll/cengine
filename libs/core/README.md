# core module {#module_core}

Foundation of every other module. Keep it small and dependency-free.

| | |
|---|---|
| CMake target | `skel::core` |
| Headers | `#include <skel/core/...>` |
| Depends on | nothing |
| Tests | `ctest --preset <preset> -L core` |

## Contents

- `core.hpp`: `skel::core::linked_version()`
- `version.hpp`: generated compile-time version constants
- `result.hpp`: `skel::core::result<T>`, `error`, `errc`, `make_error()`. This is the project-wide
  error-handling policy (see ADR 0004).
