echo "Retire any user systemd gateway unit left behind from the mise-built Hermes"

# Migration 1790017600 removed the mise-built Hermes environment and the wrapper that proved it Omarchy's, but left any hermes-gateway*.service unit whose ExecStart ran that environment by path enabled and crash-looping under Restart=always. --retire-mise now sweeps those units by their ExecStart path even after the wrapper is gone, and exits non-zero if a unit will not stop so this migration stays pending rather than done.
omarchy-install-hermes-cli --retire-mise
