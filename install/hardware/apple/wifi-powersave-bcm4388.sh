# Turn Wi-Fi power save back on for the BCM4388 in M3 Pro MacBook Pros.
#
# Omarchy keeps Wi-Fi power save off everywhere
# (/etc/NetworkManager/conf.d/omarchy-wifi-powersave.conf) for the latency
# spikes it causes and for Intel BE200/BE211 firmware, which drops the link when
# it naps. On a MacBook Pro 14" M3 Pro (J514S) with this part, driven by brcmfmac
# in its PM_FAST mode, it measured the other way: display-off idle power 50-80 mW
# lower with power save on, and no spikes (60 pings to the router, at most
# 4.7 ms on and 8.6 ms off). Only this part was measured, so only it is matched.
#
# The setting is bound to brcmfmac, which on Apple Silicon drives only the
# built-in part: another adapter (a USB dongle) keeps the default. NetworkManager
# reads conf.d in name order and the later file wins: "_" sorts after ".", so
# this file comes after omarchy-wifi-powersave.conf.
if ! omarchy-hw-aarch64-apple; then
  return 0
fi

# Not grep -q: with pipefail, lspci killed by SIGPIPE reads as no match (#6608).
if lspci -nn | grep "14e4:4434" >/dev/null; then
  echo "Detected a BCM4388 on Apple Silicon; keeping Wi-Fi power save on"

  sudo mkdir -p /etc/NetworkManager/conf.d
  sudo tee /etc/NetworkManager/conf.d/omarchy-wifi-powersave_bcm4388.conf >/dev/null <<'CONF'
# BCM4388 on Apple Silicon: power save on (see
# install/hardware/apple/wifi-powersave-bcm4388.sh). Overrides
# omarchy-wifi-powersave.conf, which sorts before this file, for the built-in
# Wi-Fi only.
[connection-omarchy-bcm4388]
match-device=driver:brcmfmac
wifi.powersave=3
CONF
fi
