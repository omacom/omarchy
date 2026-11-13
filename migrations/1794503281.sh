echo "Let the machines on a circle reach the local models this one shares"

# omarchy-local-ai's share proxy answers machines on a circle on circle0. ufw
# skips a rule it already has, and the rule is inert on a machine without Circle.
if omarchy-cmd-present ufw; then
  sudo ufw allow in on circle0 to any port 11431 proto tcp comment 'omarchy-local-ai-circle' >/dev/null
fi
