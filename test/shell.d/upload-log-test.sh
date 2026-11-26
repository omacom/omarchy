#!/bin/bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
SCRIPT="$ROOT/bin/omarchy-upload-log"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin"

# Minimal PATH containing standard utilities + curl stub, deliberately omitting
# omarchy-cmd-present (matches omarchy-settings installed without omarchy).
for cmd in bash cat cmp date mktemp rm stat uname; do
  ln -s "$(command -v "$cmd")" "$work/bin/$cmd"
done
cat >"$work/bin/curl" <<'STUB'
#!/bin/bash
echo "https://logs.omarchy.org/test-id"
STUB
cat >"$work/bin/journalctl" <<'STUB'
#!/bin/bash
echo "sample boot log line"
STUB
chmod +x "$work/bin/curl" "$work/bin/journalctl"

# 1. Without fastfetch and without omarchy-cmd-present: must not emit command-not-found.
err="$work/stderr-nofastfetch"
out=$(PATH="$work/bin" "$SCRIPT" this-boot 2>"$err")
[[ ! -s $err ]] || { echo "FAIL: unexpected stderr without fastfetch: $(cat "$err")" >&2; exit 1; }
[[ $out == *"https://logs.omarchy.org/test-id"* ]] || { echo "FAIL: upload failed: $out" >&2; exit 1; }
echo "ok - omarchy-upload-log succeeds without omarchy-cmd-present or fastfetch"

# 2. With fastfetch present and omarchy-cmd-present absent: must invoke fastfetch.
cat >"$work/bin/fastfetch" <<'STUB'
#!/bin/bash
echo "FASTFETCH_CALLED" >"$WORK_DIR/fastfetch.ran"
echo "OS: Omarchy"
STUB
chmod +x "$work/bin/fastfetch"
err="$work/stderr-fastfetch"
out=$(WORK_DIR="$work" PATH="$work/bin" "$SCRIPT" this-boot 2>"$err")
[[ ! -s $err ]] || { echo "FAIL: unexpected stderr with fastfetch: $(cat "$err")" >&2; exit 1; }
[[ -f "$work/fastfetch.ran" ]] || { echo "FAIL: fastfetch was not invoked when present on PATH" >&2; exit 1; }
[[ $out == *"https://logs.omarchy.org/test-id"* ]] || { echo "FAIL: upload failed with fastfetch: $out" >&2; exit 1; }
echo "ok - omarchy-upload-log uses fastfetch when available without omarchy-cmd-present"
