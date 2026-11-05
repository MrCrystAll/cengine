// Asserts forced ON (CI tests run in Release, where NDEBUG would disable them); slow asserts at
// their default (OFF).
#define CENGINE_ENABLE_ASSERTS 1
#include <cengine/core/assert.hpp>

#include <catch2/catch_test_macros.hpp>

#include "assert_test_support.hpp"

using cengine::core::testing::assertion_failure;
using cengine::core::testing::scoped_assert_handler;
using cengine::core::testing::throwing_handler;

TEST_CASE("CENGINE_ASSERT does nothing when the condition holds", "[core][assert]") {
    const scoped_assert_handler guard{throwing_handler};
    const int two = 2;
    CHECK_NOTHROW(CENGINE_ASSERT(two == 2, "two is two"));
}

TEST_CASE("CENGINE_ASSERT reports expression, message and location", "[core][assert]") {
    const scoped_assert_handler guard{throwing_handler};
    const int two = 2;
    try {
        CENGINE_ASSERT(two == 3, "two is not three");
        FAIL("the assert did not fire");
    } catch (const assertion_failure& failure) {
        CHECK(failure.expression == "two == 3");
        CHECK(failure.message == "two is not three");
    }
}

TEST_CASE("CENGINE_ASSERT reports the line it is written on", "[core][assert]") {
    const scoped_assert_handler guard{throwing_handler};
    const auto expected_line = static_cast<std::uint_least32_t>(__LINE__ + 2);
    try {
        CENGINE_ASSERT(false, "always fires");
        FAIL("the assert did not fire");
    } catch (const assertion_failure& failure) {
        CHECK(failure.line == expected_line);
    }
}

TEST_CASE("CENGINE_ASSERT_SLOW is not evaluated unless slow asserts are enabled",
          "[core][assert]") {
    const scoped_assert_handler guard{throwing_handler};
    int evaluations = 0;
    CENGINE_ASSERT_SLOW(++evaluations < 0, "would fire if evaluated");
    CHECK(evaluations == 0);
}

TEST_CASE("set_assert_handler returns the previous handler; nullptr restores the default",
          "[core][assert]") {
    using namespace cengine::core;
    const assert_handler original = set_assert_handler(throwing_handler);
    CHECK(original == &default_assert_handler);
    CHECK(get_assert_handler() == &throwing_handler);

    CHECK(set_assert_handler(nullptr) == &throwing_handler);
    CHECK(get_assert_handler() == &default_assert_handler);

    set_assert_handler(original);
}

TEST_CASE("CENGINE_ASSERT can be used in constant expressions", "[core][assert]") {
    constexpr auto checked_half = [](int value) {
        CENGINE_ASSERT(value % 2 == 0, "value must be even");
        return value / 2;
    };
    STATIC_REQUIRE(checked_half(8) == 4);
}
