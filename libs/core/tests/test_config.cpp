#include <cengine/core/config.hpp>

#include <catch2/catch_test_macros.hpp>

#include <limits>
#include <type_traits>

TEST_CASE("real is an IEEE 754 floating-point type", "[core][config]") {
    STATIC_REQUIRE(std::is_floating_point_v<cengine::real>);
    STATIC_REQUIRE(std::numeric_limits<cengine::real>::is_iec559);
}

TEST_CASE("real matches the double_precision flag", "[core][config]") {
    STATIC_REQUIRE(std::is_same_v<cengine::real, double> == cengine::double_precision);
    STATIC_REQUIRE(std::is_same_v<cengine::real, float> == !cengine::double_precision);
}

TEST_CASE("double_precision mirrors the CENGINE_DOUBLE_PRECISION CMake option", "[core][config]") {
    // CENGINE_TEST_EXPECT_DOUBLE is set by libs/core/tests/CMakeLists.txt from the CMake option.
    STATIC_REQUIRE(cengine::double_precision == (CENGINE_TEST_EXPECT_DOUBLE != 0));
}
