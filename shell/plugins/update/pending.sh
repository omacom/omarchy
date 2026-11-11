#!/bin/bash

# Prints what omarchy update would install, one package per line:
# source<TAB>package<TAB>old version<TAB>new version<TAB>desktop id. The desktop
# id lets the update window show the app's real icon; packages without one are
# system components.

here=$(dirname "$(realpath "$0")")
pending=$(mktemp)
trap 'rm -f "$pending"' EXIT

repo=$(timeout 60 checkupdates --nocolor 2>/dev/null)
status=$?
# checkupdates exits 2 when nothing is pending; anything else but 0 means it
# could not tell, which the window must not pass off as up to date.
(( status == 0 || status == 2 )) || echo "unknown"
awk 'NF >= 4 { print "repo\t" $1 "\t" $2 "\t" $4 }' <<<"$repo" >>"$pending"
# With AUR packages installed, an AUR the machine cannot reach, or a query
# that runs out of time, is no answer either. yay exits 1 for nothing pending
# and for a failure alike, so only the timeout counts as one.
if pacman -Qem >/dev/null; then
  if omarchy-pkg-aur-accessible; then
    timeout 60 yay -Qua 2>/dev/null | awk 'NF >= 4 && $3 == "->" { print "aur\t" $1 "\t" $2 "\t" $4 }' >>"$pending"
    (( PIPESTATUS[0] != 124 )) || echo "unknown"
  else
    echo "unknown"
  fi
fi

# A development checkout behind its upstream is an update too: the bar's icon
# counts it, as omarchy-update-available does, so the preview lists it, with
# the commit the update would move it to.
if [[ $OMARCHY_PATH != "/usr/share/omarchy" ]]; then
  upstream=$(git -C "$OMARCHY_PATH" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)
  if [[ -n $upstream ]]; then
    GIT_TERMINAL_PROMPT=0 timeout 10 git -C "$OMARCHY_PATH" fetch --quiet 2>/dev/null || true
    if (( $(git -C "$OMARCHY_PATH" rev-list --count "HEAD..$upstream" 2>/dev/null || echo 0) > 0 )); then
      printf 'checkout\tomarchy-dev-checkout\t%s\t%s\n' "$(git -C "$OMARCHY_PATH" rev-parse --short=7 HEAD)" "$(git -C "$OMARCHY_PATH" rev-parse --short=7 "$upstream")" >>"$pending"
    fi
  fi
fi

declare -A desktop
while IFS=$'\t' read -r pkg id; do
  desktop[$pkg]=$id
done < <(cut -f2 "$pending" | xargs -r "$here/launchers.sh")

while IFS=$'\t' read -r source pkg old new; do
  printf '%s\t%s\t%s\t%s\t%s\n' "$source" "$pkg" "$old" "$new" "${desktop[$pkg]:-}"
done <"$pending"
