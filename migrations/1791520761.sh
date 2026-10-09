echo "Install the DeepSeek Harness agent stub"

# install/user/mise.sh only runs during provisioning, so an install that
# predates the agent roster entry never gets the stub the roster documents:
# `dsh` would be selectable as an agent and still fail as a command until the
# user picked it, which installs it. Mirror the provisioning line, pin
# included, and leave a user who removed the preinstalls alone.
if omarchy-cmd-missing dsh && [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  omarchy-mise-install npm:@deepseek-ai/dsh@0.2.0-rc.2 dsh
fi
