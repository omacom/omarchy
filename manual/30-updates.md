# Updates

Omarchy and your packages are kept up to date via _Update > Omarchy_ in the Omarchy menu (`Super + Space`).

Omarchy itself is installed as regular pacman packages from the [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), so an update installs [the latest Omarchy release](https://github.com/basecamp/omarchy/releases), runs any pending migrations to get your system in sync with the latest, and updates all system packages from the [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) and [AUR](https://aur.archlinux.org/) (if you have installed any AUR packages).

When new releases are made, a circle arrow icon will appear to the right of your clock. Click it and the update process will start.

![update-available](images/update-available.webp)

### Four channels

Omarchy is updated along four channels: stable, RC, edge, and dev. New installations start on the stable channel, which tracks the [official releases](https://github.com/basecamp/omarchy/releases/), as well as the [stable Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror) that's running one month behind the latest, so we can catch any new incompatibilities that require config changes before they cause problems for people.

But if you'd like to help spot those potential issues, you can run on the edge channel. That'll keep your Omarchy packages tracking the latest development builds, and lets you update to the latest Arch packages as soon as they're available. You should only do this if you're experienced with Linux, and know how to recover a system that has problems.

Before any new major release, we'll be doing final validation using the RC channel. If you're interested in helping with final polishing, come hang out in #omarchy-release-candidates on the Discord.

Finally, there's the dev channel, which links Omarchy directly to a git checkout of the source code in `~/omarchy`, combined with the edge packages. You should only use this channel if you're an experienced Linux user, working directly on Omarchy, and willing to tolerate breakage.

You can switch between channels using _Update > Channel_ from the Omarchy menu (or `omarchy-channel-set` in the terminal).

### Firmware updates

Your packages aren't the only thing that goes stale. Many laptops and peripherals ship BIOS, SSD, and dock firmware through the Linux Vendor Firmware Service, and _Update > Firmware_ in the Omarchy menu will fetch and install whatever your hardware has waiting. It installs `fwupd` the first time you run it. Plenty of firmware can only be written during a reboot, so don't be surprised to be asked for one.

### Warning about direct pacman/yay updates

If you're already familiar with Arch, you might be tempted to just run `pacman -Syu` or `yay -Syu` yourself, but if you do that, you'll miss the snapshot, migrations, and configuration updates that Omarchy runs together with new packages. That's why Omarchy will actually stop a direct system upgrade and point you to `omarchy update` instead. (If you really know what you're doing, the guard will tell you how to bypass it for a single transaction.)

### Non-interactive updates

Running `omarchy update` with no flags stays interactive and asks before orphan removal and reboot. For scripting, `-y` and `--yes` mean the same unattended full pipeline, while `--non-interactive` means unattended strict mode with external steps skipped by default. Every policy flag uses the exact `--name=value` form and overrides its mode default.

| Flag | Values | No flags (interactive) | `-y` / `--yes` (full) | `--non-interactive` (strict) |
| --- | --- | --- | --- | --- |
| `--hooks` | `run`, `skip` | `run` | `run` | `skip` |
| `--aur` | `run`, `skip` | `run` | `run` | `skip` |
| `--mise` | `run`, `skip` | `run` | `run` | `skip` |
| `--orphans` | `ask`, `keep`, `remove` | `ask` | `keep` | `keep` |
| `--reboot` | `ask`, `never`, `if-needed` | `ask` | `never` | `never` |
| `--restarts` | `run`, `skip` | `run` | `run` | `run` |

```bash
omarchy update --yes
omarchy update --non-interactive
omarchy update --non-interactive --mise=run
omarchy update --yes --orphans=keep --reboot=never
```

Unattended updates need sudo authorization already in place (a cached sudo ticket or NOPASSWD). Without it the update fails promptly instead of opening a password or graphical dialog, starting with the keyring check. Repeating a policy with the same value is fine, but contradictory repeats, `ask` combined with an unattended mode, unknown flags, and positional arguments all fail immediately with exit code 2 before anything changes.

What runs and what is only reported depends on the policy. Skipped hooks, AUR, and mise steps are reported (for example `Skipping mise updates (--mise=skip)`), kept orphans are listed and retained, and a needed-but-unperformed reboot is reported per trigger (for example `Reboot required: ...`) without rebooting. Exit code 0 means the selected mandatory work finished and any skipped work was reported; it does not mean every optional component was updated.

> **Warning: `--orphans=remove` removes packages without confirmation.** It authorizes removing the currently detected orphan packages with recursive semantics. Only use it when you mean it.

> **Warning: `--reboot=if-needed` reboots automatically and can close unsaved applications.** It reboots only after the whole pipeline succeeds and update-owned inhibitors are released; it never reboots midway or after a failure.

Scripted mode is cooperative, not a sandbox. User hooks, AUR package scripts, mise backends, and git credential helpers are external code that can still prompt, so `-y`/`--yes` is best-effort there rather than a universal no-prompt guarantee. Strict mode skips hooks, AUR, and mise by default for this reason; adding `--hooks=run`, `--aur=run`, or `--mise=run` opts back in per step with a warning that the non-interactive guarantee is relaxed for that component. `--restarts=skip` defers service and shell restarts while keeping restart markers, and `--reboot=never` reports reboot need without rebooting.

Required migrations still run in order and cannot be skipped by these flags. A migration that cannot finish unattended (for example one needing a browser closed) exits nonzero, stays pending, and stops what follows; the login notifier keeps prompting until `omarchy-migrate` is run interactively. A package conflict that needs a human answer also exits nonzero with instructions to rerun `omarchy update` interactively instead of guessing.

### Rolling back bad updates

If you ever have a problem after doing an update, you can rollback your system to the snapshot taken before the update. Just restart and pick the snapshot in the boot loading menu from before you started the update.

![bootloader](images/bootloader.webp)

If somehow your configuration files have been corrupted, you can also perform an Omarchy reinstall using `omarchy reinstall` in the terminal. This will reinstall all the default Omarchy packages, put you on stable and downgrade any packages that are too new, and reset all the configuration files. Note that all your user config changes to the Omarchy defaults will be overwritten doing this!
