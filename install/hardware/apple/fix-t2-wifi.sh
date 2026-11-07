# Wi-Fi firmware and NVRAM for a T2 Mac whose disk no longer has macOS.
# Best-effort: a missing network must not fail the rest of hardware setup.
# `omarchy hw t2 wifi` retries once a connection exists, and so does the migration.
OMARCHY_T2_WIFI_BEST_EFFORT=1 omarchy-hw-t2-wifi || true
