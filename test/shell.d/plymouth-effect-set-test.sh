#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d "${TMPDIR:-/var/tmp}/ttfx-test.XXXXXXXX")
printf 'Test fixtures: %s\n' "$tmp_dir"
fake_bin="$tmp_dir/bin"
theme_dir="$tmp_dir/root/usr/share/plymouth/themes/omarchy"
theme_file="$theme_dir/omarchy.plymouth"
log="$tmp_dir/calls.log"
catalog="$tmp_dir/effects.txt"
trusted_catalog="$theme_dir/ttfx-effects.txt"
native_module="$tmp_dir/root/usr/lib/plymouth/ttfx-plymouth.so"
mkdir -p "$fake_bin" "$theme_dir" "${native_module%/*}"
printf native-module >"$native_module"
printf '%s\n' decrypt sweep waves >"$catalog"
cp "$catalog" "$trusted_catalog"
chmod 0644 "$trusted_catalog"
cat >"$theme_file" <<'EOF'
# keep this comment
[Plymouth Theme]
Name=Custom Brand
Description=Keep me
ModuleName=script

[ttfx]
ImageDir=/custom/images
Enabled=false
Mode=off
Effect=off
Seed=0
PlaybackMode=submit-to-finish
BackgroundColor=112233
TextColor=aabbcc
MessageColor=445566

[other]
Arbitrary=value
EOF
chmod 0644 "$theme_file"

