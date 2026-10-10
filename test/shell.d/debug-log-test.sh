#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Both helpers publish to a fixed name in world-writable /tmp, so the test has to
# exercise those exact names. Anything already there is copied aside first and put
# back on the way out, and only the staging files this test causes are removed --
# another helper running at the same time keeps its own working file.
log=/tmp/omarchy-debug.log
legacy_upload=/tmp/upload-log.txt
legacy_system_info=/tmp/system-info.txt
tmp=$(mktemp -d)
saved="$tmp/saved"
mkdir -p "$saved"
saved_paths=()

for path in "$log" "$legacy_upload" "$legacy_system_info"; do
  if [[ -e $path || -L $path ]]; then
    cp -a -- "$path" "$saved/${path##*/}"
    saved_paths+=("$path")
  fi
done

# The staging files the scripts create are named randomly, so glob /tmp to find
# them afterwards would also match a helper running at the same time -- deleting
# its working file, or a stale one left by an earlier run. Instead an mktemp stub
# records every path it hands out, and the test only ever touches those.
manifest="$tmp/mktemp-manifest"

cleanup() {
  local path
  if [[ -f $manifest ]]; then
    while IFS= read -r path; do
      [[ -n $path ]] && rm -f -- "$path"
    done <"$manifest"
  fi

  rm -f -- "$log" "$legacy_upload" "$legacy_system_info"
  for path in ${saved_paths[@]+"${saved_paths[@]}"}; do
    cp -a -- "$saved/${path##*/}" "$path"
  done
  rm -rf "$tmp"
}
trap cleanup EXIT

# Stubs keep the collection cheap and offline: no sudo, no network, and nothing
# that depends on what this machine happens to have installed.
mkdir -p "$tmp/bin"
for tool in inxi journalctl expac pacman fastfetch date hostname; do
  cat >"$tmp/bin/$tool" <<EOF
#!/bin/bash
echo "[stub $tool]"
EOF
  chmod +x "$tmp/bin/$tool"
done

# Real mktemp, plus a note of what it created.
cat >"$tmp/bin/mktemp" <<'EOF'
#!/bin/bash
path=$(/usr/bin/mktemp "$@") || exit $?
printf '%s\n' "$path" >>"$MKTEMP_MANIFEST"
echo "$path"
EOF
chmod +x "$tmp/bin/mktemp"

