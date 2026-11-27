echo "Socket-activate CUPS so cupsd starts on demand"

systemctl is-enabled --quiet cups.service 2>/dev/null || exit 0

# cups.service declares Also=cups.socket cups.path, so disabling it also
# removes their wants links; re-enable the socket and path afterward.
sudo systemctl disable cups.service
sudo systemctl enable --now cups.socket cups.path
