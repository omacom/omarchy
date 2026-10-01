#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

fns="$ROOT/default/bash/fns/drives"

# Every destructive step in format-drive runs through sudo, so stubbing sudo
# records what would have run without touching a disk.
driver='sudo() { echo "sudo $*"; }; format-drive /dev/omarchy-test "Test"'

run_format_drive() {
  local shell="$1" answer="$2"

  case $shell in
    bash) bash -c "source ${fns@Q}; $driver" <<<"$answer" ;;
    zsh) zsh -fc "emulate ksh -c 'source ${fns@Q}'; $driver" <<<"$answer" ;;
  esac
}

shells=(bash)
if command -v zsh >/dev/null 2>&1; then
  shells+=(zsh)
else
  skip "zsh: format-drive confirmation prompt"
fi

for shell in "${shells[@]}"; do
  output=$(run_format_drive "$shell" y 2>&1)
  [[ $output == *"sudo wipefs -a /dev/omarchy-test"* ]] ||
    fail "$shell: format-drive proceeds after y" "$output"
  pass "$shell: format-drive proceeds after y"

  output=$(run_format_drive "$shell" n 2>&1)
  [[ $output != *"sudo "* ]] || fail "$shell: format-drive stops after n" "$output"
  pass "$shell: format-drive stops after n"
done
