# Board data for a Qualcomm Wi-Fi card that linux-firmware does not list yet,
# in Snapdragon and x86 laptops alike. ath12k finds no board data for such a
# card, so it has no Wi-Fi. ath12k-board-fallback copies the record
# linux-firmware ships for the card's module family, the one Qualcomm's Windows
# driver also uses for it, and removes the copy once linux-firmware lists the
# card. The upstream fix is an entry for each card in linux-firmware's
# board-2.bin.

if lspci -nn | grep -qE '\[17cb:(1107|1112)\]'; then
  omarchy-pkg-add ath12k-board-fallback
fi
