#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/bin" "$tmp/home/.config/alacritty" "$tmp/home/.config/ghostty" \
  "$tmp/home/.config/foot" "$tmp/home/.config/kitty" "$tmp/home/.config/omarchy" "$tmp/dots"

# Stub external commands for omarchy-font-set.
cat >"$tmp/bin/fc-list" <<'SH'
#!/bin/bash
printf '%s\n' 'B&H <Mono> "Pro" / 1'\''s'
SH
for cmd in pkill omarchy-restart-shell pgrep omarchy-hook omarchy-notification-send; do
  printf '#!/bin/bash\nexit 0\n' >"$tmp/bin/$cmd"
done
chmod +x "$tmp/bin/"*

printf 'family = "Old"\nsize = 9\n' >"$tmp/dots/alacritty.toml"
printf 'font-family = "Old"\nfont-size = 9\n' >"$tmp/dots/ghostty.conf"
printf 'font=Old:size=11\n' >"$tmp/dots/foot.ini"
printf '[font]\nbase-size = 12\n' >"$tmp/dots/shell.toml"
ln -s "$tmp/dots/alacritty.toml" "$tmp/home/.config/alacritty/alacritty.toml"
ln -s "$tmp/dots/ghostty.conf" "$tmp/home/.config/ghostty/config"
ln -s "$tmp/dots/foot.ini" "$tmp/home/.config/foot/foot.ini"
ln -s "$tmp/dots/shell.toml" "$tmp/home/.config/omarchy/shell.toml"

font_name='B&H <Mono> "Pro" / 1'\''s'
HOME="$tmp/home" PATH="$tmp/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-font-set" "$font_name"

[[ -L "$tmp/home/.config/alacritty/alacritty.toml" && -L "$tmp/home/.config/ghostty/config" && -L "$tmp/home/.config/foot/foot.ini" ]] ||
  fail "omarchy-font-set preserves symlinked terminal configs"
grep -Fxq 'family = "B&H <Mono> \"Pro\" / 1'\''s"' "$tmp/dots/alacritty.toml" ||
  fail "omarchy-font-set escapes sed and quote chars in alacritty.toml" "$(<"$tmp/dots/alacritty.toml")"
grep -Fxq 'font-family = "B&H <Mono> \"Pro\" / 1'\''s"' "$tmp/dots/ghostty.conf" ||
  fail "omarchy-font-set escapes sed and quote chars in ghostty config" "$(<"$tmp/dots/ghostty.conf")"
grep -Fxq 'font=B&H <Mono> "Pro" / 1'\''s:size=11' "$tmp/dots/foot.ini" ||
  fail "omarchy-font-set escapes sed chars in foot.ini" "$(<"$tmp/dots/foot.ini")"
grep -Fq '<string>B&amp;H &lt;Mono&gt; &quot;Pro&quot; / 1&apos;s</string>' "$tmp/home/.config/fontconfig/fonts.conf" ||
  fail "omarchy-font-set XML-escapes fontconfig family names" "$(<"$tmp/home/.config/fontconfig/fonts.conf")"
pass "omarchy-font-set escapes special characters and preserves symlinked configs"

# Stub gsettings and treat foot as not running for omarchy-display-text-size
# (after omarchy-font-set has run with the original pgrep=0 stub above).
printf '#!/bin/bash\nexit 0\n' >"$tmp/bin/gsettings"
printf '#!/bin/bash\nexit 1\n' >"$tmp/bin/pgrep"
chmod +x "$tmp/bin/gsettings" "$tmp/bin/pgrep"

HOME="$tmp/home" XDG_RUNTIME_DIR="$tmp" PATH="$tmp/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-display-text-size" 16 >/dev/null
[[ -L "$tmp/home/.config/omarchy/shell.toml" && -L "$tmp/home/.config/alacritty/alacritty.toml" && -L "$tmp/home/.config/ghostty/config" && -L "$tmp/home/.config/foot/foot.ini" ]] ||
  fail "omarchy-display-text-size preserves symlinked configs"
grep -Fxq 'base-size = 16' "$tmp/dots/shell.toml" ||
  fail "omarchy-display-text-size writes through symlinked shell.toml" "$(<"$tmp/dots/shell.toml")"
