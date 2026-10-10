echo "Disable unprivileged TTY line-discipline autoload"

config=/etc/sysctl.d/99-omarchy-sysctl.conf
# Pacman preserves edited backup files. The installed file must contain this
# setting before a runtime update or a reboot can establish protection.
if [[ ! -r $config ]] || ! awk -F= '
  {
    sub(/[;#].*$/, "")
    key = $1
    gsub(/^[[:space:]-]+|[[:space:]]+$/, "", key)
    gsub(/\//, ".", key)
    if (key == "dev.tty.ldisc_autoload") {
      value = $2
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      found = 1
    }
  }
  END { exit !(found && value == "0") }
' "$config"; then
  echo "Missing dev.tty.ldisc_autoload=0 in $config; merge the package's .pacnew or repair the installed settings package, then retry." >&2
  exit 1
fi

if [[ $(sysctl -n dev.tty.ldisc_autoload) == "0" ]]; then
  exit 0
fi

# Keep failures visible and the migration pending. A reboot is useful only
# when the persisted setting is present, so request it after the check above.
# Apply only the setting owned by this migration; unrelated unsupported keys
# in the same drop-in must not block this change.
if ! sudo sysctl -w dev.tty.ldisc_autoload=0 >/dev/null; then
  omarchy-state set reboot-required
  exit 1
fi
if [[ $(sysctl -n dev.tty.ldisc_autoload) != "0" ]]; then
  echo "TTY line-discipline autoload is still enabled after applying $config; reboot and retry." >&2
  omarchy-state set reboot-required
  exit 1
fi
