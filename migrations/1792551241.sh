echo "Restore native Chromium browser default controls (log out and back in to activate)"

flags_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
for flags_file in "$flags_dir"/{chromium,chrome,microsoft-edge-stable,brave,brave-origin}-flags.conf; do
  [[ -f $flags_file ]] || continue
  sed -i --follow-symlinks '/^--no-default-browser-check$/d' "$flags_file"
done

source "$OMARCHY_PATH/install/helpers/browser-policy.sh"
for dir in "${BROWSER_POLICY_MANAGED_DIRS[@]}"; do
  if browser_policy_dir_hardened "$dir" && browser_policy_parents_hardened "$dir" &&
    [[ $(jq '.DefaultBrowserSettingEnabled' "$dir/omarchy.json" 2>/dev/null) == "false" ]]; then
    policy_tmp=$(mktemp)
    if jq 'del(.DefaultBrowserSettingEnabled)' "$dir/omarchy.json" >"$policy_tmp"; then
      as_root install -m 644 -o root -g root -T "$policy_tmp" "$dir/omarchy.json"
    else
      rm -f "$policy_tmp"
      exit 1
    fi
    rm -f "$policy_tmp"
  fi
done
