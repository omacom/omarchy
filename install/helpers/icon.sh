# The icon handling of the app launcher commands: the name an icon is known
# by, the guarded download, the lookup in the icon theme, and the removal.
#
# The commands source this file instead of each carrying its own copy of the
# rules, because the copies had already started to differ from one another.

OMARCHY_ICON_ROOT="$HOME/.local/share/icons"
OMARCHY_ICON_DIR="$OMARCHY_ICON_ROOT/hicolor/256x256/apps"
OMARCHY_OLD_ICON_DIR="$HOME/.local/share/applications/icons"

# The answer has to arrive in a reasonable time: an install that waits forever
# is worse than one that says the download failed.
OMARCHY_ICON_DOWNLOAD_TIMEOUT=10

# A shell that is stopped by a signal reports the signal plus 128.
OMARCHY_ICON_INTERRUPT_STATUS=130
OMARCHY_ICON_TERMINATE_STATUS=143

# The icon theme's layout is the theme, the size, the context and the name,
# which is four levels below the icons directory the search starts at. Every
# icon a live system holds is within them.
OMARCHY_ICON_SEARCH_DEPTH=4

# The name an icon is known by: lower case, and only the characters that can
# be part of a file name.
omarchy_icon_name() {
  printf '%s\n' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[^[:alnum:]]\+/-/g; s/^-//; s/-$//'
}

# The name a reference to an icon carries: the file name without its
# extension, or the name itself when the reference has no extension.
omarchy_icon_name_from_ref() {
  local ref="$1"
  local name
  name=$(basename "$ref")

  if [[ $name == *.* ]]; then
    omarchy_icon_name "${name%.*}"
  else
    printf '%s\n' "$name"
  fi
}

# A local icon is installed with the format it came with, under the name the
# launcher knows it by.
omarchy_icon_install_local() {
  local source="$1"
  local name="$2"
  local ext="${source##*.}"

  [[ $ext == "$source" ]] && ext="png"
  mkdir -p "$OMARCHY_ICON_DIR"
  cp "$source" "$OMARCHY_ICON_DIR/$name.$ext"
  gtk-update-icon-cache "$OMARCHY_ICON_ROOT/hicolor" &>/dev/null || true
  printf '%s\n' "$name"
}

