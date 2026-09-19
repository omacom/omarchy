echo "Stamp the Hermes Desktop bootstrap marker on already-usable installs"

# The packaged hermes-desktop path Omarchy ships may leave a working runtime
# without .hermes-bootstrap-complete, so --check and theme activation stay
# stuck. Only repair installs Omarchy owns; do not re-run install.sh.
omarchy-pkg-present hermes-desktop || exit 0
omarchy-stamp-hermes-bootstrap
