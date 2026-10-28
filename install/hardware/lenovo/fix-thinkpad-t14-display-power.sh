# Display power-saving fix for the Lenovo ThinkPad T14 Gen 2i (Tiger Lake / i915).
#
# The internal panel blanks itself and comes back on its own, with nothing in
# the kernel log: no DPMS event, no link reset, no GPU hang. Panel Self Refresh
# is the usual suspect and i915.enable_psr=0 covers it, but that is a different
# feature. Display Power Saving lets the GPU drop the display power well while
# the content is static, and this panel does not come back from it.
# Frame-buffer compression is the other i915 display power-saving path that
# leaves the panel in a state it does not recover from.
#
# Both are i915 display power-saving features, so both are turned off. The cost
# is a little more idle power draw, since the panel can no longer enter a
# low-power state while the display is static.
#
# Enabled only for the ThinkPad T14 Gen 2i for now. Other models need
# confirmation that the issue exists there too.

limine_config_dir=${OMARCHY_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}
config_file=$limine_config_dir/thinkpad-t14-display-power.conf

if omarchy-hw-match "ThinkPad T14 Gen 2i"; then
  mkdir -p "$limine_config_dir"

  # Write through a temporary file and rename it into place, so a write that
  # is interrupted cannot leave a drop-in that is empty or half a command line:
  # the boot tooling reads that file, and a partial one is worse than none.
  tmp_file=$(mktemp "$limine_config_dir/.thinkpad-t14-display-power.conf.XXXXXX")
  # mktemp creates the file 0600 and root owns it, while the migration that
  # verifies this drop-in runs as the user, so it has to be readable by them.
  chmod 0644 "$tmp_file"
  trap 'rm -f "$tmp_file"' EXIT
  cat >"$tmp_file" <<'CONF'
# Lenovo ThinkPad T14 Gen 2i display power-saving workaround
KERNEL_CMDLINE[default]+=" i915.enable_dc=0 i915.enable_fbc=0"
CONF
  mv -f "$tmp_file" "$config_file"
  trap - EXIT
fi
