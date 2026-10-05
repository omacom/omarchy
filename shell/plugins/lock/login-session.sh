#!/bin/bash

# A lock must never wait on an authorization prompt.
set -euo pipefail

login_session() {
  busctl call --allow-interactive-authorization=no \
    org.freedesktop.login1 /org/freedesktop/login1/session/auto \
    org.freedesktop.login1.Session "$@"
}

case ${1-} in
  lock) login_session Lock ;;
  locked) login_session SetLockedHint b true ;;
  unlocked) login_session SetLockedHint b false ;;
  *)
    echo "Usage: login-session.sh lock|locked|unlocked" >&2
    exit 2
    ;;
esac
