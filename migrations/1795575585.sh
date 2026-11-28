echo "Speed up waking from suspend on the MacBook Pro 11,2"

hook=/usr/lib/systemd/system-sleep/macbookpro11-cpu-resume

omarchy-hw-x86 && omarchy-hw-match "MacBookPro11,2" || exit 0
[[ -e $hook ]] && exit 0

# The hook comes with omarchy-settings, which can land after this package.
if [[ ! -f $OMARCHY_PATH/default/systemd/system-sleep/macbookpro11-cpu-resume ]]; then
  echo "Waiting for the omarchy-settings package that ships the MacBook Pro 11,2 resume hook" >&2
  exit 75
fi

sudo install -Dm755 "$OMARCHY_PATH/default/systemd/system-sleep/macbookpro11-cpu-resume" "$hook"
