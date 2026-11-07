# 13-inch Apple Silicon MacBook Pros are the only machines that need tiny-dfr.
# Intel T2 Macs drive the Touch Bar from the kernel and must not reach this
# install; omarchy-hw-apple-touchbar is false there. The package is aarch64,
# from the Asahi ALARM repository, so this leaf is also what keeps it off the
# shared Apple Silicon package list (Airs, minis, and 14-inch and 16-inch
# MacBook Pros have no Touch Bar).
if omarchy-hw-apple-touchbar; then
  echo "Detected an Apple Silicon MacBook Pro with a Touch Bar. Installing tiny-dfr..."
  omarchy-pkg-add tiny-dfr
fi
