#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mise_log="$test_tmp/mise"
mkdir -p "$mock_bin" "$test_home/.local/bin" "$test_home/.cargo/bin"

cat >"$mock_bin/mise" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_MISE_LOG"
SH
chmod +x "$mock_bin/mise"

export HOME="$test_home"
export OMARCHY_TEST_MISE_LOG="$mise_log"
export PATH="$mock_bin:$ROOT/bin:$PATH"

mise_config="$test_tmp/etc/mise/config.toml"
miserc="$test_home/.config/mise/miserc.toml"
export OMARCHY_MISE_CONFIG_PATH="$mise_config"

# Each dev env and the default tool it relies on. Python also installs Python
# itself, through the user's config.
envs=(
  "node node"
  "python uv"
)

# When Omarchy declares the tool system-wide, setup installs that version and
# leaves the user config alone. mise skips the declarations for a user who
# removed the preinstalls, and nothing declares the tool without Omarchy's
# config; either way it goes in the user's own config, and an opt-out stays.
for scenario in declared opted-out undeclared; do
  mkdir -p "$(dirname "$mise_config")"
  cp "$ROOT/etc/mise/conf.d/omarchy-tools.toml" "$mise_config"
  rm -f "$miserc"

  case $scenario in
    opted-out)
      mkdir -p "$(dirname "$miserc")"
      printf 'ignored_config_paths = ["%s"]\n' "$mise_config" >"$miserc"
      cp "$miserc" "$test_tmp/expected-miserc"
      ;;
    undeclared)
      rm "$mise_config"
      ;;
  esac

  for entry in "${envs[@]}"; do
    read -r env tool <<<"$entry"
    if [[ $scenario == "declared" ]]; then
      expected="install $tool"
      unexpected="use --global $tool"
    else
      expected="use --global $tool"
      unexpected="install $tool"
    fi

    : >"$mise_log"
    bash "$ROOT/bin/omarchy-install-dev-env" "$env" >/dev/null

    grep -Fx "$expected" "$mise_log" >/dev/null ||
      fail "$env setup runs '$expected' when $tool is $scenario" "$(<"$mise_log")"
    if grep -Fx "$unexpected" "$mise_log" >/dev/null; then
      fail "$env setup skips '$unexpected' when $tool is $scenario" "$(<"$mise_log")"
    fi
    if [[ $env == "python" ]]; then
      grep -Fx 'use --global python@latest' "$mise_log" >/dev/null ||
        fail "python setup installs Python through mise when $tool is $scenario" "$(<"$mise_log")"
    fi
    if [[ $scenario == "opted-out" ]]; then
      cmp -s "$miserc" "$test_tmp/expected-miserc" || fail "$env setup keeps the preinstall opt-out"
    fi
    pass "$env setup handles $tool when $scenario"
  done
done

touch "$test_home/.local/bin/uv" "$test_home/.local/bin/uvx" "$test_home/.cargo/bin/uv"
: >"$mise_log"
bash "$ROOT/bin/omarchy-remove-dev-env" python >/dev/null
grep -Fx 'uninstall python --all' "$mise_log" >/dev/null || fail "Python removal uninstalls mise Python"
grep -Fx 'rm -g python' "$mise_log" >/dev/null || fail "Python removal removes the global Python declaration"
grep -q 'uv' "$mise_log" && fail "Python removal does not remove the independent uv tool"
[[ -e $test_home/.local/bin/uv && -e $test_home/.local/bin/uvx && -e $test_home/.cargo/bin/uv ]] ||
  fail "Python removal preserves uv commands"
pass "Python removal preserves the default uv tool"

export TMPDIR="$test_tmp/downloads"
export OMARCHY_TEST_INSTALL_LOG="$test_tmp/installer"
mkdir -p "$TMPDIR"

cat >"$mock_bin/curl" <<'SH'
#!/bin/bash
output=""
while (( $# )); do
  if [[ $1 == "-o" ]]; then output=$2; shift; fi
  shift
done
script='printf "installer:%s\n" "$*" >>"$OMARCHY_TEST_INSTALL_LOG"
if [[ -n ${INTERRUPT_INSTALLER:-} ]]; then kill -"$INTERRUPT_INSTALLER" "$PPID"; fi
exit "${INSTALLER_STATUS:-0}"'
if [[ -n $output ]]; then printf '%s\n' "$script" >"$output"; else printf '%s\n' "$script"; fi
exit "${DOWNLOAD_STATUS:-0}"
SH
for command in omarchy-pkg-add opam; do
  printf '#!/bin/bash\nprintf "%s:%%s\\n" "$*" >>"$OMARCHY_TEST_INSTALL_LOG"\n' "$command" >"$mock_bin/$command"
done
chmod +x "$mock_bin/curl" "$mock_bin/omarchy-pkg-add" "$mock_bin/opam"

for environment in rust ocaml; do
  : >"$OMARCHY_TEST_INSTALL_LOG"
  if DOWNLOAD_STATUS=18 bash "$ROOT/bin/omarchy-install-dev-env" "$environment" >"$test_tmp/out" 2>&1; then
    fail "a truncated $environment installer fails"
  fi
  ! grep -qE '^(installer|opam):' "$OMARCHY_TEST_INSTALL_LOG" || fail "a failed $environment download runs no script or follow-up" "$(<"$OMARCHY_TEST_INSTALL_LOG")"
  [[ -z $(ls -A "$TMPDIR") ]] || fail "a failed download leaves no installer"
done
pass "neither partial installer is executed, and OCaml setup stops on download failure"

: >"$OMARCHY_TEST_INSTALL_LOG"
bash "$ROOT/bin/omarchy-install-dev-env" rust >"$test_tmp/out" 2>&1 || fail "the complete Rust installer runs" "$(<"$test_tmp/out")"
grep -qx 'installer:-y' "$OMARCHY_TEST_INSTALL_LOG" || fail "Rust keeps its install argument"
[[ -z $(ls -A "$TMPDIR") ]] || fail "a successful download leaves no installer"
pass "a complete Rust installer receives its arguments and is removed afterwards"

for environment in rust ocaml; do
  : >"$OMARCHY_TEST_INSTALL_LOG"
  status=0
  INSTALLER_STATUS=7 bash "$ROOT/bin/omarchy-install-dev-env" "$environment" >"$test_tmp/out" 2>&1 || status=$?
  (( status == 7 )) || fail "a failed $environment installer preserves its status"
  ! grep -q '^opam:' "$OMARCHY_TEST_INSTALL_LOG" || fail "a failed installer stops OCaml setup"
  [[ -z $(ls -A "$TMPDIR") ]] || fail "a failed installer leaves no file"

  for signal in TERM INT; do
    status=0
    INTERRUPT_INSTALLER=$signal bash "$ROOT/bin/omarchy-install-dev-env" "$environment" >"$test_tmp/out" 2>&1 || status=$?
    expected=143
    [[ $signal == "INT" ]] && expected=130
    (( status == expected )) || fail "a $signal-interrupted $environment installer preserves its status"
    [[ -z $(ls -A "$TMPDIR") ]] || fail "an interrupted installer leaves no file"
  done
done
pass "failed and interrupted installers fail setup and remove their files"
