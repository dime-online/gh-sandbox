# gh-sandbox

[![CI](https://github.com/dime-online/gh-sandbox/actions/workflows/ci.yml/badge.svg)](https://github.com/dime-online/gh-sandbox/actions/workflows/ci.yml)

A [gh CLI](https://cli.github.com/) extension for disposable sandbox repositories.

`gh sandbox create ci-test` gives you a fresh private repo (`<you>/sandbox-ci-test`)
to break things in; `gh sandbox destroy ci-test` takes it away again. Handy when
you want to try a workflow, an Action, a branch protection rule or a webhook
without polluting your real projects.

## Install

    gh extension install dime-online/gh-sandbox

Requires [gh](https://cli.github.com/) (authenticated) and git.

## Usage

    gh sandbox create <name> [--public] [--clone] [--description <text>] [--template <repo>]
    gh sandbox list [--json]
    gh sandbox open <name>
    gh sandbox destroy <name> [--yes]

### Examples

    gh sandbox create actions-test
    gh sandbox create pages-demo --public --description "throwaway pages test"
    gh sandbox list
    gh sandbox destroy actions-test --yes

Add `-n` / `--dry-run` before the command to print what would run instead of
running it:

    gh sandbox -n create scratch

## Safety

A sandbox is just an ordinary repo whose name starts with `sandbox-`. `list`
and `destroy` match that prefix and nothing else, so the tool cannot delete a
repository that was not created as a sandbox. `destroy` asks for confirmation
unless you pass `--yes`.

Deleting needs the `delete_repo` scope:

    gh auth refresh -h github.com -s delete_repo

## Shell completion

For bash, source the completion file from `~/.bashrc`:

    source /path/to/gh-sandbox/completions/gh-sandbox.bash

For zsh, add the `completions` directory to your `fpath` (and run `compinit`):

    fpath=(/path/to/gh-sandbox/completions $fpath)

## Development

The test suite runs offline against a small gh stub:

    make test      # or: bash tests/run.sh
    make check     # syntax pass over the scripts

`make install` honours `PREFIX` (default `/usr/local`) and `DESTDIR`.
See [CHANGELOG.md](CHANGELOG.md) for release notes.

## License

MIT — see [LICENSE](LICENSE).
