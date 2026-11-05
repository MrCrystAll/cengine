include_guard(GLOBAL)
include(GenerateExportHeader)

# =============================================================================
# Module helpers. Every microproject goes through these functions so that all
# modules are built, tested, installed and exported the same way.
#
#   skel_add_library(<name> ...)     -> target skel_<name>, alias skel::<name>
#   skel_add_executable(<name> ...)  -> target skel_<name>, binary "skel-<name>"
#   skel_add_tests(<name> ...)       -> target skel_<name>_tests, registered in CTest
#
# See docs/guides/adding-a-module.md for the full walkthrough.
# =============================================================================

# Internal: settings shared by every compiled skel target.
function(_skel_apply_common target)
  target_link_libraries(${target} PRIVATE $<BUILD_INTERFACE:skel_project_options>)
  set_target_properties(${target} PROPERTIES CXX_EXTENSIONS OFF)
  if(SKEL_ENABLE_CLANG_TIDY)
    set_target_properties(${target} PROPERTIES CXX_CLANG_TIDY "${SKEL_CLANG_TIDY_COMMAND}")
  endif()
endfunction()

# -----------------------------------------------------------------------------
# skel_add_library(<name>
#     [HEADER_ONLY]
#     HEADERS      <public headers, relative to the module dir or absolute>...
#     [SOURCES     <private sources>...]
#     [PUBLIC_DEPS <targets>...]    # part of the public API (skel::x, fmt::fmt, ...)
#     [PRIVATE_DEPS <targets>...]   # implementation details
#     [PACKAGES    <find_package names>...])  # third-party packages providing the deps
#
# Layout expected in the calling directory:
#     include/skel/<name>/*.hpp   public headers  (#include <skel/<name>/foo.hpp>)
#     src/*.cpp                   private sources
#     tests/                      unit tests (added by the module's CMakeLists)
#
# Generates <skel/<name>/export.hpp> with SKEL_<NAME>_EXPORT for shared builds.
# -----------------------------------------------------------------------------
function(skel_add_library name)
  cmake_parse_arguments(PARSE_ARGV 1 arg "HEADER_ONLY" ""
                        "HEADERS;SOURCES;PUBLIC_DEPS;PRIVATE_DEPS;PACKAGES")
  if(arg_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "skel_add_library(${name}): unknown arguments ${arg_UNPARSED_ARGUMENTS}")
  endif()
  if(NOT arg_HEADERS)
    message(FATAL_ERROR "skel_add_library(${name}): HEADERS is required")
  endif()

  set(target ${PROJECT_NAME}_${name})
  string(TOUPPER "${PROJECT_NAME}_${name}" upper)
  set(gen_include_dir "${CMAKE_CURRENT_BINARY_DIR}/include")

  foreach(pkg IN LISTS arg_PACKAGES)
    find_package(${pkg} CONFIG REQUIRED)
  endforeach()

  if(arg_HEADER_ONLY)
    if(arg_SOURCES OR arg_PRIVATE_DEPS)
      message(FATAL_ERROR "skel_add_library(${name}): HEADER_ONLY libraries take no SOURCES/PRIVATE_DEPS")
    endif()
    add_library(${target} INTERFACE)
    set(scope INTERFACE)
  else()
    add_library(${target})  # STATIC or SHARED depending on BUILD_SHARED_LIBS
    set(scope PUBLIC)
    target_sources(${target} PRIVATE ${arg_SOURCES})
    _skel_apply_common(${target})

    generate_export_header(${target}
      BASE_NAME ${upper}
      EXPORT_FILE_NAME "${gen_include_dir}/${PROJECT_NAME}/${name}/export.hpp")
    list(APPEND arg_HEADERS "${gen_include_dir}/${PROJECT_NAME}/${name}/export.hpp")

    get_target_property(type ${target} TYPE)
    if(type STREQUAL "STATIC_LIBRARY")
      target_compile_definitions(${target} PUBLIC ${upper}_STATIC_DEFINE)
    endif()

    set_target_properties(${target} PROPERTIES
      OUTPUT_NAME ${PROJECT_NAME}_${name}
      VERSION ${PROJECT_VERSION}
      SOVERSION ${PROJECT_VERSION_MAJOR}
      CXX_VISIBILITY_PRESET hidden
      VISIBILITY_INLINES_HIDDEN ON)
    target_link_libraries(${target} PRIVATE ${arg_PRIVATE_DEPS})
  endif()

  add_library(${PROJECT_NAME}::${name} ALIAS ${target})
  set_target_properties(${target} PROPERTIES EXPORT_NAME ${name})
  target_compile_features(${target} ${scope} cxx_std_23)
  target_link_libraries(${target} ${scope} ${arg_PUBLIC_DEPS})
  target_sources(${target} ${scope}
    FILE_SET HEADERS
    BASE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/include" "${gen_include_dir}"
    FILES ${arg_HEADERS})

  # Bookkeeping consumed by SkelInstall / SkelDocs
  set_property(GLOBAL APPEND PROPERTY SKEL_MODULES ${name})
  set_property(GLOBAL APPEND PROPERTY SKEL_MODULE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}")
  set_property(GLOBAL APPEND PROPERTY SKEL_DOC_INPUTS
               "${CMAKE_CURRENT_SOURCE_DIR}/include" "${gen_include_dir}")
  set_property(GLOBAL APPEND PROPERTY SKEL_EXPORT_MACROS "${upper}_EXPORT=" "${upper}_NO_EXPORT=")
  if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
    set_property(GLOBAL APPEND PROPERTY SKEL_DOC_INPUTS "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
  endif()

  if(NOT SKEL_INSTALL)
    return()
  endif()

  # --- install ---------------------------------------------------------------
  install(TARGETS ${target}
    EXPORT ${target}-targets
    RUNTIME COMPONENT ${target}
    LIBRARY COMPONENT ${target} NAMELINK_COMPONENT ${target}_dev
    ARCHIVE COMPONENT ${target}_dev
    FILE_SET HEADERS COMPONENT ${target}_dev)

  install(EXPORT ${target}-targets
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION "${SKEL_INSTALL_CMAKEDIR}"
    COMPONENT ${target}_dev)

  # Per-module loader: pulls its internal + third-party dependencies, then its
  # targets. Lets consumers do find_package(skel COMPONENTS <name>).
  set(module_file "${CMAKE_CURRENT_BINARY_DIR}/${target}-module.cmake")
  set(content "# Generated by skel_add_library(${name}) - do not edit\n")
  string(APPEND content "include_guard(GLOBAL)\ninclude(CMakeFindDependencyMacro)\n")
  foreach(dep IN LISTS arg_PUBLIC_DEPS arg_PRIVATE_DEPS)
    if(dep MATCHES "^${PROJECT_NAME}::(.+)$")
      string(APPEND content
        "include(\"\${CMAKE_CURRENT_LIST_DIR}/${PROJECT_NAME}_${CMAKE_MATCH_1}-module.cmake\")\n")
    endif()
  endforeach()
  foreach(pkg IN LISTS arg_PACKAGES)
    string(APPEND content "find_dependency(${pkg} CONFIG)\n")
  endforeach()
  string(APPEND content "include(\"\${CMAKE_CURRENT_LIST_DIR}/${target}-targets.cmake\")\n")
  file(WRITE "${module_file}" "${content}")

  install(FILES "${module_file}"
    DESTINATION "${SKEL_INSTALL_CMAKEDIR}"
    COMPONENT ${target}_dev)
endfunction()

# -----------------------------------------------------------------------------
# skel_add_executable(<name>
#     SOURCES <sources>...
#     [DEPS <targets>...]
#     [PACKAGES <find_package names>...]
#     [NO_INSTALL])
# Produces target skel_<name> and binary "skel-<name>".
# -----------------------------------------------------------------------------
function(skel_add_executable name)
  cmake_parse_arguments(PARSE_ARGV 1 arg "NO_INSTALL" "" "SOURCES;DEPS;PACKAGES")
  if(arg_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "skel_add_executable(${name}): unknown arguments ${arg_UNPARSED_ARGUMENTS}")
  endif()

  set(target ${PROJECT_NAME}_${name})
  foreach(pkg IN LISTS arg_PACKAGES)
    find_package(${pkg} CONFIG REQUIRED)
  endforeach()

  add_executable(${target} ${arg_SOURCES})
  add_executable(${PROJECT_NAME}::${name} ALIAS ${target})
  set_target_properties(${target} PROPERTIES OUTPUT_NAME ${PROJECT_NAME}-${name})
  target_compile_features(${target} PRIVATE cxx_std_23)
  target_link_libraries(${target} PRIVATE ${arg_DEPS})
  _skel_apply_common(${target})

  if(SKEL_INSTALL AND NOT arg_NO_INSTALL)
    install(TARGETS ${target} RUNTIME COMPONENT ${target})
    set_property(GLOBAL APPEND PROPERTY SKEL_APPS ${name})
  endif()
endfunction()

# -----------------------------------------------------------------------------
# skel_add_tests(<module>
#     SOURCES <test sources>...
#     [DEPS <extra targets>...])
# Creates skel_<module>_tests linked to skel::<module> + Catch2, discovered by
# CTest with the "<module>." prefix and label "<module>".
# -----------------------------------------------------------------------------
function(skel_add_tests name)
  cmake_parse_arguments(PARSE_ARGV 1 arg "" "" "SOURCES;DEPS")
  if(NOT SKEL_BUILD_TESTS)
    return()
  endif()

  set(target ${PROJECT_NAME}_${name}_tests)
  add_executable(${target} ${arg_SOURCES})
  target_compile_features(${target} PRIVATE cxx_std_23)
  target_link_libraries(${target} PRIVATE
    ${PROJECT_NAME}::${name}
    Catch2::Catch2WithMain
    ${arg_DEPS}
    $<BUILD_INTERFACE:skel_project_options>)
  # Tests are deliberately not run through clang-tidy (Catch2 macros are noisy).

  catch_discover_tests(${target}
    TEST_PREFIX "${name}."
    PROPERTIES LABELS "${name};unit"
    DISCOVERY_MODE PRE_TEST)
endfunction()
