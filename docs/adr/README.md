# Architecture decision records {#adr_index}

Short, immutable notes explaining *why* a significant decision was taken.
New decision -> new file `NNNN-title.md` (copy `0000-template.md`); to change a decision, add a
new ADR that supersedes the old one and update the old one's status.

| # | Decision | Status |
|---|---|---|
| @ref adr_0001 "0001" | Monorepo of small modules built with CMake | Accepted |
| @ref adr_0002 "0002" | vcpkg (manifest mode) for third-party dependencies | Accepted |
| @ref adr_0003 "0003" | Catch2 v3 and test-driven development | Accepted |
| @ref adr_0004 "0004" | `std::expected` for recoverable errors | Accepted |
| @ref adr_0005 "0005" | Doxygen + doxygen-awesome-css for documentation | Accepted |
| @ref adr_0006 "0006" | C++23, snake_case, Windows/Linux/macOS | Accepted |
| @ref adr_0007 "0007" | GitHub flow + tags for branches and releases | Accepted |
| @ref adr_0008 "0008" | Configurable scalar precision, double by default | Accepted |
| @ref adr_0009 "0009" | Bit-identical floating-point results across platforms | Accepted |
| @ref adr_0010 "0010" | `CENGINE_ASSERT` for invariants | Accepted |
