# ADR 0007: GitHub flow + tags for branches and releases {#adr_0007}

- **Status**: Accepted
- **Date**: 2026-11-05

## Context

We need a branching and release model for a public repository, maintained by one person for now
and possibly by more later. The options considered were git-flow (`develop` plus `release/*` merged into
`main`) and GitHub flow with tags. The project is test-driven with strict CI, so integration-branch
quality is already enforced by CI rather than by a separate stabilisation branch.

## Decision

- `main` is the single long-lived branch: protected, PRs only, all CI checks required, squash-merge only,
  linear history.
- Topic branches are named `<type>/<short-description>` (feature, bugfix, hotfix, perf, refactor, test,
  docs, ci, chore), which `pr-checks.yml` enforces.
- Releases are annotated tags `vX.Y.Z` on `main`, published by `release.yml`. The version lives only
  in `project(VERSION)`.
- `release/X.Y` maintenance branches are created from a tag only when an old version needs a patch.
- Repository settings live in `.github/rulesets/` and are applied with `gh`.

## Consequences

- One merge per change and no back-merges, and CI runs on one integration branch.
- `main` means "latest development", not "latest release". Consumers pin a tag.
- Reviews are optional (0 approvals) while the project has a single maintainer. When others
  start contributing, raise `required_approving_review_count` to 1 in the ruleset. CODEOWNERS
  is already in place.
