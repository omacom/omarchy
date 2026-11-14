# Restrict /boot for bootctl (world-accessible mount / random-seed warnings).
[[ -d /boot ]] && chmod 0700 /boot || true
[[ -e /boot/loader/random-seed ]] && chmod 0600 /boot/loader/random-seed || true
