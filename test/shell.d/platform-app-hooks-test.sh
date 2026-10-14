#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Browser and Steam installs, and Steam's removal, call the platform's own
# hooks through the real dispatcher: a Mac fixture with omarchy-mac's
# entrypoints, and x86.

require_platform_fixtures "app-install hooks on platform fixtures"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fake_platform "$tmp/apple" aarch64-apple
fake_platform "$tmp/x86" x86

# The hooks record what they were called with and which flags files the
# browser install had written by then.
lifecycle=$tmp/lifecycle
mkdir -p "$lifecycle/usr/lib/omarchy/mac"
for operation in post-install pre-remove; do
  cat >"$lifecycle/usr/lib/omarchy/mac/$operation" <<SH
#!/bin/bash
printf '%s %s\n' "$operation" "\$*" >>"$tmp/calls"
ls "\$HOME/.config" 2>/dev/null | grep -- '-flags.conf$' >"$tmp/flags-at-hook" || true
[[ ! -e $tmp/fail ]]
SH
  chmod 755 "$lifecycle/usr/lib/omarchy/mac/$operation"
done
chmod -R go-w "$lifecycle"

stub_bin=$tmp/bin
omarchy_path=$tmp/omarchy
mkdir -p "$stub_bin" "$omarchy_path/install/helpers" "$omarchy_path/config"
printf 'browser_policy_setup_dir() { :; }\nbrowser_policy_setup_firefox_distribution() { :; }\nas_root() { "$@"; }\n' \
  >"$omarchy_path/install/helpers/browser-policy.sh"
cp "$ROOT/config/chromium-flags.conf" "$omarchy_path/config/"
for command in omarchy-pkg-add omarchy-pkg-aur-add omarchy-pkg-drop omarchy-install-gaming-gpu-lib32; do
  printf '#!/bin/bash\nprintf "%%s %%s\\n" "%s" "$*" >>"%s"\n' "$command" "$tmp/calls" >"$stub_bin/$command"
done
for command in omarchy-install-chromium-copy-url omarchy-install-chromium-ytdlp omarchy-theme-set-browser setsid; do
  printf '#!/bin/bash\nexit 0\n' >"$stub_bin/$command"
