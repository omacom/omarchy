echo "Enable automatic Neovim clipboard yanks in remote sessions"

nvim_provider="$HOME/.config/nvim/lua/config/remote_clipboard.lua"

if [[ -f $nvim_provider ]] &&
  grep -qF 'name = "OmarchyRemoteClipboard"' "$nvim_provider" &&
  ! grep -qF 'vim.opt.clipboard = "unnamedplus"' "$nvim_provider"; then
  sed -i '/^  vim.g.clipboard = {/i\  -- LazyVim disables clipboard syncing over SSH; our provider supports it.\n  vim.opt.clipboard = "unnamedplus"\n' "$nvim_provider"
fi
