#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Run only in the disposable acceptance VM. Preserve machine overrides even
# when an assertion fails; never edit or re-apply the user's current theme.
override="$HOME/.config/omarchy/shell.toml"
backup=$(mktemp)
had_override=0
if [[ -e $override ]]; then
  cp "$override" "$backup"
  had_override=1
fi
cleanup() {
  for plugin in omarchy.audio omarchy.menu omarchy.clipboard omarchy.emojis omarchy.dev-gallery; do
    omarchy-shell shell hide "$plugin" >/dev/null 2>&1 || true
  done
  omarchy-shell lock hidePreview >/dev/null 2>&1 || true
  omarchy-shell osd close >/dev/null 2>&1 || true
  if (( had_override )); then cp "$backup" "$override"; else rm -f "$override"; fi
  rm -f "$backup"
}
trap cleanup EXIT

write_shadows() {
  local alpha="$1" section
  {
    for section in popups menu notifications tooltip polkit lock; do
      printf '[%s]\nshadow-color = "#000000"\nshadow-alpha = %s\nshadow-blur = 24\nshadow-spread = 2\nshadow-offset-x = -4\nshadow-offset-y = 8\n\n' "$section" "$alpha"
    done
  } >"$override"
  sleep 1
}

write_shadows 0
omarchy-shell shell summon omarchy.audio '{}' >/dev/null
wait_until "shadow baseline panel opens" 10 layer_present omarchy-keyboard-panel
# A mapped layer can still be at zero opacity during its 140 ms fade-in.
sleep 0.3
screenshot success-shadow-disabled
write_shadows 0.65
screenshot success-shadow-live-enabled
omarchy-shell shell hide omarchy.audio >/dev/null

for plugin in menu clipboard emojis; do
  omarchy-shell shell summon "omarchy.$plugin" '{}' >/dev/null
  wait_until "shadow $plugin opens" 10 layer_present "omarchy-$plugin"
  screenshot "success-shadow-$plugin"
  wtype -k Escape
  wait_until "shadow $plugin dismisses with Escape" 10 layer_absent "omarchy-$plugin"
done

omarchy-shell lock preview >/dev/null
wait_until "shadow lock preview opens without locking" 10 layer_present omarchy-lock-preview
screenshot success-shadow-lock
omarchy-shell lock hidePreview >/dev/null
wait_until "shadow lock preview closes" 10 layer_absent omarchy-lock-preview

omarchy-shell osd show '{"icon":"volume","value":65,"max":100,"duration":5000}' >/dev/null
wait_until "shadow OSD opens" 10 layer_present omarchy-osd
screenshot success-shadow-osd
omarchy-shell osd close >/dev/null

for section in surface-shadow panel-tool-tip dropdown searchable-dropdown; do
  omarchy-shell shell summon omarchy.dev-gallery "{\"section\":\"$section\"}" >/dev/null
  sleep 1
  if [[ $section == "dropdown" || $section == "searchable-dropdown" ]]; then
    wtype -k Return
    sleep 1
  fi
  screenshot "success-shadow-$section"
  omarchy-shell shell hide omarchy.dev-gallery >/dev/null
done

write_shadows 0
omarchy-shell shell summon omarchy.audio '{}' >/dev/null
wait_until "shadow disable keeps panel usable" 10 layer_present omarchy-keyboard-panel
sleep 0.3
screenshot success-shadow-live-disabled
pass "surface shadows enabled and disabled live; review captured edges and transparency"
