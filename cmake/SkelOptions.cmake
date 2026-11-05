include_guard(GLOBAL)
include(FeatureSummary)

# SKEL_BUILD_TESTS is declared in the root CMakeLists.txt (it must exist before project()).
add_feature_info(SKEL_BUILD_TESTS SKEL_BUILD_TESTS "unit and integration tests")

option(SKEL_BUILD_APPS "Build the applications under apps/" ON)
option(SKEL_BUILD_DOCS "Add the 'docs' target (Doxygen)" OFF)
option(SKEL_BUILD_PACKAGE_TEST
       "Add a CTest that installs the project and builds tests/package against it"
       ${SKEL_BUILD_TESTS})
option(SKEL_INSTALL "Generate install rules and the CMake package" ${PROJECT_IS_TOP_LEVEL})
option(SKEL_ENABLE_CLANG_TIDY "Run clang-tidy on library and app sources while compiling" OFF)
option(SKEL_ENABLE_COVERAGE "Instrument library code for coverage (GCC/Clang)" OFF)
option(SKEL_DOCS_WARN_AS_ERROR "Fail the docs build on any Doxygen warning" OFF)
option(BUILD_SHARED_LIBS "Build libraries as shared libraries" OFF)

add_feature_info(SKEL_BUILD_APPS SKEL_BUILD_APPS "applications")
add_feature_info(SKEL_BUILD_DOCS SKEL_BUILD_DOCS "Doxygen documentation")
add_feature_info(SKEL_BUILD_PACKAGE_TEST SKEL_BUILD_PACKAGE_TEST "install + find_package consumer test")
add_feature_info(SKEL_INSTALL SKEL_INSTALL "install rules and CMake package config")
add_feature_info(SKEL_ENABLE_CLANG_TIDY SKEL_ENABLE_CLANG_TIDY "clang-tidy during build")
add_feature_info(SKEL_ENABLE_COVERAGE SKEL_ENABLE_COVERAGE "coverage instrumentation")
add_feature_info(BUILD_SHARED_LIBS BUILD_SHARED_LIBS "shared libraries")

if(SKEL_BUILD_PACKAGE_TEST AND SKEL_ENABLE_COVERAGE)
  message(STATUS "SKEL_BUILD_PACKAGE_TEST disabled: incompatible with coverage instrumentation")
  set(SKEL_BUILD_PACKAGE_TEST OFF CACHE BOOL "" FORCE)
endif()
