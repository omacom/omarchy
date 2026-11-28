# Autoload the ntsync kernel module so Proton and Wine can use native NT
# synchronization primitives instead of falling back to fsync/esync.
conf="/etc/modules-load.d/ntsync.conf"

if [[ ! -e $conf && ! -L $conf ]]; then
  install -Dm644 /dev/stdin "$conf" <<<ntsync
fi
