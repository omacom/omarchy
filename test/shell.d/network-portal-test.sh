#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command python3

signin="$ROOT/bin/omarchy-network-portal-signin"
panel="$ROOT/shell/plugins/panels/network/Panel.qml"
model="$ROOT/shell/plugins/panels/network/Model.js"

# The sign-in view follows a redirect from a network nobody controls, so the
# thing it is pointed at must never be something that network chose. The panel
# passes the fixed probe endpoint; these two checks are what stop that quietly
# becoming a scraped Location header.
grep -q 'omarchy-network-portal-signin", Model.captivePortalUrl' "$panel" ||
  fail "the network panel opens the sign-in view at the fixed probe URL"
pass "the network panel opens the sign-in view at the fixed probe URL"

model_url=$(sed -n 's/^var captivePortalUrl = "\(.*\)"$/\1/p' "$model")
signin_url=$(sed -n 's/^DEFAULT_URL = "\(.*\)"$/\1/p' "$signin")
[[ -n $model_url && $model_url == "$signin_url" ]] ||
  fail "the sign-in view's default URL tracks Model.js" "Model.js=$model_url signin=$signin_url"
pass "the sign-in view's default URL tracks Model.js"

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
grep -q 'env=browser_env())' "$signin" ||
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
grep -q 'os.execvp("omarchy-launch-browser", \["omarchy-launch-browser", "--new-window", BROWSER_URL\])' "$signin" ||
  fail "the $flag toggle falls back to the real browser"
pass "the browser is one toggle away"

menu="$ROOT/default/omarchy/omarchy-menu.jsonc"
grep -q "\"checked\":\"omarchy-toggle-enabled $flag\"" "$menu" ||
  fail "the toggle is reachable from the network menu, and shows its state"
grep -q "\"action\":\"omarchy-toggle $flag\"" "$menu" ||
  fail "the network menu entry toggles the same flag it reports"
pass "the toggle is in the network menu and reports its own state"

# "Open in browser" hands the browser the fixed probe URL, never the page the
# gateway redirected to; and the view never claims to be a phone.
grep -q 'subprocess.Popen(\["omarchy-launch-browser", "--new-window", BROWSER_URL\],' "$signin" ||
  fail "the browser button opens the fixed browser URL"
pass "the browser button opens the fixed browser URL"
# archlinux.org is HSTS-preloaded: a Chromium-family browser would rewrite the
# probe URL to https and never meet the portal. The browser gets a host that is not.
grep -q '^BROWSER_URL = "http://captive.apple.com/hotspot-detect.html"' "$signin" ||
  fail "the browser URL is a plain-HTTP host that is not HSTS-preloaded"
pass "the browser URL is not HSTS-preloaded"
if grep -qi 'iphone\|Mobile/15' "$signin"; then fail "the sign-in view does not impersonate a phone"; fi
grep -q 'set_user_agent_with_application_details("Omarchy"' "$signin" ||
  fail "the sign-in view names Omarchy in its user agent"
pass "the sign-in view's user agent is honest"

# Opened from the panel, the surface stacks above it (so the panel is not
# dismissed by clicks on the page) and closes when the panel closes.
grep -q 'GtkLayerShell.Layer.OVERLAY' "$signin" || fail "the sign-in view stacks above the network panel"
pass "the sign-in view stacks above the network panel"
grep -q 'omarchy-keyboard-panel' "$signin" || fail "the sign-in view follows the panel that opened it"
pass "the sign-in view follows the panel that opened it"

