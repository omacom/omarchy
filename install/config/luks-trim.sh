source "$OMARCHY_PATH/install/helpers/luks-trim.sh"

# The ISO writes /etc/default/limine from the installer's kernel cmdline before
# the target setup runs and builds the UKI from it afterwards, so correcting the
# parameter here reaches the install's first boot entry. /etc/default/limine has
# priority over every drop-in, so it is the only place a fresh install can be
# made to pass TRIM through dm-crypt.
limine_conf="${OMARCHY_LUKS_TRIM_LIMINE_CONF:-/etc/default/limine}"

if ! omarchy_luks_has_cryptdevice "$limine_conf"; then
  exit 0
fi

if omarchy_luks_has_trim_options "$limine_conf"; then
  exit 0
fi

echo "Allowing TRIM through dm-crypt in $limine_conf"
omarchy_luks_add_trim_options "$limine_conf"
