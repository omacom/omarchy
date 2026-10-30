echo "Install the speaker tuning for the MacBook Pro 16-inch (2019)"

# See the apple-macbookpro16-1 speaker tuning. Gated on the model so a tuning
# another laptop's owner turned off is not turned back on.
if ! omarchy-hw-match "MacBookPro16,1"; then
  exit 0
fi

if omarchy-audio-tuning match >/dev/null 2>&1; then
  omarchy-pkg-add lsp-plugins-lv2
  # Without a running audio session or with EasyEffects active the tuning cannot
  # be applied now; that must not stop the remaining migrations.
  omarchy-audio-tuning on ||
    echo "Speaker tuning not applied yet. After logging in, run: omarchy audio tuning on"
fi
