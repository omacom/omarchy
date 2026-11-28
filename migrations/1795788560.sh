echo "Enable browser Memory Saver on 8 GiB machines"

source "$OMARCHY_PATH/install/helpers/browser-policy.sh"

browser_policy_low_memory || exit 0

low_memory_policy="$OMARCHY_PATH/default/chromium/policies/omarchy-low-memory.json"

for dir in "${BROWSER_POLICY_MANAGED_DIRS[@]}"; do
  browser_policy_dir_hardened "$dir" && browser_policy_parents_hardened "$dir" || continue
  cmp -s "$low_memory_policy" "$dir/omarchy-low-memory.json" 2>/dev/null && continue

  as_root install -m 644 -o root -g root -T "$low_memory_policy" "$dir/omarchy-low-memory.json"
done
