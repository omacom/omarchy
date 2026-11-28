#!/bin/bash

set -euo pipefail

# shellcheck source=base-test.sh
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home" DMI="$test_tmp/dmi" CALLS="$test_tmp/calls"
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"
mkdir -p "$HOME" "$DMI" "$test_tmp/bin"

cat >"$test_tmp/bin/cat" <<'SH'
#!/bin/bash

if [[ $1 == "/sys/class/dmi/id/sys_vendor" ]]; then
  exec /usr/bin/cat "$DMI/sys_vendor"
else
  exec /usr/bin/cat "$@"
fi
SH

cat >"$test_tmp/bin/grep" <<'SH'
#!/bin/bash

args=()
for arg in "$@"; do
  case "$arg" in
    /sys/class/dmi/id/*) arg="$DMI/${arg##*/}" ;;
    /proc/asound/card*/codec*)
      echo 'probe laptop mic codec' >>"$CALLS"
      exit 1
      ;;
  esac
  args+=("$arg")
done
exec /usr/bin/grep "${args[@]}"
SH

cat >"$test_tmp/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash

printf 'install %s\n' "$*" >>"$CALLS"
SH

printf '#!/bin/bash\nexit 0\n' >"$test_tmp/bin/aplay"
chmod +x "$test_tmp/bin/"*

write_dmi() {
  printf '%s\n' "$1" >"$DMI/sys_vendor"
  printf '%s\n' "$2" >"$DMI/board_name"
  printf '%s\n' "$3" >"$DMI/product_name"
  printf '%s\n' 'ROG' >"$DMI/product_family"
}

run_laptop_setup() {
  : >"$CALLS"
  bash -e "$ROOT/install/hardware/asus-rog.sh"
  bash -e "$ROOT/install/user/hardware/asus/fix-audio-mixer.sh"
  bash -e "$ROOT/install/user/hardware/asus/fix-mic.sh"
}

asus='ASUSTeK COMPUTER INC.'
mixer="$HOME/.config/wireplumber/wireplumber.conf.d/alsa-soft-mixer.conf"
write_dmi "$asus" RC71L 'ROG Ally RC71L_RC71L'
run_laptop_setup
[[ ! -s $CALLS && ! -e $mixer ]] || fail 'the original ROG Ally skips all three laptop setup steps'
pass 'the original ROG Ally skips all three laptop setup steps'

write_dmi "$asus" G614J 'ROG Strix G16'
run_laptop_setup
grep -Fxq 'install asusctl' "$CALLS" || fail 'ROG laptops still get asusctl'
[[ -f $mixer ]] || fail 'ROG laptops still get the mixer override'
grep -Fxq 'probe laptop mic codec' "$CALLS" || fail 'ROG laptops still probe for the mic codec'
pass 'ROG laptops still get all three setup steps'

write_dmi "$asus" RC71L 'ROG Ally'
omarchy-hw-rog-ally || fail 'the RC71L board identifies the original Ally'
pass 'the RC71L board identifies the original Ally'

for product in 'ROG Ally RC71L' 'ROG Ally RC71L_RC71L' 'ROG Ally RC71L_Action'; do
  write_dmi "$asus" '' "$product"
  omarchy-hw-rog-ally || fail "the $product product name identifies the original Ally without a board match"
done
pass 'all three RC71L product names identify the original Ally without a board match'

write_dmi "$asus" RC72LA 'ROG Ally X RC72LA_RC72LA'
if omarchy-hw-rog-ally; then fail 'the Ally X is excluded'; fi
write_dmi "$asus" RC71L2 'ROG Ally RC71L2'
if omarchy-hw-rog-ally; then fail 'a partial RC71L match is excluded'; fi
write_dmi 'Other vendor' RC71L 'ROG Ally RC71L'
if omarchy-hw-rog-ally; then fail 'a different vendor is excluded'; fi
pass 'other devices and partial matches are excluded'
