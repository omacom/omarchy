#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir "$tmp_dir/bin"
export TEST_DIR=$tmp_dir

cat >"$tmp_dir/bin/lp" <<'SCRIPT'
#!/bin/bash
if [[ -n ${LP_ERROR:-} ]]; then
  echo "$LP_ERROR" >&2
  exit 1
fi
echo "request id is HP_DeskJet_3700-42 (1 file(s))"
SCRIPT

# Replays what CUPS gave: lpstat -p <printer>, or lpstat -W <list> -l -o <printer>.
cat >"$tmp_dir/bin/lpstat" <<'SCRIPT'
#!/bin/bash
if [[ $1 == "-p" ]]; then
  cat "$TEST_DIR/printer"
else
  cat "$TEST_DIR/$2"
fi
SCRIPT

# One line per notification: the id it replaces, urgency, headline, body.
cat >"$tmp_dir/bin/omarchy-notification-send" <<'SCRIPT'
#!/bin/bash
replaces=0 urgency=low
while [[ $1 == -* ]]; do
  case $1 in
    -p) echo 7 ;;
    -r) replaces=$2 && shift ;;
    -u) urgency=$2 && shift ;;
    -g) shift ;;
  esac
  shift
done
printf '%s|%s|%s|%s\n' "$replaces" "$urgency" "$1" "${2:-}" >>"$TEST_DIR/notifications"
SCRIPT

printf '#!/bin/bash\n' >"$tmp_dir/bin/sleep"
chmod +x "$tmp_dir/bin/"*

job() {
  printf 'HP_DeskJet_3700-%s          ivan          2048   Tue 11 Nov 2026 09:12:03\n' "$1"
  [[ -z $2 ]] || printf '\tStatus: %s\n' "$2"
  printf '\tAlerts: %s\n\tqueued for HP_DeskJet_3700\n' "$3"
}

# A warning libcupsfilters gives every job on this printer, even one that prints.
quality="Unable to detect print-quality, using 'normal'!"

# Print, then give the last notification. Reading the output waits for the
# background follow-up, which keeps it open.
expect_notification() {
  local description=$1 expected=$2 actual
  rm -f "$tmp_dir/notifications"
  : "$(PATH="$tmp_dir/bin:$ROOT/bin:$PATH" omarchy-print "$tmp_dir/photo.jpg" || true)"
  actual=$(tail -n 1 "$tmp_dir/notifications")
  [[ $actual == "$expected" ]] || fail "$description" "$actual"
  pass "$description"
}

echo "printer HP_DeskJet_3700 is idle.  enabled since Tue 11 Nov 2026 09:00:00" >"$tmp_dir/printer"
job 43 "" none >"$tmp_dir/not-completed"
{ job 41 "" job-completed-with-errors; job 42 "$quality" job-completed-successfully; } >"$tmp_dir/completed"
expect_notification "a completed job reads as printed" "7|low|Printed photo.jpg|"

printf '\tgstoraster filter failed.\n' >>"$tmp_dir/printer"
job 42 "$quality" job-completed-with-errors >"$tmp_dir/not-completed"
job 41 "" job-completed-successfully >"$tmp_dir/completed"
expect_notification "a stopped job fails with the printer's message" "7|critical|Couldn't print photo.jpg|gstoraster filter failed."

LP_ERROR="lp: Error - The printer or class does not exist." \
  expect_notification "an lp error fails with lp's message" "0|critical|Couldn't print photo.jpg|lp: Error - The printer or class does not exist."

job 43 "" none >"$tmp_dir/not-completed"
expect_notification "a job in neither list names the job to look for" "7|low|Couldn't track photo.jpg|Job 42 on HP_DeskJet_3700"
