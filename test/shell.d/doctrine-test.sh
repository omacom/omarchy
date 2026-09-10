#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export OMARCHY_PATH="$ROOT"
export DOCTRINE_TEST_DIR="$scratch"
export TERM=xterm-256color
mkdir -p "$scratch/bin"

cat > "$scratch/bin/gum" <<'STUB'
#!/bin/bash
printf '%s\n' "$1" >> "$DOCTRINE_TEST_DIR/gum-calls"
case "$1" in
  style) ;;
  choose)
    count=$(cat "$DOCTRINE_TEST_DIR/count")
    (( count += 1 ))
    echo "$count" > "$DOCTRINE_TEST_DIR/count"
    choice=$(sed -n "${count}p" "$DOCTRINE_TEST_DIR/choices")
    [[ -n $choice ]] || exit 130
    printf '%s\n' "$choice"
    ;;
  pager)
    cat >> "$DOCTRINE_TEST_DIR/pages"
    ;;
  *) exit 99 ;;
esac
STUB
cat > "$scratch/bin/omarchy-launch-browser" <<'STUB'
#!/bin/bash
printf '%s\n' "$1" >> "$DOCTRINE_TEST_DIR/urls"
STUB
chmod +x "$scratch/bin/"*
export PATH="$scratch/bin:$PATH"

"$ROOT/bin/omarchy" doctrine > "$scratch/short"
"$ROOT/bin/omarchy" doctrine --full > "$scratch/full"
[[ ! -e $scratch/gum-calls ]] || fail "plain output never invokes Gum"
pass "the default and full forms print without invoking Gum"

python3 <<'PY'
import os
from pathlib import Path
root = Path(os.environ['ROOT'])
scratch = Path(os.environ['DOCTRINE_TEST_DIR'])
short = (scratch / 'short').read_text()
full = (scratch / 'full').read_text()
sections = (root / 'default/omarchy/doctrine.md').read_text().split('## ')[1:]
assert len(sections) == 10
for section in sections:
  title, body = section.strip().split('\n', 1)
  assert title in short
  assert ' '.join(body.split()) in ' '.join(full.split())
assert '\x1b' not in short + full
assert max(map(len, full.splitlines())) <= 80
print('ok - plain output includes the original titles and explanations, without escape codes')
PY

for argument in --invalid 3 --plain; do
  if "$ROOT/bin/omarchy" doctrine "$argument" > "$scratch/output" 2> "$scratch/error"; then
    fail "unsupported argument is rejected: $argument"
  else
    (( $? == 2 )) || fail "invalid argument returns usage status"
    [[ ! -s $scratch/output ]] || fail "invalid argument prints no doctrine"
  fi
done
pass "unsupported arguments are rejected"

if "$ROOT/bin/omarchy" doctrine --interactive > "$scratch/output" 2> "$scratch/error"; then
  fail "interactive mode requires a terminal"
else
  (( $? == 2 )) || fail "non-terminal interactive mode returns usage status"
  [[ ! -s $scratch/output ]] || fail "non-terminal interactive mode leaves stdout clean"
fi
pass "interactive mode explains how to read without a terminal"

"$ROOT/bin/omarchy" doctrine --web
[[ $(cat "$scratch/urls") == "https://omarchy.org/doctrine/" ]] || fail "website entry point opens the canonical URL"
pass "website entry point uses the Omarchy browser launcher"

cat > "$scratch/choices" <<'CHOICES'
10  You’re somebody now
Open in browser
Read the full doctrine
Read again
Back to principles
Quit
CHOICES
echo 0 > "$scratch/count"
script -qefc '"$ROOT/bin/omarchy" doctrine --interactive' /dev/null < /dev/null > "$scratch/session"
[[ $(tail -1 "$scratch/urls") == "https://omarchy.org/doctrine/#youre-somebody-now" ]] || fail "principle browser action uses the canonical anchor"
[[ $(rg -c '^The Omarchy Doctrine$' "$scratch/pages") == "3" ]] || fail "interactive reader pages the selection and can reread the full doctrine"
[[ $(rg -c '^Unite the nerds$' "$scratch/pages") == "2" ]] || fail "single-principle view excludes other explanations"
pass "Gum flow reads individual principles, opens section URLs, rereads, and returns to the index"

: > "$scratch/choices"
echo 0 > "$scratch/count"
script -qefc '"$ROOT/bin/omarchy" doctrine --interactive' /dev/null < /dev/null > "$scratch/session"
pass "cancelling the Gum chooser exits cleanly"
