echo "Install the Cirrus CS8409 speaker codec fix on pre-T2 Touch Bar MacBooks"

# Pre-T2 MacBookPro13,2/13,3/14,2/14,3 pair a Cirrus CS8409 HDA bridge with a
# MAX98706 speaker amp the in-tree driver never initialises, so speakers stay
# silent. install/hardware/apple/fix-cirrus-speakers.sh now installs the
# davidjo/snd_hda_macbookpro DKMS codec patch on fresh setups; this backfills it
# on existing installs. DKMS then rebuilds it on every future kernel bump, so no
# manual re-apply is needed after an omarchy update.

product_name="${OMARCHY_DMI_PRODUCT_NAME:-$(cat /sys/class/dmi/id/product_name 2>/dev/null)}"
[[ $product_name =~ ^MacBookPro1[34],[23]$ ]] || exit 0

# Read lspci into a variable before matching: piping straight into `grep -q`
# lets grep close the pipe on the first match, and the SIGPIPE that lands on
# lspci trips `set -o pipefail` into reporting "no T2 hardware" (#6608).
pci="$(lspci -nn)"
[[ $pci == *"106b:1801"* || $pci == *"106b:1802"* ]] && exit 0

omarchy-pkg-present snd-hda-macbookpro-dkms-git && exit 0

omarchy-pkg-add snd-hda-macbookpro-dkms-git
