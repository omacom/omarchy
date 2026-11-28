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
fake_platform "$tmp/qualcomm" aarch64-qualcomm
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
  [brave]=brave-flags.conf [brave-origin]=brave-origin-flags.conf [firefox]="" [zen]="" [ladybird]=""
)
for browser in chromium chrome edge brave brave-origin firefox zen ladybird; do
  run apple "$ROOT/bin/omarchy-install-browser" "$browser" || fail "apple: $browser installs" "$(cat "$tmp/output")"
  [[ $(grep -c '^post-install ' "$tmp/calls") == 1 ]] && grep -qx "post-install $browser" "$tmp/calls" ||
    fail "apple: a $browser install runs post-install $browser once" "$(cat "$tmp/calls")"
  [[ $(cat "$tmp/flags-at-hook") == "${flags[$browser]}" ]] ||
    fail "apple: the $browser hook runs once its flags file is written" "$(cat "$tmp/flags-at-hook")"
  [[ $(grep -n . "$tmp/calls" | grep -m1 'post-install' | cut -d: -f1) -gt 1 ]] ||
    fail "apple: the $browser hook runs after its package step" "$(cat "$tmp/calls")"
done
pass "apple: every browser install runs post-install <browser> after its package and flags"

# Both write a fresh flags file, which starts without the Snapdragon settings.
for browser in chromium chrome; do
  run qualcomm "$ROOT/bin/omarchy-install-browser" "$browser" ||
    fail "qualcomm: $browser installs" "$(cat "$tmp/output")"
  grep -Eq '^--enable-features=([^[:space:]]*,)?WebRtcPipeWireCamera(,|$)' "$tmp/home/.config/${flags[$browser]}" ||
    fail "qualcomm: $browser's flags enable the PipeWire camera" "$(cat "$tmp/home/.config/${flags[$browser]}")"
  run x86 "$ROOT/bin/omarchy-install-browser" "$browser" ||
    fail "x86: $browser installs" "$(cat "$tmp/output")"
  cmp -s "$ROOT/config/chromium-flags.conf" "$tmp/home/.config/${flags[$browser]}" ||
    fail "x86: $browser keeps the shipped flags" "$(cat "$tmp/home/.config/${flags[$browser]}")"
done
pass "qualcomm: Chromium and Chrome install with PipeWire camera support, and x86 keeps the shipped flags"

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
printf '#!/bin/bash\nexit "${ARCH_X86:-0}"\n' >"$gpu_bin/omarchy-hw-x86"
printf '#!/bin/bash\nexit "${NVIDIA_GSP:-1}"\n' >"$gpu_bin/omarchy-hw-nvidia-gsp"
printf '#!/bin/bash\nexit "${NVIDIA_WITHOUT_GSP:-1}"\n' >"$gpu_bin/omarchy-hw-nvidia-without-gsp"
printf '#!/bin/bash\nexit "${HYBRID_GPU:-1}"\n' >"$gpu_bin/omarchy-hw-hybrid-gpu"
cat >"$gpu_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
for pkg in "$@"; do
  case " ${INSTALLED_PKGS:-} " in
    *" $pkg "*) ;;
    *)
      # nvidia-580xx-utils provides nvidia-utils in pacman, so pacman -Q matches it.
      [[ $pkg == "nvidia-utils" && " ${INSTALLED_PKGS:-} " == *" nvidia-580xx-utils "* ]] || exit 1
      ;;
  esac
done
SH
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

# An active NVIDIA GPU adds its 32-bit driver and nvidia-prime for prime-run.
rm -f "$tmp/calls"
NVIDIA_GSP=0 PATH="$gpu_bin:$PATH" bash "$ROOT/bin/omarchy-install-gaming-gpu-lib32" >/dev/null 2>&1 ||
  fail "an active GSP NVIDIA GPU installs its 32-bit driver and nvidia-prime"
[[ $(cat "$tmp/calls") == "omarchy-pkg-add lib32-nvidia-utils nvidia-prime" ]] ||
  fail "an active GSP NVIDIA GPU gets lib32-nvidia-utils and nvidia-prime" "$(cat "$tmp/calls")"
rm -f "$tmp/calls"
NVIDIA_WITHOUT_GSP=0 PATH="$gpu_bin:$PATH" bash "$ROOT/bin/omarchy-install-gaming-gpu-lib32" >/dev/null 2>&1 ||
  fail "an active non-GSP NVIDIA GPU installs its 32-bit driver and nvidia-prime"
