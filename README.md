# nvm-yarn-kit

Shared `bin/` scripts for Node projects. Each consuming project clones this
repository into its own root as `.nvm-yarn-kit` (and gitignores it), so every
project gets the same environment setup without copying scripts around.

The scripts make sure the project runs with the Node version pinned in
`.nvmrc` and the package manager pinned in `package.json`, regardless of what
is installed globally.

## What it does

Every script in [bin/](./bin) sources `_env.sh`, which:

1. Changes the working directory to the project root (the parent of
   `.nvm-yarn-kit/`).
2. Prepends `node_modules/.bin` to `PATH`, so local CLIs such as `tsx` can be
   invoked by name.
3. Loads [nvm](https://github.com/nvm-sh/nvm) from `$NVM_DIR` (default
   `~/.nvm`).
4. Switches to the Node version in `.nvmrc`. It tries the local-only
   `nvm use` first and only falls back to `nvm install` when that version is
   not installed yet, since `nvm install` always hits the network.
5. Enables [Corepack](https://nodejs.org/api/corepack.html) and activates the
   package manager from the `packageManager` field in `package.json`.

If nvm or Corepack is missing, a warning is printed and the system tools are
used instead.

## Scripts

| Script    | Description                                                    |
| --------- | -------------------------------------------------------------- |
| `_env.sh` | Shared setup, sourced by the other scripts. Not run directly.  |
| `exec`    | Installs dependencies, then runs the given command.            |
| `yarn`    | Runs `yarn` with the pinned Node and package manager.          |

`exec` runs `yarn install --immutable` before the command, so it fails if
`yarn.lock` is out of sync with `package.json`. Install output is only shown
when the install fails.

```sh
.nvm-yarn-kit/bin/exec tsx src/start.ts
.nvm-yarn-kit/bin/yarn add some-package
```

## Usage in a project

```sh
git clone <url-of-this-repo> .nvm-yarn-kit
echo '/.nvm-yarn-kit' >> .gitignore
```

The consuming project is expected to provide:

- `.nvmrc` (optional): the Node version to use.
- `package.json` with a `packageManager` field (optional): for example
  `"packageManager": "yarn@4.18.1"`.
- `yarn.lock`: required by `exec` for `yarn install --immutable`.

## Requirements

- bash
- [nvm](https://github.com/nvm-sh/nvm) (optional, recommended)
- Node with Corepack (optional, recommended)

## Conventions

- Scripts use `set -euo pipefail` and fit within 80 columns.
- Changes are recorded in [CHANGELOG.md](./CHANGELOG.md).
