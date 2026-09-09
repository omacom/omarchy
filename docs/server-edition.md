# Server edition starter

This implements the first building blocks of [Phase 1](../plans/server.md#rollout), not a complete headless installation. ISO integration, provisioning, GUI migration/refresh gating, the terminal theme bridge, splash, issue generation, and greeting preferences remain follow-up work.

`omarchy edition` prints `/etc/omarchy-edition`, defaulting to `desktop` when the file is unreadable or absent. `omarchy edition server` and `omarchy edition desktop` are quiet predicates; the corresponding `omarchy-edition-server` and `omarchy-edition-desktop` helpers provide the same exit-code interface. Unknown marker contents match neither predicate. The installer owns this marker; writing it does not convert an installed desktop into a supported server.

`install/omarchy-server.packages` is a candidate package list for installer integration. It is not consumed by the current installation pipeline. lazyjournal remains optional; the menu falls back to journalctl.

The Bash rc sources `default/bash/server`. Only interactive login shells with terminal input and output, a usable TERM, no SSH_ORIGINAL_COMMAND (including an empty set value), and no tmux session enter the menu. Non-login shells and file-transfer command names skip it. Use arrow keys and Enter to select an entry; selecting Shell or cancelling with Escape returns to the existing shell. The planned single-key BBS shortcuts are not implemented yet. Commands that fail return to the menu for another selection.

The Theme entry currently displays the existing CLI theme commands. Applying themes and running updates are not yet guaranteed headless: the edition gates and terminal theme bridge are still pending. This starter should be exercised in a disposable Linux VM before installation use.

## Validation over SSH

Use an isolated Linux checkout with Bash 5, Node, Python, and the normal Omarchy test dependencies. The config suite also requires an `omarchy-pkgs` checkout, and the snapshot tests require `omarchy-iso`. Place them as sibling directories or set `OMARCHY_PKGS_PATH` and `OMARCHY_ISO_PATH`. Set the UTF-8 locale and runtime path explicitly because a noninteractive SSH session may not load Omarchy's shell environment:

```bash
export OMARCHY_PATH="$PWD"
export LC_ALL=C.UTF-8
env -u WAYLAND_DISPLAY -u HYPRLAND_INSTANCE_SIGNATURE ./test/all
```

This runs the CLI and shell suites headlessly; it does not run graphical acceptance tests or prove a full server installation works. The focused guard tests create their own pseudo-terminals and redirect the edition marker in a disposable helper copy, without writing `/etc/omarchy-edition`.
