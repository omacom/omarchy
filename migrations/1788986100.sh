echo "Patch cloned panel plugins that wrote centerHoverRevealSuppressed directly"

# When PluginBarApi made centerHoverRevealSuppressed readonly (4.0.3), any
# panel plugin cloned before that change kept the old pattern:
#
#   if (root.bar && "centerHoverRevealSuppressed" in root.bar)
#     root.bar.centerHoverRevealSuppressed = value
#
# which now fires a TypeError on every open/close, spamming the Quickshell log
# and stalling the event loop.  Panel.qml base now owns the correct
# setCenterHoverRevealSuppressed() implementation, so clones that still carry a
# local copy of the broken pattern just need it stripped out to inherit from base.
#
# We only touch files that have the broken assignment and belong to a plugin
# cloned from omarchy.clock or omarchy.weather (the only first-party panels
# that use this call).  Any plugin that already has the right form, or that has
# a genuinely different local override, is left alone.

PLUGINS_DIR="$HOME/.config/omarchy/plugins"

[[ -d $PLUGINS_DIR ]] || exit 0

broken_pattern='(root\.)?bar\.centerHoverRevealSuppressed[[:space:]]*='
patched=0

while IFS= read -r -d '' manifest; do
  plugin_dir="$(dirname "$manifest")"

  # Only process clones of clock or weather panels
  cloned_from="$(jq -r '.omarchy.clonedFrom // empty' "$manifest" 2>/dev/null)"
  [[ $cloned_from == "omarchy.clock" || $cloned_from == "omarchy.weather" ]] || continue

  # Find QML files that still contain the broken assignment
  while IFS= read -r -d '' qml_file; do
    # Confirm the file has the old pattern but NOT the new function-check form
    if grep -qE "$broken_pattern" "$qml_file" && \
       ! grep -q 'typeof root\.bar\.setCenterHoverRevealSuppressed' "$qml_file" && \
       ! grep -q 'typeof bar\.setCenterHoverRevealSuppressed' "$qml_file"; then

      backup=$(mktemp "${qml_file}.bak.XXXXXX")
      cp -p "$qml_file" "$backup"

      # Remove the local function block and any directly preceding comment lines
      # using recursive balanced braces to safely handle nested blocks.
      perl -0777 -i -pe '
        s{(?:\n[ \t]*//[^\n]*)*\n[ \t]*function\s+setCenterHoverRevealSuppressed\s*\([^)]*\)\s*(\{ (?: [^{}]+ | (?1) )* \})}{}gx;
      ' "$qml_file"

      # Sanity check: confirm the broken assignment was eliminated
      if grep -qE "$broken_pattern" "$qml_file"; then
        echo "  Warning: could not cleanly remove local override from $qml_file; restoring backup." >&2
        cp -p "$backup" "$qml_file"
      else
        echo "  Patched: $qml_file (backup: $backup)"
        (( patched++ )) || true
      fi
    fi
  done < <(find "$plugin_dir" -name "*.qml" -print0)

done < <(find "$PLUGINS_DIR" -maxdepth 2 -name "manifest.json" -print0)

if (( patched > 0 )); then
  echo "  Patched $patched file(s)."
else
  echo "  No cloned panel plugins needed patching."
fi

