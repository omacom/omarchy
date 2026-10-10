#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

owner="$ROOT/bin/omarchy-provision-owner"

grep -q 'configure_locale()' "$owner" || fail "provision-owner must define configure_locale"
grep -q 'en_GB.UTF-8' "$owner" || fail "provision-owner must map UK installs to en_GB.UTF-8"
grep -q 'Europe/London' "$owner" || fail "provision-owner must map Europe/London to en_GB.UTF-8"
grep -q 'setting locale from keyboard/timezone' "$owner" || fail "provisioning must call configure_locale"

# The UK keyboard branch must come before the timezone fallback.
python3 - "$owner" <<'PY' || fail "locale mapping order is wrong"
import pathlib, re, sys
text = pathlib.Path(sys.argv[1]).read_text()
fn = re.search(r"^configure_locale\(\) \{.*?\n\}\n", text, re.M | re.S).group(0)
assert "uk) locale=en_GB.UTF-8" in fn
assert "Europe/London) locale=en_GB.UTF-8" in fn
assert fn.index("uk)") < fn.index("Europe/London")
assert "/etc/locale.conf" in fn
assert "locale.gen" in fn
print("ok")
PY

pass "UK keyboard selects en_GB.UTF-8"
pass "Europe/London timezone selects en_GB.UTF-8"
pass "configure_locale writes locale.conf and enables locale.gen"
