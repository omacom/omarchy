#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
home_dir="$test_tmp/home"
hooks_log="$test_tmp/hooks.log"

mkdir -p "$stub_bin" "$home_dir/.config/alacritty" "$home_dir/.config/ghostty" \
  "$home_dir/.config/foot"

# A font that passes fc-list, and helpers that record calls without touching the
# real desktop. omarchy-cmd-present exits 1 so the missing kitty config keeps
# the kitty branch out of the way; pgrep exits 1 so restart prompts are skipped.
cat >"$stub_bin/fc-list" <<'SH'
#!/bin/bash
printf 'Test Font:style=Regular:scalable=True\n'
SH

cat >"$stub_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 1
SH

cat >"$stub_bin/omarchy-restart-shell" <<'SH'
#!/bin/bash
printf 'restart-shell\n' >>"$OMARCHY_HOOKS_LOG"
SH

cat >"$stub_bin/omarchy-hook" <<'SH'
#!/bin/bash
printf 'hook %s\n' "$*" >>"$OMARCHY_HOOKS_LOG"
SH

for t in omarchy-notification-send pgrep; do
  printf '#!/bin/bash\nexit 1\n' >"$stub_bin/$t"
done

chmod +x "$stub_bin/"*

cat >"$home_dir/.config/alacritty/alacritty.toml" <<'EOF'
[font]
family = "JetBrainsMono Nerd Font"
size = 11
EOF

cat >"$home_dir/.config/ghostty/config" <<'EOF'
font-family = "JetBrainsMono Nerd Font"
font-size = 11
EOF

cat >"$home_dir/.config/foot/foot.ini" <<'EOF'
font=JetBrainsMono Nerd Font:size=11
EOF

run_font_set() {
  HOME="$home_dir" OMARCHY_HOOKS_LOG="$hooks_log" \
    PATH="$stub_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-font-set" "$@"
}

# Changing the family must keep the terminal size that omarchy-display-text-size
# set; the old behavior clobbered it with a hardcoded :size=9 (#9415).
run_font_set 'Test Font'
grep -Fx 'font=Test Font:size=11' "$home_dir/.config/foot/foot.ini" >/dev/null \
  || fail "foot keeps its existing :size when the family changes" \
    "$(cat "$home_dir/.config/foot/foot.ini")"
grep -Fx 'family = "Test Font"' "$home_dir/.config/alacritty/alacritty.toml" >/dev/null \
  || fail "alacritty family is updated" \
    "$(cat "$home_dir/.config/alacritty/alacritty.toml")"
grep -Fx 'size = 11' "$home_dir/.config/alacritty/alacritty.toml" >/dev/null \
  || fail "alacritty size is untouched" \
    "$(cat "$home_dir/.config/alacritty/alacritty.toml")"
grep -Fx 'font-family = "Test Font"' "$home_dir/.config/ghostty/config" >/dev/null \
  || fail "ghostty family is updated" \
    "$(cat "$home_dir/.config/ghostty/config")"
grep -Fx 'font-size = 11' "$home_dir/.config/ghostty/config" >/dev/null \
  || fail "ghostty size is untouched" \
    "$(cat "$home_dir/.config/ghostty/config")"
grep -q '^hook font-set Test Font$' "$hooks_log" || fail "the font-set hook fires"
grep -q '^restart-shell$' "$hooks_log" || fail "the shell restart is requested"
pass "changing the font family preserves the display-text-size points"

# A foot config with no :size at all still gets a sensible default.
cat >"$home_dir/.config/foot/foot.ini" <<'EOF'
font=Some Placeholder Monospace
EOF
run_font_set 'Test Font'
grep -Fx 'font=Test Font:size=9' "$home_dir/.config/foot/foot.ini" >/dev/null \
  || fail "foot without a size falls back to 9pt" \
    "$(cat "$home_dir/.config/foot/foot.ini")"
pass "foot without an existing size falls back to 9pt"