#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command python3

signin="$ROOT/bin/omarchy-network-portal-signin"
panel="$ROOT/shell/plugins/panels/network/Panel.qml"

# The entry point reads the live daemon; the panel supplies connection identity,
# never a copied configuration file or a URL learned from the network.
grep -q '"omarchy-network-portal-signin", "--ssid=" + ssid' "$panel" ||
  fail "the network panel delegates discovery to the sign-in entry point"
pass "the network panel delegates discovery to the sign-in entry point"
grep -q '"--interface=" + (device ? device.name' "$panel" ||
  fail "the sign-in view receives the portal interface"
pass "the sign-in view receives the portal interface"

# A URL reaching this command from anywhere but the panel still cannot be a
# file:, javascript: or data: payload.
# Any nonzero exit is not proof: a broken install dies before the guard runs.
# It has to be the guard's own refusal, with its exit code.
for hostile in 'file:///etc/passwd' 'javascript:alert(1)' 'data:text/html,x'; do
  output=$("$signin" "$hostile" 2>&1) && status=0 || status=$?
  [[ $status -eq 1 && $output == "Refusing to open a non-http(s) URL: $hostile" ]] ||
    fail "the sign-in view refuses a non-http(s) URL" "$hostile: exit $status: $output"
done
pass "the sign-in view refuses non-http(s) URLs"

grep -qx 'gtk-layer-shell' "$ROOT/install/omarchy-base.packages" ||
  fail "gtk-layer-shell is declared, so the sign-in view is a layer surface and not a window"
pass "gtk-layer-shell is declared"

# The layer-shell library has to beat libwayland-client into the process or its
# init quietly no-ops and the surface comes up as an ordinary tiled window.
grep -q 'LD_PRELOAD' "$signin" ||
  fail "the sign-in view preloads gtk-layer-shell"
pass "the sign-in view preloads gtk-layer-shell"

# The preload that makes it a layer surface is scrubbed before a browser is
# started from it; a GTK browser inheriting libgtk-layer-shell is not a browser.
grep -q 'env=browser_env(), start_new_session=True)' "$signin" ||
  fail "Open in browser starts the browser without the layer-shell preload"
pass "Open in browser starts the browser without the layer-shell preload"

grep -q 'event.keyval == Gdk.KEY_F5 or (event.keyval == Gdk.KEY_r and ctrl)' "$signin" ||
  fail "F5 reloads on its own; Ctrl+R too"
pass "F5 reloads on its own; Ctrl+R too"

grep -q 'set_exclusive_zone(self.window, 0)' "$signin" ||
  fail "the sign-in view reserves no space, so opening it moves nothing"
pass "the sign-in view reserves no space"

grep -q 'WebContext.new_ephemeral()' "$signin" ||
  fail "the sign-in view uses an ephemeral session, so the gateway sees no real profile"
pass "the sign-in view uses an ephemeral session"

# The browser is still available, behind one toggle, and the three places that
# name the flag have to agree or it silently does nothing.
flag=portal-in-browser
grep -q "\"omarchy-toggle-enabled\", \"$flag\"" "$signin" ||
  fail "the sign-in view honours the $flag toggle"
grep -q '  launch_browser()' "$signin" ||
  fail "the $flag toggle falls back to the real browser"
pass "the browser is one toggle away"

menu="$ROOT/default/omarchy/omarchy-menu.jsonc"
grep -q "\"checked\":\"omarchy-toggle-enabled $flag\"" "$menu" ||
  fail "the toggle is reachable from the network menu, and shows its state"
grep -q "\"action\":\"omarchy-toggle $flag\"" "$menu" ||
  fail "the network menu entry toggles the same flag it reports"
pass "the toggle is in the network menu and reports its own state"

# The browser uses fresh local discovery configuration, never a redirect or
# the rejected HTTPS URL. Its security policy remains the browser's own.
grep -q 'subprocess.Popen(\["omarchy-launch-browser", "--new-window", discovery_url()\],' "$signin" ||
  fail "the browser button resolves a fresh discovery URL"
pass "the browser button resolves a fresh discovery URL"
grep -q '^DEFAULT_URL = "http://neverssl.com/"' "$signin" ||
  fail "the fallback discovery endpoint is HTTP-only"
pass "the fallback discovery endpoint is HTTP-only"
if grep -qi 'iphone\|Mobile/15' "$signin"; then fail "the sign-in view does not impersonate a phone"; fi
grep -q 'set_user_agent_with_application_details("Omarchy"' "$signin" ||
  fail "the sign-in view names Omarchy in its user agent"
pass "the sign-in view's user agent is honest"

# Opened from the panel, the surface stacks above it (so the panel is not
# dismissed by clicks on the page) and closes when the panel closes.
grep -q 'GtkLayerShell.Layer.OVERLAY' "$signin" || fail "the sign-in view stacks above the network panel"
pass "the sign-in view stacks above the network panel"
grep -q 'portalProcess.running = false' "$panel" ||
  fail "the sign-in process follows the originating network panel"
pass "the sign-in process follows the originating network panel"

python3 -u "$ROOT/test/shell.d/fixtures/network-portal-tls.py" "$signin" ||
  fail "portal TLS failures never authorize a certificate or downgrade HTTPS"
pass "portal TLS failures never authorize a certificate or downgrade HTTPS (mocked WebKit)"
