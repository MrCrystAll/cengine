#pragma once

// Test helpers for CENGINE_ASSERT: a handler that throws, so tests can observe failures.

#include <cengine/core/assert.hpp>

#include <cstdint>
#include <string>

namespace cengine::core::testing {

/// Thrown by throwing_handler; carries what the assert reported.
struct assertion_failure {
    std::string expression;
    std::string message;
    std::uint_least32_t line = 0;
};

[[noreturn]] inline void throwing_handler(const assertion_info& info) {
    throw assertion_failure{std::string{info.expression}, std::string{info.message},
                            info.location.line()};
}

/// Installs a handler for the lifetime of the object, then restores the previous one.
class scoped_assert_handler {
public:
    explicit scoped_assert_handler(assert_handler handler)
        : previous_{set_assert_handler(handler)} {}

    ~scoped_assert_handler() { set_assert_handler(previous_); }

    scoped_assert_handler(const scoped_assert_handler&) = delete;
    scoped_assert_handler& operator=(const scoped_assert_handler&) = delete;
    scoped_assert_handler(scoped_assert_handler&&) = delete;
    scoped_assert_handler& operator=(scoped_assert_handler&&) = delete;

private:
    assert_handler previous_;
};

} // namespace cengine::core::testing
