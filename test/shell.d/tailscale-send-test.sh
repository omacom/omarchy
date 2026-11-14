#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

WORKDIR=$(mktemp -d)
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

mkdir -p "$WORKDIR/bin"
printf 'pdf' >"$WORKDIR/notes.pdf"

# Taildrop takes every file; the notification keeps one argument per line.
cat >"$WORKDIR/bin/tailscale" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$WORKDIR/bin/omarchy-notification-send" <<SH
#!/bin/bash
printf '%s\n' "\$@" >"$WORKDIR/notification"
SH
chmod +x "$WORKDIR/bin/"*

# Prints the headline of the notification that sending a file to $1 leaves.
sent_title() {
  rm -f "$WORKDIR/notification"
  OMARCHY_PATH="$ROOT" PATH="$WORKDIR/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-tailscale-send" "$1" "$WORKDIR/notes.pdf"
  sed -n '3p' "$WORKDIR/notification"
}

title=$(sent_title dhh-fd.tailnet.ts.net)
[[ $title == "Sent to dhh-fd" ]] || fail "tailscale send names a MagicDNS machine by its short name" "$title"
title=$(sent_title 4090.tailnet.ts.net)
[[ $title == "Sent to 4090" ]] || fail "tailscale send shortens a MagicDNS name that starts with digits" "$title"
pass "tailscale send names a MagicDNS machine by its short name"

# The panel falls back to a peer's first Tailscale IPv4 address when the peer
# has no name, and an address has no short form: cut at its first dot it
# would read "100".
title=$(sent_title 100.64.0.1)
[[ $title == "Sent to 100.64.0.1" ]] || fail "tailscale send names an IPv4 address in full" "$title"
pass "tailscale send names an IPv4 address in full"

title=$(sent_title fd7a:115c:a1e0::1)
[[ $title == "Sent to fd7a:115c:a1e0::1" ]] || fail "tailscale send names an IPv6 address in full" "$title"
pass "tailscale send names an IPv6 address in full"
