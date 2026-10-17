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

broken_assignment='root.bar.centerHoverRevealSuppressed = value'
patched=0

while IFS= read -r -d '' manifest; do
  plugin_dir="$(dirname "$manifest")"

  # Only process clones of clock or weather panels
  # A manifest jq cannot read is not a clone to patch, and must not abort the queue.
  cloned_from="$(jq -r '.omarchy.clonedFrom // empty' "$manifest" 2>/dev/null || true)"
  [[ $cloned_from == "omarchy.clock" || $cloned_from == "omarchy.weather" ]] || continue

  # Find QML files that still contain the broken assignment
  while IFS= read -r -d '' qml_file; do
    grep -qF "$broken_assignment" "$qml_file" || continue

    backup=$(mktemp "${qml_file}.bak.XXXXXX")
    cp -p "$qml_file" "$backup"

    # Remove only the stock 4.0.0-4.0.2 override and its directly preceding comment
    # lines; an override the user has edited is left exactly as it is.
    perl -0777 -i -pe '
      s{(?:\n[ \t]*//[^\n]*)*\n[ \t]*function setCenterHoverRevealSuppressed\(value\) \{\n[ \t]*if \(root\.bar && "centerHoverRevealSuppressed" in root\.bar\)\n[ \t]*root\.bar\.centerHoverRevealSuppressed = value\n[ \t]*\}(?=\n)}{}g;
    ' "$qml_file"

    if cmp -s "$backup" "$qml_file"; then
      rm -f "$backup"
    else
      echo "  Patched: $qml_file (backup: $backup)"
      (( patched++ )) || true
    fi
  done < <(find "$plugin_dir" -name "*.qml" -print0)

done < <(find "$PLUGINS_DIR" -maxdepth 2 -name "manifest.json" -print0)

if (( patched > 0 )); then
  echo "  Patched $patched file(s)."
else
  echo "  No cloned panel plugins needed patching."
fi

