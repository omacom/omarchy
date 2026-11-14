#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
log="$test_tmp/log"
mkdir -p "$stub_bin"

# Record what would be installed and run, instead of reaching pacman or the engine.
cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
echo "pkg-add $*" >>"$LOG"
SH
cat >"$stub_bin/omarchy-local-ai" <<'SH'
#!/bin/bash
echo "local-ai $*" >>"$LOG"
SH
printf '#!/bin/bash\nexit 1\n' >"$stub_bin/omarchy-hw-nvidia"
chmod +x "$stub_bin"/*

run_local() {
  : >"$log"
  LOG="$log" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-agent-local" "$@"
}

run_local use best
[[ $(<"$log") == $'pkg-add podman crun\nlocal-ai use best' ]] || fail "use installs Podman before setting up a model" "$(<"$log")"
pass "use installs Podman before setting up a model"

for help in --help -h; do
  run_local use "$help"
  [[ $(<"$log") == "local-ai use $help" ]] || fail "use $help shows help without installing anything" "$(<"$log")"
  run_local use best "$help"
  [[ $(<"$log") == "local-ai use best $help" ]] || fail "use <recipe> $help shows help without installing anything" "$(<"$log")"
done
pass "use --help shows help without installing anything"

run_local list
[[ $(<"$log") == "local-ai list" ]] || fail "other commands install nothing" "$(<"$log")"
pass "other commands install nothing"
