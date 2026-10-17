echo "Make Chromium's first-run seed readable where an earlier migration left it root-only"

# 1787691200 shipped writing the seed under the caller's umask, so under `umask 077` it is
# root-only and Chromium cannot read it. Machines that ran it never run it again; repair them here.

chromium_dir="/usr/lib/chromium"
chromium_prefs="$chromium_dir/initial_preferences"

if [[ -d $chromium_dir && ! -x $chromium_dir ]]; then
  sudo chmod 755 "$chromium_dir"
fi

if [[ -e $chromium_prefs && ! -r $chromium_prefs ]]; then
  sudo chmod 644 "$chromium_prefs"
fi
