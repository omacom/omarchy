echo "Turn off herdr's own update check, since pacman updates herdr"

config="$HOME/.config/herdr/config.toml"

[[ -f $config ]] || exit 0

# Dotfile managers may own the file or a parent directory through a symlink.
# Preserve that layout rather than detaching or editing its target.
path="$config"
while [[ $path != "$HOME" && $path != / ]]; do
  if [[ -L $path ]]; then
    echo "Preserving symlink-managed herdr config: $config"
    exit 0
  fi
  path=$(dirname "$path")
done

# Read the config as TOML, not as text, so quoted keys and strings can't fool
# the check. A user who set anything under update made their own choice, and a
# config herdr can't parse is theirs to fix, so both are left alone.
state=$(python3 - "$config" <<'PY'
import sys
import tomllib

try:
    with open(sys.argv[1], "rb") as config:
        print("set" if "update" in tomllib.load(config) else "unset")
except (OSError, UnicodeDecodeError, tomllib.TOMLDecodeError):
    print("unreadable")
PY
)

if [[ $state == "unset" ]]; then
  printf '\n[update]\nversion_check = false\n' >>"$config"

  # The file now holds the setting, and a server started later reads it. A
  # running server only needs a reload, so a failed reload is not a failed
  # migration.
  omarchy-restart-herdr || true
fi
