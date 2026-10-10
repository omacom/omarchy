#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"

python3 - "$ROOT" <<'PY' || fail "compiled Spanish catalog serves the selector and menu label"
import gettext
import json
from pathlib import Path
import sys

root = Path(sys.argv[1])
messages = root / 'default/locale/es/LC_MESSAGES'
with (messages / 'omarchy.mo').open('rb') as source:
    catalog = gettext.GNUTranslations(source)
assert catalog.gettext('Set system language and region') == 'Seleccionar idioma y región del sistema'
assert json.loads((messages / 'menu.json').read_text())['setup.language'] == catalog.gettext('Language & Region')
PY
pass "compiled Spanish catalog serves the selector and menu label"

msgfmt --check --check-format -o "$scratch/rebuilt.mo" "$ROOT/i18n/es.po"
cmp -s "$scratch/rebuilt.mo" "$ROOT/default/locale/es/LC_MESSAGES/omarchy.mo" ||
  fail "compiled Spanish catalog matches the source PO file"
pass "compiled Spanish catalog matches the source PO file"

if (( EUID == 0 )); then
  pass "root test process; skipping the unprivileged locale picker probe"
  exit 0
fi

cat >"$scratch/bin/omarchy-menu-select" <<'SCRIPT'
#!/bin/bash
cat >"$TEST_SCRATCH/options"
if [[ ${TEST_CANCEL:-} == "1" ]]; then
  exit 1
fi
printf 'Selected language\t%s\n' "$TEST_CHOICE"
SCRIPT
cat >"$scratch/bin/sudo" <<'SCRIPT'
#!/bin/bash
printf '%s\n' "$@" >"$TEST_SCRATCH/sudo-args"
SCRIPT
cat >"$scratch/bin/omarchy-notification-send" <<'SCRIPT'
#!/bin/bash
printf '%s\n' "$@" >"$TEST_SCRATCH/notification"
SCRIPT
chmod +x "$scratch/bin/"*

export TEST_SCRATCH="$scratch"
export OMARCHY_PATH="$ROOT"
export LC_ALL=C
export PATH="$scratch/bin:$ROOT/bin:$PATH"
configured=$(sed -n 's/^LANG=//p' /etc/locale.conf | head -1)
if [[ $configured == "de_DE.UTF-8" ]]; then
  export TEST_CHOICE=en_US.UTF-8
else
  export TEST_CHOICE=de_DE.UTF-8
fi

"$ROOT/bin/omarchy-menu-language"

grep -F $'English (United States)\ten_US.UTF-8' "$scratch/options" >/dev/null ||
  fail "language picker shows a readable name and locale code"
grep -F $'German (Germany)\tde_DE.UTF-8' "$scratch/options" >/dev/null ||
  fail "language picker offers a locale that is not generated yet"
grep -F $'Arabic (India)\tar_IN.UTF-8' "$scratch/options" >/dev/null ||
  fail "language picker includes UTF-8 entries without a suffix in SUPPORTED"
grep -F $'Catalan (Spain)\tca_ES.UTF-8@valencia' "$scratch/options" >/dev/null ||
  fail "language picker includes UTF-8 locale variants"
grep -Fx -- '--apply' "$scratch/sudo-args" >/dev/null ||
  fail "language picker passes the selection to its privileged phase"
grep -Fx -- "$TEST_CHOICE" "$scratch/sudo-args" >/dev/null ||
  fail "language picker passes the selected locale unchanged"
grep -F 'Log out and back in' "$scratch/notification" >/dev/null ||
  fail "language picker explains when the change takes effect"
pass "language picker offers supported UTF-8 locales and applies the selection"

rm -f "$scratch/sudo-args" "$scratch/notification"
export TEST_CHOICE="$configured"
"$ROOT/bin/omarchy-menu-language"
[[ ! -e $scratch/sudo-args && ! -e $scratch/notification ]] ||
  fail "selecting the configured locale makes no changes"
pass "selecting the configured locale makes no changes"

export TEST_CANCEL=1
if "$ROOT/bin/omarchy-menu-language"; then
  fail "cancelled language selection exits without applying"
fi
[[ ! -e $scratch/sudo-args && ! -e $scratch/notification ]] ||
  fail "cancelled language selection makes no changes"
pass "cancelled language selection makes no changes"
unset TEST_CANCEL

if "$ROOT/bin/omarchy-menu-language" --apply 'de_DE.UTF-8;touch /tmp/unsafe' 2>/dev/null; then
  fail "language picker rejects an invalid locale"
fi
pass "language picker rejects an invalid locale"
