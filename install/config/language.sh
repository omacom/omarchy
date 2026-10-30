# Install media can preset the desktop language for its users. The marker is a
# registry code, read as data; the system locale stays English, because the
# console cannot draw every script, and the language applies per user.
marker=${OMARCHY_LANGUAGE_MARKER:-/etc/omarchy/language}
code=
[[ -r $marker ]] && read -r code <"$marker"
if [[ -n $code ]]; then
  # A bracket range follows the locale's collation, not ASCII; compare in C.
  if (LC_ALL=C; [[ $code =~ ^[a-z]{2,3}(-[A-Z]{2})?$ ]]); then
    "$OMARCHY_PATH/bin/omarchy-locale-generate" "$code"
  else
    echo "Ignoring an invalid language in $marker: $code" >&2
  fi
fi
