echo "Remove Chromium Google OAuth workaround that causes SIGTRAP crashes"

# Omarchy used to inject Chrome's --oauth2-client-id/secret into
# ~/.config/chromium-flags.conf so Chromium could sign into Google accounts.
# On Chromium 136+ that workaround aborts the browser process (SIGTRAP) when
# opening Google Search, signing in, or enabling Sync (#2225). Strip the flags
# so existing installs stop crashing; Google accounts belong in Chrome instead.

CONF="$HOME/.config/chromium-flags.conf"

if [[ -f $CONF ]] && grep -qE -- '^--oauth2-client-(id|secret)=' "$CONF"; then
  tmp=$(mktemp)
  grep -vE -- '^--oauth2-client-(id|secret)=' "$CONF" >"$tmp"
  mv "$tmp" "$CONF"
  echo "Removed Google OAuth flags from $CONF. Restart Chromium, and use Install > Browser > Chrome for Google accounts."
fi
