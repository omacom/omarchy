echo "Stop browsers asking to be the default behind Omarchy's link routing"

for flags_file in "$HOME"/.config/{chromium,chrome,microsoft-edge-stable,brave,brave-origin}-flags.conf; do
  [[ -f $flags_file ]] || continue
  grep -qxF -- '--no-default-browser-check' "$flags_file" && continue

  [[ -n $(tail -c1 "$flags_file") ]] && echo >>"$flags_file"
  echo '--no-default-browser-check' >>"$flags_file"
done

source "$OMARCHY_PATH/install/helpers/browser-policy.sh"

for dir in "${BROWSER_POLICY_FIREFOX_DIRS[@]}"; do
  if browser_policy_firefox_hardened "$dir"; then
    browser_policy_firefox_skip_default_check "$dir"
  fi
done

for dir in "${BROWSER_POLICY_MANAGED_DIRS[@]}"; do
  if browser_policy_dir_hardened "$dir" && browser_policy_parents_hardened "$dir"; then
    browser_policy_install_defaults "$dir"
  fi
done
