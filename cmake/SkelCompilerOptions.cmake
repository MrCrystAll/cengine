include_guard(GLOBAL)

# -----------------------------------------------------------------------------
# skel_project_options: INTERFACE target carrying warnings / coverage flags.
# Linked PRIVATELY (and BUILD_INTERFACE only) by every skel target, so none of
# these flags ever leak to consumers of the installed package.
# Warnings-as-errors is NOT set here: use CMAKE_COMPILE_WARNING_AS_ERROR (CI presets do).
# -----------------------------------------------------------------------------
add_library(skel_project_options INTERFACE)

set(_skel_gnu_style_warnings
  -Wshadow
  -Wnon-virtual-dtor
  -Wold-style-cast
  -Wcast-align
  -Wunused
  -Woverloaded-virtual
  -Wconversion
  -Wsign-conversion
  -Wnull-dereference
  -Wdouble-promotion
  -Wformat=2
  -Wimplicit-fallthrough)

if(MSVC AND CMAKE_CXX_COMPILER_ID STREQUAL "Clang")  # clang-cl: MSVC driver, Clang warnings
  target_compile_options(skel_project_options INTERFACE
    /W4
    /permissive-
    /utf-8
    ${_skel_gnu_style_warnings})
elseif(MSVC)  # cl.exe
  target_compile_options(skel_project_options INTERFACE
    /W4
    /permissive-
    /utf-8
    /Zc:__cplusplus
    /Zc:preprocessor
    /w14242 # conversion, possible loss of data
    /w14254 # larger bit field assigned to smaller
    /w14263 # member function hides base virtual
    /w14265 # class has virtual functions but non-virtual destructor
    /w14287 # unsigned/negative constant mismatch
    /we4289 # loop variable used outside the loop
    /w14296 # expression is always true/false
    /w14311 # pointer truncation
    /w14545 /w14546 /w14547 /w14549 /w14555 # suspicious expressions
    /w14826 # sign-extended conversion
    /w14905 /w14906 # string literal casts
    /w14928 # illegal copy-initialization
  )
else()
  target_compile_options(skel_project_options INTERFACE
    -Wall
    -Wextra
    -Wpedantic
    ${_skel_gnu_style_warnings}
  )
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    target_compile_options(skel_project_options INTERFACE
      -Wmisleading-indentation
      -Wduplicated-cond
      -Wduplicated-branches
      -Wlogical-op
    )
  endif()
endif()

# -----------------------------------------------------------------------------
# Coverage
# -----------------------------------------------------------------------------
if(SKEL_ENABLE_COVERAGE)
  if(MSVC)
    message(FATAL_ERROR "SKEL_ENABLE_COVERAGE is only supported with GCC/Clang")
  endif()
  target_compile_options(skel_project_options INTERFACE --coverage -O0 -g)
  target_link_options(skel_project_options INTERFACE --coverage)

  find_program(SKEL_GCOVR gcovr)
  if(SKEL_GCOVR)
    set(_skel_gcov_args "")
    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
      find_program(SKEL_LLVM_COV NAMES llvm-cov llvm-cov-20 llvm-cov-19 llvm-cov-18)
      if(SKEL_LLVM_COV)
        set(_skel_gcov_args --gcov-executable "${SKEL_LLVM_COV} gcov")
      endif()
    endif()
    add_custom_target(coverage
      COMMAND "${SKEL_GCOVR}"
              --root "${PROJECT_SOURCE_DIR}"
              --object-directory "${PROJECT_BINARY_DIR}"
              --filter "${PROJECT_SOURCE_DIR}/libs/"
              --exclude ".*/tests/.*"
              ${_skel_gcov_args}
              --print-summary
              --txt
              --xml-pretty --xml "${PROJECT_BINARY_DIR}/coverage.xml"
              --html-details "${PROJECT_BINARY_DIR}/coverage/index.html"
      WORKING_DIRECTORY "${PROJECT_BINARY_DIR}"
      COMMENT "Generating coverage report (run the tests first)"
      VERBATIM)
  else()
    message(STATUS "gcovr not found: the 'coverage' report target is unavailable")
  endif()
endif()

# -----------------------------------------------------------------------------
# clang-tidy (applied per target by skel_add_library / skel_add_executable)
# -----------------------------------------------------------------------------
if(SKEL_ENABLE_CLANG_TIDY)
  find_program(SKEL_CLANG_TIDY_EXE NAMES clang-tidy clang-tidy-20 clang-tidy-19 clang-tidy-18 REQUIRED)
  set(SKEL_CLANG_TIDY_COMMAND "${SKEL_CLANG_TIDY_EXE}" "--config-file=${PROJECT_SOURCE_DIR}/.clang-tidy")
  if(CMAKE_COMPILE_WARNING_AS_ERROR)
    list(APPEND SKEL_CLANG_TIDY_COMMAND "--warnings-as-errors=*")
  endif()
endif()
