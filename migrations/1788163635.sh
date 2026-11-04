echo "Remove legacy temporary passwordless sudo grants"

# Migration queues are per-user; the privileged repair is once per machine.
# The helper is a packaged program. A dev link may authorize a checkout's copy
# through the root-owned /etc/omarchy.conf; otherwise use the installed path,
# so a caller cannot put a program in $OMARCHY_PATH and have sudo run it.
helper=/usr/bin/omarchy-sudo-passwordless
if [[ -f /etc/omarchy.conf && ! -L /etc/omarchy.conf ]] &&
  [[ $(/usr/bin/stat -Lc '%u' /etc/omarchy.conf 2>/dev/null || true) == 0 ]]; then
  quoted_root=$OMARCHY_PATH
  quoted_root=${quoted_root//\\/\\\\}
  quoted_root=${quoted_root//\"/\\\"}
  quoted_root=${quoted_root//\$/\\\$}
  quoted_root=${quoted_root//\`/\\\`}
  mapfile -t dev_link < /etc/omarchy.conf
  dev_helper="$OMARCHY_PATH/bin/omarchy-sudo-passwordless"
  if (( ${#dev_link[@]} == 1 )) && [[ ${dev_link[0]} == "export OMARCHY_PATH=\"$quoted_root\"" ]] &&
    [[ -x $dev_helper ]]; then
    helper=$dev_helper
  fi
fi

if ! "$helper" __migration-complete; then
  sudo "$helper" __migrate
fi
