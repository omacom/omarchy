echo "Temporarily remove automatic printer discovery"

machine_marker="${OMARCHY_CUPS_BROWSED_REMOVAL_MARKER:-/var/lib/omarchy/migrations/1788009111}"

[[ ! -e $machine_marker ]] || exit 0
omarchy-pkg-present cups-browsed || exit 0

# Check the full removal transaction before changing the service or queues.
pacman -Rs --print cups-browsed >/dev/null

# Disable the unit while its package still owns the unit file so systemd can
# remove the enable symlink cleanly.
if systemctl is-enabled --quiet cups-browsed.service 2>/dev/null; then
  sudo systemctl disable --now cups-browsed.service >/dev/null
elif systemctl is-active --quiet cups-browsed.service 2>/dev/null; then
  sudo systemctl stop cups-browsed.service >/dev/null
fi

# cups-browsed leaves its implicitclass queues behind when stopped. Remove idle
# discovery queues before removing the backend they require, but leave queues
# with jobs for the user to resolve.
#
# A healthy CUPS server with no configured printers reports this condition on
# stderr and exits 1. Treat that as an empty queue list. A stopped scheduler
# is safe only after checking saved queues; other failures stay pending.
# CUPS picks lpstat's message language itself; in the C locale it reads
# LC_MESSAGES before LC_ALL, so pin LC_MESSAGES too. LANGUAGE=C is harmless.
if queue_report=$(LC_ALL=C LANGUAGE=C LC_MESSAGES=C lpstat -v 2>&1); then
  :
elif [[ $queue_report == "lpstat: No destinations added." ]]; then
  queue_report=""
elif [[ $queue_report == "lpstat: Scheduler is not running." ]]; then
  # lpstat cannot list queues while CUPS is down. Saved implicitclass://
  # entries in printers.conf would survive cups-browsed removal, so retry
  # rather than mark the migration complete.
  # CUPS saves this file as root:0600. A read failure is not an empty file.
  if saved_config=$(sudo cat /etc/cups/printers.conf 2>/dev/null); then
    if grep -Eq '^[[:space:]]*DeviceURI[[:space:]]+implicitclass://' <<<"$saved_config"; then
      echo "CUPS is down but discovery queues remain. Start CUPS (sudo systemctl start cups.service) and run the update again." >&2
      exit 1
    fi
  elif ! sudo test ! -e /etc/cups/printers.conf; then
    echo "Could not read saved CUPS queues; leaving printer discovery installed. Check sudo access and printers.conf, then retry." >&2
    exit 1
  fi
  queue_report=""
else
  printf '%s\n' "$queue_report" >&2
  exit 1
fi

generated_queues=$(printf '%s\n' "$queue_report" |
  sed -n 's|^device for \(.*\): implicitclass://.*|\1|p')

while IFS= read -r queue; do
  [[ -n $queue ]] || continue

  if ! reject_error=$(sudo cupsreject -r "Printer discovery has been removed from Omarchy" "$queue" 2>&1); then
    if LC_ALL=C LANGUAGE=C LC_MESSAGES=C lpstat -p "$queue" >/dev/null 2>&1; then
      printf '%s\n' "$reject_error" >&2
      exit 1
    else
      continue
    fi
  fi

  if job_report=$(LC_ALL=C LANGUAGE=C LC_MESSAGES=C lpstat -o "$queue" 2>&1); then
    [[ -z $job_report ]] || continue
  elif LC_ALL=C LANGUAGE=C LC_MESSAGES=C lpstat -p "$queue" >/dev/null 2>&1; then
    printf '%s\n' "$job_report" >&2
    exit 1
  else
    # The queue disappeared after the initial snapshot, which is already the
    # desired state.
    continue
  fi

  if ! delete_error=$(sudo lpadmin -x "$queue" 2>&1); then
    # Treat a concurrent disappearance as success. A queue that still exists
    # means CUPS did not complete the deletion, so retry the migration later.
    if LC_ALL=C LANGUAGE=C LC_MESSAGES=C lpstat -p "$queue" >/dev/null 2>&1; then
      printf '%s\n' "$delete_error" >&2
      exit 1
    fi
  fi
done <<<"$generated_queues"

omarchy-pkg-drop cups-browsed >/dev/null
sudo install -Dm644 /dev/null "$machine_marker"
