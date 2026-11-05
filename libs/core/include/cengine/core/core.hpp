#pragma once

/// @file
/// @brief Entry point of the core module.

#include <cengine/core/export.hpp>

#include <string_view>

/// @brief Root namespace of the project.
namespace cengine {}

/// @brief Core module: foundation types shared by every other module.
namespace cengine::core {

/// @brief Version of the core library the program is linked against.
///
/// Unlike cengine::core::version_string (a header constant), this is resolved at
/// link/run time, so it reports the binary actually loaded.
/// @return The version string, e.g. "0.1.0".
[[nodiscard]] CENGINE_CORE_EXPORT std::string_view linked_version() noexcept;

} // namespace cengine::core
