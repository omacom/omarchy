#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/tmp"
export INSTALL_LOG="$scratch/log" CURL_LOG="$scratch/curl" TMPDIR="$scratch/tmp"
cat >"$scratch/bin/curl" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$CURL_LOG"
output=""
while (($#)); do
  if [[ $1 == "-o" ]]; then output=$2; shift; fi
  shift
done
script='printf "installer:%s\n" "$*" >>"$INSTALL_LOG"
if [[ -n ${INTERRUPT_INSTALLER:-} ]]; then kill -"$INTERRUPT_INSTALLER" "$PPID"; fi
exit "${INSTALLER_STATUS:-0}"'
if [[ -n $output ]]; then printf '%s\n' "$script" >"$output"; else printf '%s\n' "$script"; fi
exit "${DOWNLOAD_STATUS:-0}"
SH
for command in omarchy-pkg-add opam; do
  printf '#!/bin/bash\nprintf "%s:%%s\\n" "$*" >>"$INSTALL_LOG"\n' "$command" >"$scratch/bin/$command"
done
chmod +x "$scratch/bin/"*
export PATH="$scratch/bin:$PATH"

for environment in rust ocaml; do
  : >"$INSTALL_LOG"
  if DOWNLOAD_STATUS=18 bash "$ROOT/bin/omarchy-install-dev-env" "$environment" >"$scratch/out" 2>&1; then
    fail "a truncated $environment installer fails"
  fi
  ! grep -qE '^(installer|opam):' "$INSTALL_LOG" || fail "a failed $environment download runs no script or follow-up" "$(cat "$INSTALL_LOG")"
  [[ -z $(ls -A "$TMPDIR") ]] || fail "a failed download leaves no installer"
done
pass "neither partial installer is executed, and OCaml setup stops on download failure"

: >"$INSTALL_LOG"
bash "$ROOT/bin/omarchy-install-dev-env" rust >"$scratch/out" 2>&1 || fail "the complete Rust installer runs" "$(cat "$scratch/out")"
grep -qx 'installer:-y' "$INSTALL_LOG" || fail "Rust keeps its install argument"
[[ -z $(ls -A "$TMPDIR") ]] || fail "a successful download leaves no installer"
pass "a complete Rust installer receives its arguments and is removed afterwards"

for environment in rust ocaml; do
  : >"$INSTALL_LOG"
  status=0
  INSTALLER_STATUS=7 bash "$ROOT/bin/omarchy-install-dev-env" "$environment" >"$scratch/out" 2>&1 || status=$?
  (( status == 7 )) || fail "a failed $environment installer preserves its status"
  ! grep -q '^opam:' "$INSTALL_LOG" || fail "a failed installer stops OCaml setup"
  [[ -z $(ls -A "$TMPDIR") ]] || fail "a failed installer leaves no file"

  for signal in TERM INT; do
    status=0
    INTERRUPT_INSTALLER=$signal bash "$ROOT/bin/omarchy-install-dev-env" "$environment" >"$scratch/out" 2>&1 || status=$?
    expected=143
    [[ $signal == "INT" ]] && expected=130
    (( status == expected )) || fail "a $signal-interrupted $environment installer preserves its status"
    [[ -z $(ls -A "$TMPDIR") ]] || fail "an interrupted installer leaves no file"
  done
done
pass "failed and interrupted installers fail setup and remove their files"
