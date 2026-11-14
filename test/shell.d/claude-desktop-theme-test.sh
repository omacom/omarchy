#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
real_home=$HOME
export HOME="$test_tmp/home" PATH="$ROOT/bin:$PATH" XDG_RUNTIME_DIR="$test_tmp/runtime"
mkdir -p "$XDG_RUNTIME_DIR"
current="$HOME/.local/state/omarchy/current/theme"
next="$HOME/.local/state/omarchy/current/next-theme"
palette="$HOME/.config/Claude/omarchy-theme.json"
mod_link="$HOME/.claude/skills/omarchy-theme"

render_theme() {
  mkdir -p "$next" "$current"
  cp "$ROOT/themes/$1/colors.toml" "$next/colors.toml"
  omarchy-theme-set-templates
  cp "$next/claude-desktop.json" "$current/"
  rm -rf "$next"
}

render_theme nord
omarchy-theme-set-claude-desktop
[[ ! -e $HOME/.config/Claude && ! -e $HOME/.claude ]] || fail "theme sync must not create Claude state on a machine without the app"
pass "machines without the Claude desktop app get nothing"

omarchy-theme-set-claude-desktop --activate
[[ $(readlink "$mod_link") == "$ROOT/default/claude-desktop/omarchy-theme" ]] || fail "activating links the theme mod into Claude Code's skills"
cmp -s "$current/claude-desktop.json" "$palette" || fail "activating publishes the current palette"
pass "activating links the mod and publishes the palette"

render_theme catppuccin-latte
omarchy-theme-set-claude-desktop
cmp -s "$current/claude-desktop.json" "$palette" || fail "a theme switch must publish the new palette"
[[ $(jq -r .mode "$palette") == "light" ]] || fail "a light theme publishes a light palette"
pass "each switch publishes the current palette"

cp "$palette" "$test_tmp/good-palette.json"
jq '.accent = "{{ accent }}"' "$test_tmp/good-palette.json" >"$current/claude-desktop.json"
omarchy-theme-set-claude-desktop 2>/dev/null || fail "an unresolved palette must not fail the theme switch"
cmp -s "$test_tmp/good-palette.json" "$palette" || fail "an unresolved palette must keep the last good one"
pass "an unresolved palette keeps the last good one"

rm "$current/claude-desktop.json"
omarchy-theme-set-claude-desktop --activate || fail "a theme that generates no palette must not fail the switch or the activation"
cmp -s "$test_tmp/good-palette.json" "$palette" || fail "a theme that generates no palette must keep the last good one"
pass "a theme that generates no palette keeps the last good one"

# A switch holds the theme lock while it swaps the generated files underneath,
# so a publisher that honors it is still waiting when the timeout ends it.
render_theme nord
exec {held}>"$XDG_RUNTIME_DIR/omarchy-theme-set.lock"
flock "$held"
status=0
timeout 1 "$ROOT/bin/omarchy-theme-set-claude-desktop" || status=$?
(( status == 124 )) && cmp -s "$test_tmp/good-palette.json" "$palette" || fail "publishing waits for a theme switch that is still staging"
flock -u "$held"
omarchy-theme-set-claude-desktop
cmp -s "$current/claude-desktop.json" "$palette" || fail "publishing resumes once the switch has staged"
pass "publishing waits for a theme switch that is still staging"

# A skill of the user's own under the mod's name is not replaced or added to.
rm "$mod_link"
mkdir -p "$mod_link"
if omarchy-theme-set-claude-desktop --activate 2>/dev/null; then
  fail "activating over a directory of the user's own fails"
fi
[[ -z $(ls -A "$mod_link") ]] || fail "activating over a directory of the user's own leaves it untouched"
rmdir "$mod_link"
echo "mine" >"$mod_link"
if omarchy-theme-set-claude-desktop --activate 2>/dev/null; then
  fail "activating over a file of the user's own fails"
fi
[[ $(<"$mod_link") == "mine" ]] || fail "activating over a file of the user's own leaves it untouched"
ln -sfn "$test_tmp/own-skill" "$mod_link"
if omarchy-theme-set-claude-desktop --activate 2>/dev/null; then
  fail "activating over a link the user pointed elsewhere fails"
