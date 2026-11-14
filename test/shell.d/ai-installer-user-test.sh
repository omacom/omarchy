#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
if ! command -v unshare >/dev/null || ! unshare -Ur true 2>/dev/null; then
  skip "T3 installers refuse root before package or vendor work (needs unprivileged user namespaces)"
  exit 0
fi
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/home"
# If the root guard regresses, stop at the first package operation rather than
# touching the machine. A different failure must not pass as the root refusal.
printf '#!/bin/bash\nexit 99\n' >"$scratch/bin/omarchy-pkg-add"
cp "$scratch/bin/omarchy-pkg-add" "$scratch/bin/omarchy-i18n"
chmod +x "$scratch/bin/"*
for command in omarchy-install-ai-t3-code omarchy-install-t3code-app; do
  status=0
  unshare -Ur env HOME="$scratch/home" PATH="$scratch/bin:/usr/bin:/bin" \
    /bin/bash "$ROOT/bin/$command" stable >"$scratch/log" 2>&1 || status=$?
  (( status == 1 )) && grep -q 'Run this command as your desktop user, without sudo.' "$scratch/log" ||
    fail "$command refuses root at its entrypoint" "$(cat "$scratch/log")"
done
pass "both T3 installers refuse root before package or vendor work"
