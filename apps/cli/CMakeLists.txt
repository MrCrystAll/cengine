cengine_add_executable(cli
  SOURCES src/main.cpp
  DEPS    cengine::core
)

if(CENGINE_BUILD_TESTS)
  # Smoke test: the installed-style binary starts and reports the version.
  add_test(NAME cli.smoke.version COMMAND cengine_cli)
  set_tests_properties(cli.smoke.version PROPERTIES
    PASS_REGULAR_EXPRESSION "cengine-cli ${PROJECT_VERSION}"
    LABELS "cli;smoke")
endif()
