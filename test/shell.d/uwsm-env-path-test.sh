#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

uwsm_env="$ROOT/default/uwsm/env.d/10-omarchy"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# A mise that would prepend its shims if the session activated it
mkdir -p "$tmpdir/bin" "$tmpdir/home"
cat >"$tmpdir/bin/mise" <<'SH'
#!/bin/bash
[[ $1 == "activate" ]] && printf 'export PATH="%s:$PATH"\n' "$HOME/.local/share/mise/shims"
SH
printf '#!/bin/bash\ncommand -v "$1" >/dev/null\n' >"$tmpdir/bin/omarchy-cmd-present"
chmod +x "$tmpdir/bin/mise" "$tmpdir/bin/omarchy-cmd-present"

# Load this tree's env-bootstrap rather than whatever is installed
printf 'export OMARCHY_PATH="/usr/share/omarchy"\n' >"$tmpdir/omarchy.conf"
sed "s#/etc/omarchy.conf#$tmpdir/omarchy.conf#g" "$ROOT/default/bash/env-bootstrap" >"$tmpdir/env-bootstrap"
sed "s#/usr/share/omarchy/default/bash/env-bootstrap#$tmpdir/env-bootstrap#g" "$uwsm_env" >"$tmpdir/10-omarchy"

# env-bootstrap appends the shims after the system paths; the session must not
# move them back in front of /usr/bin or the user's own directories.
path=$(HOME="$tmpdir/home" PATH="$tmpdir/bin:/usr/bin" sh -c '. "$1"; printf "%s" "$PATH"' sh "$tmpdir/10-omarchy")
[[ $path == "$tmpdir/bin:/usr/bin:$tmpdir/home/.local/share/mise/shims:$tmpdir/home/.local/bin" ]] || fail "uwsm session env leaves mise shims behind the system paths" "actual PATH: $path"
pass "uwsm session env leaves mise shims behind the system paths"
