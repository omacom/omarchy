echo "Remove the retired Voxtype installation invitation"

# Only discard the exact hook Omarchy copied. Keep user-authored additions.
# The stock install/user/first-run/install-voxtype.hook as v4.0.1-v4.0.4 shipped it, then as v4.0.0 did.
hook="$HOME/.config/omarchy/hooks/post-update.d/install-voxtype.hook"
if [[ -f $hook && ! -L $hook ]] && { cmp -s "$hook" <(cat <<'HOOK'
#!/bin/bash

set -e

if omarchy-done ensure voxtype-install-invitation; then
  omarchy-notification-send -u critical -g  "Install Dictation with Voxtype" \
    "Click to install voice dictation for Omarchy." \
    --exec omarchy-launch-floating-terminal-with-presentation omarchy-voxtype-install
fi
HOOK
) || cmp -s "$hook" <(cat <<'HOOK'
#!/bin/bash

set -e

if omarchy-done ensure voxtype-install-invitation; then
  omarchy-notification-send -u critical -g  "Install Dictation with Voxtype" \
    "Click to install voice dictation for Omarchy." \
    --exec "omarchy-launch-floating-terminal-with-presentation omarchy-voxtype-install"
fi
HOOK
); }; then
  rm "$hook"
fi
