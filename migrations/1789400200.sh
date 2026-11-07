echo "Upgrade Sunshine past the 2026.516 security floor when installed"

# Stable channel still serves sunshine 2026.516.143833; edge has
# 2026.906.222525 with upstream's security fixes (#10836). Pull that build for
# systems that already have Sunshine installed. No-op when Sunshine is absent
# or already new enough.

if ! pacman -Q sunshine &>/dev/null; then
  exit 0
fi

omarchy-pkg-upgrade-sunshine-security
