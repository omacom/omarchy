# The in-tree nct6683 driver reports fan speeds on this board but exposes
# read-only PWM controls. The nct6687 DKMS driver provides fan control.
if [[ $(cat /sys/class/dmi/id/board_vendor 2>/dev/null) == "Micro-Star International Co., Ltd." ]] &&
   [[ $(cat /sys/class/dmi/id/board_name 2>/dev/null) == "MAG X870 TOMAHAWK WIFI (MS-7E51)" ]]; then
  omarchy-pkg-add nct6687d-dkms-git

  mkdir -p /etc/modprobe.d /etc/modules-load.d
  printf 'blacklist nct6683\n' > /etc/modprobe.d/omarchy-nct6683-blacklist.conf
  printf 'nct6687\n' > /etc/modules-load.d/omarchy-nct6687.conf
fi
