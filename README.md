# nvm-yarn-kit

Shell scripts that run a Node project with the Node version from `.nvmrc`
and the package manager from `package.json`.

```sh
git clone <url-of-this-repo> .nvm-yarn-kit
echo '/.nvm-yarn-kit' >> .gitignore

.nvm-yarn-kit/bin/yarn add some-package
.nvm-yarn-kit/bin/exec tsx src/start.ts
```

- `bin/yarn` runs `yarn`.
- `bin/exec` runs `yarn install --immutable`, then the given command.

See [example/](example) for a minimal project that uses the kit
(`cd example && bin/exec node src/start.js`).

Requires bash. nvm and Corepack are optional.
