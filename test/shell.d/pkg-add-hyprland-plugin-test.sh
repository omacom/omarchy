#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_path="$test_tmp/bin"
mkdir -p "$mock_path"

# pacman answers from TEST_* variables: the installed packages, the sync
# database's -Si output, and which dependencies -T finds unsatisfied.
cat >"$mock_path/pacman" <<'EOF'
#!/bin/bash
case $1 in
  -Q)
    for installed in ${TEST_INSTALLED:-}; do
      if [[ ${installed%%=*} == "${@: -1}" ]]; then
        echo "${installed%%=*} ${installed#*=}"
        exit 0
      fi
    done
    echo "error: package '${*: -1}' was not found" >&2
    exit 1
    ;;
  -Si)
    if [[ -z ${TEST_SYNC_INFO:-} ]]; then
      echo "error: package '${*: -1}' was not found" >&2
      exit 1
    fi
    printf '%s\n' "$TEST_SYNC_INFO"
    ;;
  -T)
    printf '%s\n' "${@: -1}" >>"$TEST_TMP/checked"
    if [[ -n ${TEST_DEPTEST_STATUS:-} ]]; then
      exit "$TEST_DEPTEST_STATUS"
    fi
    ;;
esac
EOF

cat >"$mock_path/omarchy-pkg-add" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_TMP/installed"
exit "${TEST_ADD_STATUS:-0}"
EOF

chmod +x "$mock_path/pacman" "$mock_path/omarchy-pkg-add"

sync_info() {
  printf 'Repository      : %s\nName            : omarchy-hyprland-titlebars\nDepends On      : %s\nOptional Deps   : None\n\n' "$@"
}

run_plugin_add() {
  rm -f "$test_tmp/installed" "$test_tmp/checked"
  PATH="$mock_path:$ROOT/bin:$PATH" TEST_TMP="$test_tmp" \
    "$ROOT/bin/omarchy-pkg-add-hyprland-plugin" omarchy-hyprland-titlebars >"$test_tmp/output" 2>&1
}

TEST_INSTALLED="hyprland=0.57.1-1 omarchy-hyprland-titlebars=0.3.0-4" run_plugin_add ||
  fail "an installed plugin is left alone" "$(<"$test_tmp/output")"
[[ ! -e $test_tmp/installed && ! -e $test_tmp/checked ]] || fail "an installed plugin is not looked up again"
pass "an installed plugin is left alone"

TEST_INSTALLED="hyprland=0.57.1-1" \
  TEST_SYNC_INFO=$(sync_info omarchy "glibc  libgcc  hyprlang  hyprutils  hyprland=0.57.1") \
  run_plugin_add || fail "a plugin built for the installed Hyprland installs" "$(<"$test_tmp/output")"
[[ $(<"$test_tmp/checked") == "hyprland=0.57.1" ]] || fail "the plugin's Hyprland pin is checked against the installed Hyprland" "$(<"$test_tmp/checked")"
[[ $(<"$test_tmp/installed") == "omarchy-hyprland-titlebars" ]] || fail "a plugin built for the installed Hyprland installs"
pass "a plugin built for the installed Hyprland installs"

TEST_INSTALLED="hyprland=0.57.1-1" TEST_DEPTEST_STATUS=127 \
  TEST_SYNC_INFO=$(sync_info omarchy "glibc  hyprlang  hyprland=0.56.2") \
  run_plugin_add || fail "a plugin built for another Hyprland is skipped without failing" "$(<"$test_tmp/output")"
[[ ! -e $test_tmp/installed ]] || fail "a plugin built for another Hyprland is not installed"
grep -Fq 'Skipped omarchy-hyprland-titlebars: it loads only into hyprland=0.56.2, and hyprland 0.57.1-1 is installed. Add it with "omarchy-pkg-add omarchy-hyprland-titlebars" once they match.' "$test_tmp/output" ||
  fail "the skip names both Hyprland versions and how to install the plugin later" "$(<"$test_tmp/output")"
pass "a plugin built for another Hyprland is skipped, naming both versions"

TEST_DEPTEST_STATUS=127 \
  TEST_SYNC_INFO=$(sync_info omarchy "glibc  hyprland=0.56.2") \
  run_plugin_add || fail "a plugin is skipped when Hyprland is not installed" "$(<"$test_tmp/output")"
[[ ! -e $test_tmp/installed ]] || fail "a plugin is not installed without Hyprland"
grep -Fq 'and no hyprland is installed' "$test_tmp/output" || fail "the skip says Hyprland is not installed" "$(<"$test_tmp/output")"
pass "a plugin is skipped when Hyprland is not installed"

TEST_INSTALLED="hyprland=0.57.1-1" TEST_DEPTEST_STATUS=127 \
  TEST_SYNC_INFO="$(sync_info omarchy "glibc  hyprland=0.56.2")"$'\n'"$(sync_info other "glibc  hyprland=0.57.1")" \
  run_plugin_add || fail "the first repository's build decides" "$(<"$test_tmp/output")"
[[ $(<"$test_tmp/checked") == "hyprland=0.56.2" ]] || fail "the build pacman would install is the one checked" "$(<"$test_tmp/checked")"
pass "the first repository's build is the one checked, as pacman would pick it"

wrapped_info=$(printf 'Repository      : omarchy\nDepends On      : glibc  libgcc  hyprlang\n                  hyprutils  hyprland=0.56.2\nOptional Deps   : hyprland=0.1\n')
TEST_INSTALLED="hyprland=0.57.1-1" TEST_DEPTEST_STATUS=127 TEST_SYNC_INFO=$wrapped_info \
  run_plugin_add || fail "a pin pacman wrapped onto a second line is still checked" "$(<"$test_tmp/output")"
[[ $(<"$test_tmp/checked") == "hyprland=0.56.2" && ! -e $test_tmp/installed ]] ||
  fail "a pin pacman wrapped onto a second line is still checked"
pass "a pin pacman wrapped onto a second line is still checked, and nothing past the list is"

TEST_INSTALLED="hyprland=0.57.1-1" TEST_SYNC_INFO=$(sync_info omarchy "glibc  hyprland-protocols") \
  run_plugin_add || fail "a plugin with no Hyprland pin installs" "$(<"$test_tmp/output")"
[[ ! -e $test_tmp/checked && $(<"$test_tmp/installed") == "omarchy-hyprland-titlebars" ]] ||
  fail "a dependency that only starts with hyprland is not taken for the pin"
pass "a plugin with no Hyprland pin installs"

if TEST_INSTALLED="hyprland=0.57.1-1" run_plugin_add; then
  fail "a plugin missing from the sync database fails"
fi
[[ ! -e $test_tmp/installed ]] || fail "a plugin missing from the sync database is not installed"
pass "a plugin missing from the sync database fails"

if TEST_INSTALLED="hyprland=0.57.1-1" TEST_DEPTEST_STATUS=1 \
  TEST_SYNC_INFO=$(sync_info omarchy "glibc  hyprland=0.57.1") run_plugin_add; then
  fail "a dependency check that errors fails"
fi
[[ ! -e $test_tmp/installed ]] || fail "a dependency check that errors installs nothing"
pass "a dependency check that errors fails rather than skipping"

if TEST_INSTALLED="hyprland=0.57.1-1" TEST_ADD_STATUS=1 \
  TEST_SYNC_INFO=$(sync_info omarchy "glibc  hyprland=0.57.1") run_plugin_add; then
  fail "a failed install of a matching plugin fails"
fi
pass "a failed install of a matching plugin fails"
