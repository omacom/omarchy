#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command jq

tmpdir=$(mktemp -d) && [[ -n $tmpdir && -d $tmpdir ]] ||
  fail "the test gets a temporary directory to stub the shell in"
trap 'rm -rf "$tmpdir"' EXIT

stub_bin="$tmpdir/bin"
mkdir -p "$stub_bin"

# Stand in for the menu: keep the payload, then answer through the handshake
# the way Menu.qml's finishRequest does, with whatever the test put in reply.
cat >"$stub_bin/omarchy-shell" <<STUB
#!/bin/bash
payload=\$4
printf '%s' "\$payload" >"$tmpdir/payload"
selection_file=\$(jq -r .selectionFile <<<"\$payload")
done_file=\$(jq -r .doneFile <<<"\$payload")
cat "$tmpdir/reply" >"\$selection_file"
: >"\$done_file"
STUB
chmod +x "$stub_bin/omarchy-shell"

menu_select() {
  PATH="$stub_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-menu-select" "$@"
}

printf 'b\n' >"$tmpdir/reply"
[[ $(menu_select Pick a b -- --width 400) == "b" ]] ||
  fail "a select without --expect returns the selection alone"
[[ $(jq -c 'has("expectKeys")' "$tmpdir/payload") == "false" ]] ||
  fail "a select without --expect asks the menu for no keys" "$(cat "$tmpdir/payload")"
pass "a select without --expect is unchanged"

printf '?\nb\n' >"$tmpdir/reply"
menu_select Pick a b -- --expect '?' --expect '!' >/dev/null
[[ $(jq -c .expectKeys "$tmpdir/payload") == '["?","!"]' ]] ||
  fail "every --expect key reaches the menu" "$(cat "$tmpdir/payload")"
[[ $(menu_select Pick a b -- --expect '?') == $'?\nb' ]] ||
  fail "an expected key comes back on the line before the selection"
pass "an expected key comes back on the line before the selection"

# An Enter pick in a menu that expects keys leaves the key line empty, so the
# selection is always the second line.
printf '\nb\n' >"$tmpdir/reply"
[[ $(menu_select Pick a b -- --expect '?') == $'\nb' ]] ||
  fail "an Enter pick leaves the key line empty"
pass "an Enter pick leaves the key line empty"

: >"$tmpdir/reply"
! menu_select Pick a b -- --expect '?' >/dev/null ||
  fail "a cancelled select still exits non-zero"
pass "a cancelled select still exits non-zero"
