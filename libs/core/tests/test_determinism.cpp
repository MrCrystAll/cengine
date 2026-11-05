// Determinism canary (ADR 0009): fails on any platform/compiler that fuses a*b + c into an FMA,
// which would make results differ between machines. Runs for both precisions in every build.
#include <cengine/core/config.hpp>

#include <catch2/catch_template_test_macros.hpp>
#include <catch2/catch_test_macros.hpp>

#include <bit>
#include <cmath>
#include <cstdint>
#include <limits>

namespace {

template <typename T>
auto bits(T value) {
    if constexpr (sizeof(T) == sizeof(std::uint32_t)) {
        return std::bit_cast<std::uint32_t>(value);
    } else {
        return std::bit_cast<std::uint64_t>(value);
    }
}

// Read through a volatile so the compiler cannot constant-fold the expression away.
template <typename T>
T square_minus_one(T x) {
    volatile T input = x;
    const T a = input;
    return a * a - T{1};
}

} // namespace

TEMPLATE_TEST_CASE("a*a - 1 is rounded twice, never fused into an FMA", "[core][determinism]",
                   float, double) {
    using T = TestType;
    // x = 1 + 2^-k. Exactly: x*x - 1 = 2^(1-k) + 2^-2k. The 2^-2k term is below half an ulp of
    // x*x, so a correctly rounded multiply drops it; a fused multiply-add keeps it.
    constexpr int k = (std::numeric_limits<T>::digits / 2) + 4;
    const T x = T{1} + std::ldexp(T{1}, -k);
    const T expected = std::ldexp(T{1}, 1 - k);

    // Sanity: the probe really distinguishes the two behaviours.
    REQUIRE(bits(std::fma(x, x, T{-1})) != bits(expected));

    CHECK(bits(square_minus_one(x)) == bits(expected));
}

TEMPLATE_TEST_CASE("sqrt is correctly rounded", "[core][determinism]", float, double) {
    using T = TestType;
    volatile T two = T{2};
    const T root = std::sqrt(static_cast<T>(two));
    // sqrt(2) correctly rounded: the IEEE 754 value every conforming platform must produce.
    if constexpr (sizeof(T) == sizeof(std::uint32_t)) {
        CHECK(bits(root) == std::uint32_t{0x3FB504F3U});
    } else {
        CHECK(bits(root) == std::uint64_t{0x3FF6A09E667F3BCDULL});
    }
}
