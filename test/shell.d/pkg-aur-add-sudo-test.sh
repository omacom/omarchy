#!/bin/bash

# omarchy-pkg-aur-add, as migrations call it: under the no-update boundary yay
# must use the command-scoped wrapper, not the sudo binary, flags or loop the
# user's own yay config names, which user-level code can rewrite, and must pass
# it the real pacman and pacman.conf rather than ones that config names.

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf -- "${tmp:?}"' EXIT
mkdir "$tmp/bin"
cat >"$tmp/bin/yay" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$YAY_ARGS"
SH
printf '#!/bin/bash\nexit 0\n' >"$tmp/bin/omarchy-pkg-missing"
printf '#!/bin/bash\nexit 0\n' >"$tmp/bin/pacman"
chmod +x "$tmp/bin/"*
yay_args() { local -a args; mapfile -d '' -t args <"$tmp/args"; printf '%s|' "${args[@]}"; }

OMARCHY_PATH="$ROOT" OMARCHY_SUDO_NO_UPDATE=1 YAY_ARGS="$tmp/args" PATH="$tmp/bin:/usr/bin" "$ROOT/bin/omarchy-pkg-aur-add" example ||
  fail "an AUR install under the no-update boundary failed"
[[ $(yay_args) == "--sudo|$ROOT/default/omarchy/sudo-no-update/sudo|--sudoflags||--sudoloop=false|--pacman|/usr/bin/pacman|--config|/etc/pacman.conf|-S|--noconfirm|--needed|example|" ]] ||
  fail "an AUR install under the no-update boundary did not pin yay to the wrapper" "$(yay_args)"

rm -f "$tmp/args"
OMARCHY_PATH="$ROOT" YAY_ARGS="$tmp/args" PATH="$tmp/bin:/usr/bin" "$ROOT/bin/omarchy-pkg-aur-add" example || fail "an ordinary AUR install failed"
[[ $(yay_args) == "-S|--noconfirm|--needed|example|" ]] || fail "an ordinary AUR install changed yay's sudo" "$(yay_args)"

mkdir -p "$tmp/no-wrapper"; rm -f "$tmp/args"
if OMARCHY_PATH="$tmp/no-wrapper" OMARCHY_SUDO_NO_UPDATE=1 YAY_ARGS="$tmp/args" PATH="$tmp/bin:/usr/bin" "$ROOT/bin/omarchy-pkg-aur-add" example 2>/dev/null; then
  fail "an AUR install under the boundary ran without its wrapper"
fi
[[ ! -e $tmp/args ]] || fail "yay ran although the no-update wrapper was missing"
pass "AUR installs under the no-update boundary use only the command-scoped sudo wrapper"

# The AUR update step follows the same rule.
printf '#!/bin/bash\nexit 0\n' >"$tmp/bin/omarchy-pkg-aur-accessible"; chmod +x "$tmp/bin/omarchy-pkg-aur-accessible"
rm -f "$tmp/args"
OMARCHY_PATH="$ROOT" OMARCHY_SUDO_NO_UPDATE=1 YAY_ARGS="$tmp/args" PATH="$tmp/bin:/usr/bin" "$ROOT/bin/omarchy-update-aur-pkgs" >/dev/null ||
  fail "an AUR update under the no-update boundary failed"
[[ $(yay_args) == "--sudo|$ROOT/default/omarchy/sudo-no-update/sudo|--sudoflags||--sudoloop=false|--pacman|/usr/bin/pacman|--config|/etc/pacman.conf|-Sua|"* ]] ||
  fail "an AUR update under the no-update boundary did not pin yay to the wrapper" "$(yay_args)"
pass "AUR updates under the no-update boundary use only the command-scoped sudo wrapper"

# A value other than 0 or 1 is refused rather than read as outside the boundary.
for command in omarchy-pkg-aur-add omarchy-update-aur-pkgs; do
  rm -f "$tmp/args"
  if OMARCHY_PATH="$ROOT" OMARCHY_SUDO_NO_UPDATE=true YAY_ARGS="$tmp/args" PATH="$tmp/bin:/usr/bin" "$ROOT/bin/$command" example >/dev/null 2>&1; then
    fail "$command accepted an invalid no-update value"
  fi
  [[ ! -e $tmp/args ]] || fail "$command ran yay with an invalid no-update value"
done
pass "AUR helpers refuse an invalid no-update value"

# Executable directories must not satisfy the wrapper precondition.
mkdir -p "$tmp/no-wrapper/default/omarchy/sudo-no-update/sudo"
for command in omarchy-pkg-aur-add omarchy-update-aur-pkgs; do
  rm -f "$tmp/args"
  if OMARCHY_PATH="$tmp/no-wrapper" OMARCHY_SUDO_NO_UPDATE=1 YAY_ARGS="$tmp/args" PATH="$tmp/bin:/usr/bin" "$ROOT/bin/$command" example >/dev/null 2>&1; then
    fail "$command accepted a directory as its sudo wrapper"
  fi
  [[ ! -e $tmp/args ]] || fail "$command ran yay with a directory as its sudo wrapper"
done
pass "AUR helpers require a regular executable sudo wrapper"
