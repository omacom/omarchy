# Native wide-gamut OLED: Hyprland's default cm=srgb oversaturates the panel.
#
# Dell XPS 14/16 OLED is Display P3. Leaving the compositor on sRGB primaries
# makes sRGB content look too punchy. Set the internal eDP to dp3 and leave
# the catch-all rule for other outputs.

if omarchy-hw-dell-xps-oled; then
  monitors="$HOME/.config/hypr/monitors.lua"

  if [[ -f $monitors ]]; then
    tmp=$(mktemp)
    awk '
      function strip_comment(s) {
        if (s ~ /^[[:space:]]*--([^[]|$)/) return ""
        sub(/--($|[^\[]).*$/, "", s)
        return s
      }

      function brace_delta(s, i, c, d) {
        d = 0
        for (i = 1; i <= length(s); i++) {
          c = substr(s, i, 1)
          if (c == "{") {
            d++
            opened = 1
          } else if (c == "}") {
            d--
          }
        }
        return d
      }

      function scan_line(s) {
        if (s ~ /output[[:space:]]*=[[:space:]]*"eDP-1"/) call_edp = 1
        if (s ~ /output[[:space:]]*=[[:space:]]*""/) call_empty = 1
        if (s ~ /cm[[:space:]]*=/) call_cm = 1
      }

      NR == FNR {
        live = strip_comment($0)
        if (!in_call && live ~ /hl\.monitor[[:space:]]*\(/) {
          in_call = 1
          call_start = FNR
          call_edp = 0
          call_empty = 0
          call_cm = 0
          depth = 0
          opened = 0
        }
        if (in_call) {
          scan_line(live)
          depth += brace_delta(live)
          if (opened && depth <= 0) {
            if (call_edp) {
              edp_start = call_start
              edp_has_cm = call_cm
            } else if (call_empty && catchall_start == 0) {
              catchall_start = call_start
            }
            in_call = 0
            opened = 0
          }
        }
        next
      }

      edp_start {
        if (FNR == edp_start && !edp_has_cm) sub(/\{/, "{ cm = \"dp3\",")
        print
        next
      }

      catchall_start && FNR == catchall_start {
        print "-- Internal OLED is native Display P3; Hyprland'\''s default cm=srgb oversaturates it."
        print "hl.monitor({"
        print "  output = \"eDP-1\","
        print "  mode = \"preferred\","
        print "  position = \"auto\","
        print "  scale = omarchy_monitor_scale,"
        print "  cm = \"dp3\","
        print "})"
        print ""
      }

      { print }
    ' "$monitors" "$monitors" >"$tmp"

    if ! cmp -s "$monitors" "$tmp" && grep -q 'cm = "dp3"' "$tmp"; then
      echo "Detected Dell XPS OLED. Using Display P3 color management on eDP-1."
      mv "$tmp" "$monitors"
    else
      rm -f "$tmp"
    fi
  fi
fi
