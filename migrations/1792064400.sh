echo "Install workspace apps hook for existing users"

source_hook="$OMARCHY_PATH/config/omarchy/hooks/post-boot.d/workspace-apps"
target_hook="$HOME/.config/omarchy/hooks/post-boot.d/workspace-apps"

[[ -f "$source_hook" ]] || exit 0
[[ -e "$target_hook" ]] && exit 0

omarchy hook install post-boot "$source_hook"
