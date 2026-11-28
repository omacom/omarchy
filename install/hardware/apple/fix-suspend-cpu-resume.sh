# Speed up waking from suspend on the MacBook Pro 11,2 by keeping the kernel
# from bringing the secondary CPUs up during S3 resume, which it does slowly there.

sleep_hook_dir=${OMARCHY_MBP11_SLEEP_HOOK_DIR:-/usr/lib/systemd/system-sleep}

if omarchy-hw-x86 && omarchy-hw-match "MacBookPro11,2"; then
  echo "Detected MacBook Pro 11,2, applying fast resume fix..."
  install -Dm755 "$OMARCHY_PATH/default/systemd/system-sleep/macbookpro11-cpu-resume" \
    "$sleep_hook_dir/macbookpro11-cpu-resume"
fi
