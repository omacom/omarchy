#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Bash writes EPOCHREALTIME with the locale's decimal separator, a comma in
# da_DK and most of Europe. Build such a locale here rather than rely on one
# being installed.
mkdir -p "$test_tmp/locales"
if ! localedef -i da_DK -f UTF-8 "$test_tmp/locales/da_DK.UTF-8" >/dev/null 2>&1; then
  skip "microsecond clocks ignore a comma decimal separator: localedef cannot build da_DK"
  exit 0
fi
[[ $(LOCPATH="$test_tmp/locales" LC_ALL=da_DK.UTF-8 bash -c 'echo "$EPOCHREALTIME"') == *,* ]] ||
  fail "the generated locale writes EPOCHREALTIME with a comma"

for command in omarchy-dev-benchmark-cli omarchy-dev-benchmark-theme-switcher; do
  now=$(LOCPATH="$test_tmp/locales" LC_ALL=da_DK.UTF-8 bash -c '
    source <(awk "/^now_us\\(\\) \\{/ { copying=1 } copying { print } copying && /^}\$/ { exit }" "$1")
    now_us
  ' _ "$ROOT/bin/$command")
  [[ $now =~ ^[0-9]{16}$ ]] || fail "$command measures microseconds under a comma locale" "$now"
done
pass "microsecond clocks ignore a comma decimal separator"
