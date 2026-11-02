# Brave does not ship Google cloud TTS. Sites that use the Web Speech API
# (Google Translate Listen is the usual case) need a local speech-dispatcher
# backend with espeak-ng. Chromium still has cloud voices, so this stays off
# the base install and runs only when Brave is installed.

omarchy_ensure_brave_web_speech() {
  local flags_file=$1

  omarchy-pkg-add speech-dispatcher espeak-ng || return 1

  systemctl --user daemon-reload >/dev/null 2>&1 || true

  # speech-dispatcher.socket is a distro unit (WantedBy=sockets.target). Enable
  # without assuming a live user manager: an update from a TTY still needs the
  # symlink so the next graphical login has voices. --now starts it immediately
  # when the user manager is up, so an already-open session does not wait.
  if ! systemctl --user enable --now speech-dispatcher.socket >/dev/null 2>&1; then
    wants_dir="$HOME/.config/systemd/user/sockets.target.wants"
    mkdir -p "$wants_dir"
    ln -sfn /usr/lib/systemd/user/speech-dispatcher.socket \
      "$wants_dir/speech-dispatcher.socket"
  fi

  # Brave only asks speech-dispatcher for voices when started with this switch.
  if [[ -f $flags_file ]] && ! grep -qxF -- "--enable-speech-dispatcher" "$flags_file"; then
    if [[ -n $(tail -c1 "$flags_file") ]]; then
      echo >>"$flags_file"
    fi
    echo "--enable-speech-dispatcher" >>"$flags_file"
  fi
}
