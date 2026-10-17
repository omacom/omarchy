#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

stub_bin=$(mktemp -d)
trap 'rm -rf "$stub_bin"' EXIT

# Prints the CPU line the way procps top does in the numeric locale it was started under.
cat >"$stub_bin/top" <<'EOF'
#!/bin/bash
case ${LC_ALL:-${LC_NUMERIC:-${LANG:-C}}} in
  C | POSIX) printf '%s\n' "$TOP_C" ;;
  *) printf '%s\n' "$TOP_COMMA" ;;
esac
EOF
chmod +x "$stub_bin/top"

cpu_with() {
  TOP_C=$1 TOP_COMMA=$2 PATH="$stub_bin:$PATH" LC_ALL= LANG=es_ES.UTF-8 LC_NUMERIC=es_ES.UTF-8 \
    "$ROOT/bin/omarchy-system-stats" | awk -F '\t' '$1 == "cpu" { print $2 }'
}

busy=$(cpu_with \
  '%Cpu(s):  5.6 us,  3.4 sy,  0.0 ni, 84.3 id,  4.5 wa,  1.1 hi,  1.1 si,  0.0 st' \
  '%Cpu(s):  5,6 us,  3,4 sy,  0,0 ni, 84,3 id,  4,5 wa,  1,1 hi,  1,1 si,  0,0 st')
[[ $busy == "16%" ]] || fail "cpu percentage under a decimal-comma locale is 16%" "$busy"
pass "cpu percentage under a decimal-comma locale is 16%"

idle=$(cpu_with \
  '%Cpu(s):  0.0 us,  0.0 sy,  0.0 ni,100.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st' \
  '%Cpu(s):  0,0 us,  0,0 sy,  0,0 ni,100,0 id,  0,0 wa,  0,0 hi,  0,0 si,  0,0 st')
[[ $idle == "0%" ]] || fail "cpu percentage of a fully idle machine is 0%" "$idle"
pass "cpu percentage of a fully idle machine is 0%"

iowait=$(cpu_with \
  '%Cpu(s):  0.0 us,  0.0 sy,  0.0 ni,  0.0 id,100.0 wa,  0.0 hi,  0.0 si,  0.0 st' \
  '%Cpu(s):  0,0 us,  0,0 sy,  0,0 ni,  0,0 id,100,0 wa,  0,0 hi,  0,0 si,  0,0 st')
[[ $iowait == "100%" ]] || fail "cpu percentage of a machine waiting on I/O is 100%" "$iowait"
pass "cpu percentage of a machine waiting on I/O is 100%"
