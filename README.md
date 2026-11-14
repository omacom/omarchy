# Omarchy

Omarchy is a beautiful, fun & agentic Linux distribution by DHH.

Read more at [omarchy.org](https://omarchy.org).

## The Omarchy Manual

The manual lives in [`manual/`](manual/), which is its authoritative source.

- [Welcome to Omarchy!](manual/01-welcome-to-omarchy.md)

**The Basics**

- [Getting Started](manual/02-getting-started.md)
- [Coming From Mac or Windows](manual/03-coming-from-mac-or-windows.md)
- [Navigation](manual/04-navigation.md)
- [The top bar](manual/05-the-top-bar.md)
- [Themes](manual/06-themes.md)
- [Hotkeys](manual/07-hotkeys.md)
- [Unified Clipboard & History](manual/08-unified-clipboard-history.md)
- [Reminders](manual/09-reminders.md)
- [Notices](manual/10-notices.md)
- [Text Extraction & Dictation](manual/11-text-extraction-dictation.md)
- [Screenshots & Recording](manual/12-screenshots-recording.md)
- [Toggles, idle & screensaver](manual/13-toggles-idle-screensaver.md)
- [Omarchy CLI](manual/14-omarchy-cli.md)

**The Applications**

- [Terminal](manual/15-terminal.md)
- [Neovim](manual/16-neovim.md)
- [AI](manual/17-ai.md)
- [Development Tools](manual/18-development-tools.md)
- [Shell Tools](manual/19-shell-tools.md)
- [Shell Functions](manual/20-shell-functions.md)
- [TUIs](manual/21-tuis.md)
- [GUIs](manual/22-guis.md)
- [Browsers](manual/23-browsers.md)
- [Commercial apps/services](manual/24-commercial-apps-services.md)
- [Web Apps](manual/25-web-apps.md)
- [Gaming](manual/26-gaming.md)
- [Filling out PDFs](manual/27-filling-out-pdfs.md)
- [Windows VM](manual/28-windows-vm.md)
- [Other Packages](manual/29-other-packages.md)

**Configuration**

- [Updates](manual/30-updates.md)
- [Dotfiles](manual/31-dotfiles.md)
- [Shell plugins](manual/32-shell-plugins.md)
- [Monitors](manual/33-monitors.md)
- [Keyboard, Mouse, Trackpad](manual/34-keyboard-mouse-trackpad.md)
- [Networking](manual/35-networking.md)
- [System sleep](manual/36-system-sleep.md)
- [Hardware authentication](manual/37-hardware-authentication.md)
- [Fonts](manual/38-fonts.md)
- [Backgrounds](manual/39-backgrounds.md)
- [Prompt](manual/40-prompt.md)
- [Branding](manual/41-branding.md)
- [Common tweaks](manual/42-common-tweaks.md)
- [Making your own theme](manual/43-making-your-own-theme.md)

**The Rest**

- [Mac support](manual/44-mac-support.md)
- [Troubleshooting](manual/45-troubleshooting.md)
- [FAQ](manual/46-faq.md)
- [System snapshots](manual/47-system-snapshots.md)
- [Security](manual/48-security.md)
- [Omarchy on...](manual/49-omarchy-on.md)
- [Dual Boot Install](manual/50-dual-boot-install.md)
- [Unattended Installs](manual/51-unattended-installs.md)

## Touch Bar integration

This contribution integrates the animated Touch Bar on the 13-inch M1 and M2 MacBook Pros (`apple,j293` and `apple,j493`). Fresh system setup installs a prebuilt package only on those models, then configures its package-owned shell plugin, bindings and font hooks for the user. Existing users run `omarchy install touchbar`; `--package /absolute/archive` accepts a separately reviewed prebuilt package. Unsupported machines make no changes and request no administrator access. Runtime setup explicitly discovers the new plugin; edited font hooks are backed up outside active hook directories, and removal preserves user edits while retiring owned font-channel state.

The single versioned package contains both the modified tiny-dfr daemon and the [companion plugin](https://github.com/guirossibrum/omarchy-touchbar). It provides an animated Omarchy logo, tap-to-open menu, hold-to-dictate using the configured backend, brightness/media controls and labels that follow the system font. Ordinary package updates replace both together. Installation, first boot and updates never compile Rust, clone git repositories or invoke makepkg. The companion README includes a physical M1 MacBook Pro video.

See [Touch Bar setup and packaging](docs/touchbar.md) for the root/user phase boundaries, backups, removal and validation limits. **Publishing the combined signed package is a required merge dependency:** setup fails clearly if the configured repositories or preloaded image cannot supply it. The recipe is release/CI input, not an installation fallback. Package ownership and inclusion in a specific Omarchy release remain maintainer decisions.

## License

Omarchy is released under the [MIT License](https://opensource.org/licenses/MIT).
