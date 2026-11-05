#include <skel/core/core.hpp>
#include <skel/core/result.hpp>
#include <skel/core/version.hpp>

#include <cstdlib>
#include <iostream>
#include <string_view>

int main() {
    const skel::core::result<int> ok = 1;
    if (!ok || skel::core::linked_version() != std::string_view{skel::core::version_string}) {
        std::cerr << "skel package consumer: unexpected result\n";
        return EXIT_FAILURE;
    }
    std::cout << "consumer linked against skel " << skel::core::linked_version() << '\n';
    return EXIT_SUCCESS;
}
