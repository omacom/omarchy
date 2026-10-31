#!/bin/bash

set -e

# Finish Superwhisper's per-user setup for installs that ship it preset as the
# dictation backend. Nothing on the fresh-install path ran setup-user (#15551),
# so the profile missed the launcher symlink, the settings-app and panel
# symlinks, and the seeded shortcut preferences: Settings could not save and
# the default RightAlt hold conflicted with Omarchy's own binding. This runs
# the same profile setup the Superwhisper installer runs, silently, and skips
# every install that does not need it.
#
# OMARCHY_SUPERWHISPER_SETUP overrides the packaged setup-user path; tests use
# it to point at a fake.
setup=${OMARCHY_SUPERWHISPER_SETUP:-/usr/share/superwhisper/setup-user}

if omarchy-pkg-missing superwhisper-bin; then
  exit 0
fi

if [[ ! -f $setup ]]; then
  exit 0
fi

backend=$(omarchy-default-dictation 2>/dev/null) || backend=""
if [[ $backend != superwhisper ]]; then
  exit 0
fi

# setup-user creates the app/current symlink; its presence means the profile
# was already set up, so re-running would only reseed preferences over the
# user's own.
if [[ -e $HOME/.local/share/superwhisper/app/current ]]; then
  exit 0
fi

bash "$setup"

# Existing profiles may still use Right Alt, which conflicts with Omarchy.
# Keep a recording shortcut active while moving away from that binding.
# Keep this block in sync with omarchy-install-dictation-superwhisper.
shortcuts=$(superwhisper shortcuts show)
if [[ $(jq -r '.shortcuts.hold' <<< "$shortcuts") == "RightAlt" ]]; then
  if [[ -z $(jq -r '.shortcuts.toggle' <<< "$shortcuts") ]]; then
    superwhisper shortcuts set hold "RightSuper" >/dev/null
  else
    superwhisper shortcuts set hold none >/dev/null
  fi
fi
# Superwhisper requires a native recording shortcut; keep it separate from
# Omarchy's push-to-talk keys.
superwhisper shortcuts set toggle "Alt+Space" >/dev/null
superwhisper shortcuts set hold none >/dev/null
