echo "Remove the files the 4.0 notification engine left behind"

# They hold old message content: its per-popup files, history and images.
# rm and find never follow a symlink they are given.
dir="$HOME/.local/state/omarchy/notifications"
legacy="$HOME/.local/state/omarchy/notifications.json"

# 4.0 kept Do Not Disturb on its own. It carries over unless the shell has
# already written quiet state of its own.
if [[ -f $legacy && ! -s $dir/quiet.json ]] && jq -e '.dnd == true' "$legacy" >/dev/null 2>&1; then
  mkdir -p "$dir"
  chmod 700 "$dir"
  rm -f "$dir/quiet.json"
  (umask 077 && printf '%s\n' '{"snoozes":{},"dnd":true,"silencedSince":0,"codesBypassQuiet":true}' >"$dir/quiet.json")
fi
rm -f "$legacy"

rm -rf "$dir/history" "$dir/images"
if [[ -d $dir ]]; then
  find "$dir/" -maxdepth 1 -type f -regex '.*/[0-9]+-[^/]+\.json' -delete
fi
