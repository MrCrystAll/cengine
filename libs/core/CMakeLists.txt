configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/version.hpp.in"
  "${CMAKE_CURRENT_BINARY_DIR}/include/cengine/core/version.hpp"
  @ONLY)

cengine_add_library(core
  HEADERS
    include/cengine/core/core.hpp
    include/cengine/core/result.hpp
    "${CMAKE_CURRENT_BINARY_DIR}/include/cengine/core/version.hpp"
  SOURCES
    src/core.cpp
  # PUBLIC_DEPS  cengine::other fmt::fmt
  # PRIVATE_DEPS ...
  # PACKAGES     fmt           # find_package() names, also re-found by consumers
)

add_subdirectory(tests)
