# Stand-alone consumer of the INSTALLED cengine package. It is also the reference
# snippet for anyone integrating cengine into their own project.
cmake_minimum_required(VERSION 3.25)
project(cengine_package_consumer LANGUAGES CXX)

find_package(cengine CONFIG REQUIRED COMPONENTS core)

if(DEFINED CENGINE_EXPECTED_VERSION AND NOT cengine_VERSION VERSION_EQUAL CENGINE_EXPECTED_VERSION)
  message(FATAL_ERROR "Found cengine ${cengine_VERSION}, expected ${CENGINE_EXPECTED_VERSION}")
endif()

add_executable(consumer main.cpp)
target_link_libraries(consumer PRIVATE cengine::core)

enable_testing()
add_test(NAME consumer COMMAND consumer)
if(WIN32 AND DEFINED CENGINE_RUNTIME_DIR)
  # Shared builds: let Windows find the installed DLLs.
  set_tests_properties(consumer PROPERTIES
    ENVIRONMENT_MODIFICATION "PATH=path_list_prepend:${CENGINE_RUNTIME_DIR}")
endif()
