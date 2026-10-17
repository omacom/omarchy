#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mock_bin="$test_tmp/bin"
export HOME="$test_tmp/home with spaces"
export PATH="$mock_bin:$HOME/.local/bin:$ROOT/bin:/usr/local/bin:/usr/bin"
export OMARCHY_PATH="$ROOT"
export OMARCHY_TEST_MISE_LOG="$test_tmp/mise-log"
mkdir -p "$mock_bin" "$HOME/.local/bin"
devin="$HOME/.local/bin/devin"
package="http:devin[platforms_linux_x64_url=https://static.devin.ai/cli/{{ version }}/devin-{{ version }}-x86_64-unknown-linux.tar.gz,platforms_linux_arm64_url=https://static.devin.ai/cli/{{ version }}/devin-{{ version }}-aarch64-unknown-linux.tar.gz,bin_path=bin,version_list_url=https://static.devin.ai/cli/current/manifest.json,version_json_path=.version]"

cat >"$mock_bin/mise" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >>"$OMARCHY_TEST_MISE_LOG"
SH
cat >"$mock_bin/noop" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin/mise" "$mock_bin/noop"
for command in gum hyprctl omarchy-webapp-remove-all omarchy-tui-remove-all omarchy-pkg-drop; do
  ln -s noop "$mock_bin/$command"
done

apply_devin() {
  case $1 in
    migration) source "$ROOT/migrations/1792034198.sh" >/dev/null ;;
    removal) omarchy-remove-preinstalls >/dev/null ;;
  esac
}

apply_devin migration
[[ -x $devin && ! -L $devin ]] || fail "Devin CLI migration creates a missing wrapper"
[[ ! -s $OMARCHY_TEST_MISE_LOG ]] || fail "Devin CLI migration installs the package before first launch"
cp "$devin" "$test_tmp/wrapper"
apply_devin migration
cmp -s "$devin" "$test_tmp/wrapper" || fail "Devin CLI migration is idempotent"
"$devin" --prompt 'Review this project'
mapfile -d '' -t args <"$OMARCHY_TEST_MISE_LOG"
[[ ${args[*]} == "use -g --quiet $package x $package -- devin --prompt Review this project" ]] ||
  fail "Devin CLI migration wrapper installs the official package and forwards arguments"
pass "Devin CLI migration creates a lazy, repeatable wrapper"

rm -f "$devin"
mkdir -p "$HOME/.local/state/omarchy"
touch "$HOME/.local/state/omarchy/preinstalls-removed"
apply_devin migration
[[ ! -e $devin ]] || fail "Devin CLI migration respects removed preinstalls with a missing command"
rm "$HOME/.local/state/omarchy/preinstalls-removed"
pass "Devin CLI migration respects the preinstall opt-out"

for operation in migration removal; do
  for kind in script binary symlink; do
    rm -f "$devin"
    case $kind in
      script) printf '#!/bin/bash\necho user-managed devin\n' >"$devin" ;;
      binary) cp /usr/bin/true "$devin" ;;
      symlink) ln -s /usr/bin/true "$devin" ;;
    esac
    [[ $kind == "symlink" ]] || chmod +x "$devin"
    rm -f "$test_tmp/saved-$kind"
    cp -P "$devin" "$test_tmp/saved-$kind"
    for attempt in 1 2; do
      apply_devin "$operation"
      cmp -s "$devin" "$test_tmp/saved-$kind" || fail "Devin CLI $operation preserves a user $kind"
      if [[ $kind == "symlink" ]]; then
        [[ -L $devin && $(readlink "$devin") == "/usr/bin/true" ]] ||
          fail "Devin CLI $operation preserves the user's symlink"
      else
        [[ ! -L $devin ]] || fail "Devin CLI $operation keeps the user's $kind as a regular file"
      fi
    done
    pass "Devin CLI $operation preserves a user $kind on repeated runs"
  done
done

omarchy-mise-install "$package" devin
apply_devin removal
[[ ! -e $devin ]] || fail "Remove Preinstalls removes Omarchy's Devin CLI wrapper"
pass "Remove Preinstalls removes Omarchy's Devin CLI wrapper"
