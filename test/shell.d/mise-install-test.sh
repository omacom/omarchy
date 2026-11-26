#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
home="$tmpdir/home"
bin="$home/.local/bin"
mkdir -p "$bin"

retire() {
  HOME="$home" "$ROOT/bin/omarchy-mise-install" "$@"
}

wrapper() {
  printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet "%s" || exit 1\nexec mise x "%s" -- "%s" "$@"\n' "$1" "$1" "$2"
}

# The wrapper an older release wrote goes.
wrapper npm:@moonshot-ai/kimi-code kimi >"$bin/kimi"
retire npm:@moonshot-ai/kimi-code kimi
[[ ! -e $bin/kimi ]] || fail "an old mise wrapper is removed"
pass "an old mise wrapper is removed"

# Anything else at the path is the user's own: a link from Cursor's installer,
# a wrapper the user changed, or a script of theirs.
ln -s /usr/bin/true "$bin/cursor-agent"
{ wrapper muse muse; echo "# my flags"; } >"$bin/muse"
printf '#!/bin/bash\necho my kimi\n' >"$bin/kimi"
retire cursor-agent
retire muse
retire npm:@moonshot-ai/kimi-code kimi
[[ -L $bin/cursor-agent && -f $bin/muse && -f $bin/kimi ]] || fail "a user's own command at the path stays"
pass "a user's own command at the path stays"

# Nothing is written where there was nothing, which is what older migrations
# that once created wrappers now get.
retire grok
[[ ! -e $bin/grok ]] || fail "no wrapper is written"
pass "no wrapper is written"

if retire npm:x ../escape 2>/dev/null; then
  fail "a command name that leaves ~/.local/bin is refused"
fi
pass "a command name that leaves ~/.local/bin is refused"
