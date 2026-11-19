#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command magick
require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# An image from before Chrome was the default browser has Chromium, which
# takes the same flags, so it stands in under Chrome's name.
if ! command -v google-chrome-stable >/dev/null; then
  require_command chromium
  mkdir -p "$test_tmp/browser"
  ln -s "$(command -v chromium)" "$test_tmp/browser/google-chrome-stable"
  PATH="$test_tmp/browser:$PATH"
fi

look_theme() {
  "$ROOT/bin/omarchy-agent-look-theme" "$1" --out "$test_tmp/preview.png"
}

# A stock theme is what a good theme looks like: nothing to report.
cp -r "$ROOT/themes/kanagawa" "$test_tmp/good"
output=$(look_theme "$test_tmp/good") || fail "a stock theme passes the theme check" "$output"
[[ -s $test_tmp/preview.png ]] || fail "the theme check draws a preview" "$output"
pass "a stock theme passes the theme check and is drawn"

# The mistakes small models make: a palette missing keys, text the color of
# the background, and a small, flat background drawn in code.
mkdir -p "$test_tmp/bad/backgrounds"
cat >"$test_tmp/bad/colors.toml" <<'EOF'
mode = "dark"
accent = "#a8c08a"
background = "#1a120c"
foreground = "#2b1e13"
EOF
magick -size 800x450 xc:'#20160f' "$test_tmp/bad/backgrounds/1-drawn.png"
if output=$(look_theme "$test_tmp/bad"); then
  fail "a broken theme fails the theme check" "$output"
fi
for problem in "colors.toml is missing" "foreground #2b1e13 on background" "under 1920x1080" "nearly flat"; do
  [[ $output == *"$problem"* ]] || fail "the theme check reports: $problem" "$output"
done
pass "the theme check names missing keys, unreadable text, and small or flat backgrounds"

# A color the preview can't read is drawn gray, so it has to be named, or the
# check passes a theme while showing a color it never specified.
cp -r "$ROOT/themes/kanagawa" "$test_tmp/typo"
sed -i -E -e 's/^blue = .*/blue = "#GGGGGG"/' -e 's/^red = .*/red = "#ffffff-typo"/' "$test_tmp/typo/colors.toml"
if output=$(look_theme "$test_tmp/typo"); then
  fail "a theme with an unreadable color fails the theme check" "$output"
fi
[[ $output == *"aren't #rrggbb: "*"red #ffffff-typo"*"blue #GGGGGG"* ]] || fail "the theme check names the unreadable colors" "$output"

# Omarchy reads a color between single quotes as well as double, and ignores
# a comment after it.
cp -r "$ROOT/themes/kanagawa" "$test_tmp/single"
sed -i -E -e "s/^(accent = )\"(.*)\"/\\1'\\2'/" -e 's/^(blue = .*)$/\1 # the links/' "$test_tmp/single/colors.toml"
grep -q "^accent = '#" "$test_tmp/single/colors.toml" && grep -q '^blue = "#.*" # the links$' "$test_tmp/single/colors.toml" ||
  fail "the fixture has a single-quoted color and a commented one"
output=$(look_theme "$test_tmp/single") || fail "a single-quoted or commented color is read as Omarchy reads it" "$output"
pass "the theme check names a color that isn't #rrggbb"

look_page() {
  "$ROOT/bin/omarchy-agent-look-page" "$@" 2>&1
}

