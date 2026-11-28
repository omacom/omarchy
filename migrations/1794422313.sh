echo "Install the native TTFX Plymouth boot renderer"

payload=/usr/lib/omarchy/plymouth/ttfx-plymouth.so
live_module=/usr/lib/plymouth/ttfx-plymouth.so
descriptor=/usr/share/plymouth/themes/omarchy/omarchy.plymouth
if [[ ! -f $payload ]]; then
  echo "Waiting for the omarchy package to ship the native TTFX Plymouth module ($payload)"
  exit 75
fi
if ! {
  cmp -s "$payload" "$live_module" &&
    grep -Fxq 'ModuleName=ttfx-plymouth' "$descriptor" &&
    grep -Fxq '[ttfx]' "$descriptor" &&
    grep -Eq '^Mode=(fixed|random|off)$' "$descriptor"
}; then
  sudo omarchy-plymouth-ttfx-install --module "$payload"
fi
