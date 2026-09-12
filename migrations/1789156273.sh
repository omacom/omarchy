echo "Move the default OpenCode CLI installation to the V2 npm distribution"

[[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]] || exit 0

wrapper="$HOME/.local/bin/opencode"
# Earlier wrapper migrations normalize older stock launchers to this form.
# Compare the whole file so symlinks and hand-edited launchers remain intact.
if [[ -e $wrapper || -L $wrapper ]]; then
  [[ -f $wrapper && ! -L $wrapper ]] || exit 0
  (($(stat -c%s "$wrapper") <= 1024)) || exit 0
  stock=$(printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet "opencode" || exit 1\nexec mise x "opencode" -- "opencode" "$@"')
  [[ $(<"$wrapper") == "$stock" ]] || exit 0
fi

config="${MISE_GLOBAL_CONFIG_FILE:-${MISE_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/mise}/config.toml}"
action=$(python - "$config" <<'PY'
import pathlib
import sys
import tomllib

path = pathlib.Path(sys.argv[1])
data = tomllib.loads(path.read_text()) if path.exists() else {}
tools = data.get("tools", {})
old = tools.get("opencode")
new = tools.get("npm:@opencode/cli")
# Explicit pins, alternate backends, aliases and beta setups belong to the user.
custom = (
    old not in (None, "latest")
    or "opencode" in data.get("alias", {})
    or any("opencode" in key and key not in ("opencode", "npm:@opencode/cli") for key in tools)
    or new not in (None, "latest", {"version": "latest", "allow_builds": "@opencode/cli"})
)
print("skip" if custom else "migrate" if old == "latest" else "lazy")
PY
)

if [[ $action == "skip" ]]; then
  echo "Keeping the customized OpenCode mise configuration"
  exit 0
fi

if [[ $action == "migrate" ]]; then
  # Install successfully before removing the old request. Leave its executable
  # on disk for running sessions and rollback; never use OpenCode's uninstaller.
  MISE_MINIMUM_RELEASE_AGE=0 mise use --path "$config" --fuzzy "npm:@opencode/cli[allow_builds=@opencode/cli]@latest"
  mise unuse --path "$config" --no-prune opencode
fi

# Unused preinstalls stay lazy. On failure above the old wrapper stays usable,
# and the migration runner leaves this migration pending for a retry.
omarchy-mise-install "npm:@opencode/cli[allow_builds=@opencode/cli]" opencode
