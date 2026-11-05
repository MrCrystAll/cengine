#include <cengine/core/core.hpp>
#include <cengine/core/version.hpp>

#include <catch2/catch_test_macros.hpp>

#include <string_view>

TEST_CASE("linked_version matches the compile-time version", "[core][version]") {
    REQUIRE(cengine::core::linked_version() == std::string_view{cengine::core::version_string});
}

TEST_CASE("version components are consistent", "[core][version]") {
    STATIC_REQUIRE(cengine::core::version_major >= 0);
    STATIC_REQUIRE(cengine::core::version_minor >= 0);
    STATIC_REQUIRE(cengine::core::version_patch >= 0);
}
