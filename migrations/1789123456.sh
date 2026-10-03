# Move Apple Silicon top-bar widgets out from under the camera notch.
#
# The dynamic notch floor covers the cutout height, but center-anchored widgets
# still sit behind the camera housing. Empty the center and park those modules
# on the right so the cutout stays clear. Non-Apple machines are untouched;
# users who already cleared center keep their layout.

omarchy-hw-apple-silicon || exit 0

config="$HOME/.config/omarchy/shell.json"
[[ -f $config ]] || exit 0

if ! jq -e '(.bar.layout.center | length) > 0' "$config" >/dev/null 2>&1; then
  exit 0
fi

tmp=$(mktemp)
jq '
  .bar.centerAnchor = ""
  | .bar.layout.right = ((.bar.layout.center // []) + (.bar.layout.right // []))
  | .bar.layout.center = []
' "$config" >"$tmp" && mv "$tmp" "$config"
