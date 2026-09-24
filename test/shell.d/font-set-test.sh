#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
stub_bin="$tmpdir/bin"
mkdir -p "$home/.config/fontconfig" "$stub_bin"

# The user's own fontconfig rules that must survive omarchy font set.
cat >"$home/.config/fontconfig/fonts.conf" <<'XML'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="font">
    <edit name="rgba" mode="assign"><const>rgb</const></edit>
  </match>
</fontconfig>
XML

# Stub commands the script shells out to.
cat >"$stub_bin/fc-list" <<'SH'
#!/bin/bash
printf 'CaskaydiaMono Nerd Font\n'
SH
chmod +x "$stub_bin/fc-list"

cat >"$stub_bin/pkill" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$stub_bin/pkill"

cat >"$stub_bin/pgrep" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$stub_bin/pgrep"

cat >"$stub_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$stub_bin/omarchy-cmd-present"

cat >"$stub_bin/omarchy-restart-shell" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$stub_bin/omarchy-restart-shell"

cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$stub_bin/omarchy-notification-send"

cat >"$stub_bin/omarchy-hook" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$stub_bin/omarchy-hook"

HOME="$home" PATH="$stub_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  bash "$ROOT/bin/omarchy-font-set" "CaskaydiaMono Nerd Font" >/dev/null

# fonts.conf must be untouched.
if ! cmp -s "$home/.config/fontconfig/fonts.conf" <(cat <<'XML'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="font">
    <edit name="rgba" mode="assign"><const>rgb</const></edit>
  </match>
</fontconfig>
XML
); then
  fail "omarchy font set truncates the user's fonts.conf" "$(cat "$home/.config/fontconfig/fonts.conf")"
fi
pass "omarchy font set leaves the user's fonts.conf alone"

# The Omarchy rule must land in conf.d.
dropin="$home/.config/fontconfig/conf.d/50-omarchy-monospace.conf"
[[ -f $dropin ]] ||
  fail "omarchy font set writes a conf.d drop-in"
pass "omarchy font set writes a conf.d drop-in"

grep -q 'CaskaydiaMono Nerd Font' "$dropin" ||
  fail "the drop-in names the chosen font"
pass "the drop-in names the chosen font"

# A fonts.conf that matches what earlier versions generated gets removed so it
# cannot override the drop-in (conf.d loads before fonts.conf).
cat >"$home/.config/fontconfig/fonts.conf" <<'XML'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="pattern">
    <test name="family" qual="any">
      <string>monospace</string>
    </test>
    <edit name="family" mode="prepend_first" binding="strong">
      <string>JetBrainsMono Nerd Font</string>
    </edit>
  </match>
</fontconfig>
XML

HOME="$home" PATH="$stub_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  bash "$ROOT/bin/omarchy-font-set" "CaskaydiaMono Nerd Font" >/dev/null

[[ ! -f $home/.config/fontconfig/fonts.conf ]] ||
  fail "omarchy font set removes a stale generated fonts.conf"
pass "omarchy font set removes a stale generated fonts.conf"
