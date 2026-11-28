echo "Autoload the ntsync kernel module for Proton and Wine gaming performance"

conf="/etc/modules-load.d/ntsync.conf"

if [[ ! -e $conf && ! -L $conf ]]; then
  printf 'ntsync\n' | sudo install -Dm644 /dev/stdin "$conf"
fi

if [[ ! -e /dev/ntsync && -f $conf ]] && grep -qx 'ntsync' "$conf" && modprobe -qn ntsync 2>/dev/null; then
  sudo modprobe ntsync 2>/dev/null || true
fi
