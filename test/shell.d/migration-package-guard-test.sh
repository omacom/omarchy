#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A migration that reads files another package ships under /usr/share/<package>
# must first check that package is installed. Default packages such as
# omarchy-nvim can be removed, and a migration that fails on the missing file
# stays pending and stops every migration after it.

# Directories many packages share, so their name is not a package to guard.
shared_dirs=(applications dbus-1 doc fonts icons licenses locale man pixmaps polkit-1 wayland-sessions xsessions)

# Migrations that shipped without the guard. Remove an entry once its migration
# is fixed; the check below fails while a fixed migration is still listed.
declare -A known_unguarded=(
  ["1781587663.sh omarchy-nvim"]="#7108"
)

# A check only guards when the migration acts on its result: inside an if, or
# followed by || or &&. A bare `version=$(pacman -Q pkg)` aborts the migration
# under errexit when the package is gone. omarchy-pkg-add installs the package,
# so it needs no condition.
package_guarded() {
  local file=$1 package=$2
  local name="(?<![\\w-])\\Q$package\\E(?![\\w-])"
  local check="(omarchy-pkg-(present|missing)|pacman -Q\\w*)\\b"

  rg -q -P "^(?!\\s*#)(.*omarchy-pkg-add\\b.*$name|\\s*(if|elif)\\b.*$check.*$name|.*$check.*$name.*(\\|\\||&&))" "$file"
}

fixture=$(mktemp)
trap 'rm -f "$fixture"' EXIT

for guard in \
  'omarchy-pkg-present omarchy-nvim || exit 0' \
  'omarchy-pkg-missing omarchy-nvim && exit 0' \
  'if ! nvim_package=$(pacman -Q omarchy-nvim 2>/dev/null); then' \
  'omarchy-pkg-add omarchy-nvim'; do
  printf '%s\n' "$guard" >"$fixture"
  package_guarded "$fixture" omarchy-nvim || fail "lint accepts a guard: $guard"
done
pass "lint accepts checks the migration acts on"

for guard in \
  'nvim_package=$(pacman -Q omarchy-nvim)' \
  'omarchy-pkg-present omarchy-nvim' \
  '# omarchy-pkg-present omarchy-nvim || exit 0' \
  'omarchy-pkg-present omarchy-nvim-extras || exit 0'; do
  printf '%s\n' "$guard" >"$fixture"
  ! package_guarded "$fixture" omarchy-nvim || fail "lint rejects a non-guard: $guard"
done
pass "lint rejects checks whose result is ignored"

unguarded=()
for file in "$ROOT"/migrations/*.sh; do
  name=$(basename "$file")

  while IFS= read -r package; do
    [[ $package == "omarchy" || " ${shared_dirs[*]} " == *" $package "* ]] && continue
    package_guarded "$file" "$package" && continue

    [[ -v known_unguarded["$name $package"] ]] || unguarded+=("$name $package")
  done < <(rg -o --no-filename -P '/usr/share/\K[A-Za-z0-9._+-]+(?=/)' "$file" | sort -u)
done

(( ${#unguarded[@]} == 0 )) || fail "migrations check the packages whose files they read" \
  "$(printf '%s\n' "${unguarded[@]}" | sed 's/ / reads \/usr\/share\//;s/$/ without skipping when the package is missing/')"
pass "migrations check the packages whose files they read"

stale=()
for entry in "${!known_unguarded[@]}"; do
  package_guarded "$ROOT/migrations/${entry%% *}" "${entry#* }" && stale+=("$entry")
done

(( ${#stale[@]} == 0 )) || fail "fixed migrations are dropped from the known unguarded list" \
  "$(printf '%s\n' "${stale[@]}")"
pass "fixed migrations are dropped from the known unguarded list"
