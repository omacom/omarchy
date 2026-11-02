echo "Take ownership of the FIDO2 authfile so it cannot be rewritten without root"

authfile="/etc/fido2/fido2"
authdir=${authfile%/*}

# An unresolved path must remain pending. Preserve it for inspection rather
# than following it or removing a credential the user may depend on.
report_unrepairable() {
  echo "  $1"
  local recovery="Review this path with an administrator. Before using Remove > Security > Fido2 and Setup > Security > Fido2, verify that your password can authenticate sudo with the token unplugged and cached authorization cleared. If the token is your only credential, an administrator must retain root access throughout recovery instead."
  local retry="After recovery, retry omarchy update if it was interrupted; otherwise re-run omarchy-migrate. This migration remains pending."
  echo "  $recovery"
  echo "  $retry"
  omarchy-notification-send -u critical -g  "FIDO2 authfile needs attention" "$1 $recovery $retry" || true
  exit 1
}

# A symlinked parent redirects all checks and staging too, even when its
# target is absent or already contains a root-owned registration.
if [[ -L $authdir || ( -e $authdir && ! -d $authdir ) ]]; then
  report_unrepairable "$authdir is not a regular configuration directory."
fi

# Nothing to repair on any machine that never set FIDO2 up, which is almost all
# of them. Checked before any sudo so those machines never see a password
# prompt. -L as well as -e: a dangling symlink is invisible to -e.
if [[ ! -L $authfile && ! -e $authfile ]]; then
  # Absence and "cannot look" are the same answer to the tests above. The old
  # setup created /etc/fido2 with `sudo mkdir -p`, which took the union of the
  # caller's umask and sudoers' 0022, so anyone registering under `umask 077`
  # left it mode 0700 with the user-owned authfile still inside. Escalate for
  # that case alone -- a machine that never set FIDO2 up has no directory here
  # and still reaches exit 0 without a password prompt. Not through a symlink:
  # chmod would act on whatever it points at.
  if [[ ! -d $authdir || -x $authdir ]]; then
    exit 0
  fi

  # Ask root whether a registration is behind it before touching the directory
  # itself. An aborted setup that left an empty 0700 directory, or one an
  # administrator deliberately keeps private, must not have its mode widened
  # and its group and special bits discarded for a repair it does not need.
  # A successful, empty listing proves absence. Testing through sudo conflates
  # a missing path with failed authorization, which must leave this pending.
  if ! registration=$(sudo find "$authdir" -mindepth 1 -maxdepth 1 -name "${authfile##*/}" -print); then
    echo "  Could not inspect $authdir; this migration remains pending." >&2
    echo "  Retry omarchy update if it was interrupted; otherwise re-run omarchy-migrate." >&2
    exit 1
  fi

  if [[ -z $registration ]]; then
    exit 0
  fi

  sudo chmod 755 "$authdir"
fi

# The old privileged move could install a symlink here if its fixed staging path
# was redirected. Following it would trust its target; removing it could break
# authentication for anyone whose only credential is the token.
if [[ -L $authfile ]]; then
  report_unrepairable "$authfile is a symlink, not a regular file."
fi

# A directory or a device here is no more ours to rewrite than a symlink is,
# and changing a directory's mode would alter an object we do not own.
if [[ ! -f $authfile ]]; then
  report_unrepairable "$authfile is not a regular file."
fi

# Migration state is per-user, so every account re-runs this. The file's own
# ownership is the state check: the second account finds the repair already
# done and exits without escalating.
owner=$(stat -c %U "$authfile" 2>/dev/null) || owner=""
group=$(stat -c %G "$authfile" 2>/dev/null) || group=""
mode=$(stat -c %a "$authfile" 2>/dev/null) || mode=""
if [[ $owner == "root" && $group == "root" && $mode == "644" ]]; then
  exit 0
fi

# Setup used to `mv` this in from /tmp, which carried the invoking user's
# ownership into /etc. Root ownership stops that user from rewriting their own
# PAM credential without root. Mode 644 keeps the public credential mapping
# readable when pam_u2f opens an absolute authfile as the authenticating user.
#
# Rename a fresh copy over the path rather than chowning in place. A descriptor
# opened while the file was still the user's own stays writable on that inode
# through any later chmod or chown, since permission is checked at open(2), and
# pam_u2f resolving the path would keep landing on it. Replacing the inode
# leaves that descriptor writing to a file nothing reads.
stage=""

safe_stage_path() {
  local candidate=$1
  local prefix="$authfile.new."
  local suffix

  [[ $candidate == "$prefix"* ]] || return 1
  suffix=${candidate#"$prefix"}
  [[ $suffix =~ ^[[:alnum:]]{6}$ ]]
}

cleanup_stage() {
  local status=$?

  if safe_stage_path "$stage"; then
    sudo rm -f -- "$stage" || true
  fi

  return "$status"
}

trap cleanup_stage EXIT
stage=$(sudo mktemp "$authfile.new.XXXXXX")

if ! safe_stage_path "$stage" || [[ ! -f $stage || -L $stage ]]; then
  echo "  Could not create a safe staging file beside $authfile."
  exit 1
fi

sudo install -T -m 644 -o root -g root "$authfile" "$stage"
sudo mv -Tf "$stage" "$authfile"
stage=""
trap - EXIT