cat >"$fake_bin/omarchy-plymouth-effect-list" <<SH
#!/bin/bash
cat '$catalog'
[[ -z \${TEST_UNPRIVILEGED_EFFECT:-} ]] || printf '%s\n' "\$TEST_UNPRIVILEGED_EFFECT"
SH
cat >"$fake_bin/seed-tool" <<'SH'
#!/bin/bash
printf '%s\n' "${TEST_SEED:-18446744073709551615}"
SH
cat >"$fake_bin/shuf" <<'SH'
#!/bin/bash
cat >/dev/null
printf 'waves\n'
SH
cat >"$fake_bin/sudo" <<'SH'
#!/bin/bash
set -euo pipefail
[[ $1 == /bin/bash && $2 == -c ]] || exit 90
code=$3
shift 3
code=${code/PATH=\/usr\/bin:\/bin/PATH=$TEST_FAKE_BIN:\/usr\/bin:\/bin}
code=${code/theme_file=\/usr\/share\/plymouth\/themes\/omarchy\/omarchy.plymouth/theme_file=$TEST_THEME_FILE}
code=${code/effects_file=\/usr\/share\/plymouth\/themes\/omarchy\/ttfx-effects.txt/effects_file=$TEST_TRUSTED_CATALOG}
code=${code/\/run\/lock\/omarchy-plymouth.lock/$TEST_LOCK_FILE}
code=${code/module_file=\/usr\/lib\/plymouth\/ttfx-plymouth.so/module_file=$TEST_NATIVE_MODULE}
code=${code//\/usr\/bin\/limine-mkinitcpio/$TEST_FAKE_BIN\/limine-mkinitcpio}
code=${code//\/usr\/bin\/mkinitcpio/$TEST_FAKE_BIN\/mkinitcpio}
/bin/bash -c "$code" bash "$@"
SH
cat >"$fake_bin/stat" <<'SH'
#!/bin/bash
if [[ ${1:-} == -c && ${2:-} == %u ]]; then
  printf '0\n'
elif [[ ${1:-} == -c && ${2:-} == %g ]]; then
  printf '0\n'
elif [[ ${1:-} == -c && ${2:-} == %a ]]; then
  last=${!#}
  if [[ -f $last ]]; then
    /usr/bin/stat "$@"
  else
    printf '755\n'
  fi
else
  exec /usr/bin/stat "$@"
fi
SH
cat >"$fake_bin/chown" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$fake_bin/plymouth-set-default-theme" <<'SH'
#!/bin/bash
printf 'activate %s\n' "$*" >>"$TEST_LOG"
SH
cat >"$fake_bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
printf 'rebuild limine\n' >>"$TEST_LOG"
# A fresh open of the lock file conflicts with the setter's lock while it holds it.
if /usr/bin/flock -n "$TEST_LOCK_FILE" true; then
  printf 'rebuild lock free\n' >>"$TEST_LOG"
else
  printf 'rebuild lock held\n' >>"$TEST_LOG"
fi
if [[ ${TEST_REBUILD_FAIL_ONCE:-0} == 1 && ! -e ${TEST_REBUILD_MARKER:?} ]]; then
  : >"$TEST_REBUILD_MARKER"
  exit 71
fi
if [[ ${TEST_REBUILD_SIGNAL_ONCE:-0} == 1 && ! -e ${TEST_REBUILD_MARKER:?} ]]; then
  : >"$TEST_REBUILD_MARKER"
  kill -TERM "$PPID"
  exit 143
fi
SH
cat >"$fake_bin/mv" <<'SH'
#!/bin/bash
set -euo pipefail
if [[ ${TEST_EXCHANGE_SIGNAL:-0} == 1 && $* == *--exchange* && ! -e ${TEST_EXCHANGE_MARKER:?} ]]; then
  : >"$TEST_EXCHANGE_MARKER"
  /usr/bin/mv "$@"
  kill -TERM "$PPID"
  exit 0
fi
exec /usr/bin/mv "$@"
SH
cat >"$fake_bin/rm" <<'SH'
#!/bin/bash
set -euo pipefail
if [[ ${TEST_COMMIT_SIGNAL:-0} == 1 && $* == *'.omarchy.plymouth.omarchy-new.'* && ! -e ${TEST_COMMIT_MARKER:?} ]]; then
  : >"$TEST_COMMIT_MARKER"
  kill -TERM "$PPID"
fi
exec /usr/bin/rm "$@"
SH
cat >"$fake_bin/omarchy-plymouth-effect-render" <<'SH'
#!/bin/bash
printf 'renderer called\n' >>"$TEST_LOG"
exit 88
SH
cat >"$fake_bin/flock" <<'SH'
#!/bin/bash
[[ -z ${TEST_FLOCK_LOG:-} ]] || printf 'flock %s\n' "$*" >>"$TEST_FLOCK_LOG"
exec /usr/bin/flock "$@"
SH
cat >"$fake_bin/magick" <<'SH'
#!/bin/bash
printf 'magick called\n' >>"$TEST_LOG"
exit 88
SH
chmod +x "$fake_bin"/*

run_set() {
  PATH="$fake_bin:$ROOT/bin:/usr/bin:/bin" \
    OMARCHY_PLYMOUTH_THEME_FILE="$theme_file" \
    OMARCHY_PLYMOUTH_SEED_TOOL="$fake_bin/seed-tool" \
    TEST_FAKE_BIN="$fake_bin" TEST_THEME_FILE="$theme_file" \
    TEST_TRUSTED_CATALOG="$trusted_catalog" TEST_NATIVE_MODULE="$native_module" \
    TEST_LOCK_FILE="$tmp_dir/plymouth.lock" TEST_LOG="$log" \
    "$ROOT/bin/omarchy-plymouth-effect-set" "$@"
}

[[ $(run_set playback current) == input-only ]] || fail "playback current reports Input Only"
: >"$log"
run_set playback full-animated >/dev/null
grep -Fxq 'PlaybackMode=continuous' "$theme_file" || fail "Full Animated stores continuous playback"
[[ $(run_set current) == off ]] || fail "playback selection preserves the effect selector"
(( $(grep -c '^rebuild limine$' "$log") == 1 )) || fail "playback selection rebuilds exactly once"
: >"$log"
run_set playback input-only >/dev/null
grep -Fxq 'PlaybackMode=submit-to-finish' "$theme_file" || fail "Input Only stores submit-to-finish playback"
[[ $(run_set current) == off ]] || fail "Input Only preserves the effect selector"
(( $(grep -c '^rebuild limine$' "$log") == 1 )) || fail "Input Only rebuilds exactly once"
pass "playback selector switches Full Animated and Input Only transactionally"

[[ $(run_set current) == off ]] || fail "current reports the requested off selector"
[[ $(run_set resolved) == $'mode=off\neffect=off\nseed=0' ]] || fail "resolved reports stable machine-readable state"
pass "status verbs report requested and resolved state"

: >"$log"
run_set decrypt >/dev/null
[[ $(run_set current) == decrypt ]] || fail "fixed current reports its concrete selector"
[[ $(run_set resolved) == $'mode=fixed\neffect=decrypt\nseed=18446744073709551615' ]] || fail "fixed state preserves full uint64 seed"
grep -Fxq '# keep this comment' "$theme_file" || fail "setter preserves comments"
grep -Fxq 'Name=Custom Brand' "$theme_file" || fail "setter preserves branding"
grep -Fxq 'Arbitrary=value' "$theme_file" || fail "setter preserves unrelated sections"
grep -Fxq 'ModuleName=ttfx-plymouth' "$theme_file" || fail "setter activates native module"
grep -Fxq 'PlaybackMode=submit-to-finish' "$theme_file" || fail "effect selection preserves playback mode"
[[ $(stat -c %a "$theme_file") == 644 ]] || fail "setter publishes mode 0644"
(( $(grep -c '^rebuild limine$' "$log") == 1 )) || fail "fixed selection rebuilds exactly once" "$(<"$log")"
if grep -Eq 'render|magick' "$log"; then fail "native setter never renders PNGs" "$(<"$log")"; fi
pass "fixed selection publishes native effect and full seed without PNGs"

: >"$log"
TEST_SEED=42 run_set random >/dev/null
[[ $(run_set current) == random ]] || fail "random retains requested selector mode"
[[ $(run_set resolved) == $'mode=random\neffect=waves\nseed=42' ]] || fail "random resolves once to one concrete effect"
(( $(grep -c '^rebuild limine$' "$log") == 1 )) || fail "random selection rebuilds exactly once"
pass "random retains mode and stores one resolved effect and seed"

: >"$log"
TEST_SEED=7 run_set off >/dev/null
[[ $(run_set resolved) == $'mode=off\neffect=off\nseed=0' ]] || fail "off stores static-only state"
(( $(grep -c '^rebuild limine$' "$log") == 1 )) || fail "off rebuilds exactly once"
pass "off publishes native static-only state"

if run_set unknown >/dev/null 2>&1; then fail "setter rejects unknown effect"; fi
if TEST_SEED=18446744073709551616 run_set decrypt >/dev/null 2>&1; then fail "setter rejects seed overflow"; fi
pass "setter validates catalog and uint64 seed"

if TEST_UNPRIVILEGED_EFFECT=forged run_set forged >/dev/null 2>&1; then
  fail "privileged setter rejects an untrusted syntactically valid effect"
fi
pass "privileged setter validates resolved effect membership in the packaged catalog"

for mode in fail signal; do
  TEST_SEED=9 run_set sweep >/dev/null
  before=$(<"$theme_file")
  : >"$log"
  marker="$tmp_dir/$mode-marker"
  set +e
  if [[ $mode == fail ]]; then
    output=$(TEST_REBUILD_FAIL_ONCE=1 TEST_REBUILD_MARKER="$marker" TEST_SEED=10 run_set decrypt 2>&1)
  else
    output=$(TEST_REBUILD_SIGNAL_ONCE=1 TEST_REBUILD_MARKER="$marker" TEST_SEED=10 run_set decrypt 2>&1)
  fi
  status=$?
  set -e
  (( status != 0 )) || fail "$mode during rebuild returns nonzero" "$output"
  [[ $(<"$theme_file") == "$before" ]] || fail "$mode restores prior keyfile"
  (( $(grep -c '^rebuild limine$' "$log") == 2 )) || fail "$mode rebuilds restored UKI" "$(<"$log")"
done
pass "ordinary failures and signals restore and rebuild prior state"

TEST_SEED=11 run_set sweep >/dev/null
: >"$log"
exchange_marker="$tmp_dir/exchange-marker"
set +e
output=$(TEST_EXCHANGE_SIGNAL=1 TEST_EXCHANGE_MARKER="$exchange_marker" TEST_SEED=12 run_set decrypt 2>&1)
status=$?
set -e
(( status == 0 )) || fail "signal at exchange boundary cannot split publication" "$output"
[[ $(run_set resolved) == $'mode=fixed\neffect=decrypt\nseed=12' ]] || fail "exchange boundary completes new state"
(( $(grep -c '^rebuild limine$' "$log") == 1 )) || fail "exchange boundary rebuilds once"
pass "exchange bookkeeping is signal-safe"

TEST_SEED=13 run_set sweep >/dev/null
: >"$log"
commit_marker="$tmp_dir/commit-marker"
set +e
output=$(TEST_COMMIT_SIGNAL=1 TEST_COMMIT_MARKER="$commit_marker" TEST_SEED=14 run_set decrypt 2>&1)
status=$?
set -e
[[ -e $commit_marker ]] || fail "post-rebuild boundary signal was not injected"
(( status == 0 )) || fail "post-rebuild commit cannot report a false cancellation" "$output"
[[ $(run_set resolved) == $'mode=fixed\neffect=decrypt\nseed=14' ]] || fail "post-rebuild commit retains the rebuilt state"
(( $(grep -c '^rebuild limine$' "$log") == 1 )) || fail "post-rebuild commit does not falsely roll back" "$(<"$log")"
pass "post-rebuild commit boundary is signal-safe"

cat >"$theme_file" <<'EOF'
[Plymouth Theme]
Name=Legacy Brand
ModuleName=script
EOF
: >"$log"
TEST_SEED=17 run_set decrypt >/dev/null
for entry in 'BackgroundColor=1a1b26' 'TextColor=ffffff' 'MessageColor=b8bec9'; do
  grep -Fxq "$entry" "$theme_file" || fail "missing native section uses packaged default color: $entry"
done
pass "effect setter synthesizes the packaged colors for legacy descriptors"

# Another Plymouth writer holds the shared machine lock: the setter must wait
# for it before publishing, then keep it through the rebuild.
lock_file="$tmp_dir/plymouth.lock"
flock_log="$tmp_dir/flock.log"
locked_out="$tmp_dir/locked.out"
TEST_SEED=15 run_set sweep >/dev/null
before=$(<"$theme_file")
: >"$log"
: >"$flock_log"
exec 8>"$lock_file"
flock -x 8
TEST_FLOCK_LOG="$flock_log" TEST_SEED=16 run_set decrypt >"$locked_out" 2>&1 8>&- &
setter=$!
for _ in {1..250}; do
  [[ -s $flock_log ]] && break
  sleep 0.02
done
[[ -s $flock_log ]] || fail "setter asks for the machine lock" "$(<"$locked_out")"
sleep 0.3
kill -0 "$setter" 2>/dev/null || fail "setter waits while another writer holds the machine lock" "$(<"$locked_out")"
[[ $(<"$theme_file") == "$before" ]] || fail "setter publishes nothing while the machine lock is held"
[[ ! -s $log ]] || fail "setter rebuilds nothing while the machine lock is held" "$(<"$log")"
exec 8>&-
wait "$setter" || fail "setter completes once the machine lock is released" "$(<"$locked_out")"
[[ $(run_set resolved) == $'mode=fixed\neffect=decrypt\nseed=16' ]] || fail "setter publishes after the machine lock is released"
grep -Fxq 'rebuild lock held' "$log" || fail "rebuild runs under the machine lock" "$(<"$log")"
if grep -Fxq 'rebuild lock free' "$log"; then fail "setter releases the machine lock before the rebuild" "$(<"$log")"; fi
pass "publication waits for the shared machine lock and holds it through the rebuild"

# Selecting a native effect must not make an unprovisioned stock boot unusable.
mv -- "$native_module" "$native_module.retired"
before=$(<"$theme_file")
if run_set sweep >"$tmp_dir/missing-module.out" 2>&1; then
  fail "effect selection refuses a missing native module"
fi
[[ $(<"$theme_file") == "$before" ]] || fail "a missing module leaves the boot descriptor untouched"
grep -Fq "Native TTFX Plymouth module is not installed" "$tmp_dir/missing-module.out" ||
  fail "missing module refusal explains how to enable native effects"
pass "missing native module cannot replace the stock boot descriptor"
