#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1789983273.sh"
shipped_config="$ROOT/config/fcitx5/conf/quickphrase.conf"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin"
cat >"$test_dir/bin/systemctl" <<'STUB'
#!/bin/bash

printf '%s\n' "$*" >>"$SYSTEMCTL_CALLS"
STUB
chmod +x "$test_dir/bin/systemctl"

export SYSTEMCTL_CALLS="$test_dir/systemctl-calls"
home="$test_dir/home"
user_config="$home/.config/fcitx5/conf/quickphrase.conf"

run_migration() {
  : >"$SYSTEMCTL_CALLS"
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$ROOT/bin:$PATH" \
    bash -euo pipefail "$migration" >/dev/null
}

reset_home() {
  rm -rf "$home"
  mkdir -p "$(dirname "$user_config")"
}

expected_default=$'[TriggerKey]\n0=Super+semicolon'
[[ $(cat "$shipped_config") == "$expected_default" ]] ||
  fail "the shipped config keeps only the non-conflicting QuickPhrase trigger" "$(cat "$shipped_config")"
pass "the shipped config keeps only the non-conflicting QuickPhrase trigger"

reset_home
run_migration
cmp -s "$shipped_config" "$user_config" ||
  fail "the migration seeds the shipped QuickPhrase config for an unconfigured user" "$(cat "$user_config")"
[[ $(cat "$SYSTEMCTL_CALLS") == "--user try-restart omarchy-fcitx5.service" ]] ||
  fail "seeding the config reloads a running fcitx5 service" "$(cat "$SYSTEMCTL_CALLS")"
pass "the migration seeds and reloads QuickPhrase for an unconfigured user"

before=$(sha256sum "$user_config")
run_migration
[[ $before == $(sha256sum "$user_config") ]] || fail "rerunning the migration keeps the seeded config unchanged"
[[ ! -s $SYSTEMCTL_CALLS ]] || fail "rerunning the migration does not reload fcitx5"
pass "the migration is idempotent after seeding the config"

reset_home
cat >"$user_config" <<'EOF'
# Trigger Key
# [TriggerKey]
# 0=Super+grave
# 1=Super+semicolon
Choose Modifier=Alt
EOF
before=$(sha256sum "$user_config")
mkdir -p "$test_dir/failing-bin"
cat >"$test_dir/failing-bin/cat" <<'STUB'
#!/bin/bash

printf '%s\n' '[TriggerKey]'
exit 1
STUB
chmod +x "$test_dir/failing-bin/cat"
: >"$SYSTEMCTL_CALLS"
if HOME="$home" OMARCHY_PATH="$ROOT" PATH="$test_dir/failing-bin:$test_dir/bin:$ROOT/bin:$PATH" \
  bash -euo pipefail "$migration" >/dev/null; then
  fail "the migration reports an interrupted config write"
fi
[[ $before == $(sha256sum "$user_config") ]] || fail "an interrupted config write leaves the original unchanged"
[[ ! -s $SYSTEMCTL_CALLS ]] || fail "an interrupted config write does not reload fcitx5"
pass "the migration updates an existing config atomically"

run_migration
expected_existing=$'# Trigger Key\n# [TriggerKey]\n# 0=Super+grave\n# 1=Super+semicolon\nChoose Modifier=Alt\n\n[TriggerKey]\n0=Super+semicolon'
[[ $(cat "$user_config") == "$expected_existing" ]] ||
  fail "the migration adds the Omarchy default when only commented defaults exist" "$(cat "$user_config")"
[[ $(cat "$SYSTEMCTL_CALLS") == "--user try-restart omarchy-fcitx5.service" ]] ||
  fail "repairing an inherited trigger reloads fcitx5" "$(cat "$SYSTEMCTL_CALLS")"
pass "the migration repairs an existing config that still inherits upstream triggers"

before=$(sha256sum "$user_config")
run_migration
[[ $before == $(sha256sum "$user_config") ]] || fail "rerunning the repaired config leaves it unchanged"
[[ ! -s $SYSTEMCTL_CALLS ]] || fail "rerunning the repaired config does not reload fcitx5"
pass "the migration is idempotent after repairing an inherited trigger"

reset_home
cat >"$user_config" <<'EOF'
[TriggerKey]
0=Control+semicolon
Choose Modifier=Alt
EOF
before=$(sha256sum "$user_config")
run_migration
[[ $before == $(sha256sum "$user_config") ]] || fail "the migration preserves a custom trigger list"
[[ ! -s $SYSTEMCTL_CALLS ]] || fail "preserving a custom trigger list does not reload fcitx5"
pass "the migration preserves a custom trigger list"

reset_home
linked_config="$test_dir/linked-quickphrase.conf"
cat >"$linked_config" <<'EOF'
# Trigger Key
# [TriggerKey]
# 0=Super+grave
# 1=Super+semicolon
Choose Modifier=Alt
EOF
ln -s "$linked_config" "$user_config"
run_migration
[[ -L $user_config ]] || fail "the migration preserves a symlinked user config"
[[ $(cat "$linked_config") == "$expected_existing" ]] ||
  fail "the migration updates the target of a symlinked user config" "$(cat "$linked_config")"
[[ $(cat "$SYSTEMCTL_CALLS") == "--user try-restart omarchy-fcitx5.service" ]] ||
  fail "repairing a symlinked trigger config reloads fcitx5" "$(cat "$SYSTEMCTL_CALLS")"
pass "the migration atomically repairs a symlinked user config"

reset_home
printf 'TriggerKey=\n' >"$user_config"
before=$(sha256sum "$user_config")
run_migration
[[ $before == $(sha256sum "$user_config") ]] || fail "the migration preserves an explicitly disabled trigger"
[[ ! -s $SYSTEMCTL_CALLS ]] || fail "preserving an explicitly disabled trigger does not reload fcitx5"
pass "the migration preserves an explicitly disabled trigger"
