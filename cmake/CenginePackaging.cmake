include_guard(GLOBAL)

if(NOT PROJECT_IS_TOP_LEVEL OR NOT CENGINE_INSTALL)
  return()
endif()

# Binary packages:  cpack --preset <preset>   (or: cd build/<preset> && cpack)
# Source package:   cpack --config build/<preset>/CPackSourceConfig.cmake
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VENDOR "${PROJECT_NAME} contributors")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PROJECT_DESCRIPTION}")
set(CPACK_PACKAGE_HOMEPAGE_URL "${PROJECT_HOMEPAGE_URL}")
set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/LICENSE")
set(CPACK_RESOURCE_FILE_README "${PROJECT_SOURCE_DIR}/README.md")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "${PROJECT_NAME}")

if(BUILD_SHARED_LIBS)
  set(_cengine_link "shared")
else()
  set(_cengine_link "static")
endif()
if(CENGINE_DOUBLE_PRECISION)
  set(_cengine_precision "f64")
else()
  set(_cengine_precision "f32")
endif()
string(TOLOWER
  "${PROJECT_NAME}-${PROJECT_VERSION}-${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}-${_cengine_link}-${_cengine_precision}"
  CPACK_PACKAGE_FILE_NAME)

if(WIN32)
  set(CPACK_GENERATOR "ZIP")
else()
  set(CPACK_GENERATOR "TGZ")
endif()

set(CPACK_SOURCE_GENERATOR "TGZ;ZIP")
set(CPACK_SOURCE_IGNORE_FILES
  "/\\\\.git/" "/build/" "/install/" "/out/" "/\\\\.vs/" "/\\\\.vscode/" "/\\\\.idea/"
  "/\\\\.cache/" "/vcpkg_installed/")

include(CPack)
