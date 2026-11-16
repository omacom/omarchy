# Speakers on the 2016 15-inch MacBook Pro (A1707, MacBookPro13,3, Apple T1).
# The Cirrus CS8409 codec needs davidjo/snd_hda_macbookpro; it is not in the
# kernel. Other T1 machines are left out.

source "${OMARCHY_INSTALL:-$OMARCHY_PATH/install}/hardware/apple/a1707-t1-lib.sh"
a1707_t1_applicable || return 0

echo "Detected 2016 15-inch MacBook Pro (A1707, T1); installing CS8409 speaker driver"

omarchy-pkg-add dkms wget patch

src=$A1707_T1_CACHE/snd_hda_macbookpro
commit=$(a1707_t1_read_pin snd_hda_macbookpro.commit)
a1707_t1_clone_pinned https://github.com/davidjo/snd_hda_macbookpro "$src" "$commit"

if dkms status 2>/dev/null | grep -q '^snd_hda_macbookpro.*installed'; then
  echo "snd_hda_macbookpro DKMS already installed"
  return 0
fi

# The stock codec stays bound until reboot; DKMS rebuilds on kernel updates.
(cd "$src" && ./install.cirrus.driver.sh -i)
