echo "Mount binfmt_misc when sysinit starts, before the mount rate limit delays it"

# New installs get this from install/config/enable-services.sh. Existing ones
# keep waiting on the binfmt_misc automount, whose first trigger lands inside
# the opening mount burst, where the mount rate limit holds it back about a
# second past sysinit.

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

# Machine-wide, so a second user on the same box finds it already done.
if ! systemctl is-enabled --quiet proc-sys-fs-binfmt_misc.mount 2>/dev/null; then
  as_root systemctl enable proc-sys-fs-binfmt_misc.mount >/dev/null 2>&1 ||
    echo "Could not enable proc-sys-fs-binfmt_misc.mount; boot keeps waiting on its automount."
fi
