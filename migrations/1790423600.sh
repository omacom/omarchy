echo "Disable unprivileged TTY line-discipline autoload"

config=/etc/sysctl.d/99-omarchy-sysctl.conf
# A locally edited drop-in is kept by pacman and the new key lands in a
# .pacnew. Missing it must not fail the update. Warn and still try the
# runtime knob, which does not depend on that file being untouched.
if ! grep -Eq '^[[:space:]]*dev\.tty\.ldisc_autoload[[:space:]]*=[[:space:]]*0[[:space:]]*(#.*)?$' "$config" 2>/dev/null; then
  echo "Note: $config is locally modified; merge its .pacnew to keep dev.tty.ldisc_autoload=0 after reboot." >&2
fi

if [[ $(sysctl -n dev.tty.ldisc_autoload 2>/dev/null) != 0 ]]; then
  sudo sysctl -qw dev.tty.ldisc_autoload=0 ||
    echo "Could not apply dev.tty.ldisc_autoload=0 now; it applies at next boot." >&2
fi
