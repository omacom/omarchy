#!/bin/bash
#
# omarchy-pkg-add hands pacman every name it is given whenever any one of them
# is missing. A name an installed package already provides must stay out of
# the transaction: with --noconfirm pacman answers the provider-conflict
# question with N and the whole transaction fails to prepare. That is how
# migration 1791367434 aborted the whole update on machines running the
# -ut Mozc pair (fcitx5-mozc-ut provides fcitx5-mozc and declares
# Conflicts: mozc): the transaction could never resolve. (#18848)
# pacman and the privileged call are stubbed; omarchy-pkg-missing is real.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
export CALL_LOG="$scratch/calls"
export NOW_INSTALLED="$scratch/installed-now"
export PATH="$scratch/bin:$ROOT/bin:$PATH"

# SATISFIED lists dependency names an installed package already provides:
# pacman -Q answers for them (its provides fallback) and -T leaves them out.
# INSTALLED lists exact installed names.
cat > "$scratch/bin/pacman" <<'STUB'
#!/bin/bash
case "$1" in
  -T)
    shift
    [[ ${1:-} == "--" ]] && shift
    unsatisfied=0
    for dep in "$@"; do
      grep -qxF -- "$dep" <<< "${SATISFIED:-}" && continue
      grep -qxF -- "$dep" <<< "${INSTALLED:-}" && continue
      printf '%s\n' "$dep"
      unsatisfied=1
    done
    (( unsatisfied )) && exit 127
    exit 0
    ;;
  -Q)
    shift
    [[ ${1:-} == "--" ]] && shift
    grep -qxF -- "$1" <<< "${SATISFIED:-}" && exit 0
    grep -qxF -- "$1" <<< "${INSTALLED:-}" && exit 0
    [[ -f $NOW_INSTALLED ]] && grep -qxF -- "$1" "$NOW_INSTALLED" && exit 0
    exit 1
    ;;
  -S)
    printf 'pacman %s\n' "$*" >> "$CALL_LOG"
    shift
    [[ ${1:-} == "--" ]] && shift
    printf '%s\n' "$@" >> "$NOW_INSTALLED"
    exit "${INSTALL_STATUS:-0}"
    ;;
  *) printf 'pacman %s\n' "$*" >> "$CALL_LOG"; exit 99 ;;
esac
STUB
cat > "$scratch/bin/sudo" <<'STUB'
#!/bin/bash
case "$1" in
  pacman) exec "$@" ;;
  *) echo "Unexpected privileged call: $*" >> "$CALL_LOG"; exit 99 ;;
esac
STUB
chmod +x "$scratch/bin/"*

run_pkg_add() {
  : > "$CALL_LOG"
  rm -f "$NOW_INSTALLED"
  PKG_ADD_STATUS=0
  OMARCHY_PATH="$scratch" "$ROOT/bin/omarchy-pkg-add" "$@" > "$scratch/output" 2>&1 ||
    PKG_ADD_STATUS=$?
}

mozc_args=(fcitx5-mozc fcitx5-hangul fcitx5-chinese-addons fcitx5-chewing)

# The issue's state: the -ut pair installed (its fcitx5-mozc provide answers
# pacman -Q), the other three input-method packages missing.
INSTALLED=$'mozc-ut\nfcitx5-mozc-ut' SATISFIED='fcitx5-mozc' run_pkg_add "${mozc_args[@]}"
[[ $PKG_ADD_STATUS == 0 ]] || fail "the mozc-ut machine installs the missing input methods" "$(cat "$scratch/output")"
[[ $(grep -c '^pacman -S ' "$CALL_LOG") == 1 ]] || fail "the mozc-ut machine runs one transaction" "$(cat "$CALL_LOG")"
grep -qxF 'pacman -S --noconfirm --needed -- fcitx5-hangul fcitx5-chinese-addons fcitx5-chewing' "$CALL_LOG" ||
  fail "a provided name stays out of the transaction" "$(cat "$CALL_LOG")"
! grep -qF 'fcitx5-mozc' <(grep '^pacman -S ' "$CALL_LOG") ||
  fail "the conflicting provided name never reaches pacman" "$(cat "$CALL_LOG")"
pass "a provided name stays out of the transaction; the missing names still install"

# Everything already provided: nothing to do, pacman is not touched at all.
INSTALLED=$'mozc-ut\nfcitx5-mozc-ut' SATISFIED=$'fcitx5-mozc\nfcitx5-hangul\nfcitx5-chinese-addons\nfcitx5-chewing' \
  run_pkg_add "${mozc_args[@]}"
[[ $PKG_ADD_STATUS == 0 ]] || fail "an all-provided request succeeds" "$(cat "$scratch/output")"
[[ ! -s $CALL_LOG ]] || fail "an all-provided request runs no transaction" "$(cat "$CALL_LOG")"
pass "an all-provided request succeeds without touching pacman"

# A fresh machine still installs everything it was asked for.
run_pkg_add "${mozc_args[@]}"
[[ $PKG_ADD_STATUS == 0 ]] || fail "a fresh machine installs all requested packages" "$(cat "$scratch/output")"
grep -qxF 'pacman -S --noconfirm --needed -- fcitx5-mozc fcitx5-hangul fcitx5-chinese-addons fcitx5-chewing' "$CALL_LOG" ||
  fail "a fresh machine's transaction keeps every requested package" "$(cat "$CALL_LOG")"
pass "a fresh machine installs every requested package"

# An exactly-installed target stays out of the transaction on its own name,
# not only through --needed.
INSTALLED='fcitx5-hangul' run_pkg_add "${mozc_args[@]}"
[[ $PKG_ADD_STATUS == 0 ]] || fail "a partly installed request succeeds" "$(cat "$scratch/output")"
grep -qxF 'pacman -S --noconfirm --needed -- fcitx5-mozc fcitx5-chinese-addons fcitx5-chewing' "$CALL_LOG" ||
  fail "an installed target stays out of the transaction" "$(cat "$CALL_LOG")"
! grep -qF 'fcitx5-hangul' <(grep '^pacman -S ' "$CALL_LOG") ||
  fail "an installed target never reaches pacman" "$(cat "$CALL_LOG")"
pass "an installed target stays out of the transaction"

# A failed transaction still fails the command.
INSTALL_STATUS=1 run_pkg_add "${mozc_args[@]}"
[[ $PKG_ADD_STATUS == 1 ]] || fail "a failed transaction fails the command" "$(cat "$scratch/output")"
pass "a failed transaction still fails the command"
