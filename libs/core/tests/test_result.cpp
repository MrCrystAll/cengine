#include <skel/core/result.hpp>

#include <catch2/catch_test_macros.hpp>

namespace {

skel::core::result<int> parse_positive(int value) {
    if (value <= 0) {
        return skel::core::make_error(skel::core::errc::invalid_argument, "must be > 0");
    }
    return value;
}

} // namespace

TEST_CASE("result carries a value on success", "[core][result]") {
    const auto res = parse_positive(42);
    REQUIRE(res.has_value());
    CHECK(*res == 42);
}

TEST_CASE("result carries an error on failure", "[core][result]") {
    const auto res = parse_positive(-1);
    REQUIRE_FALSE(res.has_value());
    CHECK(res.error().code == skel::core::errc::invalid_argument);
    CHECK(res.error().message == "must be > 0");
}
