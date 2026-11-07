echo "Update the force-igpu sleep hook so it skips machines without a dGPU"

# The hook is a root-owned copy published once, so a changed source never reaches it.
# Replace only a copy quattro shipped, leaving an administrator's own edits alone.
hook_src="$OMARCHY_PATH/default/systemd/system-sleep/force-igpu"
hook_dst=/usr/lib/systemd/system-sleep/force-igpu
shipped_sha256=(
  cbcd9972eb194369947bfcf630909a7c2f24170fb5526355c7d32122d3b1f3be
  cb619d71989c044e75c0c446af29fc6fb7853e47a29c41800e083c0218a71f3d
)

[[ -f $hook_dst && ! -L $hook_dst ]] || exit 0

installed_sha256=$(sudo sha256sum -- "$hook_dst" | cut -d' ' -f1)
for sha256 in "${shipped_sha256[@]}"; do
  if [[ $installed_sha256 == "$sha256" ]]; then
    stage=$(sudo mktemp -- "${hook_dst%/*}/.force-igpu.omarchy.XXXXXX")
    sudo install -m 0755 -o root -g root -T "$hook_src" "$stage"
    sudo mv -Tf -- "$stage" "$hook_dst"
    break
  fi
done
