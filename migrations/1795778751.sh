echo "Enable hardware video decoding and encoding in Chromium-based browsers"

features=(
  AcceleratedVideoDecodeLinuxGL
  AcceleratedVideoDecodeLinuxZeroCopyGL
  AcceleratedVideoEncoder
)

for flags_file in "$HOME"/.config/{chromium,chrome,microsoft-edge-stable,brave,brave-origin}-flags.conf; do
  [[ -f $flags_file ]] || continue

  for feature in "${features[@]}"; do
    args=$(sed -E 's/(^|[[:space:]])#.*$//' "$flags_file")

    if grep -Eq -- "(^|[[:space:]])--enable-features=([^[:space:]]*,)?$feature([,:<[:space:]]|\$)" <<<"$args"; then
      continue
    fi

    if grep -Eq -- '(^|[[:space:]])--enable-features=' <<<"$args"; then
      sed -i --follow-symlinks -E \
        -e "s/^(([^#]*[[:space:]])?--enable-features=[^[:space:]#]*)/\1,$feature/" \
        -e "s/--enable-features=,$feature/--enable-features=$feature/" "$flags_file"
    else
      if [[ -n $(tail -c1 "$flags_file") ]]; then
        echo >>"$flags_file"
      fi
      printf '%s\n' "--enable-features=$feature" >>"$flags_file"
    fi
  done
done
