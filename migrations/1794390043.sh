echo "Open text files in the default editor from every app"

# Setup > Default > Editor only steered Omarchy's own editor launches; Files
# and every other app kept opening text files in what mimeapps.list named,
# Neovim on older installs. Point text files at the editor handler, which
# follows that choice, except where the user picked an app themselves.
omarchy-cmd-editor-mimetypes --unless-chosen
