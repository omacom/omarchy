#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stub_dir="$tmpdir/bin"
home_dir="$tmpdir/home"
state_home="$tmpdir/state"
toggles_dir="$state_home/omarchy/toggles/hypr"
mkdir -p "$stub_dir" "$home_dir"

for command in hyprctl omarchy-notification-send omarchy-restart-terminal omarchy-theme-set-foot omarchy-restart-btop; do
  printf '#!/bin/bash\nprintf "%%s\\n" "%s $*" >>"%s/commands.log"\n' "$command" "$tmpdir" >"$stub_dir/$command"
done
chmod +x "$stub_dir"/*

run() {
  HOME="$home_dir" XDG_RUNTIME_DIR="$tmpdir" XDG_STATE_HOME="$state_home" XDG_CONFIG_HOME="$home_dir/.config" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" "$@"
}

[[ $(run omarchy-hyprland-window-transparency) == "transparent" ]] || fail "windows start out transparent"
pass "windows start out transparent"

run omarchy-hyprland-window-transparency glassy
[[ $(run omarchy-hyprland-window-transparency) == "glassy" ]] || fail "glassy windows are reported"
cmp -s "$ROOT/default/hypr/toggles/window-glassy.lua" "$toggles_dir/window-glassy.lua" || fail "glassy windows are loaded after the theme"
grep -qx 'hyprctl reload' "$tmpdir/commands.log" || fail "new transparency reloads Hyprland"
grep -q '^omarchy-restart-btop ' "$tmpdir/commands.log" || fail "new transparency reloads running btop windows"
! grep -q '^omarchy-notification-send' "$tmpdir/commands.log" || fail "new transparency is shown, not announced"
pass "glassy windows override the theme"

run omarchy-hyprland-window-transparency opaque
[[ $(run omarchy-hyprland-window-transparency) == "opaque" ]] || fail "opaque windows are reported"
[[ ! -e $toggles_dir/window-glassy.lua ]] || fail "opaque windows replace glassy ones"
pass "opaque windows replace glassy ones"

run omarchy-hyprland-window-transparency transparent
[[ $(run omarchy-hyprland-window-transparency) == "transparent" ]] || fail "transparent windows are reported"
[[ ! -e $toggles_dir/window-opaque.lua ]] || fail "transparent windows drop the override"
pass "transparent windows drop the override"

if run omarchy-hyprland-window-transparency frosted 2>/dev/null; then
  fail "unknown transparency is refused"
fi
pass "unknown transparency is refused"

# A failed save keeps the transparency already chosen.
run omarchy-hyprland-window-transparency glassy
chmod a-w "$toggles_dir"
if run omarchy-hyprland-window-transparency opaque 2>/dev/null; then
  chmod u+w "$toggles_dir"
  fail "a failed save is reported"
fi
chmod u+w "$toggles_dir"
[[ $(run omarchy-hyprland-window-transparency) == "glassy" ]] || fail "a failed save keeps the transparency already chosen"
run omarchy-hyprland-window-transparency transparent
pass "a failed save keeps the transparency already chosen"

# GTK apps only ask Hyprland for blur under a CSS backdrop-filter, so glassy
# imports one into the user's gtk.css, leaving the rest of it alone.
gtk_css="$home_dir/.config/gtk-4.0/gtk.css"
mkdir -p "${gtk_css%/*}"
printf 'label { color: red; }\n' >"$gtk_css"
run omarchy-hyprland-window-transparency glassy
grep -qxF "@import url(\"file://$ROOT/default/gtk/glass.css\");" "$gtk_css" || fail "glassy GTK apps import the backdrop blur"
grep -qx 'label { color: red; }' "$gtk_css" || fail "glassy keeps the user's own GTK CSS"
run omarchy-hyprland-window-transparency glassy
(( $(grep -c 'omarchy-glass begin' "$gtk_css") == 1 )) || fail "glassy GTK apps import the backdrop blur once"
run omarchy-hyprland-window-transparency transparent
[[ $(<"$gtk_css") == 'label { color: red; }' ]] || fail "leaving glassy restores the user's GTK CSS"
grep -qF 'backdrop-filter: blur(' "$ROOT/default/gtk/glass.css" || fail "the GTK glass is a backdrop blur"
printf 'label { color: red; }' >"$gtk_css"
run omarchy-hyprland-window-transparency glassy
run omarchy-hyprland-window-transparency transparent
[[ $(od -An -c "$gtk_css" | tr -d ' \n') == 'label{color:red;}' ]] || fail "leaving glassy restores GTK CSS without a final newline"

# A GTK config that cannot be written fails the change.
printf 'label { color: red; }\n' >"$gtk_css"
chmod a-w "$gtk_css"
: >"$tmpdir/commands.log"
if run omarchy-hyprland-window-transparency glassy 2>/dev/null; then
  chmod u+w "$gtk_css"
  fail "a GTK config that cannot be written fails the change"
fi
chmod u+w "$gtk_css"
[[ $(run omarchy-hyprland-window-transparency) == "transparent" ]] || fail "a failed change keeps the previous choice"
run omarchy-hyprland-window-transparency transparent
pass "glassy GTK apps get a backdrop blur, and leaving glassy takes it out"

# Opaque reaches the windows Omarchy makes transparent through their tag.
grep -qF 'tag = "+transparent-window"' "$ROOT/default/hypr/helpers.lua" || fail "transparent windows carry a tag"
grep -qF 'o.window({ tag = "transparent-window" }, { opacity = "1 1" })' "$ROOT/default/hypr/toggles/window-opaque.lua" ||
  fail "opaque windows apply to the tagged windows"
pass "opaque windows apply to the windows Omarchy makes transparent"

# Terminals turn compositor blur down and fade their text with the window, so
# glassy gives each theme terminal file a see-through, blurred background.
theme_dir="$tmpdir/theme"
mkdir -p "$theme_dir"
printf '[colors.primary]\nbackground = "#000000"\n' >"$theme_dir/alacritty.toml"
printf '[colors-dark]\nbackground=000000\n' >"$theme_dir/foot.ini"
printf 'background #000000\n' >"$theme_dir/kitty.conf"
printf 'background = #000000\nbackground-opacity = 0.9\n' >"$theme_dir/ghostty.conf"
printf 'theme[main_bg]="#102030"\ntheme[main_fg]="#ffffff"\n' >"$theme_dir/btop.theme"
cp -r "$theme_dir" "$tmpdir/theme-before"

run omarchy-hyprland-window-transparency glassy
run omarchy-theme-set-glass "$theme_dir"
run omarchy-theme-set-glass "$theme_dir"
grep -qx 'opacity = 0.65' "$theme_dir/alacritty.toml" || fail "glassy alacritty is see-through"
grep -qx 'alpha=0.65' "$theme_dir/foot.ini" && grep -qx 'blur=yes' "$theme_dir/foot.ini" || fail "glassy foot is see-through and asks for blur"
grep -qx 'background_opacity 0.65' "$theme_dir/kitty.conf" || fail "glassy kitty is see-through"
(( $(grep -c 'omarchy-glass begin' "$theme_dir/foot.ini") == 1 )) || fail "glassy terminals get the glass once"
[[ $(grep '^theme\[main_bg\]=' "$theme_dir/btop.theme" | tail -1) == 'theme[main_bg]=""' ]] || fail "glassy btop uses the terminal background"
(( $(grep -c 'omarchy-glass begin' "$theme_dir/btop.theme") == 1 )) || fail "glassy btop gets the glass once"
pass "btop follows the glassy terminal background"
(( $(grep -c 'background-opacity' "$theme_dir/ghostty.conf") == 1 )) &&
  grep -qx 'background-opacity = 0.9' "$theme_dir/ghostty.conf" || fail "a theme's own terminal opacity is kept"
grep -qx "gtk-custom-css = $ROOT/default/gtk/glass.css" "$theme_dir/ghostty.conf" ||
  fail "a ghostty theme with its own opacity still gets the backdrop blur"
# A foot theme with its own alpha keeps it but still asks for blur, as
# Hyprland skips blur for foot unless it does.
own_alpha_dir="$tmpdir/own-alpha-theme"
mkdir -p "$own_alpha_dir"
printf '[colors-dark]\nbackground=000000\nalpha=0.8\n' >"$own_alpha_dir/foot.ini"
run omarchy-theme-set-glass "$own_alpha_dir"
(( $(grep -c '^alpha=' "$own_alpha_dir/foot.ini") == 1 )) && grep -qx 'alpha=0.8' "$own_alpha_dir/foot.ini" &&
  grep -qx 'blur=yes' "$own_alpha_dir/foot.ini" || fail "a foot theme with its own alpha still asks for blur"
if command -v foot >/dev/null; then
  foot --check-config -c "$own_alpha_dir/foot.ini" || fail "a foot theme with its own alpha stays valid"
fi
pass "a theme's own terminal opacity is kept, and its blur is still added"
if command -v foot >/dev/null; then
  foot --check-config -c "$theme_dir/foot.ini" || fail "glassy foot config is valid"
fi
# A window table of the theme's own takes the glass in, as TOML refuses a
# table declared twice.
window_dir="$tmpdir/window-theme"
mkdir -p "$window_dir"
printf '[window] # mine\npadding = { x = 4, y = 4 }\nblur = false\n\n[colors.primary]\nbackground = "#000000"\n' >"$window_dir/alacritty.toml"
cp "$window_dir/alacritty.toml" "$tmpdir/window-before.toml"
run omarchy-theme-set-glass "$window_dir"
run omarchy-theme-set-glass "$window_dir"
(( $(grep -c '^\[window\]' "$window_dir/alacritty.toml") == 1 )) || fail "glassy alacritty keeps a single window table"
if command -v python3 >/dev/null; then
  python3 -c 'import sys, tomllib; c = tomllib.load(open(sys.argv[1], "rb")); assert c["window"]["opacity"] == 0.65 and c["window"]["padding"]["x"] == 4' "$window_dir/alacritty.toml" ||
    fail "glassy alacritty with a window table of its own stays valid TOML"
fi
HOME="$home_dir" XDG_STATE_HOME="$tmpdir/no-glass" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" omarchy-theme-set-glass "$window_dir"
cmp -s "$tmpdir/window-before.toml" "$window_dir/alacritty.toml" || fail "leaving glassy restores an alacritty window table"
pass "glassy alacritty joins a window table the theme already has"

# A file without a final newline gets one with the glass, and loses it again
# when the glass comes out, so leaving glassy restores it byte for byte.
bare_dir="$tmpdir/bare-theme"
mkdir -p "$bare_dir"
printf 'background #000000' >"$bare_dir/kitty.conf"
cp "$bare_dir/kitty.conf" "$tmpdir/bare-before.conf"
run omarchy-theme-set-glass "$bare_dir"
grep -qx 'background_opacity 0.65' "$bare_dir/kitty.conf" || fail "glassy reaches a file without a final newline"
grep -qx 'background #000000' "$bare_dir/kitty.conf" || fail "glassy ends the line before its block"
HOME="$home_dir" XDG_STATE_HOME="$tmpdir/no-glass" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" omarchy-theme-set-glass "$bare_dir"
cmp -s "$tmpdir/bare-before.conf" "$bare_dir/kitty.conf" || fail "leaving glassy restores a file without a final newline"
pass "leaving glassy restores a file without a final newline byte for byte"

btop_dir="$tmpdir/transparent-btop-theme"
mkdir -p "$btop_dir"
printf 'theme[main_bg]=""\n' >"$btop_dir/btop.theme"
cp "$btop_dir/btop.theme" "$tmpdir/btop-before.theme"
run omarchy-theme-set-glass "$btop_dir"
cmp -s "$tmpdir/btop-before.theme" "$btop_dir/btop.theme" || fail "btop themes already using the terminal background are kept"
pass "btop themes already using the terminal background are kept"

ghostty_dir="$tmpdir/ghostty-theme"
mkdir -p "$ghostty_dir"
printf 'background = #000000\n' >"$ghostty_dir/ghostty.conf"
run omarchy-theme-set-glass "$ghostty_dir"
grep -qx 'background-opacity = 0.65' "$ghostty_dir/ghostty.conf" &&
  grep -qx "gtk-custom-css = $ROOT/default/gtk/glass.css" "$ghostty_dir/ghostty.conf" ||
  fail "glassy ghostty is see-through and loads the GTK backdrop blur"
pass "glassy terminals get a see-through, blurred background"

run omarchy-hyprland-window-transparency transparent
run omarchy-theme-set-glass "$theme_dir"
diff -r "$tmpdir/theme-before" "$theme_dir" || fail "leaving glassy restores the terminal files"
pass "leaving glassy restores the terminal files"

# Running foot terminals take the theme's background alpha over OSC, so a
# change of transparency reaches them without a restart. script stands in for
# foot: its child sits on a real pty, and whatever reaches the pty lands in the
# typescript.
if command -v script >/dev/null; then
  foot_home="$tmpdir/foot-home"
  foot_theme="$foot_home/.local/state/omarchy/current/theme"
  mkdir -p "$foot_theme" "$tmpdir/foot-bin"
  printf 'background = "#102030"\nforeground = "#ffffff"\n' >"$foot_theme/colors.toml"
  printf '[colors-dark]\nbackground=102030\n' >"$foot_theme/foot.ini"

  script -qfc "sleep 30" "$tmpdir/typescript" >/dev/null 2>&1 &
  script_pid=$!
  for _ in {1..50}; do pgrep -P "$script_pid" >/dev/null && break; sleep 0.1; done

  # Only the foot lookup is faked; anything else goes to the real pgrep. Every
  # call is logged, since each one scans the whole process table.
  real_pgrep=$(command -v pgrep)
  printf '#!/bin/bash\necho "$*" >>%q\nif [[ $1 == "-x" && $2 == "foot" ]]; then echo %s; else exec %q "$@"; fi\n' "$tmpdir/pgrep.log" "$script_pid" "$real_pgrep" >"$tmpdir/foot-bin/pgrep"
  chmod +x "$tmpdir/foot-bin/pgrep"

  set_foot() {
    : >"$tmpdir/pgrep.log"
    HOME="$foot_home" PATH="$tmpdir/foot-bin:$ROOT/bin:$PATH" omarchy-theme-set-foot
    sleep 0.3
    # A kernel without CONFIG_PROC_CHILDREN needs a second scan for the shells.
    scans=1
    [[ -e /proc/$script_pid/task/$script_pid/children ]] || scans=2
    (( $(wc -l <"$tmpdir/pgrep.log") == scans )) || fail "a foot retint scans the processes once" "$(cat "$tmpdir/pgrep.log")"
  }

  set_foot
  grep -qF $'\e]11;[100]#102030' "$tmpdir/typescript" || fail "running foot terminals stay opaque without glass"
  printf '# omarchy-glass begin\n[colors-dark]\nalpha=0.65\nblur=yes\n# omarchy-glass end\n' >>"$foot_theme/foot.ini"
  set_foot
  grep -qF $'\e]11;[65]#102030' "$tmpdir/typescript" || fail "running foot terminals turn glassy"
  pass "running foot terminals take the theme's background alpha, found in one process scan"

  # A kernel without CONFIG_PROC_CHILDREN has no children list. A foot pid with
  # no /proc entry stands in for that, and its shell is then found by pgrep -P.
  missing_pid=4194303
  if [[ ! -e /proc/$missing_pid ]]; then
    shell_pid=$(pgrep -P "$script_pid" | head -1)
    mkdir -p "$tmpdir/no-children-bin"
    printf '#!/bin/bash\nif [[ $1 == "-x" && $2 == "foot" ]]; then echo %s; elif [[ $1 == "-P" && $2 == %s ]]; then echo %s; else exit 1; fi\n' \
      "$missing_pid" "$missing_pid" "$shell_pid" >"$tmpdir/no-children-bin/pgrep"
    chmod +x "$tmpdir/no-children-bin/pgrep"
    printf 'background = "#203040"\nforeground = "#ffffff"\n' >"$foot_theme/colors.toml"
    HOME="$foot_home" PATH="$tmpdir/no-children-bin:$ROOT/bin:$PATH" omarchy-theme-set-foot
    sleep 0.3
    grep -qF '#203040' "$tmpdir/typescript" || fail "foot terminals retint without the kernel's children list"
    pass "foot terminals retint without the kernel's children list"
  else
    skip "foot terminals retint without the kernel's children list: pid $missing_pid exists"
  fi
  kill "$script_pid" 2>/dev/null || true
else
  skip "script is not installed"
fi

grep -qx 'blur=yes' "$ROOT/default/themed/foot.ini.tpl" || fail "foot starts ready to blur"
grep -qx 'dynamic_background_opacity yes' "$ROOT/default/themed/kitty.conf.tpl" || fail "kitty starts ready to change opacity"
pass "foot and kitty start ready for glass, since they read that only at launch"
