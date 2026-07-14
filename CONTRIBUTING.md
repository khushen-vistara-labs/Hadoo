# Contributing

This repository enforces commit, pull request, and ownership rules through local hooks and GitHub Actions.

## Commit Messages

Commit messages must follow Conventional Commits:

```text
type(scope): short summary
```

Valid examples:

```text
feat(player): add source filter chips
fix(search): remove unused Pressable import
chore(ci): add PR checks and CODEOWNERS
```

Allowed types:

- `feat`
- `fix`
- `docs`
- `style`
- `refactor`
- `perf`
- `test`
- `build`
- `ci`
- `chore`
- `revert`

Local enforcement is provided by [`.husky/commit-msg`](/Users/icemonkey/code/Hadoo/.husky/commit-msg), which runs [`scripts/validate-commit-msg.js`](/Users/icemonkey/code/Hadoo/scripts/validate-commit-msg.js).

To enable the local Git hook path in a fresh clone:

```bash
git config core.hooksPath .husky
```

## Pull Request Requirements

PR titles must also follow Conventional Commits:

```text
type(scope): short summary
```

The PR body must use the required sections from [`.github/pull_request_template.md`](/Users/icemonkey/code/Hadoo/.github/pull_request_template.md):

- `## Summary`
- `## Changes`
- `## Testing`
- `## Screenshots`
- `## Checklist`

The checklist expects contributors to confirm:

- commit messages follow Conventional Commits
- the PR title follows Conventional Commits
- no unrelated changes are included

## Required Checks

PR validation runs in GitHub Actions:

- [`.github/workflows/pr-format.yml`](/Users/icemonkey/code/Hadoo/.github/workflows/pr-format.yml) validates the PR title and required body sections
- [`.github/workflows/pr-checks.yml`](/Users/icemonkey/code/Hadoo/.github/workflows/pr-checks.yml) runs `npm ci`, `npm run typecheck`, `npm run lint`, `npm test`, and `npx expo export --platform android`
- [`.github/workflows/reviewdog.yml`](/Users/icemonkey/code/Hadoo/.github/workflows/reviewdog.yml) publishes ESLint findings on pull requests

Before opening a PR, run:

```bash
npm run typecheck
npm run lint
npm test
```

If the change affects runtime behavior, also verify the app manually and include that in the PR body.

## Code Owners

Code owner review is defined in [`.github/CODEOWNERS`](/Users/icemonkey/code/Hadoo/.github/CODEOWNERS).

Current owners:

- `@khushen-vistara`
- `@harshithRai`
