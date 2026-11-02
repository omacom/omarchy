echo "Repair remote Neovim clipboard yanks and paste"

nvim_provider="$HOME/.config/nvim/lua/config/remote_clipboard.lua"
provider_source="/usr/share/omarchy-nvim/config/lua/config/remote_clipboard.lua"

# Dotfile managers may own either the file or a parent directory through a
# symlink. Preserve that layout rather than detaching or editing its target.
provider_path="$nvim_provider"
while [[ $provider_path != "$HOME" && $provider_path != / ]]; do
  if [[ -L $provider_path ]]; then
    echo "Preserving symlink-managed Neovim provider: $nvim_provider"
    echo "Review remote clipboard settings in your dotfile configuration manually."
    exit 0
  fi
  provider_path=$(dirname "$provider_path")
done

[[ -f $nvim_provider ]] || exit 0

# Replace only known Omarchy versions, including the June file-backed provider
# and the two earlier proposed fixes. Preserve all user-authored changes.
provider_hash=$(sha256sum "$nvim_provider")
case ${provider_hash%% *} in
  c0c15941ed7cf97a1a3d3c60f0b13875e85f641bdb7431c3283e6f86fbc95f4e|bac8268c3dde4e747772467d6671e626aa4982478551d8fc8ebe1259a4854f2c|7f012a235c05e3c559b48211c1534af2f4c919750b76db88ec3d5b7814259d30|8b371d0f271e522b27696f1b71083d0a6ba7896cd3ff7b0a938b7327fcb06a46) ;;
  *)
    if [[ -f $provider_source ]] && cmp -s "$nvim_provider" "$provider_source"; then
      exit 0
    fi
    echo "Preserving customized Neovim provider: $nvim_provider"
    echo "Review remote clipboard settings manually, or use omarchy-nvim-refresh to reset them."
    exit 0
    ;;
esac

# Updates install packages before migrations. Refuse an older package so this
# migration remains pending instead of installing the provider it must repair.
nvim_package=$(pacman -Q omarchy-nvim)
if [[ $(vercmp "${nvim_package#* }" "2026.9.21-2") == -* ]] || [[ ! -f $provider_source ]]; then
  echo "Update omarchy-nvim to 2026.9.21-2 or newer before rerunning this migration." >&2
  exit 1
fi

provider_backup=$(mktemp "$nvim_provider.bak.XXXXXX")
cp -p "$nvim_provider" "$provider_backup"
provider_staged=$(mktemp "$nvim_provider.new.XXXXXX")
trap 'rm -f -- "$provider_staged"' EXIT
install -m 0644 "$provider_source" "$provider_staged"
# A failed write leaves the recognized original live, so retries can repair it.
# The temporary file is on the same filesystem for an atomic replacement.
mv -fT -- "$provider_staged" "$nvim_provider"
echo "Previous Neovim provider saved to $provider_backup"
