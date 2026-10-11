#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
mock_bin="$test_tmp/bin"
mise_log="$test_tmp/mise"
mise_config="$test_tmp/etc/mise/config.toml"
mkdir -p "$test_home/.local/bin" "$mock_bin"

cat >"$mock_bin/mise" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_MISE_LOG"
case "$*" in
'reshim --system') exit "${OMARCHY_TEST_RESHIM_STATUS:-0}" ;;
'settings add disable_tools '*) printf '%s\n' "$4" >>"$OMARCHY_TEST_DISABLED" ;;
esac
exit 0
SH
chmod +x "$mock_bin/mise"

cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash
echo "the lazy-tool migration must not need sudo" >&2
exit 1
SH
chmod +x "$mock_bin/sudo"

export HOME="$test_home"
export OMARCHY_PATH="$ROOT"
export OMARCHY_MISE_CONFIG_PATH="$mise_config"
export OMARCHY_TEST_MISE_LOG="$mise_log"
export OMARCHY_TEST_DISABLED="$test_tmp/disable-tools"

# The settings package ships the declarations before migrations run.
install_package_config() {
  mkdir -p "$(dirname "$mise_config")"
  cp "$ROOT/etc/mise/conf.d/omarchy-tools.toml" "$mise_config"
}
install_package_config
export PATH="$mock_bin:$PATH"

write_wrapper() {
  local package=$1 command=$2 bin
  bin=${3:-$command}

  cat >"$test_home/.local/bin/$command" <<EOF
#!/bin/bash
export MISE_MINIMUM_RELEASE_AGE=0
mise use -g --quiet "$package" || exit 1
exec mise x "$package" -- "$bin" "\$@"
EOF
  chmod +x "$test_home/.local/bin/$command"
}

write_wrapper cursor-agent cursor-agent
write_wrapper github:basecamp/basecamp-cli basecamp
write_wrapper 'http:muse[url=https://api.meta.ai/muse-launcher.sh,bin=muse,version_list_url=https://api.meta.ai/muse-code/channels/muse-stable,version_json_path=.version]' muse
write_wrapper codex codex
write_wrapper npm:playwright playwright
write_wrapper github:can1357/oh-my-pi omp
write_wrapper aqua:google-antigravity/antigravity-cli agy
write_wrapper npm:cf cf
cat >"$test_home/.local/bin/hunk" <<'SH'
#!/bin/bash
echo user-owned
SH
chmod +x "$test_home/.local/bin/hunk"

bash -euo pipefail "$ROOT/migrations/1791382872.sh" >/dev/null

for command in codex playwright omp agy cf cursor-agent basecamp muse; do
  [[ ! -e $test_home/.local/bin/$command ]] || fail "lazy-tool migration removes the recognized $command wrapper"
done
grep -Fx 'echo user-owned' "$test_home/.local/bin/hunk" >/dev/null || fail "lazy-tool migration preserves a user-owned command"
cmp -s "$ROOT/etc/mise/conf.d/omarchy-tools.toml" "$mise_config" || fail "lazy-tool migration leaves the package-owned config alone"
grep -Fx 'reshim --system' "$mise_log" >/dev/null || fail "lazy-tool migration reconciles bootstrap shims"
[[ ! -s $OMARCHY_TEST_DISABLED ]] || fail "lazy-tool migration keeps the default tools enabled"
pass "lazy-tool migration replaces recognized wrappers with native lazy declarations"

: >"$mise_log"
bash -euo pipefail "$ROOT/migrations/1791382872.sh" >/dev/null
grep -Fx 'echo user-owned' "$test_home/.local/bin/hunk" >/dev/null || fail "lazy-tool migration remains safe on a second run"
[[ $(grep -c '^reshim --system$' "$mise_log") == 1 ]] || fail "lazy-tool migration reshims once on a second run"
pass "lazy-tool migration is idempotent"

mkdir -p "$test_home/.local/state/omarchy"
touch "$test_home/.local/state/omarchy/preinstalls-removed"
write_wrapper npm:@kitlangton/ghui ghui
: >"$mise_log"
bash -euo pipefail "$ROOT/migrations/1791382872.sh" >/dev/null
for tool in codex gh uv npm:cf; do
  grep -qxF "$tool" "$OMARCHY_TEST_DISABLED" || fail "lazy-tool migration disables the default tools after opt-out" "$tool"
done
[[ ! -e $test_home/.local/bin/ghui ]] || fail "lazy-tool migration removes an obsolete wrapper after opt-out"
grep -Fx 'reshim --system' "$mise_log" >/dev/null || fail "lazy-tool migration removes obsolete bootstrap shims after opt-out"
pass "lazy-tool migration preserves the preinstall opt-out"

