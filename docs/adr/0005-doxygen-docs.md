# ADR 0005: Doxygen + doxygen-awesome-css for documentation {#adr_0005}

- **Status**: Accepted
- **Date**: 2026-11-05

## Context

We need API reference generated from code plus hand-written guides, in one place, without a
heavy toolchain. Alternatives: Sphinx + Breathe (two tools, Python deps), MkDocs + mkdoxy.

## Decision

Doxygen, driven from CMake (`doxygen_add_docs`, `SKEL_BUILD_DOCS`, preset `docs`), themed with
doxygen-awesome-css (fetched at configure time, pinned by tag). Guides and ADRs are Markdown
pages in `docs/`; each module's `README.md` becomes its page. CI fails on any Doxygen warning
and publishes to GitHub Pages.

## Consequences

- Every public declaration needs a `///` comment, or the docs build fails in CI.
- Markdown pages use Doxygen anchors `{#id}` and `@ref id` for cross links.
