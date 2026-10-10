#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

dri="$test_tmp/dri"
mkdir -p "$dri"

if OMARCHY_DRI_PATH="$dri" "$ROOT/bin/omarchy-hw-render-gpu"; then
  fail "render GPU is absent when dri is empty"
fi
pass "render GPU is absent when dri is empty"

touch "$dri/card1"
if OMARCHY_DRI_PATH="$dri" "$ROOT/bin/omarchy-hw-render-gpu"; then
  fail "a scanout node is not a render GPU"
fi
pass "a scanout node is not a render GPU"

touch "$dri/renderD128"
OMARCHY_DRI_PATH="$dri" "$ROOT/bin/omarchy-hw-render-gpu" ||
  fail "renderD128 is a render GPU"
pass "renderD128 is a render GPU"

args=$(PATH="$ROOT/bin:$PATH" OMARCHY_DRI_PATH="$dri" \
  "$ROOT/bin/omarchy-cmd-electron-gl-args")
[[ -z $args ]] || fail "no Electron GL flags when a render GPU exists" "$args"
pass "no Electron GL flags when a render GPU exists"

rm -f "$dri/renderD128"
args=$(PATH="$ROOT/bin:$PATH" OMARCHY_DRI_PATH="$dri" \
  "$ROOT/bin/omarchy-cmd-electron-gl-args")
[[ $args == $'--ozone-platform=wayland\n--disable-gpu' ]] ||
  fail "software GL flags when no render GPU" "$args"
pass "software GL flags when no render GPU"

real="$test_tmp/real-bin"
bind="$test_tmp/bind"
mkdir -p "$bind"
printf '#!/bin/bash\nprintf "real %%s\\n" "$*"\n' >"$real"
chmod +x "$real"

PATH="$ROOT/bin:$PATH" \
  OMARCHY_ELECTRON_GL_BIND_DIR="$bind" \
  "$ROOT/bin/omarchy-cmd-electron-gl-wrap" demo "$real"

grep -q '^# omarchy-electron-gl-wrapper$' "$bind/demo" ||
  fail "wrapper is marked as an Omarchy Electron GL wrapper"
pass "wrapper is marked as an Omarchy Electron GL wrapper"

# A repeated user finalization must not chmod an already-correct system wrapper.
stubs="$test_tmp/stubs"
mkdir -p "$stubs"
cat >"$stubs/chmod" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_PERMISSION_CALLS"
[[ ${OMARCHY_TEST_ALLOW_CHMOD:-0} == "1" ]] || exit 91
exec /usr/bin/chmod "$@"
STUB
cat >"$stubs/sudo" <<'STUB'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$OMARCHY_TEST_PERMISSION_CALLS"
exit 92
STUB
chmod +x "$stubs/chmod" "$stubs/sudo"
permission_calls="$test_tmp/permission-calls"
run_wrap() {
  PATH="$stubs:$ROOT/bin:$PATH" \
    OMARCHY_TEST_PERMISSION_CALLS="$permission_calls" \
    OMARCHY_ELECTRON_GL_BIND_DIR="$bind" \
    "$ROOT/bin/omarchy-cmd-electron-gl-wrap" demo "$real"
}

chmod 555 "$bind"
run_wrap || fail "correct wrapper needs no privilege or permission changes on repeat"
chmod 755 "$bind"
[[ ! -e $permission_calls ]] ||
  fail "correct wrapper must not invoke chmod or sudo"
pass "correct wrapper needs no privilege or permission changes on repeat"

for mode in 644 775; do
  chmod "$mode" "$bind/demo"
  OMARCHY_TEST_ALLOW_CHMOD=1 run_wrap ||
    fail "wrapper repairs incorrect mode $mode"
  [[ $(stat -c %a "$bind/demo") == "755" ]] ||
    fail "wrapper restores mode 755 from $mode"
done
pass "wrapper repairs missing execute and excessive write permissions"

out=$(PATH="$ROOT/bin:$PATH" OMARCHY_DRI_PATH="$dri" "$bind/demo" hello)
[[ $out == "real --ozone-platform=wayland --disable-gpu hello" ]] ||
  fail "wrapper injects software GL flags" "$out"
pass "wrapper injects software GL flags"

mkdir -p "$dri"
touch "$dri/renderD128"
out=$(PATH="$ROOT/bin:$PATH" OMARCHY_DRI_PATH="$dri" "$bind/demo" hello)
[[ $out == "real hello" ]] ||
  fail "wrapper is a no-op when a render GPU exists" "$out"
pass "wrapper is a no-op when a render GPU exists"

wrap() {
  PATH="$ROOT/bin:$PATH" OMARCHY_ELECTRON_GL_BIND_DIR="$bind" \
    "$ROOT/bin/omarchy-cmd-electron-gl-wrap" "$@"
}

