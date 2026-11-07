echo "Add live backgrounds, live screensavers and the background selector from omarchy-ambient"
omarchy-pkg-add omarchy-ambient fs-uae

# Retire only the compatibility menu rows and idle clone; keep selections and demos.
omarchy-ambient remove

# Link the selector into the shell. It also does this the first time it opens,
# so a shell that cannot answer now does not hold the queue.
omarchy-ambient selector enable || true
