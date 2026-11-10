echo "Disable browser promotional and welcome tabs"

default_policy="${OMARCHY_BROWSER_DEFAULT_POLICY:-$OMARCHY_PATH/default/chromium/policies/omarchy.json}"
[[ -f $default_policy ]] || default_policy="$(dirname "${BASH_SOURCE[0]}")/../default/chromium/policies/omarchy.json"

for dir in /etc/chromium/policies/managed /etc/opt/chrome/policies/managed /etc/opt/edge/policies/managed /etc/brave/policies/managed; do
  if [[ -f "$dir/omarchy.json" ]] && ! cmp -s "$default_policy" "$dir/omarchy.json"; then
    sudo install -m 644 -o root -g root -T "$default_policy" "$dir/omarchy.json"
  fi
done
