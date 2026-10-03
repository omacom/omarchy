#!/bin/bash

# The storage helper streams legacy text and serializes migration with saves.
# It only returns bounded JSON, and keeps rejected or unretained data in backups.
# Exit 3 (or a timeout) means the overlay must not save over the existing history.

path=${1:?usage: load-history.sh <path> <max-bytes>}
ceiling=${2:?usage: load-history.sh <path> <max-bytes>}
timeout -k 1 30 python3 "$(dirname -- "${BASH_SOURCE[0]}")/migrate-history.py" "$path" "$ceiling"