[[ $(cat "$tmp/calls") == "omarchy-pkg-add lib32-nvidia-580xx-utils nvidia-prime" ]] ||
  fail "an active non-GSP NVIDIA GPU gets lib32-nvidia-580xx-utils and nvidia-prime" "$(cat "$tmp/calls")"
pass "32-bit drivers: active NVIDIA GPUs add their matching lib32 driver and nvidia-prime"

# In supergfxd Integrated mode the NVIDIA PCI device is detached, so hardware
# probes return false. Fall back to the installed userspace driver package,
# checking nvidia-580xx-utils before nvidia-utils (which 580xx provides).
rm -f "$tmp/calls"
GPU="Intel Corporation Raptor Lake-P" INSTALLED_PKGS="nvidia-utils" \
  PATH="$gpu_bin:$PATH" bash "$ROOT/bin/omarchy-install-gaming-gpu-lib32" >/dev/null 2>&1 ||
  fail "Integrated mode with nvidia-utils installs lib32-nvidia-utils and nvidia-prime"
[[ $(cat "$tmp/calls") == "omarchy-pkg-add lib32-vulkan-intel lib32-nvidia-utils nvidia-prime" ]] ||
  fail "Integrated mode with nvidia-utils gets iGPU Vulkan, lib32-nvidia-utils, and nvidia-prime" "$(cat "$tmp/calls")"
rm -f "$tmp/calls"
GPU="Intel Corporation Raptor Lake-P" INSTALLED_PKGS="nvidia-580xx-utils" \
  PATH="$gpu_bin:$PATH" bash "$ROOT/bin/omarchy-install-gaming-gpu-lib32" >/dev/null 2>&1 ||
  fail "Integrated mode with nvidia-580xx-utils installs lib32-nvidia-580xx-utils and nvidia-prime"
[[ $(cat "$tmp/calls") == "omarchy-pkg-add lib32-vulkan-intel lib32-nvidia-580xx-utils nvidia-prime" ]] ||
  fail "Integrated mode with nvidia-580xx-utils gets lib32-nvidia-580xx-utils rather than lib32-nvidia-utils" "$(cat "$tmp/calls")"
pass "32-bit drivers: Integrated mode falls back to installed NVIDIA driver packages"

# Multilib only exists on x86_64; an ARM machine runs the native arm64 Steam.
rm -f "$tmp/calls"
ARCH_X86=1 GPU="Advanced Micro Devices, Inc. [AMD/ATI] Navi 31" PATH="$gpu_bin:$PATH" bash "$ROOT/bin/omarchy-install-gaming-gpu-lib32" >/dev/null 2>&1 ||
  fail "aarch64 skips the 32-bit drivers without failing"
[[ ! -e $tmp/calls ]] || fail "aarch64 installs no 32-bit driver" "$(cat "$tmp/calls")"
pass "32-bit drivers: aarch64 adds none, even with a supported GPU"

# ── Hybrid GPU Integrated-mode hints ─────────────────────────────────────────

printf '{\n  "mode": "Integrated"\n}\n' >"$tmp/supergfxd-integrated.conf"
printf '{\n  "mode": "Hybrid"\n}\n' >"$tmp/supergfxd-hybrid.conf"

# The shared lib32 driver step prints a hint once for all gaming installers
# when Integrated mode is active on hybrid hardware, and stays quiet otherwise
# (including when /etc/supergfxd.conf does not exist).
HYBRID_GPU=0 OMARCHY_PATH="$ROOT" OMARCHY_LANGUAGE_FILE="$tmp/no-lang" OMARCHY_SUPERGFXD_CONF="$tmp/supergfxd-integrated.conf" \
  PATH="$gpu_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-install-gaming-gpu-lib32" >"$tmp/gpu-integrated.out" 2>&1 ||
  fail "lib32 driver step succeeds in Integrated mode" "$(cat "$tmp/gpu-integrated.out")"
grep -Fq "Trigger > Hardware > Switch to dGPU" "$tmp/gpu-integrated.out" ||
  fail "lib32 driver step hints about switching to dGPU in Integrated mode" "$(cat "$tmp/gpu-integrated.out")"

HYBRID_GPU=0 OMARCHY_PATH="$ROOT" OMARCHY_LANGUAGE_FILE="$tmp/no-lang" OMARCHY_SUPERGFXD_CONF="$tmp/supergfxd-hybrid.conf" \
  PATH="$gpu_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-install-gaming-gpu-lib32" >"$tmp/gpu-hybrid.out" 2>&1 ||
  fail "lib32 driver step succeeds in Hybrid mode" "$(cat "$tmp/gpu-hybrid.out")"
