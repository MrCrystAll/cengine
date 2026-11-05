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
set(DOXYGEN_HAVE_DOT ${DOXYGEN_DOT_FOUND})

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
