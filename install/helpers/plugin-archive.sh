#!/bin/bash

# Hash the installed files, including names and modes, but not installer metadata.
# Ignore timestamps and ownership so reading or copying files is not a local edit.
plugin_archive_checksum() {
  tar --sort=name --mtime=@0 --owner=0 --group=0 --numeric-owner \
    --format=gnu --exclude=./.omarchy-package.json -cf - -C "$1" . |
    sha256sum | cut -d ' ' -f 1
}

plugin_archive_export() {
  local repository="$1" destination="$2" url="$3"
  local commit checksum

  commit=$(git -C "$repository" rev-parse HEAD) || return 1
  mkdir -p "$destination" || return 1
  # Only attributes committed by the author select the package contents.
  GIT_ATTR_NOSYSTEM=1 git -c core.attributesFile=/dev/null -C "$repository" archive "$commit" |
    tar -xf - -C "$destination" || return 1
  if [[ -e $destination/.omarchy-package.json || -L $destination/.omarchy-package.json ]]; then
    echo "Plugin uses the reserved installer file .omarchy-package.json" >&2
    return 1
  fi
  omarchy-plugin-validate "$destination" || return 1
  checksum=$(plugin_archive_checksum "$destination") || return 1
  jq -n --arg repository "$url" --arg commit "$commit" --arg checksum "$checksum" \
    '{schemaVersion: 1, repository: $repository, commit: $commit, checksum: $checksum}' \
    >"$destination/.omarchy-package.json"
}
