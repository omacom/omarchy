#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup_printer="$ROOT/bin/omarchy-setup-printer"
faq="$ROOT/manual/46-faq.md"
cups_browsed="$ROOT/etc/cups/cups-browsed.conf"
menu="$ROOT/default/omarchy/omarchy-menu.jsonc"

rg -q 'omarchy:summary=Add a network printer with the driverless IPP Everywhere profile' "$setup_printer" ||
  fail "setup-printer advertises IPP Everywhere"
rg -q 'lpadmin -p "\$queue" -E -v "\$uri" -m everywhere' "$setup_printer" ||
  fail "setup-printer creates queues with the everywhere model"
rg -q 'driverless list' "$setup_printer" ||
  fail "setup-printer discovers printers through driverless"
pass "setup-printer prefers IPP Everywhere for network printers"

rg -qxF 'CreateIPPPrinterQueues Driverless' "$cups_browsed" ||
  fail "cups-browsed policy stays limited to driverless IPP queues"
pass "cups-browsed policy stays limited to driverless IPP queues"

rg -q 'omarchy setup printer' "$faq" ||
  fail "FAQ documents the IPP Everywhere setup command"
rg -q 'universal.*/pdftopdf|pdftopdf' "$faq" ||
  fail "FAQ warns against universal/pdftopdf brand drivers"
pass "FAQ prefers IPP Everywhere over brand PPDs"

rg -q 'omarchy-setup-printer' "$menu" ||
  fail "Setup menu exposes the printer wizard"
pass "Setup menu exposes the printer wizard"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"
cat >"$tmp_dir/bin/driverless" <<'SH'
#!/bin/bash
if [[ ${1:-} == "list" ]]; then
  printf '%s\n' '"driverless:ipp://EPSON._ipp._tcp.local/ipp/print" en "Epson" "Epson ET-2850, driverless, cups-filters 2.0.0" ""'
fi
exit 0
SH
cat >"$tmp_dir/bin/sudo" <<'SH'
#!/bin/bash
# Record the privileged command and run it from PATH so lpadmin is mocked.
printf '%s\n' "$*" >>"$LPADMIN_LOG"
exec "$@"
SH
cat >"$tmp_dir/bin/lpadmin" <<'SH'
#!/bin/bash
printf 'lpadmin %s\n' "$*" >>"$LPADMIN_LOG"
exit 0
SH
chmod +x "$tmp_dir/bin/driverless" "$tmp_dir/bin/sudo" "$tmp_dir/bin/lpadmin"

LPADMIN_LOG="$tmp_dir/lpadmin.log"
: >"$LPADMIN_LOG"
PATH="$tmp_dir/bin:$PATH" LPADMIN_LOG="$LPADMIN_LOG" \
  "$setup_printer" Office 'ipp://192.168.1.50/ipp/print'

grep -qx 'lpadmin -p Office -E -v ipp://192.168.1.50/ipp/print -m everywhere' "$LPADMIN_LOG" ||
  fail "direct URI path creates an Everywhere queue" "$(cat "$LPADMIN_LOG")"
grep -qx 'lpadmin -p Office -o printer-error-policy=retry-job' "$LPADMIN_LOG" ||
  fail "direct URI path sets a retry error policy" "$(cat "$LPADMIN_LOG")"
pass "direct URI path creates an Everywhere queue"

: >"$LPADMIN_LOG"
PATH="$tmp_dir/bin:$PATH" LPADMIN_LOG="$LPADMIN_LOG" \
  "$setup_printer" </dev/null >"$tmp_dir/discovery.log" ||
  fail "quoted driverless discovery succeeds" "$(cat "$tmp_dir/discovery.log")"

rg -qxF 'lpadmin -p Epson_ET-2850__driverless__cups-filters_2_0_0 -E -v ipp://EPSON._ipp._tcp.local/ipp/print -m everywhere' "$LPADMIN_LOG" ||
  fail "discovered printer is added with Everywhere" "$(cat "$LPADMIN_LOG")"
pass "discovered printer is added with Everywhere"
