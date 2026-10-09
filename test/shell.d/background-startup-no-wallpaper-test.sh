#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
require_compositor "background startup without a wallpaper"
require_command quickshell

# Startup releases the cover once the layer is ready and the boot intro has
# exited, in whichever order they land. Each order is forced by holding the
# other side on a pipe until the fixture sees the first one happen.
run_case() {
  local variant="$1" order="$2" stage output release_on
  stage=$(mktemp -d)
  mkdir -p "$stage/bin" "$stage/home/.local/state/omarchy/current"
  mkfifo "$stage/release"
  if [[ $variant == "a dangling link" ]]; then
    ln -s "$stage/deleted.png" "$stage/home/.local/state/omarchy/current/background"
  fi
  for component in Commons Ui services; do
    ln -s "$ROOT/shell/$component" "$stage/$component"
  done
  ln -s "$ROOT/shell/plugins/background" "$stage/background"
  cp "$SHELL_TEST_DIR/fixtures/background-startup-no-wallpaper/shell.qml" "$stage/shell.qml"

  if [[ $order == "the link read first" ]]; then
    release_on=ready
    cat >"$stage/bin/omarchy-theme-bg-boot-intro" <<SH
#!/bin/bash
cat "$stage/release" >/dev/null
exit 0
SH
  else
    release_on=settled
    printf '#!/bin/bash\nexit 0\n' >"$stage/bin/omarchy-theme-bg-boot-intro"
    cat >"$stage/bin/readlink" <<SH
#!/bin/bash
cat "$stage/release" >/dev/null
exec "$(command -v readlink)" "\$@"
SH
    chmod +x "$stage/bin/readlink"
  fi
  chmod +x "$stage/bin/omarchy-theme-bg-boot-intro"

  # Past the fixture's own 12 s backstop, so its failure message is what reports a hang.
  if ! output=$(HOME="$stage/home" PATH="$stage/bin:$PATH" RELEASE_FIFO="$stage/release" RELEASE_ON="$release_on" timeout 14 quickshell -p "$stage" --no-color 2>&1); then
    # A stub still held on the pipe would outlive the shell that started it.
    : <>"$stage/release"
    rm -rf "$stage"
    fail "startup with $variant and $order exits cleanly" "$output"
  fi
  : <>"$stage/release"
  rm -rf "$stage"
  [[ $output == *"RESULT pass"* ]] || fail "a desktop with $variant fades in once ready, with $order" "$output"
  if rg -q 'RESULT fail|ReferenceError|TypeError|Unable to assign|Binding loop' <<<"$output"; then
    fail "startup with $variant and $order has no QML errors" "$output"
  fi
  pass "a desktop with $variant fades in once ready, with $order"
}

for variant in "a dangling link" "no link"; do
  for order in "the link read first" "the intro first"; do
    run_case "$variant" "$order"
  done
done
