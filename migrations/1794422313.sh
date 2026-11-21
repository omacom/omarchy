echo "Install the native TTFX Plymouth boot renderer"

payload=/usr/lib/omarchy/plymouth/ttfx-plymouth.so
live_module=/usr/lib/plymouth/ttfx-plymouth.so
descriptor=/usr/share/plymouth/themes/omarchy/omarchy.plymouth
if [[ -f $payload ]] && ! {
  cmp -s "$payload" "$live_module" &&
    grep -Fxq 'ModuleName=ttfx-plymouth' "$descriptor" &&
    grep -Fxq '[ttfx]' "$descriptor" &&
    grep -Eq '^Mode=(fixed|random|off)$' "$descriptor"
}; then
  sudo omarchy-plymouth-ttfx-install --module "$payload"
fi
