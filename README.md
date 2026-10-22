# nvm-yarn-kit

Bash scripts that run a Node project with the Node version from `.nvmrc` and
the package manager from `package.json`. See [example/](example).

- `bin/yarn` runs `yarn`.
- `bin/exec` runs `yarn install --immutable`, then the given command.
