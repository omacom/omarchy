echo "Make Mason's formatters runnable in Neovim data seeded without their execute bit"

# omarchy-nvim before 2026.9.21-6 cleared the execute bit on the Mason
# binaries it seeds into /etc/skel (omacom/omarchy-pkgs#2068), so shfmt and
# stylua copied into ~/.local/share/nvim could not run and LazyVim reported
# no formatter for shell and Lua files. Every link in mason/bin names a
# program Mason runs; restore the bit on the ones inside its packages tree.
mason=${XDG_DATA_HOME:-$HOME/.local/share}/nvim/mason
[[ -d $mason/bin ]] || exit 0
packages=$(readlink -f -- "$mason/packages") || exit 0

for link in "$mason"/bin/*; do
  target=$(readlink -f -- "$link") || continue
  if [[ $target == "$packages/"* && -f $target && ! -x $target && -O $target ]]; then
    chmod u+x,go+rx "$target"
  fi
done
