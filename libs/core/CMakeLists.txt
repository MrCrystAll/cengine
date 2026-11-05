configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/version.hpp.in"
  "${CMAKE_CURRENT_BINARY_DIR}/include/cengine/core/version.hpp"
  @ONLY)

# Scalar precision (ADR 0008): baked into an installed header so consumers can't mismatch it.
if(CENGINE_DOUBLE_PRECISION)
  set(CENGINE_REAL_TYPE double)
  set(CENGINE_DOUBLE_PRECISION_CPP true)
else()
  set(CENGINE_REAL_TYPE float)
  set(CENGINE_DOUBLE_PRECISION_CPP false)
endif()
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/config.hpp.in"
  "${CMAKE_CURRENT_BINARY_DIR}/include/cengine/core/config.hpp"
  @ONLY)

cengine_add_library(core
  HEADERS
    include/cengine/core/assert.hpp
    include/cengine/core/core.hpp
    include/cengine/core/result.hpp
    "${CMAKE_CURRENT_BINARY_DIR}/include/cengine/core/config.hpp"
    "${CMAKE_CURRENT_BINARY_DIR}/include/cengine/core/version.hpp"
  SOURCES
    src/assert.cpp
    src/core.cpp
  # PUBLIC_DEPS  cengine::other fmt::fmt
  # PRIVATE_DEPS ...
  # PACKAGES     fmt           # find_package() names, also re-found by consumers
)

# Deterministic floating point (ADR 0009). PUBLIC: every module and every consumer compiling
# cengine's inline code must use the same rules.
target_compile_options(cengine_core PUBLIC ${CENGINE_FP_DETERMINISM_FLAGS})

add_subdirectory(tests)
