# Workbench integration dependencies

This refreshed native panel tracks published Workbench source commit `9dce628d7e597a25f7abffa8498575f924761d97`. See `UPSTREAM.json` for file provenance. The existing PR description could not be refreshed because the GitHub integration returned 403; this document records the current dependency and validation requirements.

## Companion changes and merge order

| Change | Dependency |
|---|---|
| [Workbench #20](https://github.com/tcballard/omarchy-plugin-workbench/pull/20) | Helper and QML must both support protocol 1. Drawer remains optional. |
| [Drawer #1](https://github.com/spencerbull/omarchy-drawer/pull/1) | Requires API 1 from the revised bundled host patch OR the core host proposal; no core merge is mandatory for local testing. Existing patch users must upgrade their patch. |
| [Core lifecycle proposal, fork PR #10](https://github.com/tcballard/omarchy/pull/10) | Independent fix. Needed for reliable external live-link watching and generic-updater preservation of Workbench ownership. Overlaps upstream staged-validation/watcher proposals and should be reconciled with them. |
| [Core host proposal, fork PR #11](https://github.com/tcballard/omarchy/pull/11) | Independent of Workbench and lifecycle fixes. Provides an alternative to manually applying Drawer's patch. Most host code originates with Spencer Bull. |
| [Helper package #287](https://github.com/omacom/omarchy-pkgs/pull/287) | Pins Workbench source 9dce628d7e597a25f7abffa8498575f924761d97 from #20; requires full supported-host tests and Arch builds. Publish before shipping the refreshed native panel. |
| [Native Workbench #10027](https://github.com/omacom/omarchy/pull/10027) | Hard runtime dependency on the protocol-1 helper from #287. Drawer integration is optional. |

Recommended order: validate and review Workbench #20, publish its reviewed helper through #287, then ship the refreshed #10027 panel. Drawer and its host support form a separate track. Lifecycle fixes can merge independently. None of these PRs automatically enables, installs or requires Drawer for Workbench users.

The two core PRs currently live in tcballard/omarchy because GitHub returned 403 when creating upstream PRs. Intended upstream comparisons:
- [Lifecycle → omacom/quattro](https://github.com/omacom/omarchy/compare/quattro...tcballard:omarchy:fix/plugin-lifecycle-ownership)
- [Host API → omacom/quattro](https://github.com/omacom/omarchy/compare/quattro...tcballard:omarchy:feat/stock-bar-drawer-api)

Native desktop acceptance remains outstanding. Hiding is presentation only; it does not promise polling suspension or resource savings.