# A URL that answers with an error body still exits 0, so the answer is
# checked: an empty file or a body that is not an image is not an icon. The
# answer is written to a temporary file and only replaces the icon once it is
# an image, so a failed download leaves an installed icon alone. The
# downloader's own error is kept, so a failed fetch still says why it failed;
# a caller that wants the failure silent sends the whole call to /dev/null,
# and a caller that falls back to another source does exactly that.
omarchy_icon_download() {
  local url="$1" dest="$2" temp status

  # The temporary file is written outside the icon directory the desktop
  # indexes, so a download that dies leaves nothing the theme can pick up,
  # and it is removed when the install is interrupted.
  mkdir -p "$OMARCHY_ICON_ROOT"
  temp=$(mktemp "$OMARCHY_ICON_ROOT/.omarchy-icon.XXXXXX") || return 1

  # The caller's own handlers are kept and put back: a command that already
  # handles a signal must not lose it because it downloaded an icon. The
  # captured text is the caller's own handler, read back from the shell, and
  # it is evaluated again to put it back.
  local previous_int previous_term
  previous_int=$(trap -p INT)
  previous_term=$(trap -p TERM)
  trap "rm -f \"$temp\"; exit $OMARCHY_ICON_INTERRUPT_STATUS" INT
  trap "rm -f \"$temp\"; exit $OMARCHY_ICON_TERMINATE_STATUS" TERM

  if curl -fsSL --max-time "$OMARCHY_ICON_DOWNLOAD_TIMEOUT" -o "$temp" "$url" &&
    [[ -s $temp && $(file -b --mime-type "$temp") == image/* ]]; then
    # The temporary file is owner-only, and the icon is not.
    if chmod 0644 "$temp" && mv -f "$temp" "$dest"; then
      status=0
      # The desktop resolves the icon through the theme cache, so the cache
      # is refreshed once the icon is in place.
      gtk-update-icon-cache "$OMARCHY_ICON_ROOT/hicolor" &>/dev/null || true
    else
      status=1
    fi
  else
    status=1
  fi

  rm -f "$temp"
  trap - INT TERM
  [[ -z $previous_int ]] || eval "$previous_int"
  [[ -z $previous_term ]] || eval "$previous_term"
  return "$status"
}

# The desktop resolves an icon through the icon theme, which lives in the data
# directories it searches, and in the legacy per-user theme directory.
omarchy_icon_dirs() {
  local dir
  local -a data_dirs=("${XDG_DATA_HOME:-$HOME/.local/share}")

  # A configured list of data directories replaces the default one, the same
  # way it does for the desktop that resolves the icon.
  if [[ -n ${XDG_DATA_DIRS:-} ]]; then
    local -a configured=()
    IFS=: read -r -a configured <<<"${XDG_DATA_DIRS}"
    data_dirs+=("${configured[@]}")
  else
    data_dirs+=(/usr/local/share /usr/share)
  fi

  printf '%s\n' "$HOME/.icons"
  for dir in "${data_dirs[@]}"; do
    printf '%s\n' "$dir/icons" "$dir/pixmaps"
  done
}

# A bare name has to resolve to an icon the desktop environment can find, or
# the launcher ends up with a blank tile.
omarchy_icon_exists() {
  local name="$1" dir path stem pattern

  # An empty name is not an icon: the search would match every dotfile.
  [[ -n $name ]] || return 1

  # The name is matched literally, so a name the user typed cannot reach
  # another file. The theme indexes a name without its extension, so "foo" is
  # not "foo.bar.png", and a directory is not an icon.
  pattern=$(printf '%s' "$name" | sed 's/[][*?\\]/\\&/g')

  while IFS= read -r dir; do
    [[ -d $dir ]] || continue
    while IFS= read -r path; do
      stem=${path##*/}
      stem=${stem%.*}
      [[ $stem == "$name" ]] || continue
      # A theme entry is often a symbolic link to the real image, and the
      # mime probe has to follow it to see what it points at.
      [[ $(file -L -b --mime-type "$path") == image/* ]] || continue
      return 0
    done < <(find "$dir" -maxdepth "$OMARCHY_ICON_SEARCH_DEPTH" \( -type f -o -type l \) -name "$pattern.*" 2>/dev/null)
  done < <(omarchy_icon_dirs)

  return 1
}

# The icon is removed by the name it is known by, in every format it may have
# been installed with: the installers keep the format of the file they copied,
# and the formats the theme ships are not the only ones an icon can have.
omarchy_icon_remove() {
  # The name the user typed. The icon is known by its sanitized form, and
  # the installers before the sanitization wrote the icon under the name as
  # it was typed.
  local raw_name="$1" candidate base
  local name
  name=$(omarchy_icon_name "$raw_name")

  if [[ -n $name ]]; then
    # The icon keeps the format it was installed with, and the formats the
    # installers can produce are not bounded by the ones the theme ships. The
    # name is sanitized, so it holds no glob character and cannot reach
    # another app's icon, and only the files that are images are taken, so a
    # file that carries the name but is not an icon stays.
    for candidate in "$OMARCHY_ICON_DIR/$name".*; do
      [[ -f $candidate ]] || continue
      base=${candidate##*/}
      # The name of the icon is the file name without its extension, so a
      # file that carries a second part is the icon of another app: the
      # launcher resolves "foo.bar" to "foo-bar", and removing "foo" leaves
      # it be. A file that is not an image is not an icon, so it stays too:
      # the removal takes the icons, not everything that carries the name.
      [[ ${base%.*} == "$name" ]] || continue
      [[ $(file -L -b --mime-type "$candidate") == image/* ]] || continue
      rm -f "$candidate"
    done
  else
    # A name that sanitizes to nothing left the icon at the empty name, where
    # the installer wrote it: the file name is the extension alone. A file
    # that carries a name of its own is not one of those, and a file that is
    # not an image is not an icon.
    for candidate in "$OMARCHY_ICON_DIR/".[!.]*; do
      [[ -f $candidate ]] || continue
      base=${candidate##*/}
      # A file whose name is only the extension is one of those; a file that
      # carries a name of its own is not.
      [[ $base == .?*.* ]] && continue
      [[ $(file -L -b --mime-type "$candidate") == image/* ]] || continue
      rm -f "$candidate"
    done
  fi

  # The icons the installers wrote before the name was sanitized. The name
  # here is the one the user typed, so it can hold a glob or a path; the
  # names are quoted, so they are matched literally, and only a .png file
  # under those two directories is touched.
  rm -f "$OMARCHY_ICON_DIR/$raw_name.png" "$OMARCHY_OLD_ICON_DIR/$raw_name.png"
}
