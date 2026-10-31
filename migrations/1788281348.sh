echo "Re-stage the active theme with packaged intro videos"

theme_name_path="$HOME/.local/state/omarchy/current/theme.name"

[[ -s $theme_name_path ]] || exit 0

theme_name=$(<"$theme_name_path")
[[ $theme_name =~ ^[[:alnum:]_][[:alnum:].+_-]*$ ]] || exit 0
[[ -d $OMARCHY_PATH/themes/$theme_name/backgrounds/intros ]] || exit 0

omarchy-theme-refresh

state_dir="$HOME/.local/state/omarchy"
marker="$state_dir/background-intro.session-id"
session_id=${OMARCHY_SESSION_ID:-${HYPRLAND_INSTANCE_SIGNATURE:-}}
if [[ -z $session_id ]]; then
  hypr_dir=$(find "${XDG_RUNTIME_DIR:-/run/user/$UID}/hypr" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -n 1 | cut -d' ' -f2- || true)
  session_id=${hypr_dir##*/}
fi
[[ -n $session_id ]] || exit 0
mkdir -p "$state_dir"
marker_staged=$(mktemp "$state_dir/.background-intro.session-id.XXXXXX")
trap 'rm -f "$marker_staged"' EXIT
printf '%s\n' "$session_id" >"$marker_staged"
mv -f "$marker_staged" "$marker"
trap - EXIT
