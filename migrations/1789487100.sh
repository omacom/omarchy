echo "Warn about customized legacy Hyprland config after Quattro upgrade"

# This migration is packaged with Quattro, but the legacy checkout needed for a
# trustworthy comparison only exists while the dedicated Quattro upgrader is
# running. Normal Quattro updates should stay quiet.
[[ ${OMARCHY_UPGRADE_TO_QUATTRO_LIVE:-0} == 1 ]] || exit 0

# The upgrader names its preserved legacy checkout with a sortable timestamp.
# On a retried upgrade there can be more than one backup, so use the newest one.
legacy_omarchy_backup=""
for candidate in "$HOME"/.local/share/omarchy.omarchy-upgrade-to-quattro.*.bak; do
  [[ -d $candidate ]] || continue
  legacy_omarchy_backup=$candidate
done
[[ -n $legacy_omarchy_backup ]] || exit 0

legacy_hypr_changes=()
for name in autostart bindings envs hyprland input looknfeel monitors; do
  user_conf="$HOME/.config/hypr/$name.conf"
  if [[ $name == envs ]]; then
    reference="$legacy_omarchy_backup/default/hypr/envs.conf"
  else
    reference="$legacy_omarchy_backup/config/hypr/$name.conf"
  fi

  # Stay conservative when the exact stock reference is unavailable. A
  # surviving .conf file alone does not prove the user customized it.
  [[ -f $user_conf && -f $reference ]] || continue
  cmp -s -- "$user_conf" "$reference" || legacy_hypr_changes+=("$name.conf")
done

(( ${#legacy_hypr_changes[@]} )) || exit 0

printf '\n\033[33mWarning:\033[0m legacy Hyprland config differs from the pre-upgrade Omarchy defaults:\n' >&2
printf '  %s\n' "${legacy_hypr_changes[@]}" >&2
printf 'These .conf files are kept for reference, but Quattro no longer loads them. Port wanted settings to the corresponding ~/.config/hypr/*.lua files.\n' >&2

legacy_hypr_list=$(printf '%s, ' "${legacy_hypr_changes[@]}")
legacy_hypr_list=${legacy_hypr_list%, }
warning_hook="$HOME/.config/omarchy/hooks/post-boot.d/quattro-legacy-hypr-config-warning"
mkdir -p "$(dirname "$warning_hook")"
cat >"$warning_hook" <<WARNING_HOOK
#!/bin/bash
set -euo pipefail

if omarchy-notification-send -u critical \
  "Legacy Hyprland settings need review" \
  "Quattro found non-stock legacy settings in: $legacy_hypr_list. The old .conf files are kept for reference but are no longer loaded; port wanted settings to ~/.config/hypr/*.lua."; then
  rm -f "\$0"
fi
WARNING_HOOK
chmod +x "$warning_hook"
