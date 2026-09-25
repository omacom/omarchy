#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

# The updater builds a thin makepkg config that sources the real system and
# user configuration, only meaningful where a readable makepkg config exists
# to hand to makepkg.
if [[ ! -r ${MAKEPKG_CONF:-/etc/makepkg.conf} ]]; then
  skip "no readable makepkg config; skipping AUR build-job cap tests"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
test_home="$test_tmp/home"
config_home="$test_tmp/config"
yay_log="$test_tmp/yay-env.log"
yay_ran="$test_tmp/yay-ran"
merged_config="$test_tmp/merged-makepkg.conf"
mkdir -p "$stub_bin" "$test_home" "$config_home/pacman"

write_stub() {
  local name="$1"
  local body="$2"

  cat >"$stub_bin/$name" <<SH
#!/bin/bash
$body
SH
  chmod +x "$stub_bin/$name"
}

write_stub pacman 'exit 0'
write_stub omarchy-pkg-aur-accessible 'exit 0'
write_stub nproc 'echo "${TEST_NPROC:-8}"'
write_stub yay '
  printf "MAKEFLAGS=%s\nCARGO_BUILD_JOBS=%s\nCMAKE_BUILD_PARALLEL_LEVEL=%s\n" \
    "$MAKEFLAGS" "$CARGO_BUILD_JOBS" "$CMAKE_BUILD_PARALLEL_LEVEL" >"$YAY_LOG"
  prev=""
  for arg in "$@"; do
    if [[ $prev == --makepkgconf ]]; then
      cp "$arg" "$MAKEPKGCONF_COPY"
    fi
    prev=$arg
  done
  touch "$YAY_RAN"'

run_updater() {
  local jobs="${1:-}"
  local nproc="${2:-8}"
  local makepkg_conf="${3:-}"

  rm -f "$yay_ran" "$merged_config"
  : >"$yay_log"
  HOME="$test_home" \
  XDG_CONFIG_HOME="$config_home" \
  MAKEFLAGS= \
  MAKEPKG_CONF="$makepkg_conf" \
  YAY_LOG="$yay_log" \
  YAY_RAN="$yay_ran" \
  MAKEPKGCONF_COPY="$merged_config" \
  TEST_NPROC="$nproc" \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  LC_ALL=C \
  OMARCHY_AUR_BUILD_JOBS="$jobs" \
    "$ROOT/bin/omarchy-update-aur-pkgs" >/dev/null 2>&1
}

# The merged config is a shell script from makepkg's point of view; sourcing
# it yields the MAKEFLAGS value makepkg ends up with.
merged_makeflags() {
  bash --noprofile --norc -c 'source "$1"; printf "%s" "${MAKEFLAGS-}"' _ "$1"
}

# makepkg sources its configuration after the environment, so a MAKEFLAGS set
# there would silently replace the updater's env value. The merged config must
# append the selected job count last, where GNU Make reads the final job
# option as the effective one, whatever the configured spelling.
cat >"$config_home/pacman/makepkg.conf" <<'EOF'
MAKEFLAGS="-j4 --output-sync=recurse"
EOF
run_updater 1 8
[[ -f $yay_ran ]] || fail "yay runs for the AUR update"
[[ -f $merged_config ]] || fail "the updater hands yay a merged makepkg config"
makeflags=$(merged_makeflags "$merged_config")
[[ $makeflags == "-j4 --output-sync=recurse -j1" ]] || fail "configured MAKEFLAGS keeps its flags with the count appended" "got: $makeflags"
grep -Fxq 'MAKEFLAGS=-j1' "$yay_log" || fail "the environment still carries the selected count at the yay boundary"
pass "explicit one-job override beats a configured MAKEFLAGS while keeping its flags"

cat >"$config_home/pacman/makepkg.conf" <<'EOF'
MAKEFLAGS="--jobs=4"
EOF
run_updater 1 8
makeflags=$(merged_makeflags "$merged_config")
[[ $makeflags == "--jobs=4 -j1" ]] || fail "the --jobs=N spelling is capped by the appended count" "got: $makeflags"
pass "a --jobs=N configuration is capped by the appended count"

