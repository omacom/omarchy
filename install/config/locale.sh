# An image built from a distribution's root tarball rather than the ISO (Arch
# Linux ARM's ships LANG=C) never went through the ISO's locale step, so it
# runs non-UTF-8: byte-wise sorting, ASCII-only \u escapes, and any tool that
# reads the locale for its encoding.
# Root always writes the real files; the overrides are for unprivileged tests.
locale_conf=/etc/locale.conf
locale_gen=/etc/locale.gen
if (( EUID != 0 )); then
  locale_conf=${OMARCHY_LOCALE_CONF:-$locale_conf}
  locale_gen=${OMARCHY_LOCALE_GEN:-$locale_gen}
fi

# Repair only the stock state -- an unset LANG, or the bare C/POSIX the image
# ships. Any named locale is somebody's choice, C.UTF-8 included, so leave it.
# A machine with no locale.conf at all reads as unset, not as a failure:
# under pipefail the missing file would otherwise abort the installer.
current=$(sed -n 's/^LANG=//p' "$locale_conf" 2>/dev/null | tail -1 | tr -d '"') || current=""

case ${current:-C} in
  C | POSIX) ;;
  *)
    echo "Leaving the locale as $current"
    return 0 2>/dev/null || exit 0
    ;;
esac

echo "Setting up locale (en_US.UTF-8)..."

if ! locale -a 2>/dev/null | grep -qi "en_US.utf-\?8"; then
  if grep -q '^#en_US.UTF-8' "$locale_gen" 2>/dev/null; then
    sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' "$locale_gen"
  elif ! grep -q '^en_US.UTF-8' "$locale_gen" 2>/dev/null; then
    echo "en_US.UTF-8 UTF-8" >>"$locale_gen"
  fi

  locale-gen >/dev/null 2>&1
fi

# Only LANG changes; LC_* lines somebody set stay.
if grep -q '^LANG=' "$locale_conf" 2>/dev/null; then
  sed -i 's/^LANG=.*/LANG=en_US.UTF-8/' "$locale_conf"
else
  echo "LANG=en_US.UTF-8" >>"$locale_conf"
fi

# The session that ran this keeps its inherited LANG; everything after it here
# should see the new one.
export LANG=en_US.UTF-8

echo "Locale set to en_US.UTF-8"
