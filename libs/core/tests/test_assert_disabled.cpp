// Asserts forced OFF, as in Release. Slow asserts requested ON: they must stay off too.
#define CENGINE_ENABLE_ASSERTS 0
#define CENGINE_ENABLE_SLOW_ASSERTS 1
#include <cengine/core/assert.hpp>

#include <catch2/catch_test_macros.hpp>

#include "assert_test_support.hpp"

using cengine::core::testing::scoped_assert_handler;
using cengine::core::testing::throwing_handler;

TEST_CASE("disabled CENGINE_ASSERT does not evaluate its condition", "[core][assert]") {
    const scoped_assert_handler guard{throwing_handler};
    int evaluations = 0;
    CENGINE_ASSERT(++evaluations < 0, "would fire if evaluated");
    CHECK(evaluations == 0);
}

TEST_CASE("slow asserts are off whenever asserts are off", "[core][assert]") {
    const scoped_assert_handler guard{throwing_handler};
    int evaluations = 0;
    CENGINE_ASSERT_SLOW(++evaluations < 0, "would fire if evaluated");
    CHECK(evaluations == 0);
}
