echo "Retire the OpenClaw move that 4.0.5 shipped too early"

# This migration shipped in 4.0.5 to move OpenClaw to a self-updating copy under ~/.openclaw, before the seed package that move needs. Wherever that package was missing it stopped the update and every migration after it (#15804). It now finishes without changing anything: a copy that was already moved stays as it is, and a packaged OpenClaw keeps running from its package. The move is 1792334754.sh now, which ships with the seed package; this filename stays inert.
exit 0
