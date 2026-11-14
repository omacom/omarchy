#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/home/.local/state/omarchy" "$test_tmp/bin"
printf '[]\n' >"$test_tmp/home/.local/state/omarchy/clipboard-history.json"

cat >"$test_tmp/bin/jq" <<'SH'
#!/bin/bash
case " $* " in
  *'.type'*) printf 'text\n' ;;
  *'.text'*) printf '%s\n' "$CLIPBOARD_TEST_TEXT" ;;
  *) exit 1 ;;
esac
SH

cat >"$test_tmp/bin/omarchy-launch-browser" <<'SH'
#!/bin/bash
printf '%s' "$1" >"$CLIPBOARD_TEST_BROWSER_OUT"
SH

cat >"$test_tmp/bin/omarchy-launch-editor" <<'SH'
#!/bin/bash
printf '%s' "$1" >"$CLIPBOARD_TEST_EDITOR_OUT"
SH

chmod +x "$test_tmp/bin/"*

run_open() {
  CLIPBOARD_TEST_TEXT="$1" CLIPBOARD_TEST_BROWSER_OUT="$test_tmp/browser" \
    CLIPBOARD_TEST_EDITOR_OUT="$test_tmp/editor" HOME="$test_tmp/home" \
    XDG_STATE_HOME="$test_tmp/state" PATH="$test_tmp/bin:$PATH" \
    bash "$ROOT/bin/omarchy-clipboard-open" --history-index 0
}

run_open 'See https://example.com/docs.'
[[ $(<"$test_tmp/browser") == "https://example.com/docs" ]] ||
  fail "clipboard open leaves sentence punctuation out of the browser URL" "got: $(<"$test_tmp/browser")"
pass "clipboard open leaves sentence punctuation out of the browser URL"

run_open 'https://example.com/docs?q=a.b'
[[ $(<"$test_tmp/browser") == "https://example.com/docs?q=a.b" ]] ||
  fail "clipboard open preserves punctuation inside a URL"
pass "clipboard open preserves punctuation inside a URL"

run_open 'https://example.com/file.'
[[ $(<"$test_tmp/browser") == "https://example.com/file." ]] ||
  fail "clipboard open keeps a literal period in a standalone URL"
pass "clipboard open keeps a literal period in a standalone URL"

rm -f "$test_tmp/browser"
run_open '  https://example.com/file. '
[[ $(<"$test_tmp/browser") == "https://example.com/file." ]] ||
  fail "clipboard open keeps a literal period in a standalone URL with surrounding whitespace" "got: $(<"$test_tmp/browser")"
pass "clipboard open keeps a literal period in a standalone URL with surrounding whitespace"

rm -f "$test_tmp/browser"
run_open 'plain text without a link'
[[ ! -e $test_tmp/browser ]] || fail "clipboard open does not launch a browser for plain text"
[[ $(<"$(<"$test_tmp/editor")") == "plain text without a link" ]] ||
  fail "clipboard open passes plain text to the editor unchanged"
pass "clipboard open passes plain text to the editor unchanged"
