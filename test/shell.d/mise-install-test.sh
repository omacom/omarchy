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

# The wrapper the last releases wrote goes, and so does an older one-line form.
printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet "npm:@moonshot-ai/kimi-code" || exit 1\nexec mise x "npm:@moonshot-ai/kimi-code" -- "kimi" "$@"\n' >"$bin/kimi"
printf '#!/bin/bash\nmise use -g "cursor-agent"\nexec "cursor-agent" "$@"\n' >"$bin/cursor-agent"
retire npm:@moonshot-ai/kimi-code kimi
retire cursor-agent
[[ ! -e $bin/kimi && ! -e $bin/cursor-agent ]] || fail "an old mise wrapper is removed"
pass "an old mise wrapper is removed"

# Anything else at the path is the user's own: a link from Cursor's installer,
# or a script of theirs.
ln -s /usr/bin/true "$bin/cursor-agent"
printf '#!/bin/bash\necho my muse\n' >"$bin/muse"
retire cursor-agent
retire muse
[[ -L $bin/cursor-agent && -f $bin/muse ]] || fail "a user's own command at the path stays"
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
