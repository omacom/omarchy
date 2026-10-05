#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/home"
export HOME="$scratch/home" OMARCHY_PATH="$ROOT" CF_TEST_LOG="$scratch/calls"
export PATH="$scratch/bin:$PATH"
cat > "$scratch/bin/cf" <<'STUB'
#!/bin/bash
printf 'cf %s\n' "$*" >> "$CF_TEST_LOG"
exit "${CF_TEST_AUTH_EXIT:-0}"
STUB
cat > "$scratch/bin/omarchy-cmd-missing" <<'STUB'
#!/bin/bash
[[ ${CF_TEST_MISSING:-0} == 1 ]]
STUB
for helper in omarchy-mise-install omarchy-webapp-install omarchy-webapp-remove omarchy-plugin-enable omarchy-plugin-disable; do
  cat > "$scratch/bin/$helper" <<'STUB'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >> "$CF_TEST_LOG"
STUB
done
chmod +x "$scratch/bin/"*

if CF_TEST_AUTH_EXIT=130 bash "$ROOT/bin/omarchy-install-service-cloudflare"; then
  fail "interrupted Cloudflare login aborts setup"
fi
[[ $(cat "$CF_TEST_LOG") == 'cf auth login' ]] || fail "interrupted Cloudflare login adds nothing"
pass "interrupted Cloudflare login adds no web app or widget"

: > "$CF_TEST_LOG"
CF_TEST_MISSING=1 bash "$ROOT/bin/omarchy-install-service-cloudflare"
[[ $(head -n 1 "$CF_TEST_LOG") == 'omarchy-mise-install npm:cf cf' ]] || fail "missing cf is installed"
grep -q '^omarchy-webapp-install Cloudflare https://dash.cloudflare.com ' "$CF_TEST_LOG" || fail "successful login installs dashboard"
pass "Cloudflare setup reinstalls a missing CLI before login and dashboard creation"

: > "$CF_TEST_LOG"
for ((repeat = 0; repeat < 2; repeat++)); do
  bash "$ROOT/bin/omarchy-install-service-cloudflare"
  CF_TEST_AUTH_EXIT=1 bash "$ROOT/bin/omarchy-remove-service-cloudflare"
done
[[ $(grep -c '^cf auth login$' "$CF_TEST_LOG") == 2 ]] || fail "repeated install signs in"
[[ $(grep -c '^omarchy-webapp-remove Cloudflare$' "$CF_TEST_LOG") == 2 ]] || fail "repeated removal cleans dashboard despite failed logout"
pass "repeated Cloudflare setup and removal tolerate failed logout"
