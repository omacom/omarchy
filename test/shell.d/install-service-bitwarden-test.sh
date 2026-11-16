#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"

# Any transaction carrying bitwarden-cli fails, as it does beside the nodejs package (#12726).
cat >"$test_tmp/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
echo "add:$*" >>"$TEST_LOG"
[[ " $* " != *" bitwarden-cli "* ]]
SH
printf '#!/bin/bash\necho nodejs\n' >"$test_tmp/bin/pacman"
printf '#!/bin/bash\necho "launch:$*" >>"$TEST_LOG"\n' >"$test_tmp/bin/setsid"
chmod +x "$test_tmp/bin"/*

PATH="$test_tmp/bin:$PATH" TEST_LOG="$test_tmp/log" bash "$ROOT/bin/omarchy-install-service-bitwarden" >"$test_tmp/out" 2>&1 ||
  fail "Bitwarden installer survives a failed CLI install" "$(cat "$test_tmp/out")"

for _ in {1..50}; do
  grep -q '^launch:' "$test_tmp/log" && break
  sleep 0.02
done

if grep -Fxq 'add:bitwarden' "$test_tmp/log" && grep -Fxq 'launch:uwsm-app -- gtk-launch bitwarden' "$test_tmp/log" && grep -q 'conflicts with the installed nodejs' "$test_tmp/out"; then
  pass "Bitwarden installer installs and opens the desktop app when the CLI conflicts with nodejs"
else
  fail "Bitwarden installer installs and opens the desktop app when the CLI conflicts with nodejs" "$(cat "$test_tmp/log" "$test_tmp/out")"
fi
