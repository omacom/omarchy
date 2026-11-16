# Touch Bar on the 2016 15-inch MacBook Pro (A1707, MacBookPro13,3, Apple T1).
# Seborider/mbp-t1-touchbar (appletbdrm-t1 DKMS + patched tiny-dfr), with the
# Linux 7.2 plane-helper port vendored next to this script. Other T1 machines
# are left out. Never install t1bridge-dkms: its appletbdrm collides with this stack.

source "${OMARCHY_INSTALL:-$OMARCHY_PATH/install}/hardware/apple/a1707-t1-lib.sh"
a1707_t1_applicable || return 0

echo "Detected 2016 15-inch MacBook Pro (A1707, T1); installing Touch Bar support"

omarchy-pkg-add dkms rust python patch zstd

tb_src=$A1707_T1_CACHE/mbp-t1-touchbar
tdfr_src=$A1707_T1_CACHE/tiny-dfr
tb_commit=$(a1707_t1_read_pin mbp-t1-touchbar.base-commit)
tdfr_commit=$(a1707_t1_read_pin tiny-dfr.commit)

a1707_t1_clone_pinned https://github.com/Seborider/mbp-t1-touchbar "$tb_src" "$tb_commit"
git -C "$tb_src" apply -- "$A1707_T1_SRC/mbp-t1-touchbar-linux-7.2.patch"

a1707_t1_clone_pinned https://github.com/WhatAmISupposedToPutHere/tiny-dfr "$tdfr_src" "$tdfr_commit"
if ! grep -q 'iBridge Touchpad' "$tdfr_src/src/main.rs"; then
  patch -d "$tdfr_src" -p1 <"$tb_src/userspace/tiny-dfr-t1-digitizer-name.patch"
fi

ver=1.0
dk=/usr/src/appletbdrm-t1-$ver
if ! dkms status -m appletbdrm-t1 -v "$ver" 2>/dev/null | grep -q installed; then
  dkms remove appletbdrm-t1/"$ver" --all >/dev/null 2>&1 || true
  rm -rf "$dk"
  mkdir -p "$dk"
  cp "$tb_src"/kernel/appletbdrm.c "$tb_src"/kernel/hid-appletb-bl.c \
    "$tb_src"/kernel/Makefile "$tb_src"/kernel/dkms.conf "$dk"/
  dkms add appletbdrm-t1/"$ver"
  dkms build appletbdrm-t1/"$ver"
  dkms install --force appletbdrm-t1/"$ver"
fi

export CARGO_HOME=$A1707_T1_CACHE/cargo
mkdir -p "$CARGO_HOME"
(cd "$tdfr_src" && cargo build --release)
install -Dm755 "$tdfr_src/target/release/tiny-dfr" /usr/local/bin/tiny-dfr
mkdir -p /usr/share/tiny-dfr
cp -a "$tdfr_src"/share/tiny-dfr/. /usr/share/tiny-dfr/

mkdir -p /etc/tiny-dfr
# Own the default layout (F1-F12, media keys on Fn). Leave a user-edited copy.
if [[ ! -e /etc/tiny-dfr/layouts.toml ]]; then
  install -m644 "$A1707_T1_SRC/layouts.toml" /etc/tiny-dfr/layouts.toml
fi
if [[ ! -e /etc/tiny-dfr/config.toml ]]; then
  install -m644 "$tb_src/system/tiny-dfr-config.toml" /etc/tiny-dfr/config.toml
fi

echo uinput >/etc/modules-load.d/uinput.conf

# The Tschalar apple-ibridge stack forces USB configuration 1, which has no
# display interface. It cannot coexist with appletbdrm-t1.
cat >/etc/modprobe.d/blacklist-apple-ib.conf <<'EOF'
# The T1 Touch Bar is a DRM display driven by appletbdrm, not an HID gadget.
# These modules force USB configuration 1, which has no display interface.
# Written for the 2016 15-inch MacBook Pro (A1707, MacBookPro13,3) only.
blacklist apple_ib_tb
blacklist apple_ib_als
blacklist apple_ibridge
EOF

install -Dm755 "$tb_src/system/gen-seat-rules.sh" /usr/local/bin/touchbar-t1-gen-seat-rules
install -Dm755 "$tb_src/system/touchbar-t1-setup" /usr/local/bin/touchbar-t1-setup
install -Dm755 "$tb_src/system/touchbar-activate" /usr/local/bin/touchbar-activate
install -Dm755 "$tb_src/system/touchbar-t1-appmap" /usr/local/bin/touchbar-t1-appmap
install -Dm644 "$tb_src/system/touchbar-t1.service" /etc/systemd/system/touchbar-t1.service
install -Dm644 "$tb_src/system/tiny-dfr.service" /etc/systemd/system/tiny-dfr.service
install -Dm644 "$tb_src/system/touchbar-t1-appmap.service" /etc/systemd/system/touchbar-t1-appmap.service
mkdir -p /etc/pacman.d/hooks
install -Dm644 "$tb_src/system/pacman-hooks/95-touchbar-t1-seat-rules.hook" /etc/pacman.d/hooks/95-touchbar-t1-seat-rules.hook

# Static USB-ID exclusions; safe in the install chroot (no live DRM required).
/usr/local/bin/touchbar-t1-gen-seat-rules ||
  echo "Touch Bar seat rules will be generated on first boot"

systemctl daemon-reload
systemctl disable --now apple-ibridge.service 2>/dev/null || true
# Enable for next boot; do not start here (ISO runs in a chroot).
systemctl enable touchbar-t1.service tiny-dfr.service touchbar-t1-appmap.service