grep -Fxq 'size = 12' "$tmp/dots/alacritty.toml" ||
  fail "omarchy-display-text-size writes through symlinked alacritty.toml" "$(<"$tmp/dots/alacritty.toml")"
grep -Fxq 'font-size = 12' "$tmp/dots/ghostty.conf" ||
  fail "omarchy-display-text-size writes through symlinked ghostty config" "$(<"$tmp/dots/ghostty.conf")"
grep -Fxq 'font=B&H <Mono> "Pro" / 1'\''s:size=12' "$tmp/dots/foot.ini" ||
  fail "omarchy-display-text-size writes through symlinked foot.ini" "$(<"$tmp/dots/foot.ini")"
HOME="$tmp/home" XDG_RUNTIME_DIR="$tmp" PATH="$tmp/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-display-text-size" reset >/dev/null
[[ -L "$tmp/home/.config/omarchy/shell.toml" ]] ||
  fail "omarchy-display-text-size reset preserves symlinked shell.toml"
! grep -q 'base-size' "$tmp/dots/shell.toml" ||
  fail "omarchy-display-text-size reset clears base-size in symlinked shell.toml" "$(<"$tmp/dots/shell.toml")"
pass "omarchy-display-text-size preserves symlinked shell and terminal configs"

# Clipboard helpers fail cleanly on missing --history-index value instead of looping.
for helper in omarchy-clipboard-open omarchy-clipboard-paste-text; do
  if timeout 2s "$ROOT/bin/$helper" --history-index >/dev/null 2>&1; then
    fail "$helper rejects --history-index without a value"
  else
    status=$?
    (( status != 124 )) || fail "$helper hangs when --history-index has no value"
  fi
done
pass "clipboard helpers fail cleanly when --history-index lacks a value"

cat >"$tmp/bin/wl-copy" <<SH
#!/bin/bash
cat >"$tmp/wl-copy-out"
SH
cat >"$tmp/bin/wtype" <<SH
#!/bin/bash
printf '%s\n' "\$*" >"$tmp/wtype-out"
SH
chmod +x "$tmp/bin/wl-copy" "$tmp/bin/wtype"

HOME="$tmp/home" PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-clipboard-paste-text" "-leading-dash"
[[ $(<"$tmp/wtype-out") == "-- -leading-dash" ]] ||
  fail "omarchy-clipboard-paste-text separates leading-dash text from wtype options" "$(<"$tmp/wtype-out")"
pass "omarchy-clipboard-paste-text passes -- before typed text"

# omarchy-transcode percent-encodes file:// clipboard URIs for paths with spaces and special chars.
cat >"$tmp/bin/file" <<'SH'
#!/bin/bash
echo "image/png"
SH
cat >"$tmp/bin/magick" <<'SH'
#!/bin/bash
printf 'out' >"${@: -1}"
SH
chmod +x "$tmp/bin/file" "$tmp/bin/magick"

mkdir -p "$tmp/pics"
printf 'in' >"$tmp/pics/My Photo 100% #1.png"
HOME="$tmp/home" PATH="$tmp/bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-transcode" "$tmp/pics/My Photo 100% #1.png" jpg low >/dev/null
[[ $(<"$tmp/wl-copy-out") == "file://$tmp/pics/My%20Photo%20100%25%20%231-low.jpg" ]] ||
  fail "omarchy-transcode percent-encodes special characters in clipboard file URIs" "$(<"$tmp/wl-copy-out")"
pass "omarchy-transcode percent-encodes clipboard file URIs"

# omarchy-hyprland-window-pop exits cleanly without dispatching on an empty workspace,
# batches focused window operations, falls back when Lua dispatchers are rejected,
# and avoids replaying toggles after a partial batch failure.
cat >"$tmp/bin/hyprctl" <<SH
#!/bin/bash
if [[ \$1 == "activewindow" ]]; then
  if [[ -n \${POP_ACTIVE_JSON:-} ]]; then
    printf '%s\n' "\$POP_ACTIVE_JSON"
  else
    echo '{}'
  fi
  exit 0
