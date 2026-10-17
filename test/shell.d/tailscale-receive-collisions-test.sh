#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command timeout

workdir=$(mktemp -d)
writer_pid=""
cleanup() {
  if [[ -n $writer_pid ]]; then
    kill "$writer_pid" 2>/dev/null || true
    wait "$writer_pid" 2>/dev/null || true
  fi
  rm -rf -- "$workdir"
}
trap cleanup EXIT

stub_bin="$workdir/bin"
mkdir -p "$stub_bin"
real_ln=$(command -v ln)

cat >"$stub_bin/tailscale" <<'SH'
#!/bin/bash
set -euo pipefail
[[ $# == 5 && $1 == "file" && $2 == "get" && $3 == "--wait" && $4 == "--conflict=rename" ]]
cp -- "$RECEIVE_CASE/outbox/"* "$5/"
SH

cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >>"$RECEIVE_CASE/notifications"
SH

# Let another local writer take the first candidate immediately before the
# receiver's actual link operation. The filesystem operation remains real.
cat >"$stub_bin/ln" <<'SH'
#!/bin/bash
set -euo pipefail
if [[ ${RECEIVE_RACE:-0} == "1" && ${*: -1} == "$RECEIVE_CASE/home/Downloads/report.txt" ]]; then
  printf 'ready\n' >"$RECEIVE_CASE/ready"
  read -r reply <"$RECEIVE_CASE/done"
  [[ $reply == "done" ]]
fi
exec "$RECEIVE_REAL_LN" "$@"
SH

chmod +x "$stub_bin/"*

setup_case() {
  case_dir="$workdir/$1"
  downloads="$case_dir/home/Downloads"
  mkdir -p "$downloads" "$case_dir/outbox"
  : >"$case_dir/notifications"
}

receive() {
  HOME="$case_dir/home" XDG_DOWNLOAD_DIR="$downloads" OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" \
    RECEIVE_CASE="$case_dir" RECEIVE_REAL_LN="$real_ln" RECEIVE_RACE="${1:-0}" \
    timeout 10 "$ROOT/bin/omarchy-tailscale-receive" --once ||
    fail "taildrop fixture receiver completes" "$case_dir"
}

assert_delivery() {
  local filename="$1" path="$downloads/$1" description="$2"

  [[ -f $path && ! -L $path ]] || fail "$description" "not a regular received file: $path"
  cmp -s "$case_dir/outbox/"* "$path" || fail "$description" "received contents differ"
  [[ -z $(find "$downloads/.omarchy-taildrop" -mindepth 1 -maxdepth 1 -print -quit) ]] ||
    fail "$description" "file was left in staging"

  # Check argument boundaries as well as the path announced to the user.
  local notification
  IFS= read -r -d '' notification <"$case_dir/notifications" || true
  [[ $notification == "Received $filename" ]] || fail "$description" "$notification"
  mapfile -d '' -t notification_args <"$case_dir/notifications"
  (( ${#notification_args[@]} == 9 )) || fail "$description" "unexpected notification arguments"
  [[ ${notification_args[6]} == "--exec" && ${notification_args[7]} == "xdg-open" && ${notification_args[8]} == "$path" ]] ||
    fail "$description" "notification does not open the received file"
  pass "$description"
}

setup_case no-collision
printf 'incoming' >"$case_dir/outbox/notes with space.pdf"
receive
assert_delivery "notes with space.pdf" "taildrop preserves an unused filename and its notification argument"

setup_case regular-file
printf 'old' >"$downloads/report.txt"
printf 'incoming' >"$case_dir/outbox/report.txt"
receive
[[ $(<"$downloads/report.txt") == "old" ]] || fail "taildrop preserves an existing regular file"
pass "taildrop preserves an existing regular file"
assert_delivery report-1.txt "taildrop suffixes a regular-file collision"

setup_case directory
mkdir "$downloads/report.txt"
printf 'old' >"$downloads/report.txt/marker"
printf 'incoming' >"$case_dir/outbox/report.txt"
receive
[[ $(find "$downloads/report.txt" -mindepth 1 -maxdepth 1 -printf '%f\n') == "marker" && $(<"$downloads/report.txt/marker") == "old" ]] ||
  fail "taildrop does not deliver into an existing directory"
pass "taildrop does not deliver into an existing directory"
assert_delivery report-1.txt "taildrop suffixes a directory collision"

setup_case directory-symlink
mkdir "$case_dir/separate"
printf 'old' >"$case_dir/separate/marker"
ln -s -- "$case_dir/separate" "$downloads/report.txt"
printf 'incoming' >"$case_dir/outbox/report.txt"
receive
[[ -L $downloads/report.txt && $(readlink "$downloads/report.txt") == "$case_dir/separate" && $(find "$case_dir/separate" -mindepth 1 -maxdepth 1 -printf '%f\n') == "marker" ]] ||
  fail "taildrop preserves a directory symlink without following it"
pass "taildrop preserves a directory symlink without following it"
assert_delivery report-1.txt "taildrop suffixes a directory-symlink collision"

setup_case dangling-symlink
ln -s -- "$case_dir/absent" "$downloads/report.txt"
printf 'incoming' >"$case_dir/outbox/report.txt"
receive
[[ -L $downloads/report.txt && $(readlink "$downloads/report.txt") == "$case_dir/absent" && ! -e $case_dir/absent ]] ||
  fail "taildrop preserves a dangling symlink and its missing target"
pass "taildrop preserves a dangling symlink and its missing target"
assert_delivery report-1.txt "taildrop suffixes a dangling-symlink collision instead of leaving the file staged"

setup_case multiple-collisions
printf 'old' >"$downloads/report.archive.tar.gz"
printf 'older' >"$downloads/report.archive.tar-1.gz"
printf 'incoming' >"$case_dir/outbox/report.archive.tar.gz"
receive
[[ $(<"$downloads/report.archive.tar.gz") == "old" && $(<"$downloads/report.archive.tar-1.gz") == "older" ]] ||
  fail "taildrop preserves all earlier multi-dot filename collisions"
pass "taildrop preserves all earlier multi-dot filename collisions"
assert_delivery report.archive.tar-2.gz "taildrop advances the suffix before the final extension"

setup_case extensionless
printf 'old' >"$downloads/README"
printf 'incoming' >"$case_dir/outbox/README"
receive
assert_delivery README-1 "taildrop suffixes an extensionless filename"

setup_case competing-writer
printf 'incoming' >"$case_dir/outbox/report.txt"
printf 'competing' >"$case_dir/competing"
mkfifo "$case_dir/ready" "$case_dir/done"
(
  read -r ready <"$case_dir/ready"
  [[ $ready == "ready" ]]
  "$real_ln" -T -- "$case_dir/competing" "$downloads/report.txt"
  printf 'done\n' >"$case_dir/done"
) >"$case_dir/writer.log" 2>&1 &
writer_pid=$!
receive 1
wait "$writer_pid" || fail "the competing local writer completes" "$(<"$case_dir/writer.log")"
writer_pid=""
[[ $(<"$downloads/report.txt") == "competing" ]] || fail "taildrop does not overwrite a name taken at the link boundary"
pass "taildrop does not overwrite a name taken at the link boundary"
assert_delivery report-1.txt "taildrop retries a collision created by a competing local writer"
