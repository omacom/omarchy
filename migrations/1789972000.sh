echo "Remove hibernation drop-ins with an empty resume= device"

# omarchy-hibernation-setup used to write resume=$RESUME_DEVICE whenever the
# offset looked valid. findmnt can return blank, producing
# `resume= resume_offset=N` — a well-formed-looking cmdline that never resumes.
# Drop the broken file so the next setup run can rewrite it correctly.

drop_in=/etc/limine-entry-tool.d/resume.conf
[[ -f $drop_in ]] || exit 0

if grep -Eq 'resume=[[:space:]]+resume_offset=' "$drop_in"; then
  sudo rm -f "$drop_in"
  echo "Removed broken $drop_in; re-run omarchy hibernation setup if you use hibernate."
fi
