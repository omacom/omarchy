#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin"

# top formats its summary in the caller's locale, as procps does: Spanish keeps
# the labels and writes decimal commas, German also translates "Cpu".
cat >"$work/bin/top" <<'SH'
#!/bin/bash
case ${LC_ALL:-} in
  C) echo "%Cpu(s):  5.6 us,  3.4 sy,  0.0 ni,$IDLE id,  4.5 wa,  1.1 hi,  1.1 si,  0.0 st" ;;
  es_ES.UTF-8) echo "%Cpu(s):  5,6 us,  3,4 sy,  0,0 ni,${IDLE/./,} id,  4,5 wa,  1,1 hi,  1,1 si,  0,0 st" ;;
  *) echo "%CPU(s):  5,6 us,  3,4 sy,  0,0 ni,${IDLE/./,} id,  4,5 wa,  1,1 hi,  1,1 si,  0,0 st" ;;
esac
SH
chmod +x "$work/bin/top"

cpu() {
  IDLE="$2" LC_ALL="$1" PATH="$work/bin:$PATH" "$ROOT/bin/omarchy-system-stats" | awk -F'\t' '$1 == "cpu" { print $2 }'
}

[[ $(cpu es_ES.UTF-8 " 84.3") == "16%" ]] || fail 'system stats reads CPU idle the same in a decimal-comma locale' "$(cpu es_ES.UTF-8 " 84.3")"
pass 'system stats reads CPU idle the same in a decimal-comma locale'

[[ $(cpu de_DE.UTF-8 " 84.3") == "16%" ]] || fail 'system stats reads CPU idle where top translates its labels' "$(cpu de_DE.UTF-8 " 84.3")"
pass 'system stats reads CPU idle where top translates its labels'

[[ $(cpu C "100.0") == "0%" ]] || fail 'system stats reads a fully idle CPU as idle' "$(cpu C "100.0")"
pass 'system stats reads a fully idle CPU as idle'
