echo "Install rtkit so PipeWire gets realtime priority"

# PipeWire requests realtime scheduling via RealtimeKit at startup, but rtkit
# is not a dependency of Arch's pipewire packages and the rlimits fallback is
# not configured either (see https://github.com/omacom/omarchy/issues/9390).
# Without it, audio threads run at SCHED_OTHER nice 0 and produce xruns under
# sustained load.
#
# Processes started while rtkit was missing can carry a hard RLIMIT_RTTIME of
# 0, which the kernel enforces with SIGKILL once rtkit makes a thread
# realtime, so omarchy-realtime-repair raises those limits around the install.
# It fails, and keeps this migration pending, while anything is left that it
# could not repair or inspect.
omarchy-realtime-repair