fi
[[ $(readlink "$mod_link") == "$test_tmp/own-skill" ]] || fail "activating over a link the user pointed elsewhere leaves it untouched"
pass "activating leaves what the user put under the mod's name alone"

# Omarchy's own link is repointed when Omarchy has moved, as omarchy dev link moves it.
ln -sfn "/usr/share/omarchy/default/claude-desktop/omarchy-theme" "$mod_link"
omarchy-theme-set-claude-desktop --activate
[[ $(readlink "$mod_link") == "$ROOT/default/claude-desktop/omarchy-theme" ]] || fail "activating repoints a link from another Omarchy path"
pass "activating repoints a link from another Omarchy path"

# The installer themes the app before it opens, and opens it whatever happens.
# The launcher stub records whether the theme was in place when it ran; the
# refresh stub stands in for the switch that generates a missing palette.
mkdir -p "$test_tmp/bin"
export TEST_LOG="$test_tmp/log" TEST_PALETTE="$test_tmp/nord-palette.json"
cp "$current/claude-desktop.json" "$TEST_PALETTE"
cat >"$test_tmp/bin/omarchy-pkg-add" <<'SCRIPT'
#!/bin/bash
echo "pkg-add $*" >>"$TEST_LOG"
SCRIPT
cat >"$test_tmp/bin/omarchy-theme-refresh" <<'SCRIPT'
#!/bin/bash
echo "refresh" >>"$TEST_LOG"
[[ -z ${TEST_REFRESH_FAILS:-} ]] || exit 1
cp "$TEST_PALETTE" "$HOME/.local/state/omarchy/current/theme/claude-desktop.json"
SCRIPT
cat >"$test_tmp/bin/setsid" <<'SCRIPT'
#!/bin/bash
if [[ -L $HOME/.claude/skills/omarchy-theme ]] && cmp -s "$TEST_PALETTE" "$HOME/.config/Claude/omarchy-theme.json"; then
  echo "opened themed" >>"$TEST_LOG"
else
  echo "opened unthemed" >>"$TEST_LOG"
fi
SCRIPT
chmod +x "$test_tmp"/bin/*

# The installer opens the app in the background, so wait for the launcher's line.
install_claude() {
  : >"$TEST_LOG"
  PATH="$test_tmp/bin:$PATH" omarchy-install-ai-claude >/dev/null 2>&1
  for attempt in {1..250}; do
    grep -q '^opened' "$TEST_LOG" && return 0
    sleep 0.02
  done
  fail "installing Claude opens the app" "$(cat "$TEST_LOG")"
}

rm -rf "$HOME/.config/Claude" "$HOME/.claude"
install_claude
[[ $(tr '\n' ' ' <"$TEST_LOG") == "pkg-add claude-desktop opened themed " ]] || fail "installing Claude themes it before it opens" "$(cat "$TEST_LOG")"
pass "installing Claude themes it before it opens"

rm -rf "$HOME/.config/Claude" "$HOME/.claude" "$current/claude-desktop.json"
install_claude
[[ $(tr '\n' ' ' <"$TEST_LOG") == "pkg-add claude-desktop refresh opened themed " ]] || fail "installing Claude refreshes a theme staged before the palette existed" "$(cat "$TEST_LOG")"
pass "installing Claude refreshes a theme staged before the palette existed"

rm -rf "$HOME/.claude"
mkdir -p "$mod_link"
install_claude
grep -qx 'opened unthemed' "$TEST_LOG" || fail "a theme that cannot be set up does not keep Claude from opening" "$(cat "$TEST_LOG")"
rm -rf "$HOME/.config/Claude" "$HOME/.claude" "$current/claude-desktop.json"
TEST_REFRESH_FAILS=1 install_claude
[[ $(tr '\n' ' ' <"$TEST_LOG") == "pkg-add claude-desktop refresh opened unthemed " ]] || fail "a theme refresh that fails does not keep Claude from opening" "$(cat "$TEST_LOG")"
pass "a theme that cannot be set up does not keep Claude from opening"
cp "$TEST_PALETTE" "$current/claude-desktop.json"
omarchy-theme-set-claude-desktop --activate

# Every stock theme's palette, rendered the way a theme switch renders it.
stock_palettes='{}'
for theme in "$ROOT"/themes/*/; do
  name=$(basename "$theme")
  render_theme "$name"
  stock_palettes=$(jq --arg name "$name" --rawfile text "$current/claude-desktop.json" '.[$name] = $text' <<<"$stock_palettes")
