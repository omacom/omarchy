#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/runtime" "$tmp/cache/omarchy/image-selector" "$tmp/images with spaces" "$tmp/second directory"
images="$tmp/images with spaces"
second="$tmp/second directory"
selected="$images/selected wallpaper.png"
printf 'image' >"$selected"

cat >"$tmp/bin/omarchy-shell" <<'STUB'
#!/bin/bash
set -euo pipefail
printf '%s\0' "$@" >"$TRANSPORT_LOG.args"
case $2 in
  openFile|preloadFile)
    [[ $(stat -c '%a' "$3") == "600" ]] || exit 41
    printf '%s' "$3" >"$TRANSPORT_LOG.path"
    cp "$3" "$TRANSPORT_LOG.rows"
    if [[ $2 == "openFile" ]]; then selection_file=$5; done_file=$6; fi
    ;;
  open|preload)
    printf '%s' "${4:-}" | base64 -d >"$TRANSPORT_LOG.rows"
    if [[ $2 == "open" ]]; then selection_file=$6; done_file=$7; fi
    ;;
esac
if [[ ${TRANSPORT_FAIL:-false} == "true" ]]; then exit 42; fi
if [[ ${TRANSPORT_REFUSE:-false} == "true" ]]; then echo unreadable; exit 0; fi
if [[ $2 == "open" || $2 == "openFile" ]]; then
  if [[ ${TRANSPORT_CANCEL:-false} != "true" ]]; then
    printf '%s\n' "$TRANSPORT_SELECTED" >"$selection_file"
  fi
  if [[ ${TRANSPORT_WAIT:-false} != "true" ]]; then : >"$done_file"; fi
fi
printf 'ok\n'
STUB
chmod +x "$tmp/bin/omarchy-shell"

cache_dir="$tmp/cache/omarchy/image-selector"
key=$(printf '%s\n%s' "$images" "$second" | md5sum | cut -d ' ' -f 1)
printf 'v3\n%s:%s\n%s:%s\n' "$images" "$(stat -Lc '%Y' "$images")" "$second" "$(stat -Lc '%Y' "$second")" >"$cache_dir/$key.fast-signature"
rows_file="$cache_dir/$key.rows"
printf '%s\t%s\n' "$selected" "$tmp/cache/selected preview.jpg" >"$rows_file"
for (( i = 0; i < 1500; i++ )); do
  printf '%s/wallpaper-壁紙-%04d.mp4\t%s/preview-%04d.jpg\n' "$second" "$i" "$tmp/cache" "$i" >>"$rows_file"
done
(( $(base64 -w 0 "$rows_file" | wc -c) > 131072 )) || fail "transport fixture exceeds the single-argument limit"

run_menu() {
  env PATH="$tmp/bin:$PATH" XDG_CACHE_HOME="$tmp/cache" XDG_RUNTIME_DIR="$tmp/runtime" \
    TRANSPORT_LOG="$tmp/request" TRANSPORT_SELECTED="$selected" "$@" \
    "$ROOT/bin/omarchy-menu-images" --selected "$selected" --show-labels --filterable "$images" "$second"
}

printf '%s' "$(<"$rows_file")" >"$tmp/expected.rows"
run_menu >"$tmp/output"
cmp -s "$tmp/expected.rows" "$tmp/request.rows" || fail "large image menu preserves all image and thumbnail rows"
[[ $(<"$tmp/output") == "$selected" ]] || fail "large image menu returns the selected original path"
mapfile -d '' -t args <"$tmp/request.args"
[[ ${args[1]} == "openFile" && ${args[3]} == "$selected" && ${args[6]} == "true" && ${args[7]} == "true" ]] || fail "large image menu preserves selection and display flags"
[[ ! -e $(<"$tmp/request.path") ]] || fail "large image menu removes its rows file after selection"
pass "large image menu transports every row without oversized argv and cleans up after selection"

# Preloads return immediately: the receiver must consume the file before its
# reply, rather than storing a path to read after the caller has removed it.
env PATH="$tmp/bin:$PATH" XDG_CACHE_HOME="$tmp/cache" XDG_RUNTIME_DIR="$tmp/runtime" \
  TRANSPORT_LOG="$tmp/request" TRANSPORT_SELECTED="$selected" \
  "$ROOT/bin/omarchy-menu-images" --preload "$images" "$second"
mapfile -d '' -t args <"$tmp/request.args"
[[ ${args[1]} == "preloadFile" ]] || fail "large preloads use file transport"
cmp -s "$tmp/expected.rows" "$tmp/request.rows" || fail "large preloads deliver all rows"
[[ ! -e $(<"$tmp/request.path") ]] || fail "large preloads remove their rows file"
pass "large image menu preloads consume all rows before caller cleanup"

run_menu TRANSPORT_CANCEL=true >"$tmp/output"
[[ ! -s $tmp/output && ! -e $(<"$tmp/request.path") ]] || fail "cancelled image menu cleans up without a selection"
pass "large image menu cleans up after cancellation"

