#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command vercmp
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"
export SUNSHINE_VERSION_FILE="$tmp_dir/version" SUNSHINE_CALL_LOG="$tmp_dir/calls"
export PATH="$tmp_dir/bin:$ROOT/bin:$PATH"

# Use the real package-presence helper and version comparison, with no host changes.
cat > "$tmp_dir/bin/pacman" <<'SH'
#!/bin/bash
set -euo pipefail
case "$1" in
  -Q)
    [[ $2 == "sunshine" && -s $SUNSHINE_VERSION_FILE ]] || exit 1
    printf 'sunshine %s\n' "$(cat "$SUNSHINE_VERSION_FILE")"
    ;;
  -S)
    [[ $* == "-S --noconfirm --needed sunshine>=2026.914.233613" ]] || exit 1
    printf '%s\n' "$*" >> "$SUNSHINE_CALL_LOG"
    [[ ${FAIL_UPGRADE:-0} == "0" ]] || exit 1
    if [[ ${KEEP_OLD_VERSION:-0} == "0" ]]; then
      echo '2026.914.233613-1' > "$SUNSHINE_VERSION_FILE"
    fi
    ;;
  -T)
    [[ $2 == "sunshine>=2026.914.233613" ]] || exit 1
    (( $(vercmp "$(cat "$SUNSHINE_VERSION_FILE")" "${2#sunshine>=}") >= 0 )) || exit 127
    ;;
  *) exit 1 ;;
esac
SH
cat > "$tmp_dir/bin/sudo" <<'SH'
#!/bin/bash
[[ $1 == "pacman" ]] || exit 1
"$@"
SH
chmod +x "$tmp_dir/bin/"*
migration="$ROOT/migrations/1789471023.sh"

for version in '' 2026.914.233613-1 2026.914.233613-2 2026.915.100000-1; do
  printf '%s' "$version" > "$SUNSHINE_VERSION_FILE"
  : > "$SUNSHINE_CALL_LOG"
  bash -euo pipefail "$migration" >/dev/null
  [[ ! -s $SUNSHINE_CALL_LOG ]] || fail "absent or patched Sunshine must not be installed or downgraded"
done
pass "absent, patched, and newer Sunshine installations are unchanged"

for version in 2026.516.143833-4 2026.906.222525-1.2; do
  echo "$version" > "$SUNSHINE_VERSION_FILE"
  : > "$SUNSHINE_CALL_LOG"
  bash -euo pipefail "$migration" >/dev/null
  [[ $(cat "$SUNSHINE_VERSION_FILE") == "2026.914.233613-1" ]] || fail "vulnerable Sunshine is upgraded"
  [[ -s $SUNSHINE_CALL_LOG ]] || fail "upgrade uses pacman"
  : > "$SUNSHINE_CALL_LOG"
  bash -euo pipefail "$migration" >/dev/null
  [[ ! -s $SUNSHINE_CALL_LOG ]] || fail "Sunshine upgrade is idempotent"
done
pass "vulnerable Sunshine versions are upgraded once"

echo '2026.906.222525-1.2' > "$SUNSHINE_VERSION_FILE"
if FAIL_UPGRADE=1 bash -euo pipefail "$migration" >/dev/null; then
  fail "a failed package transaction must leave the migration pending"
fi
pass "upgrade failure is propagated"

if KEEP_OLD_VERSION=1 bash -euo pipefail "$migration" >/dev/null; then
  fail "an unchanged vulnerable version must leave the migration pending"
fi
pass "the installed version is verified after upgrading"
