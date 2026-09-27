# Changelog

## 0.3.0 — 2026-09-27
- Add `create --add-readme` so a new sandbox starts with a commit
- Add a `rename` command instead of delete-and-recreate
- Add `destroy --stale <days>` to sweep sandboxes idle for more than N
  days, with one confirmation listing everything it found
- Keep the test harness from inheriting `errexit` from the script under
  test, so a failing command fails the test instead of the suite

## 0.2.0 — 2026-09-27
- Add an offline test suite (runs against a gh stub, no network) and CI on
  ubuntu and macOS
- Add `list --json` for machine-readable output
- Add `create --clone` to clone the new sandbox afterwards
- Add an `open` command that browses a sandbox in your browser
- Validate repository names before calling the API
- Complete sandbox names for `open` and `destroy` in bash and zsh
- Add a Makefile with `install`, `test` and `check` targets

## 0.1.0 — 2026-09-27
- Initial release: `create`, `list`, `destroy` with a dry-run mode and a
  `sandbox-` name prefix so only sandboxes are ever listed or deleted
- bash and zsh completion
