cengine_add_tests(core
  SOURCES
    test_core.cpp
    test_result.cpp
    test_config.cpp
    test_determinism.cpp
    test_assert.cpp
    test_assert_slow.cpp
    test_assert_disabled.cpp
)

if(TARGET cengine_core_tests)
  # Lets test_config.cpp check that config.hpp really follows the CMake option.
  target_compile_definitions(cengine_core_tests PRIVATE
    CENGINE_TEST_EXPECT_DOUBLE=$<BOOL:${CENGINE_DOUBLE_PRECISION}>)
endif()
