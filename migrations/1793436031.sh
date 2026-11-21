echo "Correct the proportions of the default About logo"

logo_path="$HOME/.config/omarchy/branding/about.txt"
stock_hash="5fe8adced2fe67e410e177477a7272d1807b3fedc81fbc3f030dd479bc046b76"

if [[ -f $logo_path && ! -L $logo_path && $(sha256sum "$logo_path" | cut -d ' ' -f1) == "$stock_hash" ]]; then
  cp "$OMARCHY_PATH/icon.txt" "$logo_path"
fi
