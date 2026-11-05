#include <cengine/core/assert.hpp>

#include <atomic>
#include <cstdlib>
#include <iostream>

namespace cengine::core {

namespace {

// Process-wide handler; nullptr means "default". Atomic so tests/threads can swap it safely.
// NOLINTNEXTLINE(cppcoreguidelines-avoid-non-const-global-variables): intentional global hook.
std::atomic<assert_handler> g_assert_handler{nullptr};

} // namespace

void default_assert_handler(const assertion_info& info) noexcept {
    std::cerr << "cengine: assertion failed: " << info.expression << '\n'
              << "  message:  " << info.message << '\n'
              << "  location: " << info.location.file_name() << ':' << info.location.line()
              << " in " << info.location.function_name() << '\n';
    std::cerr.flush();
    std::abort();
}

assert_handler set_assert_handler(assert_handler handler) noexcept {
    const assert_handler previous = g_assert_handler.exchange(handler);
    return previous != nullptr ? previous : &default_assert_handler;
}

assert_handler get_assert_handler() noexcept {
    const assert_handler current = g_assert_handler.load();
    return current != nullptr ? current : &default_assert_handler;
}

void report_assertion_failure(const assertion_info& info) {
    get_assert_handler()(info);
    std::abort(); // a handler must not return
}

} // namespace cengine::core
