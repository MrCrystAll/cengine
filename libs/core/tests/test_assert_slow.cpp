// Asserts and slow asserts both forced ON.
#define CENGINE_ENABLE_ASSERTS 1
#define CENGINE_ENABLE_SLOW_ASSERTS 1
#include <cengine/core/assert.hpp>

#include <catch2/catch_test_macros.hpp>

#include "assert_test_support.hpp"

using cengine::core::testing::assertion_failure;
using cengine::core::testing::scoped_assert_handler;
using cengine::core::testing::throwing_handler;

TEST_CASE("CENGINE_ASSERT_SLOW fires when slow asserts are enabled", "[core][assert]") {
    const scoped_assert_handler guard{throwing_handler};
    const int two = 2;
    CHECK_THROWS_AS(CENGINE_ASSERT_SLOW(two == 3, "expensive check failed"), assertion_failure);
    CHECK_NOTHROW(CENGINE_ASSERT_SLOW(two == 2, "expensive check holds"));
}
