# core module {#module_core}

Foundation of every other module. Keep it small and dependency-free.

| | |
|---|---|
| CMake target | `cengine::core` |
| Headers | `#include <cengine/core/...>` |
| Depends on | nothing |
| Tests | `ctest --preset <preset> -L core` |

## Contents

- `core.hpp`: `cengine::core::linked_version()`
- `version.hpp`: generated compile-time version constants
- `result.hpp`: `cengine::core::result<T>`, `error`, `errc`, `make_error()`. This is the project-wide
  error-handling policy (see ADR 0004).
- `config.hpp`: generated. `cengine::real` (`double` by default, `float` with
  `CENGINE_DOUBLE_PRECISION=OFF`) and `cengine::double_precision` (ADR 0008).
- `assert.hpp`: `CENGINE_ASSERT`, `CENGINE_ASSERT_SLOW` and a replaceable failure handler
  (ADR 0010).

Linking `cengine::core` also brings in the deterministic floating-point compile flags
(no FMA contraction, no fast-math), which ADR 0009 requires for bit-identical results.
