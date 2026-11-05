#include <cengine/core/assert.hpp>
#include <cengine/core/config.hpp>
#include <cengine/core/core.hpp>
#include <cengine/core/result.hpp>
#include <cengine/core/version.hpp>

#include <cstdlib>
#include <iostream>
#include <string_view>
#include <type_traits>

// The installed config.hpp must agree with what the CMake package reports.
static_assert(cengine::double_precision == (CONSUMER_EXPECT_DOUBLE != 0));
static_assert(std::is_floating_point_v<cengine::real>);

int main() {
    const cengine::core::result<int> ok = 1;
    CENGINE_ASSERT(ok.has_value(), "installed assert.hpp is usable");
    if (!ok || cengine::core::linked_version() != std::string_view{cengine::core::version_string}) {
        std::cerr << "cengine package consumer: unexpected result\n";
        return EXIT_FAILURE;
    }
    std::cout << "consumer linked against cengine " << cengine::core::linked_version()
              << " (real is " << (cengine::double_precision ? "double" : "float") << ")\n";
    return EXIT_SUCCESS;
}
