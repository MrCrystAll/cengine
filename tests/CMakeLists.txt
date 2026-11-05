# Cross-module tests live here. Per-module unit tests live in libs/<module>/tests.

# -----------------------------------------------------------------------------
# Package test: install the build tree into a scratch prefix, then build and run
# tests/package (an independent project using find_package(cengine)). Proves that
# the exported CMake package and the installed app actually work.
# Run alone with:   ctest --preset <preset> -L package
# Skip with:        ctest --preset <preset> -LE package
# -----------------------------------------------------------------------------
if(NOT CENGINE_BUILD_PACKAGE_TEST OR NOT CENGINE_INSTALL)
  return()
endif()

set(_prefix "${PROJECT_BINARY_DIR}/package-test/install")
set(_build "${PROJECT_BINARY_DIR}/package-test/build")

add_test(NAME package.install
  COMMAND "${CMAKE_COMMAND}"
    "-DBINARY_DIR=${PROJECT_BINARY_DIR}" "-DPREFIX=${_prefix}" "-DCLEAN=${_build}" "-DCONFIG=$<CONFIG>"
    -P "${PROJECT_SOURCE_DIR}/cmake/scripts/fresh-install.cmake")
set_tests_properties(package.install PROPERTIES
  FIXTURES_SETUP cengine_installed
  LABELS package)

set(_opts
  "-DCMAKE_PREFIX_PATH=${_prefix}"
  "-DCMAKE_BUILD_TYPE=$<CONFIG>"
  "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}"
  "-DCENGINE_EXPECTED_VERSION=${PROJECT_VERSION}"
  "-DCENGINE_RUNTIME_DIR=${_prefix}/${CMAKE_INSTALL_BINDIR}")
if(CMAKE_TOOLCHAIN_FILE)
  # Reuse the already-installed vcpkg packages instead of resolving a new manifest.
  list(APPEND _opts
    "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}"
    "-DVCPKG_MANIFEST_MODE=OFF"
    "-DVCPKG_INSTALLED_DIR=${VCPKG_INSTALLED_DIR}"
    "-DVCPKG_TARGET_TRIPLET=${VCPKG_TARGET_TRIPLET}")
endif()

add_test(NAME package.consumer
  COMMAND "${CMAKE_CTEST_COMMAND}"
    --build-and-test "${CMAKE_CURRENT_SOURCE_DIR}/package" "${_build}"
    --build-generator "${CMAKE_GENERATOR}"
    --build-makeprogram "${CMAKE_MAKE_PROGRAM}"
    --build-config $<CONFIG>
    --build-options ${_opts}
    --test-command "${CMAKE_CTEST_COMMAND}" --output-on-failure -C $<CONFIG>)
set_tests_properties(package.consumer PROPERTIES
  FIXTURES_REQUIRED cengine_installed
  LABELS package)

if(CENGINE_BUILD_APPS)
  add_test(NAME package.cli
    COMMAND "${_prefix}/${CMAKE_INSTALL_BINDIR}/cengine-cli${CMAKE_EXECUTABLE_SUFFIX}")
  set_tests_properties(package.cli PROPERTIES
    FIXTURES_REQUIRED cengine_installed
    PASS_REGULAR_EXPRESSION "cengine-cli ${PROJECT_VERSION}"
    LABELS package)
endif()
