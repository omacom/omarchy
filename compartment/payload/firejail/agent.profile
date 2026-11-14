# agent.profile — Firejail sandbox for AI agents in compartment VMs.
# Deterministic FS/capability policy; secrets resolve to ENOENT, not EACCES.

# --- filesystem ---
# workspace is the ONLY writable area
whitelist /home/agent/workspace
whitelist /home/agent/.hermes
whitelist /home/agent/.config/opencode
whitelist /home/agent/.codex
whitelist /home/agent/.claude
whitelist /home/agent/hermes-agent
whitelist /opt/agent-pack
whitelist /opt/python314
read-write /home/agent/workspace
read-write /home/agent/.hermes

# secrets & identity material — absent from the sandbox's view
blacklist /home/agent/.gnupg
blacklist /home/agent/.ssh
blacklist /home/agent/.local/share/keyrings
blacklist /home/agent/.mozilla
blacklist /home/user/.gnupg
blacklist /home/user/.ssh
blacklist /home/user/.local/share/keyrings
blacklist /home/user/.mozilla
blacklist /home/user/.config/BraveSoftware
blacklist /root
blacklist /etc/whonix_private
blacklist /var/lib/tor
noblacklist /home/agent/workspace

# system areas read-only
read-only /opt/models
read-only /usr
read-only /bin
read-only /lib
read-only /sbin

private-dev
private-tmp
nonewprivs

# --- capabilities / kernel surface ---
caps.drop all
seccomp !keyctl,!add_key,!request_key,!bpf,!perf_event_open,!io_uring_setup,!mount,!umount2,!kexec_load,!clone3

# --- namespaces ---
noroot
net lo             # loopback only: local model reachable; no external egress possible
protocol unix,inet # ignored when 'net none'; kept for profiles that re-enable

# --- misc ---
noexec /home/agent/workspace
nogroups
nosound
novideo
notv
