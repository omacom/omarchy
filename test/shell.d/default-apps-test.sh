#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
installed_dir="$test_tmp/installed"
install_log="$test_tmp/install-log"
terminal_log="$test_tmp/terminal-log"
notification_log="$test_tmp/notification-log"
setup_log="$test_tmp/setup-log"
browser_file="$test_tmp/browser"
mkdir -p "$mock_bin" "$test_home/.config" "$installed_dir"

cat >"$mock_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
[[ ! -e $OMARCHY_TEST_INSTALLED_DIR/$1 ]]
SH

cat >"$mock_bin/omarchy-launch-floating-terminal-with-presentation" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_TERMINAL_LOG"
SH

cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >>"$OMARCHY_TEST_NOTIFICATION_LOG"
SH

cat >"$mock_bin/omarchy-test-setup-call" <<'SH'
#!/bin/bash
printf '%s:%s\n' "${0##*/}" "$*" >>"$OMARCHY_TEST_SETUP_LOG"
[[ ${OMARCHY_TEST_SETUP_FAIL:-} != "${0##*/}" ]]
SH

cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo:%s\n' "$*" >>"$OMARCHY_TEST_SETUP_LOG"
[[ ${OMARCHY_TEST_SETUP_FAIL:-} != "sudo" ]]
SH

cat >"$mock_bin/xdg-settings" <<'SH'
#!/bin/bash
case $1 in
get) [[ -f $OMARCHY_TEST_BROWSER_FILE ]] && cat "$OMARCHY_TEST_BROWSER_FILE" ;;
set)
  printf '%s\n' "$3" >"$OMARCHY_TEST_BROWSER_FILE"
  # xdg-settings only answers an entry that is installed, so leave one behind
  # for omarchy-cmd-default-browser to find.
  mkdir -p "$HOME/.local/share/applications"
  printf '[Desktop Entry]\nExec=true %%U\n' >"$HOME/.local/share/applications/$3"
  ;;
esac
SH

cat >"$mock_bin/omarchy-test-installer" <<'SH'
#!/bin/bash
installer=${0##*/}

if [[ $installer == "omarchy-install-browser" && ${OMARCHY_TEST_REAL_BROWSER_INSTALL:-false} == "true" ]]; then
  exec "$ROOT/bin/omarchy-install-browser" "$@"
fi

case $installer in
omarchy-pkg-add|omarchy-pkg-aur-add)
  package=$1
  printf 'pkg:%s\n' "$package" >>"$OMARCHY_TEST_INSTALL_LOG"
  case $package in
  chromium) command=chromium ;;
  firefox) command=firefox ;;
  zen-browser-bin) command=zen-browser ;;
  cursor-bin) command=cursor ;;
  sublime-text-4) command=subl ;;
  vim) command=vim ;;
  neovim) command=nvim ;;
  plain) command=plain ;;
  esac
  ;;
omarchy-install-browser)
  selection=$1
  printf 'browser:%s\n' "$selection" >>"$OMARCHY_TEST_INSTALL_LOG"
  case $selection in
  chromium) command=chromium ;;
  chrome) command=google-chrome-stable ;;
  brave) command=brave ;;
  brave-origin) command=brave-origin ;;
  edge) command=microsoft-edge-stable ;;
  firefox) command=firefox ;;
  zen) command=zen-browser ;;
  esac
  ;;
omarchy-install-terminal)
  command=$1
  printf 'terminal:%s\n' "$command" >>"$OMARCHY_TEST_INSTALL_LOG"
  ;;
omarchy-install-editor-*)
  editor=${installer#omarchy-install-editor-}
  printf 'editor:%s\n' "$editor" >>"$OMARCHY_TEST_INSTALL_LOG"
  case $editor in
  vscode) command=code ;;
  zed) command=zeditor ;;
  helix) command=helix ;;
  emacs) command=emacs ;;
  esac
  ;;
esac

[[ ${OMARCHY_TEST_INSTALL_FAIL:-false} != "true" ]] || exit 1
touch "$OMARCHY_TEST_INSTALLED_DIR/$command"
SH

