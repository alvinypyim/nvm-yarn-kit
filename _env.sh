# Shared setup sourced by scripts in bin/.
#
# Changes the working directory to the repository root, loads nvm and
# switches to the Node version pinned in .nvmrc, and activates the package
# manager pinned in package.json's "packageManager" field via Corepack. The
# sourcing script must already be running under `set -euo pipefail`. Not
# meant to be executed directly.

cd_to_repo_root() {
  local bin_dir
  bin_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "$bin_dir/.."
}

# Mirrors what `yarn run`/`npm run` do for their child processes, so locally
# installed CLIs (e.g. tsx) can be invoked by name instead of their full
# node_modules/.bin path. Prepended unconditionally (even if the directory
# doesn't exist yet) since bash resolves PATH entries at lookup time, so this
# still works if dependencies are installed later in the same script.
add_local_bin_to_path() {
  export PATH="$PWD/node_modules/.bin:$PATH"
}

# nvm.sh, and some nvm subcommands, reference unset variables internally, so
# run them with `set -u` relaxed instead of weakening strict mode for the
# rest of the script.
run_with_unbound_vars_allowed() {
  local exit_code
  set +u
  "$@"
  exit_code=$?
  set -u
  return "$exit_code"
}

load_nvm() {
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  [ -s "$NVM_DIR/nvm.sh" ] || return 0
  # shellcheck source=/dev/null
  run_with_unbound_vars_allowed . "$NVM_DIR/nvm.sh"
}

use_pinned_node_version() {
  if ! command -v nvm >/dev/null 2>&1; then
    echo "Warning: nvm not found (expected at \$NVM_DIR=$NVM_DIR); using system node $(node -v)" >&2
    return
  fi

  [ -f .nvmrc ] || return 0

  # `nvm install` always hits the network to resolve the version, even when
  # it's already installed, which is slow and has wildly variable latency.
  # Try the fast, local-only `nvm use` first, and only fall back to
  # `nvm install` when the pinned version genuinely isn't installed yet.
  run_with_unbound_vars_allowed nvm use >/dev/null 2>&1 && return 0

  nvm install >/dev/null 2>&1
  run_with_unbound_vars_allowed nvm use >/dev/null
}

read_pinned_package_manager() {
  [ -f package.json ] || return 0
  node -e "
    try {
      const pkg = require('./package.json');
      if (pkg.packageManager) process.stdout.write(pkg.packageManager);
    } catch (_) {}
  " 2>/dev/null || true
}

activate_pinned_package_manager() {
  if ! command -v corepack >/dev/null 2>&1; then
    echo "Warning: corepack not found; skipping packageManager activation from package.json" >&2
    return
  fi

  corepack enable >/dev/null 2>&1 || true

  local pm_spec
  pm_spec="$(read_pinned_package_manager)"
  [ -n "$pm_spec" ] || return 0

  local pm_name="${pm_spec%%@*}"
  command -v "$pm_name" >/dev/null 2>&1 || return 0

  "$pm_name" --version >/dev/null 2>&1 \
    || echo "Warning: failed to activate $pm_spec via Corepack" >&2
}

# Not called automatically below, since it's only meant for scripts (like
# bin/start) that run the app itself, not for bin/yarn, which forwards
# arbitrary yarn commands (including `install`) and shouldn't install twice.
#
# `--immutable` refuses to modify yarn.lock, failing instead if it's out of
# sync with package.json, so installs strictly adhere to what's committed.
# Output is captured and only shown if the install fails, since yarn writes
# both its routine progress and its failure diagnostics to stdout.
ensure_dependencies_installed() {
  local install_output
  if ! install_output="$(yarn install --immutable 2>&1)"; then
    echo "$install_output" >&2
    return 1
  fi
}

cd_to_repo_root
add_local_bin_to_path
load_nvm
use_pinned_node_version
activate_pinned_package_manager
