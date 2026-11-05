include_guard(GLOBAL)

if(NOT CENGINE_BUILD_DOCS)
  return()
endif()

# Doxygen >= 1.9.5 is required by the doxygen-awesome-css theme.
find_package(Doxygen 1.9.5 REQUIRED OPTIONAL_COMPONENTS dot)

include(FetchContent)
FetchContent_Declare(doxygen_awesome_css
  URL https://github.com/jothepro/doxygen-awesome-css/archive/refs/tags/v2.3.4.tar.gz
  URL_HASH SHA256=54d515327b559cd18c6f4d3e8a46e0facc635be1967fb69526f977285922960e
  SOURCE_SUBDIR do-not-add-subdirectory
  DOWNLOAD_EXTRACT_TIMESTAMP ON)
FetchContent_MakeAvailable(doxygen_awesome_css)

get_property(_cengine_doc_inputs GLOBAL PROPERTY CENGINE_DOC_INPUTS)
get_property(_cengine_export_macros GLOBAL PROPERTY CENGINE_EXPORT_MACROS)

set(DOXYGEN_PROJECT_NAME "${PROJECT_NAME}")
set(DOXYGEN_PROJECT_NUMBER "${PROJECT_VERSION}")
set(DOXYGEN_PROJECT_BRIEF "${PROJECT_DESCRIPTION}")
set(DOXYGEN_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/docs")
set(DOXYGEN_USE_MDFILE_AS_MAINPAGE "${PROJECT_SOURCE_DIR}/docs/index.md")
set(DOXYGEN_FILE_PATTERNS *.hpp *.h *.md)
set(DOXYGEN_EXCLUDE_PATTERNS */export.hpp)
set(DOXYGEN_RECURSIVE YES)
set(DOXYGEN_IMPLICIT_DIR_DOCS NO)  # README.md files are pages (with {#anchors}), not dir docs
set(DOXYGEN_STRIP_FROM_PATH "${PROJECT_SOURCE_DIR}")
set(DOXYGEN_STRIP_FROM_INC_PATH ${_cengine_doc_inputs})
set(DOXYGEN_EXTRACT_ALL NO)
set(DOXYGEN_EXTRACT_PRIVATE NO)
set(DOXYGEN_WARN_IF_UNDOCUMENTED YES)
set(DOXYGEN_WARN_NO_PARAMDOC YES)
if(CENGINE_DOCS_WARN_AS_ERROR)
  set(DOXYGEN_WARN_AS_ERROR FAIL_ON_WARNINGS)
endif()
set(DOXYGEN_ENABLE_PREPROCESSING YES)
set(DOXYGEN_MACRO_EXPANSION YES)
set(DOXYGEN_EXPAND_ONLY_PREDEF YES)
set(DOXYGEN_PREDEFINED ${_cengine_export_macros})
set(DOXYGEN_IMAGE_PATH "${PROJECT_SOURCE_DIR}/docs/images")
set(DOXYGEN_GENERATE_LATEX NO)
set(DOXYGEN_GENERATE_TREEVIEW YES)
set(DOXYGEN_DISABLE_INDEX NO)
set(DOXYGEN_FULL_SIDEBAR NO)
set(DOXYGEN_HTML_COLORSTYLE LIGHT)
set(DOXYGEN_HTML_EXTRA_STYLESHEET
  "${doxygen_awesome_css_SOURCE_DIR}/doxygen-awesome.css"
  "${doxygen_awesome_css_SOURCE_DIR}/doxygen-awesome-sidebar-only.css")

# -----------------------------------------------------------------------------
# Module dependency graph (docs/guides/architecture.md). Built from what
# cengine_add_library / cengine_add_executable recorded, so it is always current.
# -----------------------------------------------------------------------------
set(_cengine_dot_dir "${PROJECT_BINARY_DIR}/docs-graph")
set(_cengine_dot "digraph cengine_modules {\n")
string(APPEND _cengine_dot "  rankdir=BT;\n  node [fontname=\"Helvetica\", fontsize=11];\n")
get_property(_cengine_nodes GLOBAL PROPERTY CENGINE_GRAPH_NODES)
set(_cengine_seen_packages "")
foreach(_node IN LISTS _cengine_nodes)
  get_property(_kind GLOBAL PROPERTY CENGINE_GRAPH_KIND_${_node})
  get_property(_deps GLOBAL PROPERTY CENGINE_GRAPH_DEPS_${_node})
  get_property(_pkgs GLOBAL PROPERTY CENGINE_GRAPH_PACKAGES_${_node})
  if(_kind STREQUAL "app")
    string(APPEND _cengine_dot "  \"${_node}\" [shape=ellipse, label=\"${PROJECT_NAME}-${_node}\"];\n")
  else()
    string(APPEND _cengine_dot "  \"${_node}\" [shape=box, label=\"${PROJECT_NAME}::${_node}\"];\n")
  endif()
  foreach(_dep IN LISTS _deps)
    string(APPEND _cengine_dot "  \"${_node}\" -> \"${_dep}\";\n")
  endforeach()
  foreach(_pkg IN LISTS _pkgs)
    if(NOT _pkg IN_LIST _cengine_seen_packages)
      list(APPEND _cengine_seen_packages ${_pkg})
      string(APPEND _cengine_dot
        "  \"pkg:${_pkg}\" [shape=box, style=\"filled,dashed\", fillcolor=\"#eeeeee\", label=\"${_pkg}\"];\n")
    endif()
    string(APPEND _cengine_dot "  \"${_node}\" -> \"pkg:${_pkg}\" [style=dashed];\n")
  endforeach()
endforeach()
string(APPEND _cengine_dot "}\n")
file(WRITE "${_cengine_dot_dir}/modules.dot" "${_cengine_dot}")

if(TARGET Doxygen::dot)
  set(DOXYGEN_HAVE_DOT YES)
  set(DOXYGEN_DOTFILE_DIRS "${_cengine_dot_dir}")
  set(DOXYGEN_ENABLED_SECTIONS MODULE_GRAPH)
else()
  set(DOXYGEN_HAVE_DOT NO)
  message(STATUS "Graphviz 'dot' not found: the docs will not include the module graph")
endif()

doxygen_add_docs(docs
  "${PROJECT_SOURCE_DIR}/docs"
  ${_cengine_doc_inputs}
  WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
  COMMENT "Generating API documentation with Doxygen -> ${DOXYGEN_OUTPUT_DIRECTORY}/html")

if(CENGINE_INSTALL)
  install(DIRECTORY "${DOXYGEN_OUTPUT_DIRECTORY}/html/"
    DESTINATION "${CMAKE_INSTALL_DOCDIR}/html"
    COMPONENT ${PROJECT_NAME}_docs
    OPTIONAL)
endif()