for installer in \
  omarchy-pkg-add \
  omarchy-pkg-aur-add \
  omarchy-install-browser \
  omarchy-install-terminal \
  omarchy-install-editor-vscode \
  omarchy-install-editor-zed \
  omarchy-install-editor-helix \
  omarchy-install-editor-emacs; do
  ln -s omarchy-test-installer "$mock_bin/$installer"
done
for setup_command in \
  omarchy-install-chromium-copy-url \
  omarchy-install-chromium-ytdlp \
  omarchy-theme-set-browser; do
  ln -s omarchy-test-setup-call "$mock_bin/$setup_command"
done

# The real browser installer below calls the platform's post-install hook; on a
# Mac with the platform package installed that would run, so answer it here.
printf '#!/bin/bash\nexit 0\n' >"$mock_bin/omarchy-lifecycle-dispatch"
chmod +x "$mock_bin"/*

export HOME="$test_home"
# The user's own XDG dirs would win over HOME; keep every write in the test home.
export XDG_CONFIG_HOME="$test_home/.config" XDG_DATA_HOME="$test_home/.local/share"
export PATH="$mock_bin:$ROOT/bin:$PATH"
export OMARCHY_PATH="$ROOT"
export OMARCHY_TEST_INSTALLED_DIR="$installed_dir"
export OMARCHY_TEST_INSTALL_LOG="$install_log"
export OMARCHY_TEST_TERMINAL_LOG="$terminal_log"
export OMARCHY_TEST_NOTIFICATION_LOG="$notification_log"
export OMARCHY_TEST_SETUP_LOG="$setup_log"
export OMARCHY_TEST_BROWSER_FILE="$browser_file"

assert_missing_opens_installer() {
  local type=$1
  local selection=$2

  : >"$terminal_log"
  "omarchy-default-$type" "$selection"
  mapfile -d '' -t terminal_args <"$terminal_log"
  [[ ${terminal_args[*]} == "omarchy-default-$type --install $selection" ]] ||
    fail "missing $selection opens its default installer in a terminal"
}

browser_cases=(
  'chromium chromium browser:chromium'
  'chrome google-chrome-stable browser:chrome'
  'brave brave browser:brave'
  'brave-origin brave-origin browser:brave-origin'
  'edge microsoft-edge-stable browser:edge'
  'firefox firefox browser:firefox'
  'zen zen-browser browser:zen'
)

terminal_cases=(
  'alacritty Alacritty.desktop'
  'foot foot.desktop'
  'ghostty com.mitchellh.ghostty.desktop'
  'kitty kitty.desktop'
)

editor_cases=(
  'plain plain pkg:plain'
  'code code editor:vscode'
  'cursor cursor pkg:cursor-bin'
  'zed zeditor editor:zed'
  'sublime_text subl pkg:sublime-text-4'
  'helix helix editor:helix'
  'vim vim pkg:vim'
  'emacs emacs editor:emacs'
  'nvim nvim pkg:neovim'
)

for entry in "${browser_cases[@]}"; do
  read -r selection command installer <<<"$entry"
  assert_missing_opens_installer browser "$selection"
done
for entry in "${terminal_cases[@]}"; do
  read -r selection desktop_id <<<"$entry"
  assert_missing_opens_installer terminal "$selection"
done
for entry in "${editor_cases[@]}"; do
  read -r selection command installer <<<"$entry"
  assert_missing_opens_installer editor "$selection"
done
pass "missing defaults open visible installers for every supported app"

for entry in "${browser_cases[@]}"; do
  read -r selection command installer <<<"$entry"
  rm -f "$installed_dir/$command"
  : >"$install_log"
  omarchy-default-browser --install "$selection"
  [[ $(<"$install_log") == "$installer" ]] || fail "$selection uses its browser installer"
  [[ $(omarchy-default-browser) == "$selection" ]] || fail "$selection becomes the default browser after installation"
done
pass "browser defaults install every missing browser before selection"

: >"$install_log"
: >"$setup_log"
rm -f "$installed_dir/chromium"
OMARCHY_TEST_REAL_BROWSER_INSTALL=true omarchy-default-browser --install chromium >/dev/null
[[ $(<"$install_log") == "pkg:chromium" ]] || fail "Chromium browser installer installs the package"
[[ $(omarchy-default-browser) == "chromium" ]] || fail "Chromium becomes the default after its full installer succeeds"
cmp -s "$ROOT/config/chromium-flags.conf" "$test_home/.config/chromium-flags.conf" ||
  fail "Chromium browser installer copies the default flags"
# Chrome's installer copies these same flags, and /etc/skel seeds new installs
# with Chrome's own copy from config/, so the two must not drift apart.
cmp -s "$ROOT/config/chromium-flags.conf" "$ROOT/config/chrome-flags.conf" ||
  fail "new installs seed Chrome with the flags Chromium ships"
grep -Fxq 'sudo:install -d -m 0755 -o root -g root /etc/chromium' "$setup_log" ||
  fail "Chromium browser installer creates a root-owned Chromium policy parent"
grep -Fxq 'sudo:install -d -m 0755 -o root -g root /etc/chromium/policies' "$setup_log" ||
  fail "Chromium browser installer creates a root-owned Chromium policies parent"
grep -Fxq 'sudo:install -d -m 0755 -o root -g root /etc/chromium/policies/managed' "$setup_log" ||
  fail "Chromium browser installer creates a root-owned managed policy directory"
grep -Fxq 'sudo:find /etc/chromium/policies/managed -mindepth 1 -maxdepth 1 ! -user root -exec rm -rf -- {} +' "$setup_log" ||
  fail "Chromium browser installer drops non-root files from its policy directory"
if grep -E 'groupadd|usermod|omarchy-browser-policy' "$setup_log" >/dev/null; then
  fail "Chromium browser installer does not create a browser-policy group" "$(cat "$setup_log")"
fi
grep -Fxq 'omarchy-install-chromium-copy-url:' "$setup_log" ||
  fail "Chromium browser installer registers the Copy URL host"
grep -Fxq 'omarchy-install-chromium-ytdlp:' "$setup_log" ||
  fail "Chromium browser installer registers the yt-dlp host"
grep -Fxq 'omarchy-theme-set-browser:' "$setup_log" ||
  fail "Chromium browser installer applies the current theme"
pass "Chromium browser installer restores the complete Omarchy setup"

: >"$install_log"
: >"$setup_log"
rm -f "$installed_dir/firefox"
OMARCHY_TEST_REAL_BROWSER_INSTALL=true omarchy-default-browser --install firefox >/dev/null
[[ $(<"$install_log") == "pkg:firefox" ]] || fail "Firefox browser installer installs the package"
[[ $(omarchy-default-browser) == "firefox" ]] || fail "Firefox becomes the default after its full installer succeeds"
grep -Fxq 'sudo:install -d -m 0755 -o root -g root /usr/lib/firefox/distribution' "$setup_log" ||
  fail "Firefox browser installer creates its distribution directory"
grep -Fxq 'sudo:find /usr/lib/firefox/distribution -mindepth 1 -maxdepth 1 ! -user root -exec rm -rf -- {} +' "$setup_log" ||
  fail "Firefox browser installer drops non-root files from its distribution directory"
grep -Fxq "sudo:install -m 644 -o root -g root -T $ROOT/default/firefox/policies.json /usr/lib/firefox/distribution/policies.json" "$setup_log" ||
  fail "Firefox browser installer copies policies.json without following a destination symlink"
[[ -e $installed_dir/firefox ]] || fail "Firefox browser installer marks firefox installed"
pass "Firefox browser installer restores the complete Omarchy setup"

: >"$install_log"
: >"$setup_log"
rm -f "$installed_dir/zen-browser"
OMARCHY_TEST_REAL_BROWSER_INSTALL=true omarchy-default-browser --install zen >/dev/null
[[ $(<"$install_log") == "pkg:zen-browser-bin" ]] || fail "Zen browser installer installs the package"
[[ $(omarchy-default-browser) == "zen" ]] || fail "Zen becomes the default after its full installer succeeds"
grep -Fxq 'sudo:install -d -m 0755 -o root -g root /opt/zen-browser/distribution' "$setup_log" ||
  fail "Zen browser installer creates its distribution directory"
grep -Fxq 'sudo:find /opt/zen-browser/distribution -mindepth 1 -maxdepth 1 ! -user root -exec rm -rf -- {} +' "$setup_log" ||
  fail "Zen browser installer drops non-root files from its distribution directory"
grep -Fxq "sudo:install -m 644 -o root -g root -T $ROOT/default/firefox/policies.json /opt/zen-browser/distribution/policies.json" "$setup_log" ||
  fail "Zen browser installer copies policies.json without following a destination symlink"
[[ -e $installed_dir/zen-browser ]] || fail "Zen browser installer marks zen-browser installed"
pass "Zen browser installer restores the complete Omarchy setup"

omarchy-default-browser zen
rm -f "$installed_dir/chromium"
if OMARCHY_TEST_REAL_BROWSER_INSTALL=true OMARCHY_TEST_INSTALL_FAIL=true \
  omarchy-default-browser --install chromium >"$test_tmp/browser-package-failure" 2>&1; then
  fail "failed Chromium package installation returns an error"
fi
[[ $(omarchy-default-browser) == "zen" ]] || fail "failed Chromium package installation preserves the default browser"
[[ ! -e $installed_dir/chromium ]] || fail "failed Chromium package installation does not mark it installed"
pass "failed Chromium package installation preserves the current default"

if OMARCHY_TEST_REAL_BROWSER_INSTALL=true OMARCHY_TEST_SETUP_FAIL=sudo \
  omarchy-default-browser --install chromium >"$test_tmp/browser-install-failure" 2>&1; then
  fail "failed Chromium setup returns an error"
fi
[[ $(omarchy-default-browser) == "zen" ]] || fail "failed Chromium setup preserves the default browser"
grep -Fq 'Installing Chromium' "$test_tmp/browser-install-failure" ||
  fail "failed Chromium setup keeps progress visible in the terminal"
pass "failed Chromium setup preserves the current default"

for entry in "${terminal_cases[@]}"; do
  read -r selection desktop_id <<<"$entry"
  rm -f "$installed_dir/$selection"
  : >"$install_log"
  omarchy-default-terminal --install "$selection"
  [[ $(<"$install_log") == "terminal:$selection" ]] || fail "$selection uses the terminal installer"
  [[ $(tail -n 1 "$test_home/.config/xdg-terminals.list") == "$desktop_id" ]] ||
    fail "$selection becomes the default terminal after installation"
done
pass "terminal defaults install every missing terminal before selection"

for entry in "${editor_cases[@]}"; do
  read -r selection command installer <<<"$entry"
  rm -f "$installed_dir/$command"
  : >"$install_log"
  omarchy-default-editor --install "$selection"
  [[ $(<"$install_log") == "$installer" ]] || fail "$selection uses its editor installer"
  [[ $(omarchy-default-editor) == "$command" ]] || fail "$selection becomes the default editor after installation"
done
pass "editor defaults install every missing editor before selection"

: >"$install_log"
: >"$terminal_log"
omarchy-default-browser zen
omarchy-default-terminal kitty
omarchy-default-editor nvim
[[ ! -s $install_log && ! -s $terminal_log ]] || fail "installed defaults skip installation"
pass "installed defaults are selected immediately"

# Picking an editor points every text type at the editor handler in the
# user's mimeapps.list, replacing what was there and keeping everything else.
mimeapps="$test_home/.config/mimeapps.list"
dotfiles_list="$test_tmp/dotfiles-mimeapps.list"
printf '[Added Associations]\ntext/plain=nvim.desktop;\n\n[Default Applications]\nimage/png=imv.desktop\ntext/plain=nvim.desktop\ntext/x-tex=code.desktop\n' >"$dotfiles_list"
ln -sf "$dotfiles_list" "$mimeapps"
omarchy-default-editor vim
handler_types=$(sed -n 's/^MimeType=//p' "$ROOT/applications/omarchy-launch-editor.desktop" | tr ';' '\n' | sed '/^$/d')
while read -r type; do
  [[ $(grep -cxF "$type=omarchy-launch-editor.desktop" "$mimeapps") == 1 ]] || fail "picking an editor points $type at the editor handler once"
done <<<"$handler_types"
! grep -qxF "text/plain=nvim.desktop" "$mimeapps" || fail "picking an editor replaces the old text/plain default"
! grep -qxF "text/x-tex=code.desktop" "$mimeapps" || fail "picking an editor replaces an app chosen for a text type"
grep -qxF "image/png=imv.desktop" "$mimeapps" || fail "picking an editor keeps other types' defaults"
grep -qxF "text/plain=nvim.desktop;" "$mimeapps" || fail "picking an editor leaves added associations alone"
[[ -L $mimeapps ]] || fail "picking an editor keeps a symlinked mimeapps.list a symlink"
[[ -f $test_home/.local/share/applications/omarchy-launch-editor.desktop ]] || fail "picking an editor installs the editor handler"
pass "picking an editor opens text files in it from every app"

# The migration keeps a type the user pointed elsewhere themselves, and
# replaces Omarchy's own past defaults.
rm -f "$mimeapps"
printf '[Default Applications]\ntext/plain=nvim.desktop\ntext/xml=plain.desktop\ntext/x-tex=code.desktop\n' >"$mimeapps"
omarchy-cmd-editor-mimetypes --unless-chosen
grep -qxF "text/plain=omarchy-launch-editor.desktop" "$mimeapps" || fail "the migration replaces Neovim, the old default"
grep -qxF "text/xml=omarchy-launch-editor.desktop" "$mimeapps" || fail "the migration replaces Plain, the newer default"
grep -qxF "text/x-tex=code.desktop" "$mimeapps" || fail "the migration keeps a type the user chose"
! grep -qxF "text/x-tex=omarchy-launch-editor.desktop" "$mimeapps" || fail "the migration doesn't add a second default for a chosen type"
mkdir -p "$test_home/.local/share/applications"
printf '[Default Applications]\ntext/x-java=code.desktop\ntext/x-tcl=nvim.desktop\n' >"$test_home/.local/share/applications/mimeapps.list"
printf '[Default Applications]\n' >"$mimeapps"
omarchy-cmd-editor-mimetypes --unless-chosen
! grep -q "^text/x-java=" "$mimeapps" || fail "the migration keeps a choice saved in the older list"
grep -qxF "text/x-tcl=omarchy-launch-editor.desktop" "$mimeapps" || fail "the migration replaces Neovim saved in the older list"
rm -f "$test_home/.local/share/applications/mimeapps.list"
pass "the migration keeps the user's own choices"

# Values are ;-separated lists and keys may have spaces around "=", as GLib
# writes and reads them; a choice in ~/.config outranks the older list's.
printf '[Default Applications]\ntext/x-java=code.desktop\n' >"$test_home/.local/share/applications/mimeapps.list"
printf '[Default Applications]\ntext/plain=nvim.desktop;\ntext/xml = code.desktop;\ntext/x-java=omarchy-launch-editor.desktop\n' >"$mimeapps"
omarchy-cmd-editor-mimetypes --unless-chosen
grep -qxF "text/plain=omarchy-launch-editor.desktop" "$mimeapps" || fail "the migration reads a ;-ended old default as Omarchy's"
! grep -qxF "text/plain=nvim.desktop;" "$mimeapps" || fail "the migration replaces a ;-ended old default"
grep -qxF "text/xml = code.desktop;" "$mimeapps" || fail "the migration keeps a spaced choice"
! grep -qxF "text/xml=omarchy-launch-editor.desktop" "$mimeapps" || fail "the migration adds nothing above a spaced choice"
grep -qxF "text/x-java=omarchy-launch-editor.desktop" "$mimeapps" || fail "a choice in ~/.config outranks the older list's"
omarchy-default-editor vim
grep -qxF "text/xml=omarchy-launch-editor.desktop" "$mimeapps" || fail "picking an editor replaces a spaced line"
[[ $(grep -c "^text/xml *=" "$mimeapps") == 1 ]] || fail "picking an editor leaves one text/xml line"
rm -f "$test_home/.local/share/applications/mimeapps.list"
pass "the migration reads mimeapps.list the way GLib does"

# A CRLF list with a spaced header: one defaults section, and the user's
# choice in it kept.
printf ' [Default Applications] \r\ntext/plain=code.desktop;\r\ntext/xml=nvim.desktop\r\n' >"$mimeapps"
omarchy-cmd-editor-mimetypes --unless-chosen
[[ $(grep -c "Default Applications" "$mimeapps") == 1 ]] || fail "a CRLF list keeps one defaults section"
grep -q "^text/plain=code.desktop;" "$mimeapps" || fail "a CRLF list keeps the user's choice"
! grep -qx "text/plain=omarchy-launch-editor.desktop" "$mimeapps" || fail "a CRLF list gets no handler line over a choice"
grep -qx "text/xml=omarchy-launch-editor.desktop" "$mimeapps" || fail "a CRLF list's old default moves to the handler"
! grep -q "^text/xml=nvim.desktop" "$mimeapps" || fail "a CRLF list's old default line is replaced"
pass "the migration reads CRLF lists and spaced headers"

# A type set twice is whatever its last line says, as GLib reads it.
printf '[Default Applications]\ntext/plain=code.desktop\ntext/plain=nvim.desktop\ntext/css=nvim.desktop\ntext/css=code.desktop\n' >"$mimeapps"
omarchy-cmd-editor-mimetypes --unless-chosen
grep -qxF "text/plain=omarchy-launch-editor.desktop" "$mimeapps" || fail "a type whose last line is the old default moves to the handler"
! grep -q "^text/plain=code.desktop" "$mimeapps" || fail "an earlier line of a type doesn't count as a choice"
grep -qxF "text/css=code.desktop" "$mimeapps" || fail "a type whose last line is a choice keeps it"
! grep -qxF "text/css=omarchy-launch-editor.desktop" "$mimeapps" || fail "a chosen type gets no handler line"
pass "the migration reads a repeated type by its last line"

# A type and its alias are one type: a choice under either name holds both.
printf '[Default Applications]\napplication/xml=code.desktop\napplication/yaml=nvim.desktop\n' >"$mimeapps"
omarchy-cmd-editor-mimetypes --unless-chosen
grep -qxF "application/xml=code.desktop" "$mimeapps" || fail "a choice for a type is kept"
! grep -qxF "text/xml=omarchy-launch-editor.desktop" "$mimeapps" || fail "its alias gets no handler line over the choice"
grep -qxF "application/x-yaml=omarchy-launch-editor.desktop" "$mimeapps" || fail "an old default under an alias moves to the handler"
! grep -q "^application/yaml=nvim.desktop" "$mimeapps" || fail "the old default's alias line is replaced"
pass "the migration treats a type and its aliases as one"

# Among a type's names, the one listed first decides, as GLib reads it.
printf '[Default Applications]\napplication/xml=code.desktop\ntext/xml=plain.desktop\n' >"$mimeapps"
omarchy-cmd-editor-mimetypes --unless-chosen
grep -qxF "application/xml=code.desktop" "$mimeapps" || fail "the first-listed name's choice is kept"
! grep -qxF "text/xml=omarchy-launch-editor.desktop" "$mimeapps" || fail "no handler line over the first-listed choice"
pass "the migration reads a type's names in the order GLib does"

# The desktop's own list is read first: picking an editor clears its text
# types and keeps the rest, while the migration leaves it alone.
desktop_list="$test_home/.config/hyprland-mimeapps.list"
printf '[Default Applications]\nx-scheme-handler/https=omarchy-browser.desktop\ntext/plain=code.desktop\n' >"$desktop_list"
omarchy-cmd-editor-mimetypes --unless-chosen
grep -qxF "text/plain=code.desktop" "$desktop_list" || fail "the migration leaves the desktop's own list alone"
omarchy-default-editor vim
! grep -q "^text/plain" "$desktop_list" || fail "picking an editor clears a text type from the desktop's own list"
grep -qxF "x-scheme-handler/https=omarchy-browser.desktop" "$desktop_list" || fail "picking an editor keeps the desktop list's other lines"
rm -f "$desktop_list"
ln -s "$mimeapps" "$desktop_list"
omarchy-default-editor vim
grep -qxF "text/plain=omarchy-launch-editor.desktop" "$mimeapps" || fail "a desktop list linked to mimeapps.list keeps the handler"
rm -f "$desktop_list"
printf '[Default Applications]\ntext/x-sh=code.desktop\n' >"$desktop_list"
omarchy-default-editor vim
! grep -q "^text/x-sh" "$desktop_list" || fail "picking an editor clears an alias from the desktop's own list"
rm -f "$desktop_list"
pass "picking an editor wins over the desktop's own list"

# New installs ship the same types pointed at the handler.
shipped=$(sed -n 's/=omarchy-launch-editor\.desktop$//p' "$ROOT/default/applications/mimeapps.list" | sort)
[[ $shipped == $(sort <<<"$handler_types") ]] || fail "the shipped mimeapps.list points the handler's types at it"
pass "new installs open text files in the default editor"

previous_editor=$(omarchy-default-editor)
rm -f "$installed_dir/vim"
if OMARCHY_TEST_INSTALL_FAIL=true omarchy-default-editor --install vim >"$test_tmp/install-failure" 2>&1; then
  fail "failed default installation returns an error"
fi
[[ $(omarchy-default-editor) == "$previous_editor" ]] || fail "failed installation preserves the default"
pass "failed installation preserves the current default"

# Defaults > Browser shares the guard read; its query count and answer matter.
# Keep generated entries independent of the runner's XDG environment.
export XDG_DATA_HOME="$test_tmp/data-home"
export XDG_DATA_DIRS="$test_tmp/system-share:$test_tmp/system share"
browser_call_log="$test_tmp/xdg-settings-log"
cat >"$mock_bin/xdg-settings" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_XDG_LOG"
case $1 in
get) [[ -f $OMARCHY_TEST_BROWSER_FILE ]] && cat "$OMARCHY_TEST_BROWSER_FILE" ;;
set) printf '%s\n' "$3" >"$OMARCHY_TEST_BROWSER_FILE" ;;
esac
SH
chmod +x "$mock_bin/xdg-settings"
export OMARCHY_TEST_XDG_LOG="$browser_call_log"

for packaged in chromium.desktop:chromium google-chrome.desktop:chrome brave-browser.desktop:brave \
  brave-origin.desktop:brave-origin microsoft-edge.desktop:edge firefox.desktop:firefox zen.desktop:zen; do
  printf '%s\n' "${packaged%%:*}" >"$browser_file"
  [[ $(omarchy-default-browser) == "${packaged##*:}" ]] || fail "${packaged%%:*} still reads as ${packaged##*:}"
done
pass "every packaged browser id still reads as its own name"

# The unmatched arm is where the second call was, and it is the arm any browser
# that registered itself lands in.
: >"$browser_call_log"
printf 'unmatched.desktop\n' >"$browser_file"
omarchy-default-browser >/dev/null
(( $(wc -l <"$browser_call_log") == 1 )) || fail "an unmatched browser id is read with a single xdg-settings call"
pass "reading an unmatched browser id asks xdg-settings once"

: >"$browser_call_log"
printf 'firefox.desktop\n' >"$browser_file"
omarchy-default-browser >/dev/null
(( $(wc -l <"$browser_call_log") == 1 )) || fail "a packaged browser id is read with a single xdg-settings call"
pass "reading a packaged browser id asks xdg-settings once"

# A browser that registers itself gets a generated entry whose filename names no
# browser. Zen installs exactly this.
mkdir -p "$XDG_DATA_HOME/applications"
cat >"$XDG_DATA_HOME/applications/userapp-Zen-81ROQ3.desktop" <<'DESKTOP'
[Desktop Entry]
Exec=/opt/zen-browser-bin/zen %u
Name=Zen
DESKTOP
printf 'userapp-Zen-81ROQ3.desktop\n' >"$browser_file"
[[ $(omarchy-default-browser) == "zen" ]] || fail "a browser registered under a generated id reads as itself"
pass "a browser registered under a generated desktop id is recognised"

: >"$browser_call_log"
omarchy-default-browser >/dev/null
(( $(wc -l <"$browser_call_log") == 1 )) || fail "a generated id is resolved without a second xdg-settings call"
pass "resolving a generated id still asks xdg-settings once"

mkdir -p "$test_tmp/system share/applications"
cat >"$test_tmp/system share/applications/userapp-Firefox-system.desktop" <<'DESKTOP'
[Desktop Entry]
Exec=env -u UNUSED "MOZ_ENABLE_WAYLAND=1" "/opt/browser with spaces/firefox" %u
DESKTOP
printf 'userapp-Firefox-system.desktop\n' >"$browser_file"
[[ $(omarchy-default-browser) == "firefox" ]] || fail "wrapped system browser resolves through an XDG directory containing spaces"
pass "wrapped browser entries resolve without executing their environment"

cat >"$XDG_DATA_HOME/applications/userapp-Literal.desktop" <<DESKTOP
[Desktop Entry]
Exec=env "NOTE=\$(touch $test_tmp/exec-must-not-run)" /opt/firefox %u
DESKTOP
printf 'userapp-Literal.desktop\n' >"$browser_file"
[[ $(omarchy-default-browser) == "firefox" && ! -e $test_tmp/exec-must-not-run ]] || fail "desktop Exec data is never evaluated as shell code"
pass "desktop command substitutions remain literal data"

cat >"$XDG_DATA_HOME/applications/userapp-Unrelated.desktop" <<'DESKTOP'
[Desktop Entry]
Exec=unknown-wrapper --label firefox %u
DESKTOP
printf 'userapp-Unrelated.desktop\n' >"$browser_file"
[[ $(omarchy-default-browser) == "userapp-Unrelated.desktop" ]] || fail "an unrelated executable's arguments are not mistaken for a browser"
pass "unrecognised wrappers retain their desktop id"

cat >"$XDG_DATA_HOME/applications/userapp-Flatpak.desktop" <<'DESKTOP'
[Desktop Entry]
Exec=flatpak run --branch=stable --command firefox org.mozilla.firefox %u
DESKTOP
printf 'userapp-Flatpak.desktop\n' >"$browser_file"
[[ $(omarchy-default-browser) == "firefox" ]] || fail "a registered Flatpak browser resolves to its menu name"
pass "Flatpak browser entries are recognised"

# Trace the shipped resolver's attempted paths without writing into /usr.
printf 'userapp-system-paths.desktop\n' >"$browser_file"
env -u XDG_DATA_DIRS bash -x "$ROOT/bin/omarchy-default-browser" >"$test_tmp/default-path-output" 2>"$test_tmp/default-path-trace"
grep -Fq '/usr/local/share/applications/userapp-system-paths.desktop' "$test_tmp/default-path-trace" || fail "unset XDG_DATA_DIRS searches /usr/local/share/applications"
grep -Fq '/usr/share/applications/userapp-system-paths.desktop' "$test_tmp/default-path-trace" || fail "unset XDG_DATA_DIRS searches /usr/share/applications"
pass "unset XDG_DATA_DIRS keeps the standard system application directories"

printf 'something-else.desktop\n' >"$browser_file"
[[ $(omarchy-default-browser) == "something-else.desktop" ]] || fail "an unrecognised id still reports itself"
pass "an unrecognised desktop id still reports the raw value"

# With no default set the resolver gets an empty id, which names the applications
# directory itself rather than an entry in it.
rm -f "$browser_file"
[[ -z $(omarchy-default-browser 2>"$test_tmp/no-browser-stderr") && ! -s $test_tmp/no-browser-stderr ]] ||
  fail "no default browser reads as nothing, without errors" "$(cat "$test_tmp/no-browser-stderr")"
pass "no default browser reads as nothing"
