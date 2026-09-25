echo "Activate the Omarchy theme for existing T3 Code installs"

omarchy-pkg-present t3code-bin || exit 0
omarchy-install-ai-t3-code
