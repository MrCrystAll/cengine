include_guard(GLOBAL)
include(GenerateExportHeader)

# =============================================================================
# Module helpers. Every microproject goes through these functions so that all
# modules are built, tested, installed and exported the same way.
#
#   cengine_add_library(<name> ...)     -> target cengine_<name>, alias cengine::<name>
#   cengine_add_executable(<name> ...)  -> target cengine_<name>, binary "cengine-<name>"
#   cengine_add_tests(<name> ...)       -> target cengine_<name>_tests, registered in CTest
#   cengine_add_tests(<name> INTERNAL ...) -> cengine_<name>_internal_tests (can see src/)
#   cengine_add_benchmarks(<name> ...)  -> target cengine_<name>_benchmarks (nanobench)
#
# See docs/guides/adding-a-module.md for the full walkthrough.
# =============================================================================

# Internal: remembers a module/app and its dependencies for the docs' module graph.
#   kind: "module" or "app"; deps: link targets (only cengine::<x> ones are kept);
#   packages: third-party find_package names.
function(_cengine_record_graph_node name kind deps packages)
  set(internal "")
  foreach(dep IN LISTS deps)
    if(dep MATCHES "^${PROJECT_NAME}::(.+)$")
      list(APPEND internal ${CMAKE_MATCH_1})
    endif()
  endforeach()
  set_property(GLOBAL APPEND PROPERTY CENGINE_GRAPH_NODES "${name}")
  set_property(GLOBAL PROPERTY CENGINE_GRAPH_KIND_${name} "${kind}")
  set_property(GLOBAL PROPERTY CENGINE_GRAPH_DEPS_${name} "${internal}")
  set_property(GLOBAL PROPERTY CENGINE_GRAPH_PACKAGES_${name} "${packages}")
endfunction()

# Internal: settings shared by every compiled cengine target.
function(_cengine_apply_common target)
  target_link_libraries(${target} PRIVATE $<BUILD_INTERFACE:cengine_project_options>)
  set_target_properties(${target} PROPERTIES CXX_EXTENSIONS OFF)
  if(CENGINE_ENABLE_CLANG_TIDY)
    set_target_properties(${target} PROPERTIES CXX_CLANG_TIDY "${CENGINE_CLANG_TIDY_COMMAND}")
  endif()
endfunction()

# -----------------------------------------------------------------------------
# cengine_add_library(<name>
#     [HEADER_ONLY]
#     HEADERS      <public headers, relative to the module dir or absolute>...
#     [SOURCES     <private sources>...]
#     [PUBLIC_DEPS <targets>...]    # part of the public API (cengine::x, fmt::fmt, ...)
#     [PRIVATE_DEPS <targets>...]   # implementation details
#     [PACKAGES    <find_package names>...])  # third-party packages providing the deps
#
# Layout expected in the calling directory:
#     include/cengine/<name>/*.hpp   public headers  (#include <cengine/<name>/foo.hpp>)
#     src/*.cpp                   private sources
#     tests/                      unit tests (added by the module's CMakeLists)
#
# Generates <cengine/<name>/export.hpp> with CENGINE_<NAME>_EXPORT for shared builds.
# -----------------------------------------------------------------------------
function(cengine_add_library name)
  cmake_parse_arguments(PARSE_ARGV 1 arg "HEADER_ONLY" ""
                        "HEADERS;SOURCES;PUBLIC_DEPS;PRIVATE_DEPS;PACKAGES")
  if(arg_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "cengine_add_library(${name}): unknown arguments ${arg_UNPARSED_ARGUMENTS}")
  endif()
  if(NOT arg_HEADERS)
    message(FATAL_ERROR "cengine_add_library(${name}): HEADERS is required")
  endif()

  set(target ${PROJECT_NAME}_${name})
  string(TOUPPER "${PROJECT_NAME}_${name}" upper)
  set(gen_include_dir "${CMAKE_CURRENT_BINARY_DIR}/include")

  foreach(pkg IN LISTS arg_PACKAGES)
    find_package(${pkg} CONFIG REQUIRED)
  endforeach()

  if(arg_HEADER_ONLY)
    if(arg_SOURCES OR arg_PRIVATE_DEPS)
      message(FATAL_ERROR "cengine_add_library(${name}): HEADER_ONLY libraries take no SOURCES/PRIVATE_DEPS")
    endif()
    add_library(${target} INTERFACE)
    set(scope INTERFACE)
  else()
    add_library(${target})  # STATIC or SHARED depending on BUILD_SHARED_LIBS
    set(scope PUBLIC)
    target_sources(${target} PRIVATE ${arg_SOURCES})
    _cengine_apply_common(${target})

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

  # Bookkeeping consumed by CengineInstall / CengineDocs
  set_property(GLOBAL APPEND PROPERTY CENGINE_MODULES ${name})
  set_property(GLOBAL APPEND PROPERTY CENGINE_MODULE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}")
  set_property(GLOBAL APPEND PROPERTY CENGINE_DOC_INPUTS
               "${CMAKE_CURRENT_SOURCE_DIR}/include" "${gen_include_dir}")
  set_property(GLOBAL APPEND PROPERTY CENGINE_EXPORT_MACROS "${upper}_EXPORT=" "${upper}_NO_EXPORT=")
  if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
    set_property(GLOBAL APPEND PROPERTY CENGINE_DOC_INPUTS "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
  endif()
  _cengine_record_graph_node(${name} module "${arg_PUBLIC_DEPS};${arg_PRIVATE_DEPS}" "${arg_PACKAGES}")

  if(NOT CENGINE_INSTALL)
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
    DESTINATION "${CENGINE_INSTALL_CMAKEDIR}"
    COMPONENT ${target}_dev)

  # Per-module loader: pulls its internal + third-party dependencies, then its
  # targets. Lets consumers do find_package(cengine COMPONENTS <name>).
  set(module_file "${CMAKE_CURRENT_BINARY_DIR}/${target}-module.cmake")
  set(content "# Generated by cengine_add_library(${name}) - do not edit\n")
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
    DESTINATION "${CENGINE_INSTALL_CMAKEDIR}"
    COMPONENT ${target}_dev)
