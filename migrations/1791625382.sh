echo "Open files from browsers and other apps in the same app the file manager uses"

# xdg-open only reads the shared MIME database when mimetype is installed.
# Without it file(1) guesses from content, so .md is text/plain and .3mf is
# application/octet-stream, and neither reaches its default app.
omarchy-pkg-add perl-file-mimeinfo
