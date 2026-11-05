#include <skel/core/core.hpp>
#include <skel/core/version.hpp>

#include <catch2/catch_test_macros.hpp>

#include <string_view>

TEST_CASE("linked_version matches the compile-time version", "[core][version]") {
    REQUIRE(skel::core::linked_version() == std::string_view{skel::core::version_string});
}

TEST_CASE("version components are consistent", "[core][version]") {
    STATIC_REQUIRE(skel::core::version_major >= 0);
    STATIC_REQUIRE(skel::core::version_minor >= 0);
    STATIC_REQUIRE(skel::core::version_patch >= 0);
}
