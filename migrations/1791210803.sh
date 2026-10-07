echo "Keep Ctrl+Space for tmux and herdr once a second input method is added"

# fcitx5 switches input methods on Ctrl+Space unless its config says otherwise,
# and it never writes that config on its own. Seed Omarchy's trigger keys only
# for users who have no config yet and a single input method, where the trigger
# does nothing today, so nobody's current switching key changes under them.
config="$HOME/.config/fcitx5/config"
profile="$HOME/.config/fcitx5/profile"

if [[ -e $config || -L $config ]]; then
  exit 0
fi

if [[ -f $profile ]] && grep -Eq '^[[:space:]]*\[Groups/[0-9]+/Items/[1-9][0-9]*\][[:space:]]*$' "$profile"; then
  exit 0
fi

mkdir -p "$(dirname "$config")"
cp "$OMARCHY_PATH/config/fcitx5/config" "$config"

# A running fcitx5 keeps its old keys in memory, and fcitx5-configtool would
# write those back over this file; reload so both agree. If that fails, take
# the file back out so the retry starts over instead of skipping the reload.
if fcitx5-remote --check >/dev/null 2>&1 && ! fcitx5-remote -r; then
  rm -f "$config"
  echo "Could not reload fcitx5; run omarchy-migrate again from your desktop session." >&2
  exit 1
fi
