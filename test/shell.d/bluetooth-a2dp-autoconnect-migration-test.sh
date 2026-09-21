#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1790015500.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin"
export CALL_LOG="$test_dir/calls"
: > "$CALL_LOG"

cat > "$test_dir/bin/systemctl" <<'SH'
#!/bin/bash
if [[ "$*" == *"--user try-restart wireplumber.service"* ]]; then
  echo "wireplumber-restart" >> "$CALL_LOG"
fi
exit 0
SH
chmod +x "$test_dir/bin/"*

export PATH="$test_dir/bin:$ROOT/bin:$PATH"
export OMARCHY_PATH="$ROOT"

home="$test_dir/home"
conf_rel="wireplumber/wireplumber.conf.d/bluetooth-a2dp-autoconnect.conf"
user_conf="$home/.config/$conf_rel"

# Case 1: Existing config contains a2dp_source
mkdir -p "$(dirname "$user_conf")"
cat > "$user_conf" <<'EOF'
monitor.bluez.rules = [
  {
    matches = [
      {
        device.name = "~bluez_card.*"
      }
    ]
    actions = {
      update-props = {
        bluez5.auto-connect = [ a2dp_sink a2dp_source ]
      }
    }
  }
]
EOF

HOME="$home" bash -euo pipefail "$migration" >/dev/null

grep -q "a2dp_source" "$user_conf" && fail "migration drops a2dp_source from user config"
grep -q "a2dp_sink" "$user_conf" || fail "migration retains a2dp_sink in user config"
grep -Fxq "wireplumber-restart" "$CALL_LOG" || fail "migration restarts wireplumber when config was updated"
pass "migration drops a2dp_source and restarts wireplumber"

# Case 2: Idempotency
: > "$CALL_LOG"
HOME="$home" bash -euo pipefail "$migration" >/dev/null
[[ ! -s "$CALL_LOG" ]] || fail "migration is idempotent and does not restart wireplumber again"
pass "migration is idempotent"

# Case 3: Missing config is left untouched
rm -rf "$home"
mkdir -p "$home"
: > "$CALL_LOG"
HOME="$home" bash -euo pipefail "$migration" >/dev/null
[[ ! -e "$user_conf" ]] || fail "migration does not create user config if it was not already present"
[[ ! -s "$CALL_LOG" ]] || fail "migration does not restart wireplumber when no config was present"
pass "missing config is untouched"
