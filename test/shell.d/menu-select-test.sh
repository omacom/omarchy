#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command perl

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

STUB_DIR="$TMPDIR/stub"
mkdir -p "$STUB_DIR"
payloads="$TMPDIR/payloads"

# The script under test blocks on the doneFile named inside the payload it
# hands to `omarchy-shell shell summon omarchy.menu <json>` -- so the stub
# records the payload ($4) and then answers the tempfile handshake a real
# shell would: the pick goes to selectionFile and doneFile is created.
cat >"$STUB_DIR/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$4" >>"$CAPTURED_PAYLOADS"
perl -MJSON::PP=decode_json -e '
  my $p = decode_json($ARGV[0]);
  open my $s, ">", $p->{selectionFile} or exit 1;
  print $s $ENV{FAKE_PICK} // "";
  close $s;
  open my $d, ">", $p->{doneFile} or exit 1;
  close $d;
' "$4"
SH
chmod +x "$STUB_DIR/omarchy-shell"

# Runs the real script against the stub shell; the stub answers the handshake
# with $1 as the pick and leaves the payload it was summoned with in $payloads.
run_select() {
  local pick="$1"
  shift
  PATH="$STUB_DIR:$PATH" \
    CAPTURED_PAYLOADS="$payloads" \
    FAKE_PICK="$pick" \
    "$ROOT/bin/omarchy-menu-select" "$@"
}

# A caller that passes --default-index gets the field in the select payload,
# and the selection still comes back through the tempfile handshake.
: >"$payloads"
output=$(run_select b Pick a b c -- --default-index 1)
[[ $output == "b" ]] || fail "menu select returns the picked row" "$output"
pass "menu select returns the picked row"
grep -Fq '"defaultIndex":1' "$payloads" ||
  fail "menu select emits the default index in the payload" "$(cat "$payloads")"
pass "menu select emits the default index in the payload"

# The field is the whole contract: a caller that never passes the flag gets a
# payload with no defaultIndex key at all, identical to before it existed.
: >"$payloads"
run_select a Pick a b c >/dev/null
if grep -q 'defaultIndex' "$payloads"; then
  fail "menu select omits the default index when the flag was not passed" "$(cat "$payloads")"
fi
pass "menu select omits the default index when the flag was not passed"

# A flag with nothing after it fails before any summon, so the stub is never
# reached and the option stream is untouched.
if run_select "" Pick a b c -- --default-index 2>"$TMPDIR/stderr"; then
  fail "menu select rejects --default-index without a value"
fi
pass "menu select rejects --default-index without a value"
grep -q 'requires a value' "$TMPDIR/stderr" ||
  fail "menu select says --default-index requires a value" "$(cat "$TMPDIR/stderr")"
pass "menu select says --default-index requires a value"

# Options that arrive on stdin must survive a post-"--" flag: the flag parses
# after the option stream is collected, never inside it.
: >"$payloads"
printf 'a\nb\n' | run_select b Pick -- --default-index 1 >/dev/null
grep -Fq '"options":["a","b"]' "$payloads" ||
  fail "menu select keeps the stdin option stream intact behind the flag" "$(cat "$payloads")"
pass "menu select keeps the stdin option stream intact behind the flag"
grep -Fq '"defaultIndex":1' "$payloads" ||
  fail "menu select emits the default index for a stdin-fed caller" "$(cat "$payloads")"
pass "menu select emits the default index for a stdin-fed caller"

# The new case arm does not swallow the sibling menu args it sits beside.
: >"$payloads"
run_select b Pick a b c -- --width 400 --maxheight 500 --default-index 1 >/dev/null
for field in '"width":400' '"maxHeight":500' '"defaultIndex":1'; do
  grep -Fq "$field" "$payloads" ||
    fail "menu select carries $field alongside its sibling menu args" "$(cat "$payloads")"
done
pass "menu select carries width, maxHeight, and defaultIndex together"

# A non-numeric value coerces to 0 through perl int(), the same as --width.
: >"$payloads"
run_select a Pick a b c -- --default-index abc >/dev/null
grep -Fq '"defaultIndex":0' "$payloads" ||
  fail "menu select coerces a non-numeric default index to 0" "$(cat "$payloads")"
pass "menu select coerces a non-numeric default index to 0"

# The flag is new surface: no shipped caller passes it yet, so every existing
# invocation keeps its absent-field payload. Phase 6 adopts it first.
sweep=$(grep -rln -- '--default-index' "$ROOT/bin" | grep -v '/omarchy-menu-select$' || true)
[[ -z $sweep ]] ||
  fail "no existing caller passes --default-index yet" "$sweep"
pass "no existing caller passes --default-index yet"
