echo "Use output-relative slurp coordinates for region screen share"

file="$HOME/.config/hyprland-preview-share-picker/config.yaml"
[[ -f $file ]] || exit 0
grep -Fq "slurp -f '%o@%x,%y,%w,%h'" "$file" || exit 0

tmp=$(mktemp)
sed "s/slurp -f '%o@%x,%y,%w,%h'/slurp -f '%o@%X,%Y,%W,%H'/" "$file" >"$tmp"
cat "$tmp" >"$file"
rm -f "$tmp"
