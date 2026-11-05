configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/version.hpp.in"
  "${CMAKE_CURRENT_BINARY_DIR}/include/skel/core/version.hpp"
  @ONLY)

skel_add_library(core
  HEADERS
    include/skel/core/core.hpp
    include/skel/core/result.hpp
    "${CMAKE_CURRENT_BINARY_DIR}/include/skel/core/version.hpp"
  SOURCES
    src/core.cpp
  # PUBLIC_DEPS  skel::other fmt::fmt
  # PRIVATE_DEPS ...
  # PACKAGES     fmt           # find_package() names, also re-found by consumers
)

add_subdirectory(tests)
