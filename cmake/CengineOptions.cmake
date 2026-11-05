include_guard(GLOBAL)
include(FeatureSummary)

# CENGINE_BUILD_TESTS is declared in the root CMakeLists.txt (it must exist before project()).
add_feature_info(CENGINE_BUILD_TESTS CENGINE_BUILD_TESTS "unit and integration tests")

option(CENGINE_BUILD_APPS "Build the applications under apps/" ON)
option(CENGINE_BUILD_DOCS "Add the 'docs' target (Doxygen)" OFF)
option(CENGINE_BUILD_PACKAGE_TEST
       "Add a CTest that installs the project and builds tests/package against it"
       ${CENGINE_BUILD_TESTS})
option(CENGINE_INSTALL "Generate install rules and the CMake package" ${PROJECT_IS_TOP_LEVEL})
option(CENGINE_ENABLE_CLANG_TIDY "Run clang-tidy on library and app sources while compiling" OFF)
option(CENGINE_ENABLE_COVERAGE "Instrument library code for coverage (GCC/Clang)" OFF)
option(CENGINE_DOCS_WARN_AS_ERROR "Fail the docs build on any Doxygen warning" OFF)
option(BUILD_SHARED_LIBS "Build libraries as shared libraries" OFF)
option(CENGINE_DOUBLE_PRECISION "cengine::real is double (ON) or float (OFF); see ADR 0008" ON)

add_feature_info(CENGINE_BUILD_APPS CENGINE_BUILD_APPS "applications")
add_feature_info(CENGINE_BUILD_DOCS CENGINE_BUILD_DOCS "Doxygen documentation")
add_feature_info(CENGINE_BUILD_PACKAGE_TEST CENGINE_BUILD_PACKAGE_TEST "install + find_package consumer test")
add_feature_info(CENGINE_INSTALL CENGINE_INSTALL "install rules and CMake package config")
add_feature_info(CENGINE_ENABLE_CLANG_TIDY CENGINE_ENABLE_CLANG_TIDY "clang-tidy during build")
add_feature_info(CENGINE_ENABLE_COVERAGE CENGINE_ENABLE_COVERAGE "coverage instrumentation")
add_feature_info(BUILD_SHARED_LIBS BUILD_SHARED_LIBS "shared libraries")
add_feature_info(CENGINE_DOUBLE_PRECISION CENGINE_DOUBLE_PRECISION "double-precision cengine::real")

if(CENGINE_BUILD_PACKAGE_TEST AND CENGINE_ENABLE_COVERAGE)
  message(STATUS "CENGINE_BUILD_PACKAGE_TEST disabled: incompatible with coverage instrumentation")
  set(CENGINE_BUILD_PACKAGE_TEST OFF CACHE BOOL "" FORCE)
endif()