! grep -Fq "Switch to dGPU" "$tmp/gpu-hybrid.out" ||
  fail "lib32 driver step stays quiet about Integrated mode in Hybrid mode" "$(cat "$tmp/gpu-hybrid.out")"

HYBRID_GPU=0 OMARCHY_PATH="$ROOT" OMARCHY_LANGUAGE_FILE="$tmp/no-lang" OMARCHY_SUPERGFXD_CONF="$tmp/no-supergfxd.conf" \
  PATH="$gpu_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-install-gaming-gpu-lib32" >"$tmp/gpu-noconf.out" 2>"$tmp/gpu-noconf.err" ||
  fail "lib32 driver step succeeds without supergfxd.conf" "$(cat "$tmp/gpu-noconf.out" "$tmp/gpu-noconf.err")"
[[ ! -s $tmp/gpu-noconf.err ]] && ! grep -Fq "Switch to dGPU" "$tmp/gpu-noconf.out" ||
  fail "lib32 driver step stays quiet with no stderr when supergfxd.conf is absent" "$(cat "$tmp/gpu-noconf.out" "$tmp/gpu-noconf.err")"
pass "32-bit drivers: hints about Switch to dGPU only in Integrated mode"

# Battle.net launch sends a transient notification in Integrated mode and still launches.
hint_bin=$tmp/hint-bin
mkdir -p "$hint_bin"
printf '#!/bin/bash\nexit "${HYBRID_GPU:-0}"\n' >"$hint_bin/omarchy-hw-hybrid-gpu"
printf '#!/bin/bash\nprintf "%%s\\n" "$@" >"%s"\n' "$tmp/notify" >"$hint_bin/omarchy-notification-send"
printf '#!/bin/bash\nprintf "%%s\\n" "$*" >>"%s"\n' "$tmp/umu" >"$hint_bin/umu-run"
printf '#!/bin/bash\nexit 1\n' >"$hint_bin/pgrep"
printf '#!/bin/bash\necho "[]"\n' >"$hint_bin/hyprctl"
chmod +x "$hint_bin"/*

bnet_home=$tmp/bnet-home
mkdir -p "$bnet_home/Games/battlenet/drive_c/Program Files (x86)/Battle.net"
: >"$bnet_home/Games/battlenet/drive_c/Program Files (x86)/Battle.net/Battle.net Launcher.exe"
: >"$bnet_home/Games/battlenet/user.reg"

rm -f "$tmp/notify" "$tmp/umu"
HOME="$bnet_home" OMARCHY_PATH="$ROOT" OMARCHY_LANGUAGE_FILE="$tmp/no-lang" \
  OMARCHY_SUPERGFXD_CONF="$tmp/supergfxd-integrated.conf" \
  PATH="$hint_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-launch-battlenet" >"$tmp/bnet.out" 2>&1 ||
  fail "Battle.net launches in Integrated mode" "$(cat "$tmp/bnet.out")"
for _ in {1..40}; do [[ -s $tmp/notify ]] && break; sleep 0.05; done
grep -Fxq -- "--transient" "$tmp/notify" &&
  grep -Fxq "Running on integrated GPU" "$tmp/notify" &&
  grep -Fq "Trigger > Hardware > Switch to dGPU" "$tmp/notify" ||
  fail "Battle.net launch sends a transient Switch to dGPU hint in Integrated mode" "$(cat "$tmp/notify" 2>/dev/null)"
[[ -s $tmp/umu ]] || fail "Battle.net still launches after sending the Integrated-mode hint"

rm -f "$tmp/notify" "$tmp/umu"
HOME="$bnet_home" OMARCHY_PATH="$ROOT" OMARCHY_LANGUAGE_FILE="$tmp/no-lang" \
  OMARCHY_SUPERGFXD_CONF="$tmp/supergfxd-hybrid.conf" \
  PATH="$hint_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-launch-battlenet" >"$tmp/bnet.out" 2>&1 ||
  fail "Battle.net launches in Hybrid mode" "$(cat "$tmp/bnet.out")"
[[ ! -e $tmp/notify ]] || fail "Battle.net sends no Integrated-mode hint in Hybrid mode" "$(cat "$tmp/notify")"
[[ -s $tmp/umu ]] || fail "Battle.net launches in Hybrid mode"
pass "Battle.net launch sends a transient Switch to dGPU hint only in Integrated mode"
