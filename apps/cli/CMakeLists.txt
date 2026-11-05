skel_add_executable(cli
  SOURCES src/main.cpp
  DEPS    skel::core
)

if(SKEL_BUILD_TESTS)
  # Smoke test: the installed-style binary starts and reports the version.
  add_test(NAME cli.smoke.version COMMAND skel_cli)
  set_tests_properties(cli.smoke.version PROPERTIES
    PASS_REGULAR_EXPRESSION "skel-cli ${PROJECT_VERSION}"
    LABELS "cli;smoke")
endif()
