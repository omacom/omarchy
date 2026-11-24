echo "Repair the Copy URL shortcut for profiles that predate its pinned extension id"

# Keep unstamped upgrades on the same repair as first-run and login, which
# cover profiles restored after shipped migrations were stamped complete.
omarchy-cmd-repair-chromium-copy-url --prompt
