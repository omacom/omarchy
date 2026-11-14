echo "Install the Broadcom wl driver for the BCM4352 adapters the installer now covers"

# The install-time leaf only started covering 14e4:43b1 with the release that carries this migration, so a laptop
# set up before it has no driver for that adapter at all: b43 and brcmfmac do not drive it, the kernel leaves it on
# bcma, and there is no wireless interface to join a network with. Those machines cannot fetch this update over
# Wi-Fi, so they arrive here over Ethernet or tethering or not at all.
#
# Deliberately narrower than the leaf, which also covers 14e4:43a0 and 14e4:4331: those got the driver at setup
# time, and one of those machines that no longer has it had it removed on purpose. Installing wl back is what
# #7593 is about, where the driver hard-freezes a 2011 MacBook Air on BCM4331.
pci_info=$(lspci -nn)

if [[ ! $pci_info =~ 14e4:43b1 ]]; then
  exit 0
fi

# Only the installation needs the reboot. Every user after the first one on a machine that already has the driver
# must not be told to reboot again for it.
if omarchy-pkg-missing broadcom-wl-dkms; then
  omarchy-pkg-add broadcom-wl-dkms

  # modprobe reads the module's blacklist of b43, bcma, brcmfmac and friends when the module loads, and the
  # adapter is bound to bcma until then. Reloading it here would not move an interface anyone is online with.
  omarchy-state set reboot-required
fi
