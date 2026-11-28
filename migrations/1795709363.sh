echo "Add Shure MV7+ microphone panel and hidraw udev rule"

rule_source="$OMARCHY_PATH/default/udev/shure-mv7plus.rules"
plugin_manifest="$OMARCHY_PATH/shell/plugins/panels/mv7plus/manifest.json"
if [[ ! -r $rule_source || ! -r $plugin_manifest ]]; then
  echo "Waiting for omarchy to ship the Shure MV7+ panel and udev rule"
  exit 75
fi

rule_target=/etc/udev/rules.d/62-shure-mv7plus.rules
if [[ ! -f $rule_target ]] || ! cmp -s "$rule_source" "$rule_target"; then
  sudo install -Dm644 "$rule_source" "$rule_target"
  sudo udevadm control --reload-rules 2>/dev/null || true
  sudo udevadm trigger --subsystem-match=hidraw 2>/dev/null || true
fi

# Best-effort rescan and placement, matching other first-party bar widgets.
omarchy-shell -q shell rescanPlugins 2>/dev/null || true

config_file="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/shell.json"
if [[ -s $config_file ]] && jq -e '(.disabledPlugins // []) | index("omarchy.mv7plus")' "$config_file" >/dev/null 2>&1; then
  echo "Shure MV7+ panel is disabled in shell.json; skipping bar placement"
  exit 0
fi

omarchy-bar put omarchy.mv7plus --before omarchy.audio
