#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
migration="$ROOT/migrations/1793769095.sh"

mkdir -p "$test_tmp/bin"
cat >"$test_tmp/bin/pw-metadata" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$PW_METADATA_LOG"
EOF
chmod +x "$test_tmp/bin/pw-metadata"

run_migration() {
  local test_home="$1" config_home="$2" metadata_log="$3"

  mkdir -p "$test_home" "$config_home"
  env -i \
    HOME="$test_home" \
    XDG_CONFIG_HOME="$config_home" \
    OMARCHY_PATH="$ROOT" \
    PATH="$test_tmp/bin:$ROOT/bin:/usr/bin" \
    PW_METADATA_LOG="$metadata_log" \
    bash -euo pipefail "$migration" >/dev/null
}

home="$test_tmp/install-home"
config_home="$test_tmp/install-config"
metadata_log="$test_tmp/install-metadata"
run_migration "$home" "$config_home" "$metadata_log"
[[ -f $config_home/pipewire/pipewire.conf.d/10-sample-rates.conf ]] || fail "migration installs the drop-in under XDG_CONFIG_HOME"
[[ ! -e $home/.config/pipewire/pipewire.conf.d/10-sample-rates.conf ]] || fail "migration does not write to HOME/.config when XDG_CONFIG_HOME differs"
grep -q 'clock.allowed-rates' "$metadata_log" || fail "migration applies the rates to the running graph"
pass "migration installs PipeWire rates under XDG_CONFIG_HOME"

home="$test_tmp/existing-home"
config_home="$test_tmp/existing-config"
metadata_log="$test_tmp/existing-metadata"
mkdir -p "$config_home/pipewire"
printf 'context.properties = {\n  default.clock.allowed-rates = [ 48000 ]\n}\n' >"$config_home/pipewire/pipewire.conf"
run_migration "$home" "$config_home" "$metadata_log"
[[ ! -e $config_home/pipewire/pipewire.conf.d/10-sample-rates.conf ]] || fail "migration leaves custom rates under XDG_CONFIG_HOME alone"
[[ ! -e $metadata_log ]] || fail "migration does not change live rates when custom rates exist"
pass "migration preserves custom rates under XDG_CONFIG_HOME"
