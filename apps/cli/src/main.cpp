#include <cengine/core/core.hpp>

#include <cstdlib>
#include <iostream>

int main() {
    std::cout << "cengine-cli " << cengine::core::linked_version() << '\n';
    return EXIT_SUCCESS;
}
