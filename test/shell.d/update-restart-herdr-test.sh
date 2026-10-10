#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin" "$tmp_dir/home/.local/state/omarchy"

# The service phase restarts the shell last; stand in for it so nothing real runs.
for step in omarchy-restart-shell omarchy-state; do
  printf '#!/bin/bash\nexit 0\n' >"$tmp_dir/bin/$step"
  chmod +x "$tmp_dir/bin/$step"
done

# A Herdr whose installed client and running server report their own versions.
cat >"$tmp_dir/bin/herdr" <<'STUB'
#!/bin/bash
case "$*" in
  --version) echo "herdr ${HERDR_CLIENT:-0.9.3}" ;;
  "status server --json")
    if [[ ${HERDR_SERVER:-} == "none" ]]; then
      echo '{"status":"stopped","running":false}'
    else
      printf '{"status":"running","running":true,"version":"%s"}\n' "${HERDR_SERVER:-0.9.3}"
    fi
    ;;
  *) echo "unexpected herdr $*" >&2; exit 1 ;;
esac
STUB
chmod +x "$tmp_dir/bin/herdr"

services() {
  HOME="$tmp_dir/home" PATH="$tmp_dir/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-update-restart" --services-only 2>&1
}

output=$(HERDR_CLIENT=0.9.3 HERDR_SERVER=0.8.2 services)
grep -q 'Herdr 0.9.3 is installed, but its server is still running 0.8.2' <<<"$output" ||
  fail "an outdated running Herdr server is named after an update" "$output"
grep -q "herdr server stop" <<<"$output" ||
  fail "the notice says how to restart the Herdr server" "$output"
pass "an outdated running Herdr server is named after an update"

output=$(HERDR_CLIENT=0.9.3 HERDR_SERVER=0.9.3 services)
if grep -q 'Herdr' <<<"$output"; then fail "a current Herdr server gets no notice" "$output"; fi
pass "a current Herdr server gets no notice"

output=$(HERDR_CLIENT=0.9.3 HERDR_SERVER=none services)
if grep -q 'Herdr' <<<"$output"; then fail "no notice without a running Herdr server" "$output"; fi
pass "no notice without a running Herdr server"

# Without Herdr the check is skipped, even if a herdr elsewhere on PATH would answer.
printf '#!/bin/bash\n[[ $1 != "herdr" ]]\n' >"$tmp_dir/bin/omarchy-cmd-present"
chmod +x "$tmp_dir/bin/omarchy-cmd-present"
output=$(HERDR_CLIENT=0.9.3 HERDR_SERVER=0.8.2 services) ||
  fail "the service phase succeeds without Herdr installed" "$output"
if grep -q 'Herdr' <<<"$output"; then fail "no Herdr notice without Herdr installed" "$output"; fi
pass "the service phase succeeds without Herdr installed"
