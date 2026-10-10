echo "Tell users when pam_faillock has locked the account"

# preauth silent hid pam_faillock's "account is locked" message, so sudo and the
# lock screen kept saying the password was wrong even when it was correct
# (issue #13185). Drop silent from the stock lines Omarchy owns.

strip_preauth_silent() {
  local file="$1"
  [[ -f $file ]] || return 0
  grep -q 'pam_faillock\.so preauth silent' "$file" || return 0
  sudo sed -i 's/\(pam_faillock\.so preauth\) silent /\1 /' "$file"
}

strip_preauth_silent /etc/pam.d/system-auth
strip_preauth_silent /etc/pam.d/omarchy-lock-password
