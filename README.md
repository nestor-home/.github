# nestor-home/.github

What every repository of the [nestor-home](https://github.com/nestor-home) organization shares.

| Path | What |
|---|---|
| `profile/README.md` | The organization's public page. |
| `CONTRIBUTING.md`, `SECURITY.md`, `PULL_REQUEST_TEMPLATE.md` | Defaults for every repository that has none. |
| `.github/workflows/release-please.yml` | Release pull request, tag and GitHub Release from Conventional Commits. |
| `.github/workflows/pr-title.yml` | Checks that a pull request title is a Conventional Commit. |
| `.github/workflows/container.yml` | Multi-platform image (amd64, arm64) pushed to GHCR, with provenance. |
| `.github/workflows/deploy.yml` | Deploys an image to the server, behind an approved environment. |
| `deploy/deploy.sh` | What `deploy.yml` runs on the server. |
| `settings/` | Repository settings and rulesets, applied with `settings/configure.sh`. |

Repositories call the workflows on `main`:

```yaml
jobs:
  release:
    uses: nestor-home/.github/.github/workflows/release-please.yml@main
    secrets: inherit
```

`main` is protected like every repository's: a change reaches all of them once merged, after
actionlint and shellcheck. A change to inputs or outputs updates every caller.

## How a repository releases

1. Pull requests are squash-merged; their title, a Conventional Commit, becomes the commit.
2. On `main`, release-please keeps a release pull request open with the next version and the
   changelog. Merging it creates the `vX.Y.Z` tag and the GitHub Release.
3. In the same run, the repository's `release.yml` publishes: PyPI, npm or crates.io through
   trusted publishing (no stored token), images on GHCR, and the site on the server.

release-please acts as the organization's GitHub App `nestor-home-release` (variable
`RELEASE_APP_ID`, secret `RELEASE_APP_PRIVATE_KEY`): its release pull requests run CI like any other,
and its tags trigger workflows. Callers pass `secrets: inherit`.

A repository's `release.yml` keeps its publish job itself: registries trust a workflow file of the
repository that publishes, not a reusable workflow.

## A new repository

1. Add `.github/workflows/ci.yml` ending with a job named `ci` that needs every other job,
   and `.github/workflows/pr-title.yml` calling the shared one.
2. Add `release-please-config.json`, `.release-please-manifest.json` and `release.yml`
   (copy them from a repository of the same language).
3. Register the trusted publisher on the registry (environment `pypi`, `npm` or `crates-io`).
4. Run `settings/configure.sh <repository>`.
