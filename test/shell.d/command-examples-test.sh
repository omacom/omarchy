#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The help reader must show every example a command declares: one declared as
# ` | `-separated values on a single omarchy:examples line (the convention), and
# one declared across repeated omarchy:examples lines (#18837).

help="$("$ROOT/bin/omarchy" theme install --help)"

if [[ $help == *'https://github.com/example/omarchy-example-theme.git'* ]]; then
  pass "theme install --help shows its https example"
else
  fail "theme install --help shows its https example"
fi

if [[ $help == *'git@github.com:example/omarchy-example-theme.git'* ]]; then
  pass "theme install --help shows its ssh example"
else
  fail "theme install --help shows its ssh example"
fi

# Repeated omarchy:examples lines accumulate instead of the last one replacing
# the rest, so a command that declares them one per line still lists all of them.
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin"
cp "$ROOT/bin/omarchy" "$test_tmp/bin/"

cat >"$test_tmp/bin/omarchy-example-sandbox" <<'METADATA'
#!/bin/bash

# omarchy:summary=Sandbox command for metadata tests
# omarchy:args=[nothing]
# omarchy:examples=omarchy example sandbox first
# omarchy:examples=omarchy example sandbox second

exit 0
METADATA
chmod +x "$test_tmp/bin/omarchy-example-sandbox"

sandbox_help="$(bash "$test_tmp/bin/omarchy" example sandbox --help)"

if [[ $sandbox_help == *'omarchy example sandbox first'* ]]; then
  pass "a second omarchy:examples line does not erase the first"
else
  fail "a second omarchy:examples line does not erase the first"
fi

if [[ $sandbox_help == *'omarchy example sandbox second'* ]]; then
  pass "a second omarchy:examples line is shown"
else
  fail "a second omarchy:examples line is shown"
fi
