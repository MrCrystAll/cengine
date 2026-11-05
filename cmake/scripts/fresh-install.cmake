# Usage: cmake -DBINARY_DIR=<build> -DPREFIX=<prefix> -DCONFIG=<cfg> [-DCLEAN=<dir>;<dir>] -P fresh-install.cmake
# Removes the previous scratch install/build, then installs the build tree into PREFIX.
foreach(var BINARY_DIR PREFIX CONFIG)
  if(NOT DEFINED ${var})
    message(FATAL_ERROR "fresh-install.cmake: ${var} is required")
  endif()
endforeach()

foreach(dir IN LISTS PREFIX CLEAN)
  file(REMOVE_RECURSE "${dir}")
endforeach()

execute_process(
  COMMAND "${CMAKE_COMMAND}" --install "${BINARY_DIR}" --prefix "${PREFIX}" --config "${CONFIG}"
  RESULT_VARIABLE result)
if(NOT result EQUAL 0)
  message(FATAL_ERROR "cmake --install failed (${result})")
endif()
