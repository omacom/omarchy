echo "Install the Cirrus CS8409 speaker codec fix on pre-T2 MacBooks"

# Pre-T2 MacBookPro13,1-13,3/14,1-14,3 pair a Cirrus CS8409 HDA bridge with a
# MAX98706 speaker amp the in-tree driver never initialises, so speakers stay
# silent. install/hardware/apple/fix-cirrus-speakers.sh now installs the
# davidjo/snd_hda_macbookpro DKMS codec patch on fresh setups; this backfills it
# on existing installs. DKMS then rebuilds it on every future kernel bump, so no
# manual re-apply is needed after an omarchy update.

product_name="${OMARCHY_DMI_PRODUCT_NAME:-$(cat /sys/class/dmi/id/product_name 2>/dev/null)}"
[[ $product_name =~ ^MacBookPro1[34],[1-3]$ ]] || exit 0

# Read lspci into a variable before matching: piping straight into `grep -q`
# lets grep close the pipe on the first match, and the SIGPIPE that lands on
# lspci trips `set -o pipefail` into reporting "no T2 hardware" (#6608).
pci="$(lspci -nn)"
[[ $pci == *"106b:1801"* || $pci == *"106b:1802"* ]] && exit 0

omarchy-pkg-present snd-hda-macbookpro-dkms-git && exit 0

# Many owners built the driver by hand before this existed (davidjo's dkms.sh or
# a fork). Leave it alone: pacman would refuse its /usr/src files and fail the
# migration, and a second DKMS version would race it for updates/dkms.
if [[ -e ${OMARCHY_CS8409_SRC_DIR:-/usr/src/snd_hda_macbookpro-0.1} ]] ||
  { omarchy-cmd-present dkms && [[ -n $(dkms status snd_hda_macbookpro 2>/dev/null) ]]; }; then
  echo "Existing snd_hda_macbookpro driver found; leaving it in place"
  exit 0
fi

omarchy-pkg-add snd-hda-macbookpro-dkms-git