# A game reads a key two ways: once per press, and held across frames. The
# page reports what it saw of one requested press, which lands on a focused
# button that the press removes, as a title screen's start button is.
cat >"$test_tmp/keys.html" <<'EOF'
<!doctype html><html><body><button id="start">Start</button><script>
let presses = 0, stillDown = false, frames = 0, heldFrames = 0;
const held = {};
start.focus();
start.addEventListener("keydown", () => start.remove());
addEventListener("keydown", e => { presses++; held[e.code] = true; queueMicrotask(() => stillDown = held[e.code]); });
addEventListener("keyup", e => { held[e.code] = false; });
(function loop() { if (presses) { frames++; if (held.ArrowLeft) heldFrames++; } requestAnimationFrame(loop); })();
setTimeout(() => console.error(`error presses=${presses} down=${stillDown} released=${!held.ArrowLeft && !held.ArrowRight} frame=${frames > 0} read=${heldFrames > 0}`), 2500);
</script></body></html>
EOF
output=$(look_page "$test_tmp/keys.html" --keys "ArrowLeft ArrowRight" --out "$test_tmp/page.png") || true
# Every key is released, though the button the first landed on is gone, and
# the page runs in real time, so its loop sees frames with the key held.
[[ $output == *"presses=2 down=true released=true frame=true read=true"* ]] ||
  fail "each key is pressed once, held across frames, and released" "$output"
pass "look page presses each key once, holds it across frames, and releases it"

# A file keeps its fragment, and --theme adds that theme's palette to it, as
# omarchy-games-launch does for the current theme.
cat >"$test_tmp/hash.html" <<'EOF'
<!doctype html><html><body><script>
const hash = new URLSearchParams(location.hash.slice(1));
console.error(`error seed=${hash.get("seed")} mode=${JSON.parse(hash.get("palette")).mode}`);
</script></body></html>
EOF
output=$(look_page "$test_tmp/hash.html#seed=1" --theme catppuccin-latte --after 0 --out "$test_tmp/hash.png") || true
[[ $output == *"seed=1 mode=light"* ]] || fail "look page passes a file's fragment and the theme's palette" "$output"
pass "look page shows a page in another theme's palette"

# When the browser fails, an image left at --out by an earlier look must not
# be reported as this one. This stand-in records how it was started.
mkdir -p "$test_tmp/broken"
cat >"$test_tmp/broken/google-chrome-stable" <<EOF
#!/bin/bash
echo "\$*" >>"$test_tmp/browser.log"
exit 7
EOF
chmod +x "$test_tmp/broken/google-chrome-stable"
[[ -s $test_tmp/page.png ]] || fail "the earlier look left a screenshot to go stale"
if output=$(PATH="$test_tmp/broken:$PATH" look_page "$test_tmp/keys.html" --out "$test_tmp/page.png"); then
  fail "look page fails when the browser does" "$output"
fi
[[ $output != *"screenshot:"* && ! -e $test_tmp/page.png ]] || fail "look page doesn't report an earlier screenshot" "$output"
pass "look page never reports an earlier screenshot as a new one"

# The browser keeps its own sandbox wherever it can start with one, and
# drops it only to try again after failing with it.
[[ $(head -1 "$test_tmp/browser.log") != *--no-sandbox* && $(tail -1 "$test_tmp/browser.log") == *--no-sandbox* ]] ||
  fail "look page drops the sandbox only after the browser fails with it" "$(<"$test_tmp/browser.log")"
pass "look page runs without the browser's sandbox only where the browser can't start one"

look_app() {
  PATH="$test_tmp/bin:$PATH" "$ROOT/bin/omarchy-agent-look-app" "$@" 2>&1
}

# An app with the template's hook draws itself, at the size asked for.
mkdir -p "$test_tmp/bin"
cat >"$test_tmp/hooked" <<EOF
#!/bin/bash
echo "\$OMARCHY_LOOK_SIZE" >"$test_tmp/size"
magick -size 8x8 xc:red "\$OMARCHY_LOOK_SCREENSHOT"
EOF
chmod +x "$test_tmp/hooked"
output=$(look_app --size 640x480 --out "$test_tmp/app.png" -- "$test_tmp/hooked") || fail "look app captures an app that draws itself" "$output"
[[ $(<"$test_tmp/size") == "640x480" ]] || fail "look app passes --size to an app that draws itself" "$(<"$test_tmp/size")"
pass "look app passes --size to an app that draws itself"

