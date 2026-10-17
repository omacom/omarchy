#!/bin/bash

# #114: omarchy-upload-log runs from the live ISO, where the omarchy package (and the helpers it
# ships, omarchy-cmd-present among them) is not installed yet. The script has to gather its own
# system information there, and must not depend on a helper that is not in PATH.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stub="$tmpdir/bin"
mkdir -p "$stub"

cat >"$stub/fastfetch" <<'SH'
#!/bin/bash
printf 'FASTFETCH RAN %s\n' "$*"
SH

# The uploader: keep the file it was handed so the test can read what was gathered.
cat >"$stub/curl" <<'SH'
#!/bin/bash
for argument in "$@"; do
  case "$argument" in
    file=@*) cat "${argument#file=@}" >"$UPLOAD_CAPTURE" ;;
  esac
done
printf 'https://logs.omarchy.org/example\n'
SH
chmod +x "$stub"/*

# Only the tools the install upload uses, not /usr/bin: an installed Omarchy has omarchy-cmd-present
# there, which would hide exactly the live ISO's situation this test is about.
for command in cat cmp date stat uname; do
  ln -s "$(command -v "$command")" "$stub/$command"
done

run_without_omarchy_helpers() {
  UPLOAD_CAPTURE="$tmpdir/uploaded" PATH="$stub" "$BASH" "$ROOT/bin/omarchy-upload-log" install
}

status=0
output=$(run_without_omarchy_helpers 2>"$tmpdir/stderr") || status=$?

(( status == 0 )) || fail "the live ISO upload exits cleanly" "status=$status stderr: $(cat "$tmpdir/stderr")"
if grep -q 'omarchy-cmd-present' "$tmpdir/stderr"; then
  fail "the upload does not call a helper the live ISO lacks" "$(cat "$tmpdir/stderr")"
fi
grep -q 'FASTFETCH RAN' "$tmpdir/uploaded" 2>/dev/null ||
  fail "an available fastfetch is used for the system information" "$(cat "$tmpdir/uploaded" 2>/dev/null | head -20)"
pass "the upload gathers system information without omarchy's helpers"
