# Contributing to Nestor

Thank you for helping. Each repository's `AGENTS.md` and `README.md` say how to set it up and run
its checks; this page holds what all repositories share.

## Pull requests

- `main` is protected: every change goes through a pull request, with the `ci` checks green.
- Pull requests are squash-merged. Their **title** becomes the commit, so it follows
  [Conventional Commits](https://www.conventionalcommits.org/):
  `feat: add a QR pairing method`, `fix: keep refused codes`, `docs: …`, `refactor: …`, `test: …`,
  `ci: …`, `chore: …`. A breaking change adds `!` (`feat!: …`) and explains it in the body.
- One pull request is one coherent change, with its tests and documentation.
- Tests check real behaviour, never a copy of the implementation or of another repository.

## Releases

Nobody tags by hand. release-please keeps a release pull request open on each repository, with the
next version (from the commit types) and the changelog. Merging it publishes the release.
Before 1.0, `feat` and breaking changes raise the minor version, everything else the patch.

## Reporting

Questions, ideas and feedback: [Discussions](https://github.com/orgs/nestor-home/discussions).
Reproducible bugs: the repository's issues. Vulnerabilities: see [SECURITY.md](SECURITY.md).
