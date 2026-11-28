echo "Let agents in Foot notify when they finish or wait on you"

foot_ini="$HOME/.config/foot/foot.ini"

[[ -f $foot_ini ]] || exit 0
# A bell section of the user's own is left alone.
grep -q '^\[bell\]' "$foot_ini" && exit 0

cat >>"$foot_ini" <<'INI'

[bell]
# Agents ring the bell when they finish or wait on you; an agent window that
# isn't focused answers with a notification.
command=omarchy-agent-bell
INI
