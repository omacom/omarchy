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
kimi="$HOME/.local/bin/kimi"
package="npm:@moonshot-ai/kimi-code"

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

apply_kimi() {
  case $1 in
    removal) omarchy-remove-preinstalls >/dev/null ;;
  esac
}

for operation in removal; do
  for kind in script binary symlink; do
    rm -f "$kimi"
    case $kind in
      script) printf '#!/bin/bash\necho user-managed kimi\n' >"$kimi" ;;
      binary) cp /usr/bin/true "$kimi" ;;
      symlink) ln -s /usr/bin/true "$kimi" ;;
    esac
    [[ $kind == "symlink" ]] || chmod +x "$kimi"
    rm -f "$test_tmp/saved-$kind"
    cp -P "$kimi" "$test_tmp/saved-$kind"
    for attempt in 1 2; do
      apply_kimi "$operation"
      cmp -s "$kimi" "$test_tmp/saved-$kind" || fail "Kimi $operation preserves a user $kind"
      if [[ $kind == "symlink" ]]; then
        [[ -L $kimi && $(readlink "$kimi") == "/usr/bin/true" ]] ||
          fail "Kimi $operation preserves the user's symlink"
      else
        [[ ! -L $kimi ]] || fail "Kimi $operation keeps the user's $kind as a regular file"
      fi
    done
    pass "Kimi $operation preserves a user $kind on repeated runs"
  done
done

omarchy-mise-install "$package" kimi
apply_kimi removal
[[ ! -e $kimi ]] || fail "Remove Preinstalls removes Omarchy's Kimi wrapper"
pass "Remove Preinstalls removes Omarchy's Kimi wrapper"
