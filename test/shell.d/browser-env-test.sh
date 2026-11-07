#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

envs="$ROOT/default/bash/envs"
uwsm_default="$ROOT/default/uwsm/default"
uwsm_env="$ROOT/default/uwsm/env.d/10-omarchy"

browser=$(env -u BROWSER bash -c 'source "$1"; printf "%s" "$BROWSER"' bash "$envs")
[[ $browser == "omarchy-launch-browser" ]] || fail "bash env provides a default browser" "actual: $browser"
pass "bash env provides a default browser"

browser=$(BROWSER=firefox bash -c 'source "$1"; printf "%s" "$BROWSER"' bash "$envs")
[[ $browser == "firefox" ]] || fail "bash env preserves the inherited browser" "actual: $browser"
pass "bash env preserves the inherited browser"

# A session-wide BROWSER makes xdg-settings refuse "set default-web-browser",
# breaking the browsers' own "Set as default" buttons.
browser=$(env -u BROWSER bash -c 'source "$1"; printf "%s" "${BROWSER:-}"' bash "$uwsm_default")
[[ -z $browser ]] || fail "uwsm session env leaves BROWSER unset" "actual: $browser"
pass "uwsm session env leaves BROWSER unset"

! grep -q "export BROWSER" "$uwsm_env" || fail "uwsm env.d fallback leaves BROWSER unset"
pass "uwsm env.d fallback leaves BROWSER unset"

# uwsm never sources /etc/profile.d, so 10-omarchy has to pull in the flatpak
# package's script itself or the Flatpak export dirs never reach XDG_DATA_DIRS
# and Flatpak apps stay out of the launcher (#17309).
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/bin"
printf '#!/bin/bash\nexit 1\n' >"$tmpdir/bin/omarchy-cmd-present"
chmod +x "$tmpdir/bin/omarchy-cmd-present"
printf 'export FLATPAK_PROFILE_SOURCED=1\n' >"$tmpdir/flatpak.sh"
# The env bootstrap is repointed away so a dev-linked host cannot put its own
# checkout's bin ahead of the stubs, and HOME keeps user uwsm overrides out.
sed -e "s#/usr/share/omarchy/default/bash/env-bootstrap#$tmpdir/no-env-bootstrap#g" \
  -e "s#/etc/profile.d/flatpak.sh#$tmpdir/flatpak.sh#g" \
  "$uwsm_env" >"$tmpdir/10-omarchy"
sourced=$(HOME="$tmpdir" PATH="$tmpdir/bin:$PATH" bash -c '. "$1"; printf "%s" "${FLATPAK_PROFILE_SOURCED:-}"' bash "$tmpdir/10-omarchy")
[[ $sourced == "1" ]] || fail "uwsm env.d sources the flatpak profile script" "marker not exported"
pass "uwsm env.d sources the flatpak profile script"
