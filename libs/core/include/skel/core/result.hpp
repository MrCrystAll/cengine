#pragma once

/// @file
/// @brief Project-wide error type and `result<T>` alias (error-handling policy).
///
/// Recoverable failures are returned, never thrown:
/// @code
/// skel::core::result<config> load(std::string_view path);
/// @endcode
/// Exceptions are reserved for programming errors / truly exceptional states.

#include <expected>
#include <string>
#include <utility>

namespace skel::core {

/// @brief Category of a recoverable failure. Extend as modules need it.
enum class errc {
    unknown,          ///< Unspecified failure.
    invalid_argument, ///< Caller passed an invalid value.
    not_found,        ///< Requested entity does not exist.
    io,               ///< I/O failure.
};

/// @brief A recoverable error: a machine-readable code plus a human message.
struct error {
    errc code = errc::unknown; ///< What kind of failure happened.
    std::string message;       ///< Context for humans (logs, diagnostics).

    /// @brief Errors compare equal when their codes match (messages are informative only).
    [[nodiscard]] friend bool operator==(const error& lhs, const error& rhs) noexcept {
        return lhs.code == rhs.code;
    }
};

/// @brief Return type of every fallible operation.
template <typename T>
using result = std::expected<T, error>;

/// @brief Builds the unexpected branch of a result<T>.
/// @param code Failure category.
/// @param message Human readable context.
/// @return An object convertible to any result<T>.
[[nodiscard]] inline std::unexpected<error> make_error(errc code, std::string message = {}) {
    return std::unexpected<error>{error{code, std::move(message)}};
}

} // namespace skel::core