# Drawn on the GPU first, where shader effects show, and in software only
# when that draws nothing.
cat >"$test_tmp/gpuless" <<EOF
#!/bin/bash
echo -n "\$QT_QUICK_BACKEND " >>"$test_tmp/backends"
[[ \$QT_QUICK_BACKEND == "software" ]] && magick -size 8x8 xc:red "\$OMARCHY_LOOK_SCREENSHOT"
exit 0
EOF
chmod +x "$test_tmp/gpuless"
output=$(look_app --after 0 --out "$test_tmp/app.png" -- "$test_tmp/gpuless") || fail "look app falls back to software rendering" "$output"
[[ $(<"$test_tmp/backends") == "rhi software " ]] || fail "look app tries the GPU before software" "$(<"$test_tmp/backends")"
pass "look app draws on the GPU and falls back to software without one"

# Another theme and language reach the app through a home of its own, and
# the user's stay as they were.
mkdir -p "$test_tmp/home/.config/omarchy/themes/paper" "$test_tmp/home/.local/state/omarchy/current/theme"
echo 'accent = "#000001"' >"$test_tmp/home/.config/omarchy/themes/paper/colors.toml"
echo 'accent = "#ffffff"' >"$test_tmp/home/.local/state/omarchy/current/theme/colors.toml"
echo en >"$test_tmp/home/.config/omarchy/language"
cat >"$test_tmp/themed" <<EOF
#!/bin/bash
cat "\$HOME/.local/state/omarchy/current/theme/colors.toml" "\$HOME/.config/omarchy/language" >"$test_tmp/seen"
magick -size 8x8 xc:red "\$OMARCHY_LOOK_SCREENSHOT"
EOF
chmod +x "$test_tmp/themed"
output=$(HOME="$test_tmp/home" look_app --theme Paper --language da --out "$test_tmp/app.png" -- "$test_tmp/themed") || fail "look app shows an app in another theme and language" "$output"
[[ $(<"$test_tmp/seen") == $'accent = "#000001"\nda' ]] || fail "look app hands the app the theme and language asked for" "$(<"$test_tmp/seen")"
[[ $(<"$test_tmp/home/.config/omarchy/language") == "en" ]] || fail "look app leaves the user's language alone"
output=$(HOME="$test_tmp/home" look_app --language da --out "$test_tmp/app.png" -- "$test_tmp/themed") || fail "look app shows an app in another language" "$output"
[[ $(<"$test_tmp/seen") == $'accent = "#ffffff"\nda' ]] || fail "look app keeps the user's theme when only the language changes" "$(<"$test_tmp/seen")"
pass "look app shows an app in another theme or language without changing the user's"

# The wait is counted in whole seconds; half of one is refused by name.
for wait in 0.5 08; do
  if output=$(look_app --after "$wait" -- "$test_tmp/hooked"); then
    fail "look app refuses an --after that isn't whole seconds: $wait" "$output"
  fi
done
[[ $output == *"--after takes whole seconds"* ]] || fail "look app says what --after takes" "$output"
pass "look app says when --after isn't whole seconds"

# Any other program is started once, by the compositor, and captured on
# screen. Its window belongs to a process it started, and another window
# opening meanwhile is the user's: the stand-in compositor lists that first.
cat >"$test_tmp/plain" <<EOF
#!/bin/bash
echo started >>"$test_tmp/plain.runs"
sleep 60 &
echo \$! >"$test_tmp/plain.pid"
wait
EOF
cat >"$test_tmp/bin/hyprctl" <<EOF
#!/bin/bash
case \$1 in
  monitors) echo '[{"dpmsStatus":true}]' ;;
  dispatch)
    command=\$(python3 -I -c 'import json, sys; print(json.JSONDecoder().raw_decode(sys.argv[1][len("hl.dsp.exec_cmd("):])[0])' "\$2")
    setsid bash -c "\$command" </dev/null >/dev/null 2>&1 &
    ;;
  clients)
    if [[ -s "$test_tmp/plain.pid" ]]; then
      printf '[{"stableId":"1001","pid":%s,"at":[0,0],"size":[8,8]},{"stableId":"2002","pid":%s,"at":[0,0],"size":[8,8]}]\n' "\$(<"$test_tmp/stranger.pid")" "\$(<"$test_tmp/plain.pid")"
    else
      echo '[]'
    fi
    ;;
