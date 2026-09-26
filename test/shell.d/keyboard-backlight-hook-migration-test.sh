#!/bin/bash

# The hibernate hook is installed by omarchy-hibernation-setup, which returns
# early once hibernation is already configured — so an existing install would
# keep the hook that never restored the level unless a migration replaces it.
# The migration must replace exactly the file this release supersedes, and touch
# nothing else.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1789301036.sh"
previous_hook="$ROOT/test/shell.d/fixtures/keyboard-backlight-previous"
current_hook="$ROOT/default/systemd/system-sleep/keyboard-backlight"
sandbox=$(mktemp -d -p /tmp)
trap 'rm -rf "$sandbox"' EXIT

sleep_dir="$sandbox/system-sleep"
destination="$sleep_dir/keyboard-backlight"
migration_copy="$sandbox/migration.sh"

mkdir -p "$sleep_dir"

# Same rewriting the other migration tests use: point the migration at the
# sandbox and drop the privilege escalation and the root ownership flags, so it
# can run as the test user.
sed \
  -e "s|system_sleep_dir=/usr/lib/systemd/system-sleep|system_sleep_dir=$sleep_dir|" \
  -e "s|sudo ||g" \
  -e "s|-o root -g root ||g" \
  "$migration" >"$migration_copy"

export OMARCHY_PATH="$ROOT"

cp "$previous_hook" "$destination"
chmod 0755 "$destination"

bash -euo pipefail "$migration_copy"
cmp -s "$current_hook" "$destination" ||
  fail "migration replaces the hook that never restored the level"
[[ $(stat -c '%a' "$destination") == 755 ]] ||
  fail "replaced hook stays executable" "mode is $(stat -c '%a' "$destination")"
pass "migration replaces the superseded hibernate hook"

# Second run: the destination is now the current hook, so nothing changes.
before=$(sha256sum "$destination" | cut -d' ' -f1)
bash -euo pipefail "$migration_copy"
[[ $(sha256sum "$destination" | cut -d' ' -f1) == "$before" ]] ||
  fail "a second run leaves the replaced hook alone"
pass "migration is a no-op once the hook is replaced"

# An administrator's own hook — anything that is not the superseded file — must
# survive untouched.
printf '#!/bin/bash\necho custom\n' >"$destination"
chmod 0755 "$destination"
custom=$(sha256sum "$destination" | cut -d' ' -f1)
bash -euo pipefail "$migration_copy"
[[ $(sha256sum "$destination" | cut -d' ' -f1) == "$custom" ]] ||
  fail "migration leaves a customized hook alone"
pass "migration leaves a customized hook alone"

# A machine that never installed the hook has nothing to repair.
rm -f "$destination"
bash -euo pipefail "$migration_copy"
[[ ! -e $destination ]] ||
  fail "migration does not install the hook where it was never installed"
pass "migration does not install the hook where it was never installed"
