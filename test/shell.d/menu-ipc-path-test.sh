#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command perl

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

runtime_dir="$tmpdir/runtime"
stub_bin="$tmpdir/bin"
ipc_log="$tmpdir/ipc.log"
mkdir -m 700 -p "$runtime_dir" "$stub_bin"

cat >"$stub_bin/omarchy-shell" <<'SH'
#!/bin/bash
payload="${@: -1}"
perl -MJSON::PP=decode_json -e '
  my $p = decode_json($ARGV[0]);
  my $sel = $p->{selectionFile};
  my $done = $p->{doneFile};
  die "missing ipc paths" unless defined $sel && defined $done;
  if (defined $ENV{IPC_LOG}) {
    open my $l, ">>", $ENV{IPC_LOG} or die $!;
    print $l "$sel\n$done\n";
    close $l;
  }
  open my $s, ">", $sel or die $!;
  print $s "picked\n";
  close $s;
  open my $d, ">", $done or die $!;
  close $d;
' "$payload"
SH
chmod +x "$stub_bin/omarchy-shell"

for cmd in omarchy-menu-select omarchy-menu-input omarchy-menu-images; do
  if grep -E '^selection_file=\$\(mktemp\)$' "$ROOT/bin/$cmd"; then
    fail "$cmd must not mktemp in the default /tmp"
  fi
  grep -Fq '${XDG_RUNTIME_DIR:-/tmp/omarchy-$UID}' "$ROOT/bin/$cmd" ||
    fail "$cmd stages menu IPC under the runtime directory"
done
pass "menu helpers do not stage IPC files in world-writable /tmp"

: >"$ipc_log"
PATH="$stub_bin:$PATH" XDG_RUNTIME_DIR="$runtime_dir" IPC_LOG="$ipc_log" \
  "$ROOT/bin/omarchy-menu-select" Prompt one >"$tmpdir/select.out"

[[ $(<"$tmpdir/select.out") == picked ]] ||
  fail "menu-select still returns the chosen row" "$(<"$tmpdir/select.out")"
while IFS= read -r path; do
  [[ $path == "$runtime_dir"/omarchy-menu-select.* ]] ||
    fail "menu-select IPC path is under XDG_RUNTIME_DIR" "$path"
done <"$ipc_log"
pass "menu-select stages IPC under XDG_RUNTIME_DIR"

: >"$ipc_log"
PATH="$stub_bin:$PATH" XDG_RUNTIME_DIR="$runtime_dir" IPC_LOG="$ipc_log" \
  "$ROOT/bin/omarchy-menu-input" Reminder >"$tmpdir/input.out"

[[ $(<"$tmpdir/input.out") == picked ]] ||
  fail "menu-input still returns the typed value" "$(<"$tmpdir/input.out")"
while IFS= read -r path; do
  [[ $path == "$runtime_dir"/omarchy-menu-input.* ]] ||
    fail "menu-input IPC path is under XDG_RUNTIME_DIR" "$path"
done <"$ipc_log"
pass "menu-input stages IPC under XDG_RUNTIME_DIR"
