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
kiro_cli="$HOME/.local/bin/kiro-cli"
package="http:kiro-cli[platforms_linux_x64_url=https://prod.download.cli.kiro.dev/stable/{{version}}/kirocli-x86_64-linux.tar.gz,platforms_linux_arm64_url=https://prod.download.cli.kiro.dev/stable/{{version}}/kirocli-aarch64-linux.tar.gz,version_list_url=https://prod.download.cli.kiro.dev/stable/latest/manifest.json,version_json_path=.version]"

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

apply_kiro_cli() {
  case $1 in
    migration) source "$ROOT/migrations/1792033795.sh" >/dev/null ;;
    removal) omarchy-remove-preinstalls >/dev/null ;;
  esac
}

apply_kiro_cli migration
[[ -x $kiro_cli && ! -L $kiro_cli ]] || fail "Kiro CLI migration creates a missing wrapper"
[[ ! -s $OMARCHY_TEST_MISE_LOG ]] || fail "Kiro CLI migration installs the package before first launch"
cp "$kiro_cli" "$test_tmp/wrapper"
apply_kiro_cli migration
cmp -s "$kiro_cli" "$test_tmp/wrapper" || fail "Kiro CLI migration is idempotent"
"$kiro_cli" --prompt 'Review this project'
mapfile -d '' -t args <"$OMARCHY_TEST_MISE_LOG"
[[ ${args[*]} == "use -g --quiet $package x $package -- kiro-cli --prompt Review this project" ]] ||
  fail "Kiro CLI migration wrapper installs the official package and forwards arguments"
pass "Kiro CLI migration creates a lazy, repeatable wrapper"

rm -f "$kiro_cli"
mkdir -p "$HOME/.local/state/omarchy"
touch "$HOME/.local/state/omarchy/preinstalls-removed"
apply_kiro_cli migration
[[ ! -e $kiro_cli ]] || fail "Kiro CLI migration respects removed preinstalls with a missing command"
rm "$HOME/.local/state/omarchy/preinstalls-removed"
pass "Kiro CLI migration respects the preinstall opt-out"

for operation in migration removal; do
  for kind in script binary symlink; do
    rm -f "$kiro_cli"
    case $kind in
      script) printf '#!/bin/bash\necho user-managed kiro-cli\n' >"$kiro_cli" ;;
      binary) cp /usr/bin/true "$kiro_cli" ;;
      symlink) ln -s /usr/bin/true "$kiro_cli" ;;
    esac
    [[ $kind == "symlink" ]] || chmod +x "$kiro_cli"
    rm -f "$test_tmp/saved-$kind"
    cp -P "$kiro_cli" "$test_tmp/saved-$kind"
    for attempt in 1 2; do
      apply_kiro_cli "$operation"
      cmp -s "$kiro_cli" "$test_tmp/saved-$kind" || fail "Kiro CLI $operation preserves a user $kind"
      if [[ $kind == "symlink" ]]; then
        [[ -L $kiro_cli && $(readlink "$kiro_cli") == "/usr/bin/true" ]] ||
          fail "Kiro CLI $operation preserves the user's symlink"
      else
        [[ ! -L $kiro_cli ]] || fail "Kiro CLI $operation keeps the user's $kind as a regular file"
      fi
    done
    pass "Kiro CLI $operation preserves a user $kind on repeated runs"
  done
done

omarchy-mise-install "$package" kiro-cli
apply_kiro_cli removal
[[ ! -e $kiro_cli ]] || fail "Remove Preinstalls removes Omarchy's Kiro CLI wrapper"
pass "Remove Preinstalls removes Omarchy's Kiro CLI wrapper"
