# Plugin Workbench shell integration

This first-party surface is adapted from [tcballard/omarchy-plugin-workbench](https://github.com/tcballard/omarchy-plugin-workbench) under the MIT License. `UPSTREAM.json` records the source baseline, modified-tree status and exact source hashes. This candidate is synchronized with Workbench commit `9dce628d7e597a25f7abffa8498575f924761d97` in PR #20.

Refresh and verify with Workbench's `scripts/sync-native-adaptation.py /absolute/omarchy-checkout` and `--check`. The adapter changes only plugin identity and the packaged helper path, and includes `Navigation.js`. The panel checks helper protocol 1 before loading data. Drawer remains optional and owns its profile state.

Native desktop visual and interaction acceptance remains required before publishing this candidate.