done
export STOCK_PALETTES="$stock_palettes"

# The mod itself, against a stand-in for the engine that records what it is asked.
# Node runs with the real home: where it is a mise shim, a scratch one has no trusted config.
TEST_HOME="$HOME" HOME="$real_home" run_node_test <<'JS'
const fs = require('fs')
const { register, paletteColors } = requireFromRoot('default/claude-desktop/omarchy-theme/hooks/register.js')

const home = process.env.TEST_HOME
const palettePath = `${home}/.config/Claude/omarchy-theme.json`
const hooks = {}
register((event, hook) => { hooks[event] = hook })

function engine() {
  const sets = []
  const $ = {
    env: { get: async name => (name === 'HOME' ? home : process.env[name]) },
    fs: { read: async file => fs.readFileSync(file, 'utf8') },
    theme: { set: async theme => { sets.push(theme); return { isDrawn: true, requestId: 'theme' } } },
  }
  return { $, sets }
}

async function main() {
  const nord = JSON.parse(fs.readFileSync(palettePath, 'utf8'))

  let { $, sets } = engine()
  let result = await hooks['session.start']($, { cwd: '/' }, async e => ({ cwd: e.cwd }))
  assertDeepEqual(result, { cwd: '/' }, 'the session start is passed on')
  assertEqual(sets.length, 1, 'a starting session sets the theme once')
  assertDeepEqual(Object.keys(sets[0]), ['colors'], 'the theme carries colors alone')
  assertDeepEqual(Object.keys(sets[0].colors.inputs), ['dark'], 'a dark theme gives the dark half alone')
  const colors = Object.values(sets[0].colors.inputs.dark)
  assert(colors.includes(nord.background) && colors.includes(nord.foreground), 'the colors are built on the theme background and foreground')

  result = await hooks['classic.SessionStart']($, {}, async () => ({ watchPaths: ['/other'] }))
  assertDeepEqual(result.watchPaths, ['/other', palettePath], 'the session watches the palette beside what it already watched')

  ;({ $, sets } = engine())
  await hooks['classic.FileChanged']($, { file_path: '/other', event: 'change' }, async () => ({}))
  assertEqual(sets.length, 0, 'another watched file changing sets nothing')
  await hooks['classic.FileChanged']($, { file_path: palettePath, event: 'change' }, async () => ({}))
  assertEqual(sets.length, 1, 'the palette changing sets the theme again')

  for (const broken of ['not json', '{}', 'null', JSON.stringify({ ...nord, mode: 'dim' }), JSON.stringify({ ...nord, accent: '{{ accent }}' }), JSON.stringify({ ...nord, background: '#fff' })]) {
    fs.writeFileSync(palettePath, broken)
    ;({ $, sets } = engine())
    await hooks['session.start']($, { cwd: '/' }, async e => ({ cwd: e.cwd }))
    if (sets.length > 0) fail('an unusable palette sets nothing', broken)
  }
  fs.rmSync(palettePath)
  ;({ $, sets } = engine())
  await hooks['session.start']($, { cwd: '/' }, async e => ({ cwd: e.cwd }))
  assertEqual(sets.length, 0, 'a missing or unusable palette sets nothing and still starts the session')

  // The app ignores a whole palette when any text in it falls under 3:1.
  for (const [name, text] of Object.entries(JSON.parse(process.env.STOCK_PALETTES))) {
    const refused = paletteColors(JSON.parse(text)).problems.filter(line => line.startsWith("Desktop won't paint"))
    if (refused.length > 0) fail(`the app paints the ${name} theme`, refused.join('\n'))
  }
  pass('the app paints every stock theme')
}

main().catch(error => fail('the mod runs', error.stack))
JS
