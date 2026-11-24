echo "Drop the unknown BrowserColorScheme key from Chromium browser policies"

source "$OMARCHY_PATH/install/helpers/browser-policy.sh"

carries_key() {
  local dir
  for dir in "${BROWSER_POLICY_MANAGED_DIRS[@]}"; do
    if [[ -f $dir/color.json ]] && grep -Fq '"BrowserColorScheme"' "$dir/color.json"; then
      return 0
    fi
  done
  return 1
}

carries_key || exit 0

# The privileged wrapper always runs the packaged writer, even in a dev checkout.
if grep -Fq '"BrowserColorScheme"' /usr/bin/omarchy-theme-set-browser-policy; then
  echo "Waiting for the omarchy package whose browser policy writer drops BrowserColorScheme" >&2
  exit 75
fi

omarchy-theme-set-browser

if carries_key; then
  echo "A managed color.json still carries BrowserColorScheme" >&2
  exit 1
fi
