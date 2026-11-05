#include <cengine/core/core.hpp>
#include <cengine/core/result.hpp>
#include <cengine/core/version.hpp>

#include <cstdlib>
#include <iostream>
#include <string_view>

int main() {
    const cengine::core::result<int> ok = 1;
    if (!ok || cengine::core::linked_version() != std::string_view{cengine::core::version_string}) {
        std::cerr << "cengine package consumer: unexpected result\n";
        return EXIT_FAILURE;
    }
    std::cout << "consumer linked against cengine " << cengine::core::linked_version() << '\n';
    return EXIT_SUCCESS;
}
