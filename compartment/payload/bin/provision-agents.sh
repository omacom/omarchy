#!/bin/bash
# provision-agents.sh — install agent CLIs inside a Whonix compartment.
# Runs in-guest (over Tor). Called from in-guest-provision or manually.
# Installs: node, opencode, claude-code, codex — per Omarchy agent framework.
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
set -e
echo "PHASE:agents"

# Node.js via debian package (nodejs+npm) — already in deb set or fetched over Tor
if ! command -v node >/dev/null 2>&1; then
  apt-get -o Acquire::http::Proxy=DIRECT update -qq 2>/dev/null || true
  DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::http::Proxy=DIRECT -y install nodejs npm 2>/dev/null || true
fi

# Agent CLIs via npm global install (Tor-proxied npm is fine — public registries)
NPM="npm --prefix /usr/local"
if command -v npm >/dev/null 2>&1; then
  $NPM install -g @openai/codex@latest 2>/dev/null && echo "codex ok" || echo "codex failed"
  $NPM install -g opencode-ai@latest 2>/dev/null && echo "opencode ok" || echo "opencode failed"
  $NPM install -g @anthropic-ai/claude-code@latest 2>/dev/null && echo "claude ok" || echo "claude failed"
fi

# default agent marker for vm-exec 'agent'/'attach' intents — pick an
# actually-installed agent (hermes only exists when the hermes pack landed)
if [ ! -f /etc/compartment/default-agent ]; then
  for a in opencode hermes codex claude devin; do
    if command -v "$a" >/dev/null 2>&1; then echo "$a" > /etc/compartment/default-agent; break; fi
  done
fi
echo "AGENTS_DONE"
