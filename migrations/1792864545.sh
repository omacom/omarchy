echo "Create the record of administrators' migrations"

# systemd-tmpfiles creates it at every boot; this creates it now rather than at
# the next one. It fails rather than skip it: every later migration an
# administrator runs is recorded, so the record must exist before any of them.
sudo systemd-tmpfiles --create /etc/tmpfiles.d/omarchy-admin-migrations.conf
