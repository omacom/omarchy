# A child's first login opens on the first Kids theme installed, when Kids is
# one of the collections their picker offers.
[[ " $(id -nG) " == *" omarchy-child "* ]] || exit 0
omarchy-theme-collections | grep -qx kids || exit 0

while read -r theme; do
  [[ -z $theme || $theme == \#* ]] && continue
  if [[ -d $HOME/.config/omarchy/themes/$theme || -d $OMARCHY_PATH/themes/$theme ]]; then
    omarchy-theme-set "$theme"
    exit
  fi
done <"$OMARCHY_PATH/default/omarchy/theme-collections/kids"
