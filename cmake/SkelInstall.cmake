include_guard(GLOBAL)

if(NOT SKEL_INSTALL)
  return()
endif()

include(CMakePackageConfigHelpers)

get_property(SKEL_ALL_MODULES GLOBAL PROPERTY SKEL_MODULES)

configure_package_config_file(
  "${PROJECT_SOURCE_DIR}/cmake/skel-config.cmake.in"
  "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
  INSTALL_DESTINATION "${SKEL_INSTALL_CMAKEDIR}")

write_basic_package_version_file(
  "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake"
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion)

install(FILES
  "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
  "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake"
  DESTINATION "${SKEL_INSTALL_CMAKEDIR}"
  COMPONENT ${PROJECT_NAME}_dev)

install(FILES "${PROJECT_SOURCE_DIR}/LICENSE" "${PROJECT_SOURCE_DIR}/README.md"
  DESTINATION "${CMAKE_INSTALL_DOCDIR}"
  COMPONENT ${PROJECT_NAME}_dev)
