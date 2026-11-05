# Stand-alone consumer of the INSTALLED skel package. It is also the reference
# snippet for anyone integrating skel into their own project.
cmake_minimum_required(VERSION 3.25)
project(skel_package_consumer LANGUAGES CXX)

find_package(skel CONFIG REQUIRED COMPONENTS core)

if(DEFINED SKEL_EXPECTED_VERSION AND NOT skel_VERSION VERSION_EQUAL SKEL_EXPECTED_VERSION)
  message(FATAL_ERROR "Found skel ${skel_VERSION}, expected ${SKEL_EXPECTED_VERSION}")
endif()

add_executable(consumer main.cpp)
target_link_libraries(consumer PRIVATE skel::core)

enable_testing()
add_test(NAME consumer COMMAND consumer)
if(WIN32 AND DEFINED SKEL_RUNTIME_DIR)
  # Shared builds: let Windows find the installed DLLs.
  set_tests_properties(consumer PROPERTIES
    ENVIRONMENT_MODIFICATION "PATH=path_list_prepend:${SKEL_RUNTIME_DIR}")
endif()
