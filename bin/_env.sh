cd_to_project_root() {
  local bin_dir
  bin_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "$bin_dir/../.."
}

add_local_bin_to_path() {
  export PATH="$PWD/node_modules/.bin:$PATH"
}

run_with_unbound_vars_allowed() {
  local exit_code=0
  set +u
  "$@" || exit_code=$?
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
    echo "Warning: nvm not found (expected at \$NVM_DIR=$NVM_DIR);" \
      "using system node $(node -v)" >&2
    return
  fi

  [ -f .nvmrc ] || return 0

  run_with_unbound_vars_allowed nvm use >/dev/null 2>&1 && return 0

  run_with_unbound_vars_allowed nvm install >/dev/null 2>&1
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
    echo "Warning: corepack not found;" \
      "skipping packageManager activation from package.json" >&2
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

ensure_dependencies_installed() {
  local install_output
  if ! install_output="$(yarn install --immutable 2>&1)"; then
    echo "$install_output" >&2
    return 1
  fi
}

cd_to_project_root
add_local_bin_to_path
load_nvm
use_pinned_node_version
activate_pinned_package_manager
