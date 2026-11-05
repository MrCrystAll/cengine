cmake_minimum_required(VERSION 3.25)

# -----------------------------------------------------------------------------
# Options that must be known before project() (they drive vcpkg manifest features)
# -----------------------------------------------------------------------------
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  set(_cengine_is_top_level ON)
else()
  set(_cengine_is_top_level OFF)
endif()

option(CENGINE_BUILD_TESTS "Build unit tests (pulls the vcpkg 'tests' feature)" ${_cengine_is_top_level})
if(CENGINE_BUILD_TESTS)
  list(APPEND VCPKG_MANIFEST_FEATURES "tests")
endif()

project(cengine
  VERSION 0.1.0
  DESCRIPTION "Modular C++23 monorepo"
  HOMEPAGE_URL "https://github.com/OWNER/cengine"
  LANGUAGES CXX)

if(PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
  message(FATAL_ERROR "In-source builds are not allowed. Use a preset: cmake --preset <name>")
endif()

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

include(CengineOptions)          # user-facing options
include(CengineProjectSettings)  # output dirs, RPATH, install dirs
include(CengineCompilerOptions)  # warnings, coverage, clang-tidy (cengine_project_options)
include(CengineModule)           # cengine_add_library / cengine_add_executable / cengine_add_tests

if(CENGINE_BUILD_TESTS)
  enable_testing()
  find_package(Catch2 3 CONFIG REQUIRED)
  include(Catch)
endif()

# -----------------------------------------------------------------------------
# Modules
# -----------------------------------------------------------------------------
add_subdirectory(libs)

if(CENGINE_BUILD_APPS)
  add_subdirectory(apps)
endif()

if(CENGINE_BUILD_TESTS)
  add_subdirectory(tests)   # cross-module / install / package tests
endif()

# -----------------------------------------------------------------------------
# Install, docs, packaging (must come after every module is declared)
# -----------------------------------------------------------------------------
include(CengineInstall)
include(CengineDocs)
include(CenginePackaging)

include(FeatureSummary)
feature_summary(WHAT ENABLED_FEATURES DISABLED_FEATURES PACKAGES_FOUND)
