# The LIFEBOOK P727's built-in keyboard sits behind an active i8042 mux that
# leaves the AT Translated Set 2 device silent at the LUKS unlock prompt.
# Disabling multiplexing restores input before userspace (#13502).

if omarchy-hw-fujitsu-lifebook-p727; then
  echo "Detected Fujitsu LIFEBOOK P727; disabling i8042 multiplexing for disk unlock"

  mkdir -p /etc/limine-entry-tool.d
  cat > /etc/limine-entry-tool.d/lifebook-p727-i8042.conf <<'DROPIN'
# Built-in keyboard is silent at LUKS unlock while i8042 multiplexing is on
# (#13502). Keep multiplexing off so the AT Translated Set 2 device answers.
KERNEL_CMDLINE[default]+=" i8042.nomux"
DROPIN
fi
