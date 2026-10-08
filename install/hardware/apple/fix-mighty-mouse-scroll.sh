# The wired Apple Mighty Mouse (A1152, USB 05ac:0304) reports horizontal
# low-resolution wheel events alongside vertical high-resolution events.
# Some libinput sessions discard horizontal scrolling after reconnecting it.
# Use standard wheel events for this model only. The compositor must restart
# to load a changed quirk file; reconnecting the mouse alone is insufficient.

quirks_file="/etc/libinput/local-overrides.quirks"

if ! grep -qF "[Apple Mighty Mouse standard wheel events]" "$quirks_file" 2>/dev/null; then
  mkdir -p /etc/libinput
  if [[ -f $quirks_file && ! -e $quirks_file.before-omarchy-mighty-mouse ]]; then
    cp -a "$quirks_file" "$quirks_file.before-omarchy-mighty-mouse"
  fi

  # Start on a new line even when an existing override lacks a trailing newline.
  printf '\n' >> "$quirks_file"
  cat >> "$quirks_file" <<'EOF'
[Apple Mighty Mouse standard wheel events]
MatchUdevType=mouse
MatchVendor=0x05AC
MatchProduct=0x0304
AttrEventCode=-REL_WHEEL_HI_RES;-REL_HWHEEL_HI_RES;
EOF
fi
