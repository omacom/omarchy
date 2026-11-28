echo "Replace imv and mpv with Omaview"

omarchy-pkg-add omaview

# Omarchy's own Image Viewer (imv) and Media Player (mpv) launchers give way to
# Omaview's Media Viewer. Only a copy still as Omarchy shipped it goes, so one
# the user changed, or linked from their dotfiles, stays theirs.
applications="$HOME/.local/share/applications"
for entry in imv.desktop mpv.desktop; do
  file="$applications/$entry"
  [[ -f $file && ! -L $file ]] || continue
  case $(sha256sum <"$file") in
    120d30326a77e1f23d050e52293d0acf1aeb9499bf9cd47b93996d6e2be99480* | \
      a7a75999f161c6a409ff4c5da26ad9c79fc1ffdd4e633aac87f972ad72fc85d4* | \
      d105a16b60ecc1c67f6cc37e5bb7831ca8a08d0e602cb64dd4a1386703362385* | \
      9844e9d22d1b4b9801965afea1eb250103cfc6f12e6e62e542ac47abd4b8094d*)
      rm -f "$file"
      ;;
  esac
done
if [[ -d $applications ]]; then
  update-desktop-database "$applications"
fi

# imv and mpv-mpris go. mpv stays, as Omarchy's wallpaper engine, owe, plays
# video wallpapers through it. A mimeapps.list line naming imv.desktop stops
# resolving, and Omarchy's default, Omaview, opens those files instead.
omarchy-pkg-drop imv mpv-mpris