endfunction()

# -----------------------------------------------------------------------------
# cengine_add_executable(<name>
#     SOURCES <sources>...
#     [DEPS <targets>...]
#     [PACKAGES <find_package names>...]
#     [NO_INSTALL])
# Produces target cengine_<name> and binary "cengine-<name>".
# -----------------------------------------------------------------------------
function(cengine_add_executable name)
  cmake_parse_arguments(PARSE_ARGV 1 arg "NO_INSTALL" "" "SOURCES;DEPS;PACKAGES")
  if(arg_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "cengine_add_executable(${name}): unknown arguments ${arg_UNPARSED_ARGUMENTS}")
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
  _cengine_apply_common(${target})
  _cengine_record_graph_node(${name} app "${arg_DEPS}" "${arg_PACKAGES}")

  if(CENGINE_INSTALL AND NOT arg_NO_INSTALL)
    install(TARGETS ${target} RUNTIME COMPONENT ${target})
    set_property(GLOBAL APPEND PROPERTY CENGINE_APPS ${name})
  endif()
endfunction()

# -----------------------------------------------------------------------------
# cengine_add_tests(<module>
#     [INTERNAL]
#     SOURCES <test sources>...
#     [DEPS <extra targets>...])
# Creates cengine_<module>_tests linked to cengine::<module> + Catch2, discovered by
# CTest with the "<module>." prefix and labels "<module>;unit".
#
# INTERNAL: creates cengine_<module>_internal_tests instead, for testing implementation
# details (GJK, solvers, ...). It links a private static copy of the module built from the
# same sources, with the module's src/ on the include path and no symbol visibility
# limits, so it works identically in static and shared builds. Labels "<module>;internal".
# Use it only for code that is intentionally not public API.
# -----------------------------------------------------------------------------
function(cengine_add_tests name)
  cmake_parse_arguments(PARSE_ARGV 1 arg "INTERNAL" "" "SOURCES;DEPS")
  if(arg_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "cengine_add_tests(${name}): unknown arguments ${arg_UNPARSED_ARGUMENTS}")
  endif()
  if(NOT CENGINE_BUILD_TESTS)
    return()
  endif()

  if(arg_INTERNAL)
    set(target ${PROJECT_NAME}_${name}_internal_tests)
    _cengine_internal_library(${name} under_test)
    set(prefix "${name}.internal.")
    set(labels "${name};internal")
  else()
    set(target ${PROJECT_NAME}_${name}_tests)
    set(under_test ${PROJECT_NAME}::${name})
    set(prefix "${name}.")
    set(labels "${name};unit")
  endif()

  add_executable(${target} ${arg_SOURCES})
  target_compile_features(${target} PRIVATE cxx_std_23)
  target_link_libraries(${target} PRIVATE
    ${under_test}
    Catch2::Catch2WithMain
    ${arg_DEPS}
    $<BUILD_INTERFACE:cengine_project_options>)
  # Tests are deliberately not run through clang-tidy (Catch2 macros are noisy).

  catch_discover_tests(${target}
    TEST_PREFIX "${prefix}"
    PROPERTIES LABELS "${labels}"
    DISCOVERY_MODE PRE_TEST)
