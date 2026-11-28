#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -r "$tmp_dir"' EXIT

# The stub picker drains stdin like the real one, so the offered list can be
# asserted; sudo records its call instead of escalating.
cat >"$tmp_dir/omarchy-menu-select" <<'EOF'
#!/bin/bash
cat >"$STUB_DIR/list"
printf '%s\n' "$PICKED"
EOF

cat >"$tmp_dir/sudo" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$STUB_DIR/sudo-calls"
EOF

printf '#!/bin/bash\nprintf "%%s\\n" "$1"\n' >"$tmp_dir/omarchy-i18n"
printf '#!/bin/bash\nexit 0\n' >"$tmp_dir/omarchy-shell"
printf '#!/bin/bash\nexit 0\n' >"$tmp_dir/omarchy-notification-send"
chmod +x "$tmp_dir/omarchy-menu-select" "$tmp_dir/sudo" "$tmp_dir/omarchy-i18n" "$tmp_dir/omarchy-shell" "$tmp_dir/omarchy-notification-send"

export STUB_DIR="$tmp_dir" PICKED="Asia/Ashgabat"
PATH="$tmp_dir:$PATH" "$ROOT/bin/omarchy-menu-timezone" >/dev/null

grep -qFx Asia/Ashgabat "$tmp_dir/list" || fail "the timezone menu offers the canonical zone"
! grep -qFx Asia/Ashkhabad "$tmp_dir/list" || fail "the timezone menu drops tzdata backward-compatibility aliases"
grep -qFx UTC "$tmp_dir/list" || fail "the timezone menu offers UTC, which zone.tab omits"
grep -qFx Etc/GMT+5 "$tmp_dir/list" || fail "the timezone menu offers the fixed-offset zones"
grep -qFx 'timedatectl set-timezone Asia/Ashgabat' "$tmp_dir/sudo-calls" ||
  fail "the timezone menu sets the picked zone over sudo timedatectl" "$(cat "$tmp_dir/sudo-calls")"
pass "the timezone menu lists zone.tab's zones without tzdata aliases"
