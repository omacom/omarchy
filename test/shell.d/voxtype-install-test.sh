#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
lib_path="$test_tmp/lib/voxtype"
calls="$test_tmp/calls.log"
mkdir -p "$stub_bin" "$lib_path"

for command in gum omarchy-pkg-drop omarchy-pkg-add hyprctl omarchy-restart-shell omarchy-notification-send systemctl; do
  printf '#!/bin/bash\nexit 0\n' >"$stub_bin/$command"
done
printf '#!/bin/bash\nexit 1\n' >"$stub_bin/omarchy-pkg-present"
# Voxtype is already installed, so the install asks nothing and only sets it up.
printf '#!/bin/bash\nexit 1\n' >"$stub_bin/omarchy-cmd-missing"
printf '#!/bin/bash\nexit 0\n' >"$stub_bin/omarchy-dictation-use"
cat >"$stub_bin/omarchy-hw-vulkan" <<'SH'
#!/bin/bash
(( ${VULKAN:-1} == 1 ))
SH
cat >"$stub_bin/voxtype" <<'SH'
#!/bin/bash
printf 'voxtype %s\n' "$*" >>"$TEST_LOG"
SH
chmod +x "$stub_bin"/*

run_install() {
  local vulkan=$1 backend=$2

  : >"$calls"
  rm -rf "$test_tmp/home" "$lib_path/voxtype-vulkan"
  mkdir -p "$test_tmp/home"
  case $backend in
  executable)
    printf '#!/bin/bash\n' >"$lib_path/voxtype-vulkan"
    chmod +x "$lib_path/voxtype-vulkan"
    ;;
  unusable)
    : >"$lib_path/voxtype-vulkan"
    ;;
  esac

  HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" OMARCHY_VOXTYPE_LIB_PATH="$lib_path" \
    VULKAN="$vulkan" TEST_LOG="$calls" PATH="$stub_bin:$ROOT/bin:$PATH" \
    XDG_CONFIG_HOME="$test_tmp/home/.config" bash "$ROOT/bin/omarchy-install-dictation-voxtype" >/dev/null ||
    fail "Voxtype install completes (vulkan=$vulkan backend=$backend)"

  grep -Fx 'voxtype setup systemd' "$calls" >/dev/null ||
    fail "Voxtype install sets up the user service (vulkan=$vulkan backend=$backend)"
}

run_install 1 executable
grep -Fx 'voxtype setup gpu --enable' "$calls" >/dev/null ||
  fail "Voxtype enables the GPU backend when Vulkan and the backend binary are present"
pass "Voxtype enables the GPU backend when Vulkan and the backend binary are present"

run_install 1 missing
! grep -q 'setup gpu' "$calls" ||
  fail "Voxtype does not enable a Vulkan backend the package did not ship"
pass "Voxtype does not enable a Vulkan backend the package did not ship"

run_install 1 unusable
! grep -q 'setup gpu' "$calls" ||
  fail "Voxtype does not enable a Vulkan backend that is not executable"
pass "Voxtype does not enable a Vulkan backend that is not executable"

run_install 0 executable
! grep -q 'setup gpu' "$calls" ||
  fail "Voxtype does not enable the GPU backend without a Vulkan runtime"
pass "Voxtype does not enable the GPU backend without a Vulkan runtime"

english="$test_tmp/home/.config/voxtype/config.toml"
grep -qx 'model = "base.en"' "$english" && grep -qx 'language = "en"' "$english" ||
  fail "an English desktop keeps the English-only whisper model"
pass "an English desktop keeps the English-only whisper model"

printf 'sv\n' >"$test_tmp/language"
OMARCHY_LANGUAGE_FILE="$test_tmp/language" run_install 0 executable
swedish="$test_tmp/home/.config/voxtype/config.toml"
grep -qx 'model = "base"' "$swedish" && grep -qx 'language = "sv"' "$swedish" ||
  fail "a Swedish desktop gets a multilingual model and Swedish" "$(grep -E '^(model|language) ' "$swedish")"
pass "a Swedish desktop gets a multilingual model and Swedish"

# A config someone already pointed at another model is not rewritten.
printf 'sv\n' >"$test_tmp/language"
mkdir -p "$test_tmp/home/.config/voxtype"
printf 'model = "large-v3"\nlanguage = "ja"\n' >"$swedish"
OMARCHY_LANGUAGE_FILE="$test_tmp/language" PATH="$stub_bin:$ROOT/bin:$PATH" \
  XDG_CONFIG_HOME="$test_tmp/home/.config" HOME="$test_tmp/home" \
  bash "$ROOT/bin/omarchy-voxtype-language" apply-stock
grep -qx 'model = "large-v3"' "$swedish" && grep -qx 'language = "ja"' "$swedish" ||
  fail "apply-stock leaves a whisper model the user already chose"
pass "apply-stock leaves a whisper model the user already chose"

# Existing stock configs must not point at a model whose download failed.
cat >"$swedish" <<'TOML'
[whisper]
model = "base.en"
language = "en"
[postprocess]
model = "keep-this-model"
language = "keep-this-language"
TOML
cp "$swedish" "$test_tmp/before.toml"
cat >"$stub_bin/voxtype" <<'STUB'
#!/bin/bash
printf 'voxtype %s\n' "$*" >>"$TEST_LOG"
grep -qx 'model = "base.en"' "$TEST_CONFIG" || exit 97
exit "${TEST_DOWNLOAD_STATUS:-0}"
STUB
cat >"$stub_bin/systemctl" <<'STUB'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$TEST_LOG"
if [[ $* == "--user restart voxtype.service" ]]; then
  grep -qx 'model = "base"' "$TEST_CONFIG" && grep -qx 'language = "sv"' "$TEST_CONFIG" || exit 98
fi
STUB
run_stock_update() {
  HOME="$test_tmp/home" XDG_CONFIG_HOME="$test_tmp/home/.config" OMARCHY_LANGUAGE_FILE="$test_tmp/language" \
    TEST_LOG="$calls" TEST_CONFIG="$swedish" TEST_DOWNLOAD_STATUS="$1" PATH="$stub_bin:$ROOT/bin:$PATH" \
    bash "$ROOT/bin/omarchy-voxtype-language" apply-stock
}
: >"$calls"
if run_stock_update 23; then
  fail "a failed model download stops the stock config update"
else
  status=$?
fi
(( status == 23 )) || fail "the download failure is preserved"
cmp -s "$swedish" "$test_tmp/before.toml" || fail "a failed download leaves the working config unchanged"
! grep -q '^systemctl ' "$calls" || fail "a failed download never restarts the daemon"
pass "a failed model download preserves the working config and running daemon"

: >"$calls"
run_stock_update 0
grep -Fxq 'voxtype setup --download --model base --no-post-install' "$calls" || fail "the replacement model is downloaded"
grep -Fxq 'systemctl --user restart voxtype.service' "$calls" || fail "the running daemon receives the changed config"
grep -qx 'model = "keep-this-model"' "$swedish" && grep -qx 'language = "keep-this-language"' "$swedish" ||
  fail "language setup preserves settings outside the whisper section"
pass "the stock update downloads first, preserves other sections, and restarts the running daemon"