# A user-owned symlink or command at a retired wrapper path must survive.
rm "$test_home/.local/state/omarchy/preinstalls-removed"
ln -s "$test_home/official-cursor" "$test_home/.local/bin/cursor-agent"
printf '#!/bin/bash\necho user-muse\n' >"$test_home/.local/bin/muse"
chmod +x "$test_home/.local/bin/muse"
bash -euo pipefail "$ROOT/migrations/1791382872.sh" >/dev/null
[[ -L $test_home/.local/bin/cursor-agent ]] || fail "migration preserves a user-owned Cursor symlink"
[[ $("$test_home/.local/bin/muse") == user-muse ]] || fail "migration preserves a user-owned Muse command"
pass "migration preserves user-owned Cursor and Muse files"

# Matching install/exec lines do not prove ownership of the rest of a file.
for customization in environment comment before after changed-bin trailing-blank; do
  write_wrapper codex codex
  wrapper="$test_home/.local/bin/codex"
  case $customization in
  environment) sed -i '2i export CODEX_HOME="$HOME/custom-codex"' "$wrapper" ;;
  comment) sed -i '2i # My customized launcher' "$wrapper" ;;
  before) sed -i '2i echo preparing' "$wrapper" ;;
  after) printf 'echo finished\n' >>"$wrapper" ;;
  changed-bin) sed -i 's/-- "codex"/-- "my-codex"/' "$wrapper" ;;
  trailing-blank) printf '\n' >>"$wrapper" ;;
  esac
  cp "$wrapper" "$test_tmp/expected-wrapper"
  bash -euo pipefail "$ROOT/migrations/1791382872.sh" >/dev/null
  cmp -s "$wrapper" "$test_tmp/expected-wrapper" || fail "migration preserves $customization customization byte-for-byte"
done
pass "migration preserves customized wrappers with matching mise lines"

# Exercise the actual historical templates, including wrappers without --quiet.
for form in cooldown-export bail-on-failure mise-exec bare-exec; do
  case $form in
  cooldown-export)
    printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g "codex" || exit 1\nexec mise x "codex" -- "codex" "$@"\n' ;;
  bail-on-failure)
    printf '#!/bin/bash\nmise use -g "codex" || exit 1\nexec mise x "codex" -- "codex" "$@"\n' ;;
  mise-exec)
    printf '#!/bin/bash\nmise use -g "codex"\nexec mise exec "codex" -- "codex" "$@"\n' ;;
  bare-exec)
    printf '#!/bin/bash\nmise use -g "codex"\nexec "codex" "$@"\n' ;;
  esac >"$test_home/.local/bin/codex"
  bash -euo pipefail "$ROOT/migrations/1791382872.sh" >/dev/null
  [[ ! -e $test_home/.local/bin/codex ]] || fail "migration removes the unmodified $form wrapper"
done
pass "migration removes all shipped legacy wrapper templates"

# Before the settings package delivers the declarations, or when a reshim fails,
# the old wrappers keep working and the migration stays pending.
for failure in package reshim; do
  write_wrapper codex codex
  if [[ $failure == package ]]; then
    rm -f "$mise_config"
    bash -euo pipefail "$ROOT/migrations/1791382872.sh" >/dev/null 2>&1 && status=0 || status=$?
    install_package_config
  else
    OMARCHY_TEST_RESHIM_STATUS=1 bash -euo pipefail "$ROOT/migrations/1791382872.sh" >/dev/null 2>&1 && status=0 || status=$?
  fi
  ((status != 0)) || fail "lazy-tool migration stays pending when its setup fails" "$failure"
  [[ -x $test_home/.local/bin/codex ]] || fail "lazy-tool migration keeps the old wrapper when its setup fails" "$failure"
done
rm -f "$test_home/.local/bin/codex"
pass "lazy-tool migration keeps old wrappers until the replacement shims exist"

# The shorthand migration runs first. It must leave a customized wrapper alone too,
# or it would rewrite it into a template the lazy-tool migration then deletes.
write_wrapper npm:playwright playwright
printf '\n' >>"$test_home/.local/bin/playwright"
cp "$test_home/.local/bin/playwright" "$test_tmp/expected-wrapper"
PATH="$mock_bin:$ROOT/bin:$PATH" bash -euo pipefail "$ROOT/migrations/1791382812.sh" >/dev/null
PATH="$mock_bin:$ROOT/bin:$PATH" bash -euo pipefail "$ROOT/migrations/1791382872.sh" >/dev/null
cmp -s "$test_home/.local/bin/playwright" "$test_tmp/expected-wrapper" ||
  fail "shorthand and lazy-tool migrations preserve a wrapper with a trailing blank line"
pass "shorthand and lazy-tool migrations preserve customized wrappers together"
