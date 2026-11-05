#pragma once

/// @file
/// @brief `CENGINE_ASSERT` / `CENGINE_ASSERT_SLOW` and the replaceable failure handler (ADR 0010).
///
/// @code
/// CENGINE_ASSERT(mass > real{0}, "bodies must have a positive mass");
/// @endcode
///
/// Asserts are on when `NDEBUG` isn't defined. In Release they compile to nothing, and the
/// condition isn't evaluated, so never put side effects in it.

#include <cengine/core/export.hpp>

#include <source_location>
#include <string_view>

namespace cengine::core {

/// @brief What a failed assertion reports to the handler.
struct assertion_info {
    std::string_view expression;   ///< The asserted condition, as written.
    std::string_view message;      ///< Why the condition must hold.
    std::source_location location; ///< Where the assertion is written.
};

/// @brief Called when an assertion fails. It must not return; it may throw (as tests do).
using assert_handler = void (*)(const assertion_info& info);

/// @brief Prints the failure to `stderr`, then calls `std::abort()`.
/// @param info The failed assertion.
[[noreturn]] CENGINE_CORE_EXPORT void default_assert_handler(const assertion_info& info) noexcept;

/// @brief Installs the assertion failure handler for the whole process (thread-safe).
/// @param handler The new handler, or `nullptr` to restore default_assert_handler.
/// @return The previously installed handler (never `nullptr`).
CENGINE_CORE_EXPORT assert_handler set_assert_handler(assert_handler handler) noexcept;

/// @brief The handler currently installed.
/// @return The current handler (never `nullptr`).
[[nodiscard]] CENGINE_CORE_EXPORT assert_handler get_assert_handler() noexcept;

/// @brief Invokes the current handler. If the handler returns, aborts the program.
/// @param info The failed assertion.
[[noreturn]] CENGINE_CORE_EXPORT void report_assertion_failure(const assertion_info& info);

} // namespace cengine::core

/// @def CENGINE_ENABLE_ASSERTS
/// @brief 1 to compile assertions in, 0 to compile them out. Defaults to 1 unless `NDEBUG` is
/// defined. Define it on the command line to override.
#if !defined(CENGINE_ENABLE_ASSERTS)
#if defined(NDEBUG)
#define CENGINE_ENABLE_ASSERTS 0
#else
#define CENGINE_ENABLE_ASSERTS 1
#endif
#endif

/// @def CENGINE_ENABLE_SLOW_ASSERTS
/// @brief 1 to also compile CENGINE_ASSERT_SLOW in (only when CENGINE_ENABLE_ASSERTS is 1).
/// Defaults to 0.
#if !defined(CENGINE_ENABLE_SLOW_ASSERTS)
#define CENGINE_ENABLE_SLOW_ASSERTS 0
#endif

/// @cond CENGINE_INTERNAL
// NOLINTBEGIN(cppcoreguidelines-macro-usage): stringizing and compiling out need macros.
#define CENGINE_DETAIL_ASSERT_CHECK(condition, message)                                            \
    (static_cast<bool>(condition)                                                                  \
         ? static_cast<void>(0)                                                                    \
         : ::cengine::core::report_assertion_failure(::cengine::core::assertion_info{              \
               #condition, (message), std::source_location::current()}))

// Unevaluated: no code, no side effects, but variables used only in asserts stay "used".
#define CENGINE_DETAIL_ASSERT_SKIP(condition, message)                                             \
    static_cast<void>(sizeof(static_cast<bool>(condition)))

#if CENGINE_ENABLE_ASSERTS
#define CENGINE_DETAIL_ASSERT(condition, message) CENGINE_DETAIL_ASSERT_CHECK(condition, message)
#else
#define CENGINE_DETAIL_ASSERT(condition, message) CENGINE_DETAIL_ASSERT_SKIP(condition, message)
#endif

#if CENGINE_ENABLE_ASSERTS && CENGINE_ENABLE_SLOW_ASSERTS
#define CENGINE_DETAIL_ASSERT_SLOW(condition, message)                                             \
    CENGINE_DETAIL_ASSERT_CHECK(condition, message)
#else
#define CENGINE_DETAIL_ASSERT_SLOW(condition, message)                                             \
    CENGINE_DETAIL_ASSERT_SKIP(condition, message)
#endif
// NOLINTEND(cppcoreguidelines-macro-usage)
/// @endcond

/// @brief Checks an invariant: calls the assertion handler if @p condition is false.
/// Compiled out (and @p condition not evaluated) when CENGINE_ENABLE_ASSERTS is 0.
/// Usable in `constexpr` functions.
/// @param condition Expression that must be true.
/// @param message Short explanation of the invariant (string literal).
#define CENGINE_ASSERT(condition, message) CENGINE_DETAIL_ASSERT(condition, message)

/// @brief Like CENGINE_ASSERT, for expensive checks. Active only when both
/// CENGINE_ENABLE_ASSERTS and CENGINE_ENABLE_SLOW_ASSERTS are 1.
/// @param condition Expression that must be true.
/// @param message Short explanation of the invariant (string literal).
#define CENGINE_ASSERT_SLOW(condition, message) CENGINE_DETAIL_ASSERT_SLOW(condition, message)
