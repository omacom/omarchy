#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1788380505.sh"
[[ -f $migration ]] || fail "SDDM Qt6 guard migration exists"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin" "$test_dir/etc/sddm.conf.d" "$test_dir/usr/share/sddm/themes/"{omarchy,maya,custom6} "$test_dir/usr/bin"

cat >"$test_dir/bin/sudo" <<'STUB'
#!/bin/bash
exec "$@"
STUB
chmod +x "$test_dir/bin/sudo"

cat >"$test_dir/bin/ldd" <<'STUB'
#!/bin/bash
# Fake ldd: prints missing-library lines when the binary name contains -broken.
if [[ ${1##*/} == *-broken* ]]; then
  printf 'libQt5Core.so.5 => not found\nlibQt5Gui.so.5 => not found\n'
fi
STUB
chmod +x "$test_dir/bin/ldd"

cat >"$test_dir/usr/share/sddm/themes/omarchy/metadata.desktop" <<'EOF'
[SddmGreeterTheme]
Name=Omarchy
QtVersion=6
EOF

cat >"$test_dir/usr/share/sddm/themes/maya/metadata.desktop" <<'EOF'
[SddmGreeterTheme]
Name=Maya
EOF

cat >"$test_dir/usr/share/sddm/themes/custom6/metadata.desktop" <<'EOF'
[SddmGreeterTheme]
Name=Custom
QtVersion=6
EOF

touch "$test_dir/usr/bin/sddm-greeter-good"
touch "$test_dir/usr/bin/sddm-greeter-broken"
chmod +x "$test_dir/usr/bin/"sddm-greeter-*

run_migration() {
  HOME="$test_dir/home" \
    OMARCHY_SDDM_CONF="$test_dir/etc/sddm.conf" \
    OMARCHY_SDDM_CONF_DIR="$test_dir/etc/sddm.conf.d" \
    OMARCHY_SDDM_THEME_DIR="$test_dir/usr/share/sddm/themes" \
    OMARCHY_SDDM_QT5_GREETER="$test_dir/usr/bin/$1" \
    PATH="$test_dir/bin:$PATH" \
    bash -euo pipefail "$migration"
}

# Scenario 1: the active theme already declares QtVersion=6 — no change.
{
  reset_state() {
    rm -rf "$test_dir/etc" "$test_dir/home"
    mkdir -p "$test_dir/etc/sddm.conf.d" "$test_dir/home"
  }
  reset_state
  printf '[Theme]\nCurrent=omarchy\n' >"$test_dir/etc/sddm.conf.d/10-theme.conf"
  run_migration sddm-greeter-broken >/dev/null
  grep -Fx 'Current=omarchy' "$test_dir/etc/sddm.conf.d/10-theme.conf" >/dev/null ||
    fail "safe Qt6 theme is left unchanged"
}

# Scenario 2: a non-Qt6 theme is active and the Qt5 greeter cannot run — reset.
{
  reset_state
  printf '[Theme]\nCurrent=omarchy\n' >"$test_dir/etc/sddm.conf.d/10-theme.conf"
  printf '[Theme]\nCurrent=maya\n' >"$test_dir/etc/sddm.conf.d/99-user-theme.conf"
  run_migration sddm-greeter-broken >/dev/null
  grep -Fx 'Current=omarchy' "$test_dir/etc/sddm.conf.d/99-user-theme.conf" >/dev/null ||
    fail "unsafe non-Qt6 theme is reset to omarchy"
  grep -Fx 'Current=omarchy' "$test_dir/etc/sddm.conf.d/10-theme.conf" >/dev/null ||
    fail "packaged theme file stays valid"
}

# Scenario 3: a non-Qt6 theme is active but the Qt5 greeter is runnable — leave it.
{
  reset_state
  printf '[Theme]\nCurrent=maya\n' >"$test_dir/etc/sddm.conf.d/10-theme.conf"
  run_migration sddm-greeter-good >/dev/null
  grep -Fx 'Current=maya' "$test_dir/etc/sddm.conf.d/10-theme.conf" >/dev/null ||
    fail "non-Qt6 theme is left alone when Qt5 greeter works"
}

# Scenario 4: a custom theme declares QtVersion=6 even though the Qt5 greeter is broken.
{
  reset_state
  printf '[Theme]\nCurrent=custom6\n' >"$test_dir/etc/sddm.conf.d/10-theme.conf"
  run_migration sddm-greeter-broken >/dev/null
  grep -Fx 'Current=custom6' "$test_dir/etc/sddm.conf.d/10-theme.conf" >/dev/null ||
    fail "custom Qt6 theme is left unchanged"
}

# Scenario 5: no Current= is configured anywhere — nothing to guard.
{
  reset_state
  run_migration sddm-greeter-broken >/dev/null
  [[ ! -e $test_dir/etc/sddm.conf.d/10-theme.conf ]] ||
    fail "guard does not create a theme file when none exists"
}

pass "SDDM Qt6 theme guard resets unsafe themes and preserves safe ones"
