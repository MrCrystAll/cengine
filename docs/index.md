# cengine documentation {#mainpage}

Modular C++23 monorepo: a set of small, independently testable and installable
libraries ("modules") plus thin applications built on top of them.

## Start here

| Page | What it covers |
|---|---|
| @ref getting_started "Getting started" | Prerequisites, presets, build/test/install in 5 minutes |
| @ref architecture "Architecture" | Repository layout, module graph, module rules, dependency direction |
| @ref adding_a_module "Adding a module" | Step-by-step: new library, its tests, its docs |
| @ref testing "Testing (TDD)" | Red/green/refactor workflow, Catch2 conventions, internal tests, CTest labels |
| @ref benchmarking "Benchmarking" | nanobench benchmarks: running, comparing, writing |
| @ref dependencies "Dependencies" | vcpkg manifest, features, overlay ports, versioning |
| @ref install_and_package "Install and package" | `cmake --install`, CPack, consuming with `find_package` |
| @ref adr_index "Architecture decisions" | Why things are the way they are |

## Modules

| Module | Target | Description |
|---|---|---|
| @ref module_core "core" | `cengine::core` | Foundation types: version, `result<T>` / error policy |

API reference: see the **Namespaces** and **Files** sections in the sidebar.
