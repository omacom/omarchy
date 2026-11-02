echo "Move the monospace font rule aside and upgrade your generated font override"

# The package rule moved from 50-omarchy.conf to 51-omarchy.conf so the
# generated user rule (loaded by 50-user.conf) is evaluated first. Only
# clean up once the replacement is actually installed: on a checkout that
# links Omarchy commands without updating fixed system paths, the installed
# settings package may still supply only the old file, and deleting it
# would remove every Omarchy font default from that machine. Staying
# pending retries after the package update lands (omarchy update installs
# packages before running migrations).
if [[ ! -e /usr/share/fontconfig/conf.avail/51-omarchy.conf && ! -L /etc/fonts/conf.d/51-omarchy.conf ]]; then
  echo "The settings package has not installed 51-omarchy.conf yet; leaving this migration pending"
  exit 1
fi

# Pacman orphans the removed 50- files instead of deleting them, so an old
# install would keep the old hijacking rule alongside the new one. Remove
# both the installed target and its conf.d symlink; either may already be
# gone.
if [[ -e /usr/share/fontconfig/conf.avail/50-omarchy.conf || -L /usr/share/fontconfig/conf.avail/50-omarchy.conf || -e /etc/fonts/conf.d/50-omarchy.conf || -L /etc/fonts/conf.d/50-omarchy.conf ]]; then
  sudo rm -f /usr/share/fontconfig/conf.avail/50-omarchy.conf /etc/fonts/conf.d/50-omarchy.conf
fi

# A rule the old omarchy-font-set generated keeps working after the rename,
# and keeps hijacking: its unguarded prepend_first runs before the package
# rule and puts the chosen font ahead of explicit families that only gained
# "monospace" from 48-guessfamily.conf. Upgrade that known block to the
# scoped form, preserving the selected font; anything else in the file is
# the user's own and stays untouched.
user_font="$HOME/.config/fontconfig/fonts.conf"
if [[ -f $user_font ]] && grep -Fq 'prepend_first' "$user_font"; then
  first_prepend=$(grep -n 'prepend_first' "$user_font" | head -n 1 | cut -d: -f1)
  old_start=$(grep -n '<match' "$user_font" | awk -F: -v pl="$first_prepend" '$1 <= pl {s=$1} END {print s}' || true)
  old_end=$(awk -v pl="$first_prepend" 'NR >= pl && /<\/match>/ {print NR; exit}' "$user_font" || true)
  # Only the known generated block qualifies: one monospace test plus the
  # prepend_first edit and nothing else. A custom prepend_first block, or a
  # file where another rule names the first non-monospace family, keeps
  # whatever the user wrote.
  block_ok=false
  if [[ -n $old_start && -n $old_end ]]; then
    block=$(sed -n "${old_start},${old_end}p" "$user_font")
    if (( $(grep -c '<string>' <<<"$block") == 2 )) &&
      (( $(grep -c '<string>monospace</string>' <<<"$block") == 1 )) &&
      (( $(grep -c '<test' <<<"$block") == 1 )) &&
      (( $(grep -c '<edit' <<<"$block") == 1 )); then
      block_ok=true
    fi
  fi
  # Read the font only from a qualifying block, and tolerate an empty
  # result: a grep pipeline with no surviving lines exits non-zero, which
  # under the migration runner's pipefail would abort the migration and
  # block every later one on each retry.
  chosen=""
  if $block_ok; then
    chosen=$(grep -o '<string>.*</string>' <<<"$block" | sed -e 's/^<string>//' -e 's|</string>$||' | grep -vx 'monospace' | head -n 1 || true)
  fi
  if $block_ok && [[ -n $chosen ]]; then
    scoped=$(mktemp)
    cat >"$scoped" <<XML
  <match target="pattern">
    <test name="family" qual="any">
      <string>monospace</string>
    </test>
    <test name="family" qual="first" compare="eq">
      <string>monospace</string>
    </test>
    <edit name="family" mode="prepend" binding="strong">
      <string>$chosen</string>
    </edit>
  </match>
XML
    replaced=$(mktemp)
    {
      head -n $((old_start - 1)) "$user_font"
      cat "$scoped"
      tail -n +"$((old_end + 1))" "$user_font"
    } >"$replaced"
    # Write through a symlink into a dotfiles repo rather than replacing
    # the link with a copy, so the tracked file keeps the upgrade.
    cat "$replaced" >"$user_font"
    rm -f "$scoped" "$replaced"
    echo "Upgraded the generated monospace override to the scoped form (kept $chosen)"
  fi
fi
