#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "plugin marketplace overlay"

# The overlay is driven through the request files it hands its summoner, so the
# behaviour worth pinning is what it does with them: a second summon must finish
# the request the first one left open, or the waiting command never returns.
# The request files belong in the fixture's own scratch directory: run_qml_fixture
# installs the EXIT trap that removes it, and a trap of ours would replace that
# one and leave both the directory and the fixture's HOME behind.
qml_fixture_scratch
scratch="$QML_FIXTURE_TMP/request"
mkdir -p "$scratch"

OMARCHY_QML_TEST_SCRATCH="$scratch" \
  run_qml_fixture marketplace-request "plugin marketplace finishes an open request before serving another" Ui Commons
