#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

# 10-omarchy must bring the flatpak package's XDG_DATA_DIRS additions into the
# uwsm session (issue #17309): uwsm never sources /etc/profile.d, so a session
# started from the display manager misses the Flatpak export directories and
# Flatpak apps never appear in the app launcher.

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
mkdir -p "$home" "$tmpdir/profile.d" "$tmpdir/bin"

# Stub omarchy-cmd-present so the file's mise activation stays off the host's
# real mise.
printf '#!/bin/bash\nexit 1\n' >"$tmpdir/bin/omarchy-cmd-present"
chmod +x "$tmpdir/bin/omarchy-cmd-present"

# Copy of env-bootstrap with /etc/omarchy.conf repointed at the fixture, so
# the copy resolves OMARCHY_PATH without touching the host.
sed "s#/etc/omarchy.conf#$tmpdir/omarchy.conf#g" "$ROOT/default/bash/env-bootstrap" >"$tmpdir/env-bootstrap"

# Copy of 10-omarchy with both absolute source paths repointed at the fixture
# tree: env-bootstrap inside it, and the distro-provided flatpak profile
# script whose presence the fix conditions on.
sed -e "s#/usr/share/omarchy/default/bash/env-bootstrap#$tmpdir/env-bootstrap#g" \
  -e "s#/etc/profile.d/flatpak.sh#$tmpdir/profile.d/flatpak.sh#g" \
  "$ROOT/default/uwsm/env.d/10-omarchy" >"$tmpdir/env.d"

# OMARCHY_PATH points at an empty fixture tree: the real checkout would trip
# env-bootstrap's dev-link mode and put the checkout's own bin ahead of the
# stubs. A custom MISE_DATA_DIR keeps the file's mise activation just as
# hermetic — omarchy-cmd-present resolves to the stub, mise never runs.
printf 'export OMARCHY_PATH="%s/omarchy"\n' "$tmpdir" >"$tmpdir/omarchy.conf"

# Stand-in for /etc/profile.d/flatpak.sh, shipped by the flatpak package: it
# prepends the Flatpak export directories to XDG_DATA_DIRS.
cat >"$tmpdir/profile.d/flatpak.sh" <<'EOF'
if [ -n "${XDG_DATA_DIRS:-}" ]; then
  export XDG_DATA_DIRS="${XDG_DATA_HOME:-$HOME/.local/share}/flatpak/exports/share:/var/lib/flatpak/exports/share:$XDG_DATA_DIRS"
else
  export XDG_DATA_DIRS="${XDG_DATA_HOME:-$HOME/.local/share}/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share"
fi
EOF

session_env() {
  # `;` rather than `&&` before printf: the copy's last line (the mise
  # activation) returns 1 under the stub, and that is the sourced file's
  # return status. The XDG_DATA_DIRS assertions cover the sourcing itself.
  HOME="$home" PATH="$tmpdir/bin:/usr/bin:/bin" MISE_DATA_DIR="$tmpdir/mise" \
    XDG_DATA_DIRS="${1:-}" \
    bash -c '. "$1"; printf "%s" "${XDG_DATA_DIRS-}"' sh "$tmpdir/env.d"
}

assert_dirs_present() {
  local dirs="$1"
  local description="$2"
  case ":$dirs:" in
    *":$home/.local/share/flatpak/exports/share:"*) ;;
    *) fail "$description" "missing \$HOME Flatpak export dir in: $dirs" ;;
  esac
  case ":$dirs:" in
    *":/var/lib/flatpak/exports/share:"*) pass "$description" ;;
    *) fail "$description" "missing system Flatpak export dir in: $dirs" ;;
  esac
}

# The session env must pick up the Flatpak export directories.
assert_dirs_present "$(session_env)" "uwsm session env adds the Flatpak export dirs"

# Existing entries survive, since the distro script only prepends.
dirs=$(session_env "/usr/local/share:/usr/share")
assert_dirs_present "$dirs" "uwsm session env keeps inherited XDG_DATA_DIRS entries"
case ":$dirs:" in
  *":/usr/local/share:/usr/share:"*) pass "uwsm session env preserves the inherited XDG_DATA_DIRS order" ;;
  *) fail "uwsm session env preserves the inherited XDG_DATA_DIRS order" "actual: $dirs" ;;
esac

# Without the flatpak package installed, the session env must still come up
# clean: the guarded source neither crashes nor invents the directories.
rm "$tmpdir/profile.d/flatpak.sh"
dirs=$(session_env "/usr/local/share:/usr/share")
case ":$dirs:" in
  *":/var/lib/flatpak/exports/share:"*) fail "uwsm session env without flatpak stays clean" "flatpak dir present without the package: $dirs" ;;
  *) pass "uwsm session env without flatpak stays clean" ;;
esac
[[ $dirs == "/usr/local/share:/usr/share" ]] || fail "uwsm session env without flatpak keeps XDG_DATA_DIRS" "actual: $dirs"
pass "uwsm session env without flatpak keeps XDG_DATA_DIRS"
