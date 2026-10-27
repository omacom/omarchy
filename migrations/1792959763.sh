echo "Stop fprintd before sleep instead of restarting it after resume"

# The hook shipped with fingerprint recovery restarted fprintd on post.
# That queued job can stop the daemon the lock screen has just opened, and
# a restart from inside the hook waits on the sleep transaction that is
# waiting on the hook. The hook in default/ stops fprintd before sleep and
# does nothing after resume. Replace only the previously shipped text so an
# administrator's own hook is left alone.

hook_src="${OMARCHY_FPRINTD_RESUME_SRC:-$OMARCHY_PATH/default/systemd/system-sleep/fprintd-resume}"
hook_dst="${OMARCHY_FPRINTD_RESUME_DST:-/usr/lib/systemd/system-sleep/fprintd-resume}"

# Bytes of default/systemd/system-sleep/fprintd-resume before this change.
legacy_sha256=97b33e1ef96c6f173482d24131d68f3e6d2cd3b0233e64f01a551d3f553e8bb6

[[ -f $hook_dst && ! -L $hook_dst ]] || exit 0

digest=$(/usr/bin/sha256sum -- "$hook_dst" 2>/dev/null || sudo /usr/bin/sha256sum -- "$hook_dst") || exit 1
[[ ${digest%% *} == "$legacy_sha256" ]] || exit 0

if [[ ! -f $hook_src || -L $hook_src ]]; then
  echo "Missing the shipped fprintd hook at $hook_src" >&2
  exit 1
fi

echo "Replacing the fprintd resume hook so it stops the daemon before sleep"
sudo install -Dm755 "$hook_src" "$hook_dst"
