include_guard(GLOBAL)
include(GNUInstallDirs)

# Where the CMake package files are installed: <prefix>/lib/cmake/cengine
set(CENGINE_INSTALL_CMAKEDIR "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
    CACHE STRING "Install directory for the CMake package files")
mark_as_advanced(CENGINE_INSTALL_CMAKEDIR)

if(NOT PROJECT_IS_TOP_LEVEL)
  return()  # never impose global settings on a parent project
endif()

set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)
endif()

# Put every binary in one place so tests/apps find shared libs (DLLs) without PATH tweaks.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/lib")

# Relocatable installs on Linux/macOS: executables look for libs relative to themselves.
if(APPLE)
  set(_cengine_rpath_base "@loader_path")
else()
  set(_cengine_rpath_base "$ORIGIN")
endif()
file(RELATIVE_PATH _cengine_bin_to_lib
     "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}"
     "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}")
set(CMAKE_INSTALL_RPATH "${_cengine_rpath_base}" "${_cengine_rpath_base}/${_cengine_bin_to_lib}")
