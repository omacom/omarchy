#!/bin/bash

set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command magick

test_tmp=$(mktemp -d)
[[ -n $test_tmp && -d $test_tmp ]] || fail "the test creates its own scratch directory"
trap 'rm -rf -- "$test_tmp"' EXIT

# The preview ends by opening the image in imv; the test reads the file instead
mkdir "$test_tmp/bin"
printf '#!/bin/bash\n' >"$test_tmp/bin/imv"
chmod +x "$test_tmp/bin/imv"

render() {
  local logo_size=$1 name=$2

  magick -size "$logo_size" xc:none "$test_tmp/$name-logo.png"
  PATH="$test_tmp/bin:$PATH" OMARCHY_PATH="$ROOT" /bin/bash "$ROOT/bin/omarchy-plymouth-preview" \
    '#000000' '#ffffff' "$test_tmp/$name-logo.png" "$test_tmp/$name.png" >/dev/null 2>&1 ||
    fail "omarchy-plymouth-preview renders a $logo_size logo"
}

# Size of what the preview drew in the text colour. A transparent logo draws
# nothing, so this is the prompt alone: entry field, lock and bullets.
prompt_size() {
  magick "$test_tmp/$1.png" -colorspace gray -threshold 50% -trim -format '%wx%h' info: 2>/dev/null
}

render 400x200 small
render 1920x1080 full
small=$(prompt_size small)
full=$(prompt_size full)

[[ -n $small && $small != "1x1" ]] || fail "the preview draws the prompt below a small logo"
[[ $full == "$small" ]] ||
  fail "the prompt stays wholly on screen below a full-screen logo" "small logo: $small, full-screen logo: $full"

pass "a full-screen logo leaves the unlock prompt on screen"
