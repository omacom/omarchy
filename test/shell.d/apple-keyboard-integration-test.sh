#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir "$work/bin"
export KEYBOARD_TEST_ROOT="$work" OMARCHY_PATH="$ROOT"
cat > "$work/bin/cat" <<'STUB'
#!/bin/bash
if [[ $1 == /sys/class/dmi/id/product_name ]]; then
  [[ ${DMI_STATUS:-0} == 0 ]] || exit "$DMI_STATUS"
  printf '%s\n' "${DMI_MODEL:-Unknown}"
else
  /usr/bin/cat "$@"
fi
STUB
cat > "$work/bin/sudo" <<'STUB'
#!/bin/bash
set -euo pipefail
[[ $# == 4 && $1 == install && $2 == -Dm644 &&
   $4 == /usr/share/libinput/99-omarchy-macbookpro13-3.quirks ]] || exit 99
/usr/bin/install -Dm644 "$3" "$KEYBOARD_TEST_ROOT$4"
STUB
chmod +x "$work/bin/"*
export PATH="$work/bin:$PATH"
leaf="$ROOT/install/hardware/apple/fix-spi-keyboard-integration.sh"
output="$work/usr/share/libinput/99-omarchy-macbookpro13-3.quirks"

for model in Unknown MacBookPro13,2 MacBookPro14,3 MacBookPro13,30; do
  DMI_MODEL=$model bash -euo pipefail "$leaf"
  [[ ! -e $output ]] || fail "must not install for $model"
done
DMI_STATUS=1 bash -euo pipefail "$leaf"
[[ ! -e $output ]] || fail 'missing DMI must not install the quirk'
pass 'only the observed model is eligible, including when DMI is unavailable'

DMI_MODEL=MacBookPro13,3 bash -euo pipefail "$leaf"
cmp "$ROOT/default/libinput/99-omarchy-macbookpro13-3.quirks" "$output" || fail 'installs the complete quirk'
[[ $(stat -c %a "$output") == 644 ]] || fail 'quirk is installed with mode 644'
DMI_MODEL=MacBookPro13,3 bash -euo pipefail "$leaf"
cmp "$ROOT/default/libinput/99-omarchy-macbookpro13-3.quirks" "$output" || fail 'repeated setup changes the quirk'
pass 'setup installs repeatably without writing administrator local overrides'

DMI_MODEL=MacBookPro13,3 bash -euo pipefail "$ROOT/migrations/1791593012.sh"
DMI_MODEL=MacBookPro13,3 bash -euo pipefail "$ROOT/migrations/1791593012.sh"
cmp "$ROOT/default/libinput/99-omarchy-macbookpro13-3.quirks" "$output" || fail 'migration must use the same quirk as setup'
pass 'migration repeats the same scoped setup safely'

require_command python3
python3 - "$output" <<'PY'
import configparser, fnmatch, sys
c = configparser.ConfigParser(interpolation=None)
c.read(sys.argv[1])
s = c['Omarchy MacBookPro13,3 SPI Keyboard']
pattern = s['MatchDMIModalias']
assert fnmatch.fnmatchcase('dmi:bvntest:svnAppleInc.:pnMacBookPro13,3:pvr1:', pattern)
for vendor, model in [('AppleInc.', 'MacBookPro13,2'), ('AppleInc.', 'MacBookPro13,30'), ('Other', 'MacBookPro13,3')]:
    assert not fnmatch.fnmatchcase(f'dmi:bvntest:svn{vendor}:pn{model}:pvr1:', pattern)
assert s['MatchName'] == 'Apple SPI Keyboard'
assert s['MatchUdevType'] == 'keyboard' and s['MatchBus'] == 'spi'
assert int(s['MatchVendor'], 16) == 0
assert s['AttrKeyboardIntegration'] == 'internal'
PY
pass 'quirk matches the observed vendor-zero keyboard and excludes other models'
