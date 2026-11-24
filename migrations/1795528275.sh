echo "Drop the unknown BrowserColorScheme key from Chromium browser policies"

# BrowserColorScheme was never a Chromium policy: chrome://policy reports the
# key as unknown whatever its value, and it never influenced the browser's
# colour scheme. The writers now emit BrowserThemeColor alone, and
# omarchy-theme-set-browser counts a file that still carries the key as stale,
# but it only runs on a theme change — so refresh such files once here and the
# error disappears on update instead of at the next theme switch.

policy_dirs=(
  /etc/chromium/policies/managed
  /etc/opt/chrome/policies/managed
  /etc/opt/edge/policies/managed
  /etc/brave/policies/managed
)

carries_key() {
  local dir
  for dir in "${policy_dirs[@]}"; do
    if [[ -f $dir/color.json ]] && grep -q '"BrowserColorScheme"' "$dir/color.json"; then
      return 0
    fi
  done
  return 1
}

carries_key || exit 0

omarchy-theme-set-browser

# A rewrite that did not take would otherwise be marked complete and never
# retried, leaving the unknown policy in the managed file.
if carries_key; then
  echo "A managed color.json still carries BrowserColorScheme" >&2
  exit 1
fi