fi
printf '%s\n' "\$*" >>"$tmp/hyprctl-pop-calls"
if [[ \$1 == "--batch" ]]; then
  case "\${POP_BATCH_MODE:-ok}" in
    ok)
      IFS=';' read -ra cmds <<<"\$2"
      for _ in "\${cmds[@]}"; do printf 'ok\n\n\n'; done
      ;;
    reject)
      IFS=';' read -ra cmds <<<"\$2"
      for _ in "\${cmds[@]}"; do printf 'Invalid dispatcher\n\n\n'; done
      ;;
    partial)
      printf 'ok\n\n\nInvalid dispatcher\n\n\nok\n'
      ;;
    fail)
      exit 1
      ;;
  esac
elif [[ \$1 == "dispatch" && \$2 == hl.dsp.* && \${POP_BATCH_MODE:-ok} == "reject" ]]; then
  exit 1
fi
SH
chmod +x "$tmp/bin/hyprctl"

rm -f "$tmp/hyprctl-pop-calls"
PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-hyprland-window-pop"
[[ ! -e "$tmp/hyprctl-pop-calls" ]] ||
  fail "omarchy-hyprland-window-pop does not dispatch when no window is focused" "$(<"$tmp/hyprctl-pop-calls")"
pass "omarchy-hyprland-window-pop exits cleanly on an empty workspace"

rm -f "$tmp/hyprctl-pop-calls"
POP_ACTIVE_JSON='{"address":"0x1234","pinned":false}' POP_BATCH_MODE=ok \
  PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-hyprland-window-pop" 1200 800
(( $(wc -l <"$tmp/hyprctl-pop-calls") == 1 )) &&
  grep -Fq 'hl.dsp.window.float({ window = "address:0x1234", action = "toggle" })' "$tmp/hyprctl-pop-calls" &&
  grep -Fq 'hl.dsp.window.center({ window = "address:0x1234" })' "$tmp/hyprctl-pop-calls" &&
  grep -Fq 'hl.dsp.window.tag({ window = "address:0x1234", tag = "+pop" })' "$tmp/hyprctl-pop-calls" ||
  fail "omarchy-hyprland-window-pop batches unpinned window pop in one IPC call" "$(<"$tmp/hyprctl-pop-calls")"

rm -f "$tmp/hyprctl-pop-calls"
POP_ACTIVE_JSON='{"address":"0x1234","pinned":true}' POP_BATCH_MODE=ok \
  PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-hyprland-window-pop"
(( $(wc -l <"$tmp/hyprctl-pop-calls") == 1 )) &&
  grep -Fq 'hl.dsp.window.pin({ window = "address:0x1234" })' "$tmp/hyprctl-pop-calls" &&
  grep -Fq 'hl.dsp.window.tag({ window = "address:0x1234", tag = "-pop" })' "$tmp/hyprctl-pop-calls" ||
  fail "omarchy-hyprland-window-pop batches pinned window unpop in one IPC call" "$(<"$tmp/hyprctl-pop-calls")"

rm -f "$tmp/hyprctl-pop-calls"
POP_ACTIVE_JSON='{"address":"0x1234","pinned":true}' POP_BATCH_MODE=reject \
  PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-hyprland-window-pop"
grep -Fq 'dispatch pin address:0x1234' "$tmp/hyprctl-pop-calls" &&
  grep -Fq 'dispatch togglefloating address:0x1234' "$tmp/hyprctl-pop-calls" &&
  grep -Fq 'dispatch tagwindow -pop address:0x1234' "$tmp/hyprctl-pop-calls" ||
  fail "omarchy-hyprland-window-pop falls back to legacy dispatchers when batch replies reject Lua" "$(<"$tmp/hyprctl-pop-calls")"

rm -f "$tmp/hyprctl-pop-calls"
if POP_ACTIVE_JSON='{"address":"0x1234","pinned":true}' POP_BATCH_MODE=partial \
  PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-hyprland-window-pop"; then
  fail "omarchy-hyprland-window-pop fails cleanly on partial batch failure"
fi
(( $(wc -l <"$tmp/hyprctl-pop-calls") == 1 )) ||
  fail "omarchy-hyprland-window-pop does not replay toggles after a partial batch failure" "$(<"$tmp/hyprctl-pop-calls")"
pass "omarchy-hyprland-window-pop batches dispatches and handles fallback safely"
