echo "Load Omarchy's shell setup on Apple Silicon"

# omarchy-settings skipped every etc-override on Apple Silicon, including the
# /etc/skel/.bashrc that sources default/bash/rc, so Mac accounts were created
# with Arch's stock ~/.bashrc and none of Omarchy's aliases, functions or env.
if ! omarchy-hw-aarch64-apple; then
  exit 0
fi

bashrc="$HOME/.bashrc"

# A bashrc that already loads Omarchy's, or one kept in a dotfiles repo, is the
# user's own to keep.
if [[ -L $bashrc ]] || { [[ -f $bashrc ]] && grep -q 'default/bash/rc' "$bashrc"; }; then
  exit 0
fi

if [[ -f $bashrc ]]; then
  cp -a "$bashrc" "$bashrc.bak"
  echo "Your previous ~/.bashrc is saved as ~/.bashrc.bak"
fi

cp -f "$OMARCHY_PATH/default/bashrc" "$bashrc"
