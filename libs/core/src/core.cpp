#include <skel/core/core.hpp>
#include <skel/core/version.hpp>

namespace skel::core {

std::string_view linked_version() noexcept {
    return version_string;
}

} // namespace skel::core