endfunction()

# Internal: returns (in out_var) a target exposing <module>'s implementation to tests.
# Compiled libraries get a private STATIC twin (cengine_<module>_internal) built from the
# same sources with the same usage requirements, plus src/ on its include path.
function(_cengine_internal_library name out_var)
  set(lib ${PROJECT_NAME}_${name})
  set(internal ${lib}_internal)
  if(TARGET ${internal})
    set(${out_var} ${internal} PARENT_SCOPE)
    return()
  endif()

  get_target_property(type ${lib} TYPE)
  get_target_property(lib_source_dir ${lib} SOURCE_DIR)
  if(type STREQUAL "INTERFACE_LIBRARY")
    add_library(${internal} INTERFACE)
    target_link_libraries(${internal} INTERFACE ${lib})
    if(EXISTS "${lib_source_dir}/src")
      target_include_directories(${internal} INTERFACE "${lib_source_dir}/src")
    endif()
    set(${out_var} ${internal} PARENT_SCOPE)
    return()
  endif()

  get_target_property(sources ${lib} SOURCES)
  set(abs_sources "")
  foreach(src IN LISTS sources)
    if(src MATCHES "\\.(c|cc|cpp|cxx)$")
      cmake_path(ABSOLUTE_PATH src BASE_DIRECTORY "${lib_source_dir}" OUTPUT_VARIABLE abs)
      list(APPEND abs_sources "${abs}")
    endif()
  endforeach()
  get_target_property(link_libs ${lib} LINK_LIBRARIES)            # public + private deps
  get_target_property(iface_link_libs ${lib} INTERFACE_LINK_LIBRARIES)
  string(TOUPPER "${lib}" upper)

  add_library(${internal} STATIC EXCLUDE_FROM_ALL ${abs_sources})
  target_compile_features(${internal} PUBLIC cxx_std_23)
  target_include_directories(${internal} PUBLIC
    "$<TARGET_PROPERTY:${lib},INTERFACE_INCLUDE_DIRECTORIES>"
    "${lib_source_dir}/src")
  target_compile_options(${internal} PUBLIC "$<TARGET_PROPERTY:${lib},INTERFACE_COMPILE_OPTIONS>")
  # Static twin: export macros must expand to nothing even in shared builds.
  target_compile_definitions(${internal} PUBLIC ${upper}_STATIC_DEFINE)
  foreach(dep IN LISTS link_libs iface_link_libs)
    if(dep AND NOT dep MATCHES "-NOTFOUND$")
      target_link_libraries(${internal} PUBLIC "${dep}")
    endif()
  endforeach()
  set_target_properties(${internal} PROPERTIES CXX_EXTENSIONS OFF POSITION_INDEPENDENT_CODE ON)
  set(${out_var} ${internal} PARENT_SCOPE)
endfunction()

# -----------------------------------------------------------------------------
# cengine_add_benchmarks(<module>
#     SOURCES <benchmark sources>...
#     [INTERNAL]                    # benchmark implementation details, like INTERNAL tests
#     [DEPS <extra targets>...])
# Creates cengine_<module>_benchmarks (nanobench, shared runner from benchmarks/) when
# CENGINE_BUILD_BENCHMARKS is ON. With tests enabled, also registers the CTest
# "<module>.benchmarks.smoke" (label "benchmark") that runs every benchmark once.
# -----------------------------------------------------------------------------
function(cengine_add_benchmarks name)
  cmake_parse_arguments(PARSE_ARGV 1 arg "INTERNAL" "" "SOURCES;DEPS")
  if(arg_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "cengine_add_benchmarks(${name}): unknown arguments ${arg_UNPARSED_ARGUMENTS}")
  endif()
  if(NOT CENGINE_BUILD_BENCHMARKS)
    return()
  endif()

  if(arg_INTERNAL)
    _cengine_internal_library(${name} under_bench)
  else()
    set(under_bench ${PROJECT_NAME}::${name})
  endif()

  set(target ${PROJECT_NAME}_${name}_benchmarks)
  add_executable(${target} ${arg_SOURCES})
  target_compile_features(${target} PRIVATE cxx_std_23)
  target_link_libraries(${target} PRIVATE
    ${under_bench}
    cengine_bench_runner
    ${arg_DEPS}
    $<BUILD_INTERFACE:cengine_project_options>)

  if(CENGINE_BUILD_TESTS)
    add_test(NAME ${name}.benchmarks.smoke COMMAND ${target} --smoke)
    set_tests_properties(${name}.benchmarks.smoke PROPERTIES LABELS "${name};benchmark")
  endif()
endfunction()
