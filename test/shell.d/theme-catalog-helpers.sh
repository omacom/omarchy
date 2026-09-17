#!/bin/bash

# Shared setup for the theme marketplace tests: a catalog served over file://
# that points at git repositories created here, plus stand-ins for the parts of
# Omarchy a test must not really run. Sourced after base-test.sh.

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  echo "source test/shell.d/theme-catalog-helpers.sh from a shell test" >&2
  exit 1
fi

require_command git
require_command jq

MARKETPLACE_TMP=$(mktemp -d)
trap 'rm -rf "$MARKETPLACE_TMP"' EXIT

MARKETPLACE_HOME="$MARKETPLACE_TMP/home"
MARKETPLACE_CDN="$MARKETPLACE_TMP/cdn"
MARKETPLACE_STUBS="$MARKETPLACE_TMP/stubs"
MARKETPLACE_THEMES="$MARKETPLACE_HOME/.config/omarchy/themes"
MARKETPLACE_LOG="$MARKETPLACE_TMP/calls"

declare -A MARKETPLACE_REPOS MARKETPLACE_COMMITS

mkdir -p "$MARKETPLACE_THEMES" "$MARKETPLACE_HOME/.local/state/omarchy/current" \
  "$MARKETPLACE_CDN/v1" "$MARKETPLACE_STUBS"

# Two commits each, so a test can pin to the older one and watch an update move.
marketplace_make_repo() {
  local name="$1"
  local dir="$MARKETPLACE_TMP/repos/omarchy-$name-theme"

  mkdir -p "$dir"
  printf 'accent = "#3355ff"\nbackground = "#0b0b13"\n' >"$dir/colors.toml"
  printf 'preview\n' >"$dir/preview.png"
  git -C "$dir" init --quiet -b master
  git -C "$dir" -c user.email=t@e -c user.name=t add -A
  git -C "$dir" -c user.email=t@e -c user.name=t commit --quiet -m first
  printf 'accent = "#4466ff"\nbackground = "#0b0b13"\n' >"$dir/colors.toml"
  git -C "$dir" -c user.email=t@e -c user.name=t commit --quiet -am second

  printf '%s' "$dir"
}

# "delta" is listed under a name the repo does not derive to: omarchy-dlt-theme
# gives "dlt". That disagreement is the case the marker has to survive.
marketplace_build_repos() {
  local name
  local repo_name

  for name in alpha beta gamma delta; do
    repo_name="$name"
    [[ $name == "delta" ]] && repo_name="dlt"
    MARKETPLACE_REPOS[$name]=$(marketplace_make_repo "$repo_name")
    MARKETPLACE_COMMITS[$name]=$(git -C "${MARKETPLACE_REPOS[$name]}" rev-parse HEAD)
  done
}

# Writes the published files from the fixtures, naming the repositories and
# commits that exist now. Safe to call again after a test has rewritten the
# catalog, which is how one gets put back.
marketplace_write_catalog() {
  local name
  local dir
  local fixtures="$SHELL_TEST_DIR/fixtures/theme-catalog"
  local filter=""

  for name in alpha beta gamma delta; do
    filter+="| sub(\"REPO_$name\"; \"file://${MARKETPLACE_REPOS[$name]}\") "
    filter+="| sub(\"COMMIT_$name\"; \"${MARKETPLACE_COMMITS[$name]}\"; \"g\") "
  done

  for name in catalog.json catalog.min.json; do
    jq --arg cdn "file://$MARKETPLACE_CDN" \
      "tojson | sub(\"CDN\"; \$cdn; \"g\") $filter | fromjson" \
      "$fixtures/$name" >"$MARKETPLACE_CDN/v1/$name"
  done

  for name in alpha beta gamma delta; do
    dir="$MARKETPLACE_CDN/v1/previews/$name/${MARKETPLACE_COMMITS[$name]}"
    mkdir -p "$dir"
    printf 'RIFF----WEBP fake %s 1200\n' "$name" >"$dir/1200.webp"
    printf 'RIFF----WEBP fake %s 480\n' "$name" >"$dir/480.webp"
  done
}

marketplace_forget_catalog() {
  rm -rf "$XDG_CACHE_HOME/omarchy/theme-catalog"
}

marketplace_build_stubs() {
  cat >"$MARKETPLACE_STUBS/omarchy-theme-set" <<'STUB'
#!/bin/bash
printf '%s' "$1" >"$HOME/.local/state/omarchy/current/theme.name"
printf 'theme-set %s\n' "$1" >>"$OMARCHY_TEST_CALLS"
STUB

  cat >"$MARKETPLACE_STUBS/omarchy-shell" <<'STUB'
#!/bin/bash
[[ ${OMARCHY_TEST_SHELL_UP:-0} == 1 ]] || exit 1
printf 'shell %s\n' "$*" >>"$OMARCHY_TEST_CALLS"
echo ok
STUB

  cat >"$MARKETPLACE_STUBS/omarchy-launch-floating-terminal-with-presentation" <<'STUB'
#!/bin/bash
printf 'floating %s\n' "$*" >>"$OMARCHY_TEST_CALLS"
STUB

  cat >"$MARKETPLACE_STUBS/omarchy-notification-send" <<'STUB'
#!/bin/bash
printf 'notify %s\n' "$*" >>"$OMARCHY_TEST_CALLS"
STUB

  # gum wants a terminal it cannot have here. `filter` answers with the line
  # OMARCHY_TEST_FILTER names, so the text fallback can be driven end to end.
  cat >"$MARKETPLACE_STUBS/gum" <<'STUB'
#!/bin/bash
case "${1:-}" in
filter | choose)
  # Keep what was offered so a test can assert on the whole list, not just on
  # the row this picks.
  rows=$(cat)
  [[ -n ${OMARCHY_TEST_MENU:-} ]] && printf '%s\n' "$rows" >"$OMARCHY_TEST_MENU"
  printf '%s\n' "$rows" | grep -m1 -- "${OMARCHY_TEST_FILTER:-}" || true
  ;;
*) exit 0 ;;
esac
STUB

  chmod +x "$MARKETPLACE_STUBS"/*
}

marketplace_setup() {
  marketplace_build_repos
  marketplace_build_stubs

  export HOME="$MARKETPLACE_HOME"
  export XDG_CACHE_HOME="$MARKETPLACE_HOME/.cache"
  export XDG_CONFIG_HOME="$MARKETPLACE_HOME/.config"
  export XDG_DATA_HOME="$MARKETPLACE_HOME/.local/share"
  export OMARCHY_THEME_CATALOG_URL="file://$MARKETPLACE_CDN"
  export OMARCHY_TEST_CALLS="$MARKETPLACE_LOG"
  export OMARCHY_TEST_MENU="$MARKETPLACE_TMP/menu"
  export PATH="$MARKETPLACE_STUBS:$ROOT/bin:$PATH"
  : >"$MARKETPLACE_LOG"
  marketplace_write_catalog
}

marketplace_calls() {
  cat "$MARKETPLACE_LOG"
}

marketplace_reset_calls() {
  : >"$MARKETPLACE_LOG"
}

assert_contains() {
  local description="$1"
  local haystack="$2"
  local needle="$3"

  if [[ $haystack != *"$needle"* ]]; then
    fail "$description" "expected to contain: $needle"$'\n'"actual:"$'\n'"$haystack"
  fi
  pass "$description"
}

assert_equal() {
  local description="$1"
  local actual="$2"
  local expected="$3"

  if [[ $actual != "$expected" ]]; then
    fail "$description" "expected: $expected"$'\n'"actual:   $actual"
  fi
  pass "$description"
}
