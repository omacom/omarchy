echo "Prioritize the Omarchy package repository over Arch repositories"

# Move the existing section rather than replacing pacman.conf so channel URLs,
# custom repositories, and administrator options survive the migration.
#
# Stage the rewritten config as root inside /etc, a directory the unprivileged
# desktop user cannot write to, so the path cannot be swapped between the check
# and the privileged write (TOCTOU). Staging on the destination filesystem lets
# the final step rename it into place as a single atomic replacement.
pacman_config=$(sudo mktemp /etc/pacman.conf.XXXXXX)
trap 'sudo rm -f "$pacman_config"' EXIT

awk '
  /^[[:space:]]*\[[^]]+\]/ {
    section = $0
    sub(/^[[:space:]]*\[/, "", section)
    sub(/\].*$/, "", section)
    if (section != "options") repositories = 1
  }
  !repositories { prefix = prefix $0 "\n"; next }
  section == "omarchy" { omarchy = omarchy $0 "\n"; next }
  { others = others $0 "\n" }
  END { printf "%s%s%s", prefix, omarchy, others }
' /etc/pacman.conf | sudo tee "$pacman_config" >/dev/null

# Compare as root: the staged file is root-owned, so the desktop user cannot
# read it to tell whether the ordering already matches.
if ! sudo cmp -s /etc/pacman.conf "$pacman_config"; then
  sudo cp -a /etc/pacman.conf /etc/pacman.conf.bak
  sudo chmod 644 "$pacman_config"
  sudo mv -f "$pacman_config" /etc/pacman.conf
fi

# Clean up before the upgrade: sudo can expire during it, and a cleanup that
# fails in the EXIT trap would fail the migration after a successful upgrade.
sudo rm -f "$pacman_config"
trap - EXIT

# Refresh databases and upgrade against the new repository priority. Run this
# even when the config is already ordered so a failed upgrade can be retried.
omarchy-update-system-pkgs