for mode in TRANSPORT_FAIL TRANSPORT_REFUSE; do
  if run_menu "$mode=true" >"$tmp/output" 2>"$tmp/error"; then
    fail "large image menu rejects failed or refused IPC"
  fi
  [[ ! -e $(<"$tmp/request.path") ]] || fail "failed image menu removes its rows file"
  rg -q 'Image selector failed to accept request' "$tmp/error" || fail "failed image menu reports refusal"
done
pass "large image menu cleans up after failed and refused IPC"

rm "$tmp/request.path"
env PATH="$tmp/bin:$PATH" XDG_CACHE_HOME="$tmp/cache" XDG_RUNTIME_DIR="$tmp/runtime" \
  TRANSPORT_LOG="$tmp/request" TRANSPORT_SELECTED="$selected" TRANSPORT_WAIT=true \
  "$ROOT/bin/omarchy-menu-images" "$images" "$second" >"$tmp/output" 2>"$tmp/error" &
menu_pid=$!
for attempt in {1..200}; do
  [[ -f $tmp/request.path ]] && break
  sleep 0.01
done
[[ -f $tmp/request.path ]] || { kill "$menu_pid"; wait "$menu_pid" || true; fail "interrupted menu starts its file request"; }
kill -TERM "$menu_pid"
status=0
wait "$menu_pid" || status=$?
[[ $status == "143" && ! -e $(<"$tmp/request.path") ]] || fail "interrupted image menu removes its rows file"
pass "large image menu removes its rows file when interrupted"

head -n 1 "$rows_file" >"$tmp/small.rows"
mv "$tmp/small.rows" "$rows_file"
run_menu >"$tmp/output"
mapfile -d '' -t args <"$tmp/request.args"
[[ ${args[1]} == "open" ]] || fail "small image menu retains existing IPC"
# Command substitution strips the rows' trailing newline in both transports.
[[ $(<"$rows_file") == $(<"$tmp/request.rows") && $(<"$tmp/output") == "$selected" ]] || fail "small image menu retains rows and selection"
pass "small image menu preserves existing base64 IPC"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const qml = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
const context = { shell: {}, JSON }
for (const name of ['readImageRowsFile', 'openImagePickerRows', 'openFile', 'preloadFile']) {
  const indent = ['openFile', 'preloadFile'].includes(name) ? '    ' : '  '
  const match = qml.match(new RegExp(`function ${name}\\([\\s\\S]*?\\n${indent}\\}`))
  assert(match, `image transport exposes ${name}`)
  const source = match[0].replace(/: string/g, '')
  vm.runInNewContext(`${source}; this.${name} = ${name}`, context)
  context.shell[name] = context[name]
}
assert(/id: imageRowsFileComponent\s*FileView \{\s*blockLoading: true/.test(qml), 'image rows reader blocks until the file is consumed')
let reads = 0
let destroyed = 0
let contents = 'original\tthumbnail'
let loaded = true
context.imageRowsFileComponent = {
  createObject(parent, args) {
    assertEqual(args.path, '/private/rows', 'image rows reader uses the supplied path')
    return { text() { reads++; return contents }, get loaded() { return loaded }, destroy() { destroyed++ } }
  }
}
let payloads = []
context.shell.summon = (id, payload) => {
  assertEqual(destroyed, reads, 'rows are consumed and the reader is released before summon')
  payloads.push(JSON.parse(payload))
  return true
}
assertEqual(context.openFile('/private/rows', 'original', '/selection', '/done', 'true', 'true'), 'ok', 'file request opens the picker')
contents = 'changed\tnew-thumbnail'
assertEqual(context.openFile('/private/rows', 'changed', '/selection', '/done', 'false', 'false'), 'ok', 'repeated file request opens the picker')
assertEqual(payloads[0].imageRows, 'original\tthumbnail', 'queued open owns the original rows after the file changes')
assertEqual(payloads[1].imageRows, contents, 'repeated path reads new rows instead of a stale cache')
assertEqual(payloads[0].selectedImage, 'original', 'file request retains selected image')
assertEqual(payloads[0].doneFile, '/done', 'file request retains completion file')
assertEqual(payloads[0].showLabels, 'true', 'file request retains labels')
let preloaded = []
context.shell.imagePickerItem = () => ({ preloadRows(...args) { preloaded.push(args) } })
assertEqual(context.preloadFile('/private/rows', 'changed', 'true', 'false'), 'ok', 'file preload reads rows before returning')
assertDeepEqual(preloaded[0], [contents, 'changed', 'true', 'false'], 'file preload preserves rows and flags')
loaded = false
assertEqual(context.openFile('/private/rows', '', '', '', '', ''), 'unreadable', 'failed file read refuses opening')
assertEqual(context.preloadFile('/private/rows', '', '', ''), 'unreadable', 'failed file read refuses preloading')
assertEqual(payloads.length, 2, 'failed read cannot summon a stale request')
assertEqual(preloaded.length, 1, 'failed read cannot preload stale rows')
assertEqual(reads, destroyed, 'every rows reader is released')
JS
