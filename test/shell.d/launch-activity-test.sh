#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mock_bin="$tmp_dir/bin"
test_home="$tmp_dir/home"
btop_conf="$test_home/.config/btop/btop.conf"
mkdir -p "$mock_bin" "$(dirname "$btop_conf")"

cat >"$mock_bin/omarchy-hw-nvidia-suspended" <<'STUB'
#!/bin/bash
[[ ${OMARCHY_TEST_NVIDIA_SUSPENDED:-false} == "true" ]]
STUB
cat >"$mock_bin/omarchy-launch-tui" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_LAUNCH_LOG"
STUB
chmod +x "$mock_bin"/*

launch() {
  HOME="$test_home" OMARCHY_TEST_LAUNCH_LOG="$tmp_dir/launch.log" PATH="$mock_bin:$PATH" "$ROOT/bin/omarchy-launch-activity"
}

shown_gpus() {
  sed -n 's/^shown_gpus = "\(.*\)"$/\1/p' "$btop_conf"
}

write_conf() {
  printf '#* Set which GPU vendors to show.\nshown_gpus = "%s"\n\ncustom_gpu_name0 = ""\n' "$1" >"$btop_conf"
}

write_conf "nvidia amd intel"
OMARCHY_TEST_NVIDIA_SUSPENDED=true launch
[[ $(shown_gpus) == "amd intel" ]] || fail "a suspended NVIDIA GPU is left out of shown_gpus" "$(<"$btop_conf")"
[[ $(<"$tmp_dir/launch.log") == "btop" ]] || fail "Activity still launches btop"
pass "a suspended NVIDIA GPU is left out of shown_gpus"

OMARCHY_TEST_NVIDIA_SUSPENDED=false launch
[[ $(shown_gpus) == "nvidia amd intel" ]] || fail "an awake NVIDIA GPU is put back into shown_gpus" "$(<"$btop_conf")"
pass "an awake NVIDIA GPU is put back into shown_gpus"

write_conf "amd"
OMARCHY_TEST_NVIDIA_SUSPENDED=true launch
[[ $(shown_gpus) == "amd" ]] || fail "a list without nvidia is left alone" "$(<"$btop_conf")"
grep -q '^custom_gpu_name0 = ""$' "$btop_conf" || fail "the rest of the config is untouched"
pass "a list without nvidia is left alone"

rm "$btop_conf"
: >"$tmp_dir/launch.log"
OMARCHY_TEST_NVIDIA_SUSPENDED=true launch
[[ $(<"$tmp_dir/launch.log") == "btop" ]] || fail "Activity launches without a btop config"
[[ ! -e $btop_conf ]] || fail "no config is invented when none exists"
pass "Activity launches without a btop config"
