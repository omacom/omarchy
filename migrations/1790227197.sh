echo "Stop saved connections from broadcasting the hostname"

# The conf.d defaults only shape profiles created from now on, so retrofit
# the ones already saved. MACs are left alone here: changing a saved
# connection's address mid-life breaks MAC-filtered networks, while the
# hostname it keeps shouting is the bigger leak.
if omarchy-cmd-present nmcli; then
  # nmcli -t escapes a colon inside a field as \:, so asking for NAME would
  # misalign the split on connections whose name contains one. The name is
  # not needed: UUID and TYPE are enough to find and modify the profile.
  while IFS=: read -r uuid type; do
    case $type in
      802-11-wireless | 802-3-ethernet)
        nmcli connection modify "$uuid" \
          ipv4.dhcp-send-hostname no \
          ipv6.dhcp-send-hostname no \
          ipv6.ip6-privacy 2 2>/dev/null || true
        ;;
    esac
  done < <(nmcli -t -f UUID,TYPE connection show 2>/dev/null)
fi