esac
EOF
cat >"$test_tmp/bin/grim" <<EOF
#!/bin/bash
echo "\$*" >>"$test_tmp/grim.log"
magick -size 8x8 xc:red "\${@: -1}"
EOF
chmod +x "$test_tmp/plain" "$test_tmp/bin/hyprctl" "$test_tmp/bin/grim"
sleep 60 &
stranger=$!
echo "$stranger" >"$test_tmp/stranger.pid"
trap 'kill "$stranger" $(cat "$test_tmp/plain.pid" 2>/dev/null) 2>/dev/null; rm -rf "$test_tmp"' EXIT

output=$(look_app --after 0 --out "$test_tmp/app.png" -- "$test_tmp/plain") || fail "look app captures a program on screen" "$output"
[[ $(<"$test_tmp/plain.runs") == "started" ]] || fail "look app starts a program without the hook only as a floating window" "$(<"$test_tmp/plain.runs")"
[[ $(<"$test_tmp/grim.log") == "-T 2002 "* ]] || fail "look app captures the program's own window, not another that opened" "$(<"$test_tmp/grim.log")"
kill -0 "$stranger" 2>/dev/null || fail "look app leaves another window's program running"
for _ in {1..20}; do
  kill -0 "$(<"$test_tmp/plain.pid")" 2>/dev/null || break
  sleep 0.1
done
kill -0 "$(<"$test_tmp/plain.pid")" 2>/dev/null && fail "look app closes the program it started"
pass "look app captures and closes only the program it started"

# A wrapper that starts the program in the background and exits leaves its
# window under another parent; it is still the program's own.
cat >"$test_tmp/wrapper" <<EOF
#!/bin/bash
sleep 60 &
echo \$! >"$test_tmp/plain.pid"
EOF
chmod +x "$test_tmp/wrapper"
: >"$test_tmp/plain.pid"
: >"$test_tmp/grim.log"
output=$(look_app --after 0 --out "$test_tmp/app.png" -- "$test_tmp/wrapper") || fail "look app captures a window a wrapper started" "$output"
[[ $(<"$test_tmp/grim.log") == "-T 2002 "* ]] || fail "look app captures the wrapped program's window, not another that opened" "$(<"$test_tmp/grim.log")"
kill -0 "$stranger" 2>/dev/null || fail "look app leaves another window's program running after a wrapper"
pass "look app finds a window a wrapper started before exiting"

# An app with the hook that draws nothing offscreen is captured on screen,
# started as itself with its own arguments.
cat >"$test_tmp/undrawn" <<EOF
#!/bin/bash
# OMARCHY_LOOK_SCREENSHOT
[[ -n \${OMARCHY_LOOK_SCREENSHOT:-} ]] && exit 0
echo "\$*" >"$test_tmp/undrawn.args"
sleep 60 &
echo \$! >"$test_tmp/plain.pid"
wait
EOF
chmod +x "$test_tmp/undrawn"
: >"$test_tmp/plain.pid"
output=$(look_app --after 0 --out "$test_tmp/app.png" -- "$test_tmp/undrawn" sample.txt) || fail "look app captures on screen an app that drew nothing offscreen" "$output"
[[ $(<"$test_tmp/undrawn.args") == "sample.txt" ]] || fail "look app starts the app itself on screen, with its arguments" "$(cat "$test_tmp/undrawn.args" 2>/dev/null)"
pass "look app falls back to the screen with the app's own command"
