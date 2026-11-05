#include <skel/core/core.hpp>

#include <cstdlib>
#include <iostream>

int main() {
    std::cout << "skel-cli " << skel::core::linked_version() << '\n';
    return EXIT_SUCCESS;
}
