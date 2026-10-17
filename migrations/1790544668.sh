echo "Add Ctrl+Shift clipboard chords to existing Foot configs"

# Hyprland's universal Super+C/V for terminals injects Ctrl+Shift+C/V since
# 129c67e2. Packaged Foot templates already accept both the old Insert chords
# and the new ones, but upgraded installs that kept only Control+Insert /
# Shift+Insert let Super+C reach the foreground as an interrupt (issue #13349).

foot_config="$HOME/.config/foot/foot.ini"
[[ -f $foot_config ]] || exit 0

ensure_keybinding() {
  local key="$1"
  local required="$2"
  local line

  line=$(grep -E "^${key}=" "$foot_config" || true)
  [[ -n $line ]] || return 0
  [[ $line == *"$required"* ]] && return 0

  KEY="$key" REQUIRED="$required" awk '
    BEGIN {
      key = ENVIRON["KEY"]
      required = ENVIRON["REQUIRED"]
      prefix = key "="
    }
    index($0, prefix) == 1 {
      rest = substr($0, length(prefix) + 1)
      $0 = prefix rest " " required
    }
    { print }
  ' "$foot_config" >"$foot_config.tmp"
  cat "$foot_config.tmp" >"$foot_config"
  rm -f "$foot_config.tmp"
}

ensure_keybinding clipboard-copy Control+Shift+c
ensure_keybinding clipboard-paste Control+Shift+v
