# Broadcom 720p FaceTime HD (PCI 14e4:1570) on 2013-2015 Intel Macs. There is
# no in-tree driver; facetimehd is the reverse-engineered module. Linux 7.2
# removed strncpy, so the packaged facetimehd-dkms must be built from
# patjak/facetimehd after 54fb8f2. AUR 0.7.0.2 does not compile on linux-omarchy 7.2.

dmi_vendor="${OMARCHY_DMI_VENDOR:-/sys/class/dmi/id/sys_vendor}"
sys_vendor="$(cat "$dmi_vendor" 2>/dev/null || true)"

if [[ $sys_vendor == Apple* ]] && omarchy-hw-facetimehd; then
  echo "Detected FaceTime HD camera"

  omarchy-pkg-add facetimehd-firmware facetimehd-data facetimehd-dkms
fi
