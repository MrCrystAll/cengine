# Repository settings as code

These are applied once with the [GitHub CLI](https://cli.github.com/) (`gh auth login` first). They
implement [CONTRIBUTING.md](../../CONTRIBUTING.md) and ADR 0007. Rulesets are enforced on
public repositories (private ones need GitHub Pro or Team).

| File | Protects |
|---|---|
| `main.json` | `main` and `release/**`: PRs only, squash-only, linear history, no force-push or deletion, all CI checks green and up to date |
| `release-tags.json` | `v*` tags: only admins can create them; nobody can move or delete them |

## Apply

Run from the repository root (Git Bash on Windows):

```bash
REPO=MrCrystAll/cengine

# Merge settings: squash only, PR title/body as the commit, delete merged branches
gh repo edit "$REPO" \
  --default-branch main \
  --enable-squash-merge --enable-merge-commit=false --enable-rebase-merge=false \
  --delete-branch-on-merge --enable-auto-merge
gh api -X PATCH "repos/$REPO" \
  -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY

# Rulesets
gh api -X POST "repos/$REPO/rulesets" --input .github/rulesets/main.json
gh api -X POST "repos/$REPO/rulesets" --input .github/rulesets/release-tags.json

# GitHub Pages from Actions (docs.yml)
gh api -X POST "repos/$REPO/pages" -f build_type=workflow
```

To update a ruleset later, find its id with `gh api repos/$REPO/rulesets` and run
`gh api -X PUT repos/$REPO/rulesets/<id> --input <file>`.

## Notes

- **Required check names** are the CI job names (`windows-msvc`, `linux-gcc`, `clang-tidy`,
  `branch-name`, ...). If you rename a job in a workflow, update `main.json` too, or PRs will wait
  forever for a check that never reports.
- Required checks only show up in GitHub after they have run once, so push a first PR soon after
  applying the rulesets.
- **More contributors**: set `required_approving_review_count` to `1` (and optionally
  `require_code_owner_review` to `true`) in `main.json`, then `PUT` it. `.github/CODEOWNERS` decides who
  is asked to review.