# The upload stub reports what it was actually handed, so the assertions below
# read the file the script published rather than trusting the URL it printed.
cat >"$tmp/bin/curl" <<'EOF'
#!/bin/bash
report=$CURL_REPORT
target=""
for arg in "$@"; do
  case "$arg" in
    file=@*) target=${arg#file=@} ;;
  esac
done
{
  printf 'path=%s\n' "$target"
  if [[ -f $target ]]; then
    printf 'exists=yes\n'
    printf 'mode=%s\n' "$(stat -c '%a' "$target")"
    printf 'has_diagnostics=%s\n' "$(grep -q 'SYSTEM INFORMATION' "$target" && echo yes || echo no)"
  else
    printf 'exists=no\n'
  fi
} >"$report"
echo "https://logs.omarchy.org/stub"
EOF
chmod +x "$tmp/bin/curl"

canary="$tmp/canary"
printf 'untouched\n' >"$canary"

# Start recording before either helper runs.
: >"$manifest"

# --- omarchy-debug -------------------------------------------------------

rm -f "$log"
ln -s "$canary" "$log"

MKTEMP_MANIFEST="$manifest" PATH="$tmp/bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-debug" --no-sudo --print >"$tmp/printed" 2>/dev/null || true

[[ $(cat "$canary") == untouched ]] ||
  fail "omarchy debug does not write through a symlink another local process planted" \
    "canary now reads: $(cat "$canary")"
pass "omarchy debug does not write through a planted symlink"

if [[ -L $log ]]; then
  fail "omarchy debug replaces a planted symlink instead of following it"
fi
[[ -f $log ]] || fail "omarchy debug publishes the log"
pass "omarchy debug replaces a planted symlink with the log"

grep -q 'SYSTEM INFORMATION' "$log" ||
  fail "the published log carries the collected diagnostics" "$(head -5 "$log")"
pass "the published log carries the collected diagnostics"

grep -q 'SYSTEM INFORMATION' "$tmp/printed" ||
  fail "--print still emits the log" "$(cat "$tmp/printed")"
pass "--print still emits the log"

mode=$(stat -c '%a' "$log" 2>/dev/null || true)
if [[ -n $mode ]]; then
  if (( 8#$mode & 077 )); then
    fail "the published log is owner-only" "mode: $mode"
  fi
  pass "the published log is owner-only"
else
  skip "the filesystem does not report modes; cannot check the log's permissions"
fi

# --- omarchy-upload-log --------------------------------------------------

rm -f "$legacy_upload" "$legacy_system_info"
printf 'upload canary\n' >"$tmp/upload-canary"
ln -s "$tmp/upload-canary" "$legacy_upload"
ln -s "$tmp/upload-canary" "$legacy_system_info"

upload_out=$(CURL_REPORT="$tmp/curl-report" MKTEMP_MANIFEST="$manifest" \
  PATH="$tmp/bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-upload-log" installed 2>&1 || true)

[[ $(cat "$tmp/upload-canary") == "upload canary" ]] ||
  fail "omarchy upload-log does not write through the symlinks it used to own" \
    "canary now reads: $(cat "$tmp/upload-canary")"
pass "omarchy upload-log leaves its old fixed names alone"

if [[ ! -L $legacy_upload || ! -L $legacy_system_info ]]; then
  fail "omarchy upload-log no longer writes to the legacy fixed paths" \
    "$legacy_upload: $(stat -c '%F' "$legacy_upload" 2>/dev/null || echo missing)
$legacy_system_info: $(stat -c '%F' "$legacy_system_info" 2>/dev/null || echo missing)"
fi
pass "omarchy upload-log leaves the legacy fixed names as they were"

# The file curl was handed is the one that matters: it has to exist, carry the
# diagnostics, be owner-only while it sits in /tmp, and no longer be the fixed
# name another local process could pre-create.
[[ -f $tmp/curl-report ]] || fail "omarchy upload-log uploaded a file" "$upload_out"
report=$(cat "$tmp/curl-report")

grep -qx 'exists=yes' "$tmp/curl-report" ||
  fail "the uploaded file exists at upload time" "$report"
pass "the uploaded file exists at upload time"

grep -qx 'has_diagnostics=yes' "$tmp/curl-report" ||
  fail "the uploaded file carries the collected diagnostics" "$report"
pass "the uploaded file carries the collected diagnostics"

uploaded=$(sed -n 's/^path=//p' "$tmp/curl-report")
if [[ $uploaded == "$legacy_upload" || $uploaded == "$legacy_system_info" ]]; then
  fail "omarchy upload-log uploads from a private temporary file" "uploaded: $uploaded"
fi
pass "omarchy upload-log uploads from a private temporary file"

upload_mode=$(sed -n 's/^mode=//p' "$tmp/curl-report")
if [[ -n $upload_mode ]]; then
  if (( 8#$upload_mode & 077 )); then
    fail "the uploaded file is owner-only while it sits in /tmp" "mode: $upload_mode"
  fi
  pass "the uploaded file is owner-only while it sits in /tmp"
else
  skip "the filesystem does not report modes; cannot check the uploaded file's permissions"
fi

grep -q 'https://logs.omarchy.org/stub' <<<"$upload_out" ||
  fail "omarchy upload-log still uploads and reports the URL" "$upload_out"
pass "omarchy upload-log still uploads and reports the URL"

# Nothing either helper staged may outlive it. The manifest is the exact list of
# files the scripts created, so this needs no scan of /tmp.
[[ -s $manifest ]] || fail "the helpers stage their logs in a temporary file"
pass "the helpers stage their logs in a temporary file"

while IFS= read -r staged; do
  [[ -n $staged ]] || continue
  if [[ -e $staged || -L $staged ]]; then
    fail "the helpers leave no staging file behind" "$staged still exists"
  fi
done <"$manifest"
pass "the helpers leave no staging file behind"