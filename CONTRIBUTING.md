# Contributing to cengine

Thanks for helping! This page covers the branching model, PRs and releases. The build, test and
code conventions are in [CLAUDE.md](CLAUDE.md) and [docs/guides](docs/guides), and they apply to
humans too.

## Branching model: GitHub flow + tags

```
main ──●──●──●──●──●──●──●──►        always green, protected, PRs only
        \   /  \      /   ▲
         ●─●    ●────●    │ tag v0.2.0 = a release
   feature/x   bugfix/y   │
                          └─ release/0.2 ──●──►   (only if 0.2.x needs a patch while main moved on)
                                hotfix/z ─●┘        tag v0.2.1 on release/0.2
```

- **`main`** is the only long-lived branch. Every change reaches it through a pull request with green CI.
- **Topic branches** are short-lived and created from `main`: `<type>/<short-description>`.

  | Type | Use for |
  |---|---|
  | `feature/` | new behaviour |
  | `bugfix/` | fixing a bug on `main` |
  | `hotfix/` | urgent fix for a released version (targets `main` or `release/X.Y`) |
  | `perf/` | performance work with no behaviour change |
  | `refactor/` | restructuring with no behaviour change |
  | `test/` | tests only |
  | `docs/` | documentation only |
  | `ci/` | CI, workflows, repo tooling |
  | `chore/` | version bumps, dependency updates, housekeeping |

  The description is lowercase with digits and `-` `.` `_` allowed, for example `feature/sweep-and-prune` or
  `bugfix/nan-in-contact-solver`. Once an issue tracker exists, put the key first:
  `feature/ceng-42-sweep-and-prune`. The `branch-name` CI check enforces this.
- **Releases are tags** (`vX.Y.Z`) on `main`. There is no release branch for normal releases.
- **`release/X.Y`** maintenance branches are created from the `vX.Y.0` tag only when an older version
  needs a patch. They only accept `hotfix/*` and `bugfix/*` PRs.

## Pull requests

1. Branch from an up-to-date `main`: `git switch -c feature/<desc> origin/main`.
2. Work test-first (see [docs/guides/testing.md](docs/guides/testing.md)) and commit as often as you like.
3. Open a PR into `main` and fill in the template. **The PR title becomes the commit message on
   `main`**, so write it in the imperative ("Add sweep-and-prune broadphase").
4. Required to merge: every CI check green, the branch up to date with `main`, and all review
   threads resolved.
5. Merge with **Squash and merge**, the only merge method enabled. The branch is deleted automatically.

Keep PRs small and focused: one behaviour, one PR.

## Releasing

1. Open `chore/release-X.Y.Z`. Bump `project(VERSION X.Y.Z)` in the root `CMakeLists.txt` (it's the
   only place the version lives), then merge the PR.
2. Tag the merge commit and push the tag:
   ```bash
   git switch main && git pull
   git tag -a vX.Y.Z -m "cengine X.Y.Z"
   git push origin vX.Y.Z
   ```
3. `release.yml` checks that the tag matches the CMake version, runs the full CI, and publishes the
   packages to a GitHub Release.

Versions follow [SemVer](https://semver.org). Before 1.0.0, a minor bump may break the API.

### Patching an old release

```bash
git switch -c release/0.2 v0.2.0 && git push -u origin release/0.2   # once per line
git switch -c hotfix/<desc> release/0.2                              # fix + regression test
# PR hotfix/<desc> -> release/0.2 (bump to 0.2.1 in the same PR), merge, tag v0.2.1 on release/0.2
```

If the bug also exists on `main`, fix it there first and cherry-pick the fix into the hotfix branch
(`git cherry-pick -x <sha>`).

## Repository settings (maintainers)

The settings are kept as code in [`.github/rulesets/`](.github/rulesets) and applied with the GitHub CLI.
See [`.github/rulesets/README.md`](.github/rulesets/README.md).