cat >"$config_home/pacman/makepkg.conf" <<'EOF'
MAKEFLAGS="-j 4"
EOF
run_updater 1 8
makeflags=$(merged_makeflags "$merged_config")
[[ $makeflags == "-j 4 -j1" ]] || fail "a spaced -j N configuration is capped, keeping its argument" "got: $makeflags"
pass "a spaced -j N configuration is capped without breaking its argument"

# Default: half the cores, mirrored into the merged config.
: >"$config_home/pacman/makepkg.conf"
run_updater "" 8
makeflags=$(merged_makeflags "$merged_config")
[[ $makeflags == "-j4" ]] || fail "default job count is half the cores" "got: $makeflags"
pass "default job count caps at half the cores"

# Floor: never fewer than one job.
run_updater "" 1
makeflags=$(merged_makeflags "$merged_config")
[[ $makeflags == "-j1" ]] || fail "job count never drops below one" "got: $makeflags"
pass "job count floors at one job on a single-core machine"

# Explicit override wins over the half-core default.
run_updater 2 8
makeflags=$(merged_makeflags "$merged_config")
[[ $makeflags == "-j2" ]] || fail "OMARCHY_AUR_BUILD_JOBS overrides the default" "got: $makeflags"
grep -Fxq 'CARGO_BUILD_JOBS=2' "$yay_log" || fail "Cargo receives the selected job count"
grep -Fxq 'CMAKE_BUILD_PARALLEL_LEVEL=2' "$yay_log" || fail "CMake receives the selected job count"
pass "OMARCHY_AUR_BUILD_JOBS overrides the default half-core count"

# A MAKEPKG_CONF custom file is the configuration; the user file is not read
# on top of it, exactly as makepkg resolves it.
custom_conf="$test_tmp/custom-makepkg.conf"
cat >"$custom_conf" <<'EOF'
MAKEFLAGS="-j2"
OMARCHY_PROBE_CUSTOM=1
EOF
run_updater 1 8 "$custom_conf"
makeflags=$(merged_makeflags "$merged_config")
custom_seen=$(bash --noprofile --norc -c 'source "$1"; printf "%s" "${OMARCHY_PROBE_CUSTOM-}"' _ "$merged_config")
[[ $makeflags == "-j2 -j1" ]] || fail "a MAKEPKG_CONF file is honored and capped" "got: $makeflags"
[[ $custom_seen == "1" ]] || fail "a MAKEPKG_CONF file keeps its settings"
pass "an alternate MAKEPKG_CONF file keeps its settings and is capped"

# Relative sources inside a user config resolve from that file's own path, not
# the merged config's.
cat >"$config_home/pacman/extra.conf" <<'EOF'
OMARCHY_PROBE_INCLUDED=1
EOF
cat >"$config_home/pacman/makepkg.conf" <<'EOF'
source "$(dirname "${BASH_SOURCE[0]}")/extra.conf"
EOF
run_updater 1 8
included=$(bash --noprofile --norc -c 'source "$1"; printf "%s" "${OMARCHY_PROBE_INCLUDED-}"' _ "$merged_config")
[[ $included == "1" ]] || fail "a relative source from a user config resolves from its own path"
pass "relative sources inside a user config keep resolving from that file"

# A configuration that fails to source aborts the config load, as it does at
# the merge base, instead of being masked by the merged config.
cat >"$config_home/pacman/makepkg.conf" <<'EOF'
source /missing/path.conf
EOF
run_updater 1 8
set +e
bash --noprofile --norc -c 'source "$1" || exit 7' _ "$merged_config"
error_status=$?
set -e
(( error_status == 7 )) || fail "a failing user config still aborts the config load" "got: $error_status"
pass "a failing user config still aborts the build config load"

# Skip path: AUR unreachable means no yay run at all.
write_stub omarchy-pkg-aur-accessible 'exit 1'
run_updater "" 8
[[ ! -f $yay_ran ]] || fail "yay is not invoked when the AUR is unreachable"
pass "AUR updates are skipped when the AUR is unreachable"