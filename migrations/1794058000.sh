echo "Restore the Plymouth LUKS prompt on legacy Apple Silicon and Asahi initramfs images"

# Omarchy 4.5 stopped overwriting a platform-owned HOOKS line, so a legacy
# Apple Silicon or Asahi install whose mkinitcpio.conf unlocks with the busybox
# encrypt hook lost Plymouth. That file never listed the hook; the pre-4.5
# drop-in had been inserting it, and the graphical passphrase prompt fell back
# to the text console (#18009). 00-omarchy-hooks.conf inserts plymouth again
# when its install hook is on disk. An image already built does not pick that
# up until it is rebuilt.
#
# Rebuild only that legacy LUKS line. A new Apple Silicon install, every x86
# and plain aarch64 machine, and an unencrypted asahi root already build the
# image they should. A line that lists plymouth itself was rebuilt when it was
# edited. The broken image is the mkinitcpio preset (initramfs-linux-asahi.img):
# a legacy install has no Apple boot package, so prefer mkinitcpio -P, and fall
# back to limine-mkinitcpio only when that is the builder on disk.

conf=${OMARCHY_MKINITCPIO_CONF:-/etc/mkinitcpio.conf}
conf_dir=${OMARCHY_MKINITCPIO_CONF_DIR:-/etc/mkinitcpio.conf.d}
plymouth_install=${OMARCHY_INITCPIO_INSTALL:-/usr/lib/initcpio/install}/plymouth
rebuild_marker=${OMARCHY_PLYMOUTH_REBUILD_MARKER:-/var/lib/omarchy/migrations/1794058000}

# The rebuild is machine-wide, but migrations run once per user. A marker
# records completion so another user's run does not repeat it, while a missing
# marker still retries an interrupted rebuild.
[[ ! -e $rebuild_marker ]] || exit 0
[[ -f $conf && -d $conf_dir && -f $plymouth_install ]] || exit 0

original=$(bash -c 'source "$1" || exit 1; printf "%s\n" "${HOOKS[*]:-}"' -- "$conf") || exit 0
[[ " $original " == *" encrypt "* && " $original " != *" plymouth "* ]] || exit 0

platform=""
if detector=$(command -v omarchy-hw-platform); then
  platform=$("$detector") || exit 0
fi
# omarchy-settings can update before the runtime whose detector still says
# apple-silicon. The baseline normalizes the same name.
[[ $platform != "apple-silicon" ]] || platform=aarch64-apple
if [[ " $original " != *" asahi "* && $platform != "aarch64-apple" ]]; then
  exit 0
fi

# mkinitcpio appends the drop-ins to mkinitcpio.conf in its own order and
# sources the result once. Do the same, and skip the rebuild when that does
# not actually put plymouth on the busybox encrypt line (a held-back drop-in,
# or a line the baseline replaces outright).
effective=$(
  config=$(mktemp)
  trap 'rm -f "$config"' EXIT
  cat -- "$conf" >"$config"
  conf_files=()
  mapfile -d '' conf_files < <(LC_ALL=C.UTF-8 find "$conf_dir" -maxdepth 1 -xtype f -name '*.conf' -print0 |
    sed -z 's/.*\///' | LC_ALL=C.UTF-8 sort -zVu)
  for dropin in "${conf_files[@]}"; do
    [[ -n $dropin ]] || continue
    cat -- "$conf_dir/$dropin" >>"$config"
  done
  bash -c 'source "$1" || exit 1; printf "%s\n" "${HOOKS[*]:-}"' -- "$config"
) || exit 0
[[ " $effective " == *" plymouth "* && " $effective " == *" encrypt "* ]] || exit 0

echo "The legacy LUKS initramfs has no Plymouth hook; rebuilding it"
if omarchy-cmd-present mkinitcpio; then
  sudo mkinitcpio -P
elif omarchy-cmd-present limine-mkinitcpio; then
  sudo limine-mkinitcpio
else
  exit 0
fi
sudo install -Dm644 /dev/null "$rebuild_marker"
