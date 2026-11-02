#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

bash -n "$ROOT/bin/omarchy-powerprofiles-apple-cpufreq-apply" ||
  fail "apple-cpufreq apply script has a syntax error"
bash -n "$ROOT/bin/omarchy-powerprofiles-set" ||
  fail "powerprofiles-set script has a syntax error after apple fallback"
bash -n "$ROOT/bin/omarchy-powerprofiles-list" ||
  fail "powerprofiles-list script has a syntax error after apple fallback"

[[ -f $ROOT/etc/sudoers.d/omarchy-powerprofiles-apple-cpufreq ]] ||
  fail "apple-cpufreq sudoers drop-in is missing"

pass "apple-cpufreq power profile scripts and sudoers drop-in are present"
