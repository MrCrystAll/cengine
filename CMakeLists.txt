cmake_minimum_required(VERSION 3.25)

# -----------------------------------------------------------------------------
# Options that must be known before project() (they drive vcpkg manifest features)
# -----------------------------------------------------------------------------
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  set(_skel_is_top_level ON)
else()
  set(_skel_is_top_level OFF)
endif()

option(SKEL_BUILD_TESTS "Build unit tests (pulls the vcpkg 'tests' feature)" ${_skel_is_top_level})
if(SKEL_BUILD_TESTS)
  list(APPEND VCPKG_MANIFEST_FEATURES "tests")
endif()

project(skel
  VERSION 0.1.0
  DESCRIPTION "Modular C++23 monorepo"
  HOMEPAGE_URL "https://github.com/OWNER/skel"
  LANGUAGES CXX)

if(PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
  message(FATAL_ERROR "In-source builds are not allowed. Use a preset: cmake --preset <name>")
endif()

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

include(SkelOptions)          # user-facing options
include(SkelProjectSettings)  # output dirs, RPATH, install dirs
include(SkelCompilerOptions)  # warnings, coverage, clang-tidy (skel_project_options)
include(SkelModule)           # skel_add_library / skel_add_executable / skel_add_tests

if(SKEL_BUILD_TESTS)
  enable_testing()
  find_package(Catch2 3 CONFIG REQUIRED)
  include(Catch)
endif()

# -----------------------------------------------------------------------------
# Modules
# -----------------------------------------------------------------------------
add_subdirectory(libs)

if(SKEL_BUILD_APPS)
  add_subdirectory(apps)
endif()

if(SKEL_BUILD_TESTS)
  add_subdirectory(tests)   # cross-module / install / package tests
endif()

# -----------------------------------------------------------------------------
# Install, docs, packaging (must come after every module is declared)
# -----------------------------------------------------------------------------
include(SkelInstall)
include(SkelDocs)
include(SkelPackaging)

include(FeatureSummary)
feature_summary(WHAT ENABLED_FEATURES DISABLED_FEATURES PACKAGES_FOUND)
