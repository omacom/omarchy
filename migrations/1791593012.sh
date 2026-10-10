echo "Delete clipboard images no longer referenced by clipboard history"

image_dir="$HOME/.local/state/omarchy/clipboard-images"
history_path="$HOME/.local/state/omarchy/clipboard-history.json"

[[ -d $image_dir ]] || exit 0

referenced=$(mktemp)
trap 'rm -f "$referenced"' EXIT

# The clipboard now keeps as many history entries as it displays and deletes
# an image file as soon as its entry falls off, but every image copied before
# that change is still on disk. Anything here that the history no longer
# mentions is unreachable from the picker, so remove it. A missing history
# means nothing is referenced.
if [[ -r $history_path ]]; then
  jq -r '.. | objects | select(.type == "image") | .path // empty' "$history_path" 2>/dev/null | sort -u >"$referenced" || true
else
  : >"$referenced"
fi

removed=0
while IFS= read -r -d '' file; do
  if grep -Fxq "$file" "$referenced"; then
    continue
  else
    rm -f -- "$file"
    removed=$((removed + 1))
  fi
done < <(find "$image_dir" -maxdepth 1 -type f -print0)

echo "Removed $removed unreferenced clipboard image(s)"
