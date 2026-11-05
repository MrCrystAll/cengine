#include <cengine/core/core.hpp>
#include <cengine/core/version.hpp>

namespace cengine::core {

std::string_view linked_version() noexcept {
    return version_string;
}

} // namespace cengine::core