done
chmod +x "$stub_bin"/*

run() {
  local platform=$1
  shift
  rm -f "$tmp/calls" "$tmp/flags-at-hook"
  rm -rf "$tmp/home"
  mkdir -p "$tmp/home"
  HOME="$tmp/home" OMARCHY_PATH="$omarchy_path" OMARCHY_OPT_PATH="$tmp/opt" \
    OMARCHY_PROC_ROOT="$tmp/$platform/proc" OMARCHY_LIFECYCLE_ROOT="$lifecycle" \
    PATH="$stub_bin:$tmp/$platform/bin:$ROOT/bin:$PATH" bash "$@" >"$tmp/output" 2>&1
}

# ── browsers ─────────────────────────────────────────────────────────────────

declare -A flags=(
  [chromium]=chromium-flags.conf [chrome]=chrome-flags.conf [edge]=microsoft-edge-stable-flags.conf
  [brave]=brave-flags.conf [brave-origin]=brave-origin-flags.conf [firefox]="" [zen]=""
)
for browser in chromium chrome edge brave brave-origin firefox zen; do
  run apple "$ROOT/bin/omarchy-install-browser" "$browser" || fail "apple: $browser installs" "$(cat "$tmp/output")"
  [[ $(grep -c '^post-install ' "$tmp/calls") == 1 ]] && grep -qx "post-install $browser" "$tmp/calls" ||
    fail "apple: a $browser install runs post-install $browser once" "$(cat "$tmp/calls")"
  [[ $(cat "$tmp/flags-at-hook") == "${flags[$browser]}" ]] ||
    fail "apple: the $browser hook runs once its flags file is written" "$(cat "$tmp/flags-at-hook")"
  [[ $(grep -n . "$tmp/calls" | grep -m1 'post-install' | cut -d: -f1) -gt 1 ]] ||
    fail "apple: the $browser hook runs after its package step" "$(cat "$tmp/calls")"
done
pass "apple: every browser install runs post-install <browser> after its package and flags"

touch "$tmp/fail"
for browser in chromium brave; do
  if run apple "$ROOT/bin/omarchy-install-browser" "$browser"; then
    fail "apple: a failed $browser hook fails the install"
  fi
  ! grep -q 'browser installed' "$tmp/output" || fail "apple: a failed $browser hook is not announced as installed" "$(cat "$tmp/output")"
done
pass "apple: a failed browser hook fails the install"

for browser in chromium brave-origin zen; do
  run x86 "$ROOT/bin/omarchy-install-browser" "$browser" || fail "x86: $browser installs" "$(cat "$tmp/output")"
  ! grep -q '^post-install' "$tmp/calls" || fail "x86: a $browser install runs no hook" "$(cat "$tmp/calls")"
done
rm -f "$tmp/fail"
pass "x86: browser installs run no hook, even with Mac entrypoints on disk"

# ── Steam ────────────────────────────────────────────────────────────────────

run apple "$ROOT/bin/omarchy-install-gaming-steam" || fail "apple: Steam installs" "$(cat "$tmp/output")"
[[ $(cat "$tmp/calls") == $'omarchy-install-gaming-gpu-lib32 \nomarchy-pkg-add steam\npost-install steam' ]] ||
  fail "apple: Steam's hook runs after the 32-bit drivers and the package" "$(cat "$tmp/calls")"
run apple "$ROOT/bin/omarchy-remove-gaming-steam" || fail "apple: Steam is removed" "$(cat "$tmp/output")"
[[ $(head -n 2 "$tmp/calls") == $'pre-remove steam\nomarchy-pkg-drop steam' ]] ||
  fail "apple: Steam's pre-remove hook runs before the package goes" "$(cat "$tmp/calls")"
touch "$tmp/fail"
if run apple "$ROOT/bin/omarchy-install-gaming-steam"; then
  fail "apple: a failed Steam hook fails the install"
fi
if run apple "$ROOT/bin/omarchy-remove-gaming-steam"; then
  fail "apple: a failed pre-remove hook stops the removal"
fi
! grep -q '^omarchy-pkg-drop' "$tmp/calls" || fail "apple: a failed pre-remove hook removes nothing" "$(cat "$tmp/calls")"
pass "apple: Steam's install and removal run their hooks in order, and fail with them"

run x86 "$ROOT/bin/omarchy-install-gaming-steam" || fail "x86: Steam installs" "$(cat "$tmp/output")"
[[ $(cat "$tmp/calls") == $'omarchy-install-gaming-gpu-lib32 \nomarchy-pkg-add steam' ]] ||
  fail "x86: Steam installs as before" "$(cat "$tmp/calls")"
run x86 "$ROOT/bin/omarchy-remove-gaming-steam" || fail "x86: Steam is removed" "$(cat "$tmp/output")"
[[ $(cat "$tmp/calls") == "omarchy-pkg-drop steam" ]] || fail "x86: Steam is removed as before" "$(cat "$tmp/calls")"
rm -f "$tmp/fail"
pass "x86: Steam installs and is removed as before, running no hook"

# ── 32-bit drivers ───────────────────────────────────────────────────────────

# Without an Intel, AMD or NVIDIA GPU there is nothing to add, which must not
# fail the Steam install that asked.
gpu_bin=$tmp/gpu-bin
mkdir -p "$gpu_bin"
printf '#!/bin/bash\necho "00:02.0 VGA compatible controller: %s"\n' '${GPU:-Apple Inc. AGX}' >"$gpu_bin/lspci"
printf '#!/bin/bash\nexit 1\n' >"$gpu_bin/omarchy-hw-nvidia-gsp"
printf '#!/bin/bash\nexit 1\n' >"$gpu_bin/omarchy-hw-nvidia-without-gsp"
printf '#!/bin/bash\necho "omarchy-pkg-add $*" >>"%s"\n' "$tmp/calls" >"$gpu_bin/omarchy-pkg-add"
chmod +x "$gpu_bin"/*
rm -f "$tmp/calls"
PATH="$gpu_bin:$PATH" bash "$ROOT/bin/omarchy-install-gaming-gpu-lib32" >"$tmp/output" 2>&1 ||
  fail "no supported GPU is not a failure" "$(cat "$tmp/output")"
[[ ! -e $tmp/calls ]] || fail "no supported GPU installs nothing" "$(cat "$tmp/calls")"
GPU="Advanced Micro Devices, Inc. [AMD/ATI] Navi 31" PATH="$gpu_bin:$PATH" bash "$ROOT/bin/omarchy-install-gaming-gpu-lib32" >/dev/null 2>&1 ||
  fail "an AMD GPU installs its 32-bit driver"
[[ $(cat "$tmp/calls") == "omarchy-pkg-add lib32-vulkan-radeon" ]] || fail "an AMD GPU gets lib32-vulkan-radeon" "$(cat "$tmp/calls")"
pass "32-bit drivers: a machine with no supported GPU adds nothing without failing"
