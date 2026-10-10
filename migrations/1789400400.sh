echo "Upgrade Chromium past the CVE-2026-85046 security floor when installed"

# Stable-mirror freezes have left default Chromium on builds older than
# 152.0.7977.82 while an in-the-wild exploit was public (#10732). Upgrade from
# the configured repos when Chromium is installed and behind that floor. The
# helper exits non-zero while the floor is unmet so this migration stays
# pending and retries on a later update. No-op when Chromium is absent.

if ! pacman -Q chromium &>/dev/null; then
  exit 0
fi

omarchy-pkg-upgrade-chromium-security
