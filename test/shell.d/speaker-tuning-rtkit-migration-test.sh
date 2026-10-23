#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"
export XDG_CONFIG_HOME="$tmp_dir/config" OMARCHY_PATH="$ROOT" CALL_LOG="$tmp_dir/calls"
export PATH="$tmp_dir/bin:$PATH"

cat > "$tmp_dir/bin/systemctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >> "$CALL_LOG"
SH
chmod +x "$tmp_dir/bin/systemctl"

migration="$ROOT/migrations/1790114905.sh"
host_source="$ROOT/default/audio/filter-chain-host.conf"
host_config="$XDG_CONFIG_HOME/pipewire/omarchy-speaker-tuning.conf"
mkdir -p "${host_config%/*}"

grep -q 'args = { rtportal.enabled = false }' "$host_source" ||
  fail "the shipped tuning host asks RTKit directly"
pass "the shipped tuning host asks RTKit directly"

# The copy an earlier Omarchy installed: the same file with the old setting.
sed 's/args = { rtportal.enabled = false }/args = { }/' "$host_source" > "$host_config"
: > "$CALL_LOG"
bash -euo pipefail "$migration" >/dev/null
cmp -s "$host_source" "$host_config" || fail "an installed Omarchy host is replaced"
grep -Fxq -- "--user try-restart omarchy-speaker-tuning.service" "$CALL_LOG" ||
  fail "a replaced host is restarted if it runs"
pass "an installed Omarchy host is replaced and restarted"

: > "$CALL_LOG"
bash -euo pipefail "$migration" >/dev/null
[[ ! -s $CALL_LOG ]] || fail "the migration is idempotent"
pass "the migration is idempotent"

# Another tool's host under the same name, as a community calibrator writes it.
foreign='context.properties = { log.level = 0 }
context.modules = [
  { name = libpipewire-module-rt args = { } flags = [ ifexists nofail ] }
]'
printf '%s\n' "$foreign" > "$host_config"
: > "$CALL_LOG"
bash -euo pipefail "$migration" >/dev/null
[[ $(cat "$host_config") == "$foreign" && ! -s $CALL_LOG ]] ||
  fail "a host another tool wrote is left alone"
pass "a host another tool wrote is left alone"

rm -f "$host_config"
bash -euo pipefail "$migration" >/dev/null
[[ ! -e $host_config && ! -s $CALL_LOG ]] || fail "no tuning installed means nothing to do"
pass "no tuning installed means nothing to do"
