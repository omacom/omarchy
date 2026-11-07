#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

cache_home="$tmp/cache"
images="$tmp/images"
stub_bin="$tmp/bin"
mkdir -p "$images" "$stub_bin"

cat >"$stub_bin/awk" <<'EOF'
#!/bin/bash
printf 'awk\n' >>"$AWK_CALLS_FILE"
exec /usr/bin/awk "$@"
EOF
chmod +x "$stub_bin/awk"

for name in one two; do
  printf 'image-%s' "$name" >"$images/$name.png"
done

cache_dir="$cache_home/omarchy/image-selector"
mkdir -p "$cache_dir"

one_signature=$(stat -Lc '%s:%Y' "$images/one.png")
one_hash=$(printf '%s\t%s' "$images/one.png" "$one_signature" | md5sum | cut -d ' ' -f 1)
duplicate_hash=$(printf 'duplicate' | md5sum | cut -d ' ' -f 1)
printf '%s\t%s\t%s\n' "$images/one.png" "$one_signature" "$one_hash" >>"$cache_dir/index.tsv"
# A later duplicate row must not change the answer a lookup gets.
printf '%s\t%s\t%s\n' "$images/one.png" "$one_signature" "$duplicate_hash" >>"$cache_dir/index.tsv"
printf 'thumbnail' >"$cache_dir/$one_hash.jpg"

awk_calls="$tmp/awk-calls"
: >"$awk_calls"

rows=$(PATH="$stub_bin:$PATH" XDG_CACHE_HOME="$cache_home" AWK_CALLS_FILE="$awk_calls" \
  "$ROOT/shell/plugins/image-picker/list.sh" "$images")

(( $(wc -l <<<"$rows") == 2 )) || fail "direct picker lists every image" "$rows"
[[ ! -s $awk_calls ]] || fail "direct picker reads the thumbnail index once, not an awk scan per image" "$(cat "$awk_calls")"

while IFS=$'\t' read -r row_image row_thumbnail; do
  if [[ $row_image == "$images/one.png" ]]; then
    [[ $row_thumbnail == "$cache_dir/$one_hash.jpg" ]] ||
      fail "direct picker reuses the indexed thumbnail for a scanned image" "$row_thumbnail"
  else
    [[ $row_thumbnail == "$images/two.png" ]] ||
      fail "direct picker stands an unindexed image in as its own thumbnail" "$row_thumbnail"
  fi
done <<<"$rows"

pass "direct picker reads the thumbnail index once and keeps first-row lookups"
