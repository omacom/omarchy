echo "Rebuild the initramfs with early Thunderbolt authorization"

hooks_conf="${OMARCHY_THUNDERBOLT_HOOKS_CONF:-/etc/mkinitcpio.conf.d/omarchy_hooks.conf}"
install_hook="${OMARCHY_THUNDERBOLT_INSTALL_HOOK:-/etc/initcpio/install/omarchy-thunderbolt-autoauth}"
runtime_hook="${OMARCHY_THUNDERBOLT_RUNTIME_HOOK:-/etc/initcpio/hooks/omarchy-thunderbolt-autoauth}"
rebuild_marker="${OMARCHY_THUNDERBOLT_REBUILD_MARKER:-/var/lib/omarchy/migrations/1786961462}"

omarchy-cmd-present limine-mkinitcpio || exit 0
[[ -f $hooks_conf && -f $install_hook && -f $runtime_hook ]] || exit 0
grep -q ' omarchy-thunderbolt-autoauth encrypt' "$hooks_conf" || exit 0
[[ ! -e $rebuild_marker ]] || exit 0

sudo limine-mkinitcpio
sudo install -Dm644 /dev/null "$rebuild_marker"
