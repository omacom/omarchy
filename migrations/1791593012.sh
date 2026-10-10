echo "Delete clipboard images no longer referenced by clipboard history"

# The sweep lives in the prune helper so it stays test-covered; the migration
# itself runs once and stays a thin wrapper.
exec "$OMARCHY_PATH/bin/omarchy-clipboard-prune-images" --sweep
