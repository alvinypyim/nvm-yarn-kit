# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- `README.md` and `CHANGELOG.md`.

### Changed

- Extracted from the `ai-node` project into its own repository, preserving
  history.
- Wrapped warning messages in `_env.sh` to 80 columns.
- Moved `_env.sh`, `exec` and `yarn` into `bin/`. The kit is now cloned as
  `.nvm-yarn-kit` in the project root instead of being cloned as `bin/`, and
  scripts are run as `.nvm-yarn-kit/bin/exec`.
- `exec` validates its arguments before installing dependencies.

### Fixed

- `nvm install` now runs with `set -u` relaxed, like the other nvm calls.
- `run_with_unbound_vars_allowed` always restores `set -u`, even when the
  wrapped command fails.

## 2026-10-19

### Added

- nvm- and Corepack-aware `_env.sh` and `yarn` scripts.
- `exec`, a generic script that installs dependencies with
  `yarn install --immutable` and then runs the given command. It replaces
  the project-specific `start` script.
