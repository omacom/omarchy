#!/bin/bash

# Read one bounded history snapshot from stdin, then commit it under the same
# lock used by the loader. Success means the atomic replacement completed.

path=${1:?usage: save-history.sh <path> <max-bytes> [--clear-backups]}
ceiling=${2:?usage: save-history.sh <path> <max-bytes> [--clear-backups]}
timeout -k 1 30 python3 "$(dirname -- "${BASH_SOURCE[0]}")/migrate-history.py" --save "$path" "$ceiling" ${3:+"$3"}
