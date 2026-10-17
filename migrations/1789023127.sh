echo "Re-apply powerprofilesctl shebang fix reverted by daemon upgrades"

# The install-time rewrite of /usr/bin/powerprofilesctl to #!/bin/python3 ran
# once, and every power-profiles-daemon upgrade since restored the packaged
# #!/usr/bin/env python3 shebang. On a PATH where mise's python3 shadows the
# system one, the CLI then dies with ImportError inside Omarchy's power
# profile callers. The libalpm hook shipped alongside this migration
# maintains the fix from now on; this repairs installs that already lost it.
# The packaged script only elevates when the packaged shebang is actually
# present, so a second user on the machine re-runs it without a prompt.
source "$OMARCHY_PATH/install/config/fix-powerprofilesctl-shebang.sh"