# A symlink is never an Omarchy launcher, even one aliasing the real binary.
app_real="$test_tmp/app/app"
mkdir -p "$(dirname "$app_real")"
cp "$real" "$app_real"
chmod 751 "$app_real"
app_hash=$(sha256sum "$app_real")
ln -s "$app_real" "$bind/app"
status=0
wrap app "$app_real" 2>"$test_tmp/error" || status=$?
(( status == 3 )) || fail "a symlink to the real binary is refused as an unmanaged launcher" "status $status"
[[ -L $bind/app && $(readlink "$bind/app") == "$app_real" ]] || fail "a symlink to the real binary is preserved"
[[ $(sha256sum "$app_real") == "$app_hash" && $(stat -c %a "$app_real") == "751" ]] ||
  fail "a refused symlink leaves the real binary's bytes and mode alone"
pass "a symlink to the real binary is refused and preserved"

other_real="$test_tmp/other-real"
cp "$real" "$other_real"
wrap demo "$other_real"
grep -Fxq "real=$other_real" "$bind/demo" || fail "marked wrapper can be updated to another binary"
pass "marked regular wrappers can be updated"

printf '#!/bin/bash\nprintf custom\\n\n' >"$bind/chromium"
chmod 750 "$bind/chromium"
custom_hash=$(sha256sum "$bind/chromium")
if wrap chromium "$real" 2>"$test_tmp/error"; then
  fail "custom Chromium launcher must be refused"
fi
[[ $(sha256sum "$bind/chromium") == "$custom_hash" && $(stat -c %a "$bind/chromium") == "750" ]] ||
  fail "custom Chromium launcher bytes and permissions are preserved"
grep -Fq 'unmanaged launcher' "$test_tmp/error" || fail "custom launcher refusal explains the conflict"
pass "custom Chromium launcher is refused and preserved"

for link_target in "$other_real" "$test_tmp/missing" "$bind/demo"; do
  ln -s "$link_target" "$bind/unknown"
  if wrap unknown "$real" 2>"$test_tmp/error"; then
    fail "unknown symlink must be refused" "$link_target"
  fi
  [[ -L $bind/unknown && $(readlink "$bind/unknown") == "$link_target" ]] ||
    fail "unknown symlink is preserved" "$link_target"
  rm "$bind/unknown"
done
pass "unknown, dangling, and marked-wrapper symlinks are refused and preserved"

cp "$real" "$bind/self"
self_hash=$(sha256sum "$bind/self")
if wrap self "$bind/self" 2>"$test_tmp/error"; then
  fail "literal self-wrap must be refused"
fi
[[ $(sha256sum "$bind/self") == "$self_hash" ]] || fail "self-wrap preserves real executable"
ln "$app_real" "$bind/hardlink"
if wrap hardlink "$app_real" 2>"$test_tmp/error"; then
  fail "hardlink self-wrap must be refused"
fi
[[ $bind/hardlink -ef $app_real ]] || fail "hardlink self-wrap preserves hardlink"
[[ $(sha256sum "$app_real") == "$app_hash" && $(stat -c %a "$app_real") == "751" ]] ||
  fail "hardlink self-wrap preserves binary bytes and mode"
pass "literal self-wrap and hardlinked binaries are refused"

for invalid_name in "" . .. ../escape nested/launcher; do
  if wrap "$invalid_name" "$real" 2>"$test_tmp/error"; then
    fail "command name must be a basename" "$invalid_name"
  fi
done
[[ ! -e $test_tmp/escape && ! -e $bind/nested ]] || fail "invalid names do not escape the launcher directory"
pass "invalid and traversing command names are refused"

# Fail after staging has begun: an old wrapper stays, and no new launcher
# appears, until both the staged write and permissions have succeeded.
failure_stubs="$test_tmp/failure-stubs"
mkdir -p "$failure_stubs"
for command in mktemp tee chmod mv; do
  printf '#!/bin/bash\nexit 93\n' >"$failure_stubs/$command"
  chmod +x "$failure_stubs/$command"
  for launcher in demo fresh; do
    old_wrapper_hash=$(sha256sum "$bind/demo")
    if PATH="$failure_stubs:$ROOT/bin:$PATH" OMARCHY_ELECTRON_GL_BIND_DIR="$bind" \
      "$ROOT/bin/omarchy-cmd-electron-gl-wrap" "$launcher" "$app_real" \
      2>"$test_tmp/error"; then
      fail "failed staging $command must be reported for $launcher"
    fi
    [[ $(sha256sum "$bind/demo") == "$old_wrapper_hash" ]] || fail "failed $command preserves old wrapper"
    [[ ! -e $bind/fresh ]] || fail "failed $command installs no new launcher"
    [[ $(sha256sum "$app_real") == "$app_hash" && $(stat -c %a "$app_real") == "751" ]] ||
      fail "failed $command preserves real binary bytes and mode"
    if compgen -G "$bind/.omarchy-electron-gl.*" >/dev/null; then
      fail "failed $command cleans up staged files"
    fi
  done
  rm "$failure_stubs/$command"
done
pass "mktemp, write, chmod, and rename failures preserve launchers and clean up staged files"
