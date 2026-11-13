# A language the install media preset (/etc/omarchy/language) becomes this
# user's desktop language; the system step generated its locale.
code=
[[ -r /etc/omarchy/language ]] && read -r code </etc/omarchy/language
if [[ -n $code ]]; then
  "$OMARCHY_PATH/bin/omarchy-language" seed "$code" || echo "Could not set the preset language $code" >&2
fi
