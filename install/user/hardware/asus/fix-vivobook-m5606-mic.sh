# M5606UA / ALC294 1043:3be0 defaults to +30 dB internal mic boost.
# Speech clips heavily with this gain; 0 dB was validated on the actual laptop.
# Do not change headset boost, Capture gain, or unrelated ASUS codecs.
if [[ $(cat /sys/class/dmi/id/sys_vendor 2>/dev/null) == "ASUSTeK COMPUTER INC." ]] &&
   omarchy-hw-match '^ASUS Vivobook S 16 M5606UA_M5606UA$'; then
  for codec in /proc/asound/card*/codec*; do
    if grep -q '^Codec: Realtek ALC294$' "$codec" 2>/dev/null &&
       grep -q '^Subsystem Id: 0x10433be0$' "$codec" 2>/dev/null; then
      cardnum=${codec#*/card}
      cardnum=${cardnum%%/*}
      if amixer -c "$cardnum" set 'Internal Mic Boost' 0 >/dev/null 2>&1; then
        sudo alsactl store "$cardnum"
      fi
      break
    fi
  done
fi
