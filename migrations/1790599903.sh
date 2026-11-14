echo "Restore LIFEBOOK P727 keyboard at disk unlock"

if ! omarchy-hw-fujitsu-lifebook-p727; then
  exit 0
fi

dropin=/etc/limine-entry-tool.d/lifebook-p727-i8042.conf
rebuild_marker="${OMARCHY_LIFEBOOK_P727_REBUILD_MARKER:-/var/lib/omarchy/migrations/1790599903}"
if [[ ! -f $dropin ]]; then
  sudo mkdir -p /etc/limine-entry-tool.d
  sudo tee "$dropin" >/dev/null <<'DROPIN'
# Built-in keyboard is silent at LUKS unlock while i8042 multiplexing is on
# (#13502). Keep multiplexing off so the AT Translated Set 2 device answers.
KERNEL_CMDLINE[default]+=" i8042.nomux"
DROPIN
  sudo rm -f "$rebuild_marker"
fi

# The marker spares another user's migration a second rebuild, while a missing
# marker still retries one that failed or picks up a drop-in written since.
if omarchy-cmd-present limine-mkinitcpio && [[ ! -e $rebuild_marker ]]; then
  sudo limine-mkinitcpio
  sudo install -Dm644 /dev/null "$rebuild_marker"
fi
