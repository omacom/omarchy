echo "Point Microsoft Office at the Microsoft 365 apps page"

office_launcher="$HOME/.local/share/applications/Microsoft Office.desktop"
if [[ -f $office_launcher ]]; then
  sed -i '\|^Exec=omarchy-launch-webapp "https://www.office.com/login"|s|https://www.office.com/login|https://m365.cloud.microsoft/apps|' "$office_launcher"
fi
