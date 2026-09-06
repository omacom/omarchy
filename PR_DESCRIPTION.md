> **Note**: *This is my first-ever Pull Request to a major open-source project! If anything needs adjustment or doesn't fully meet the project standards, please let me know and I'll gladly update it.*

---

### Summary
This PR adds first-class **Doom Emacs** support to Omarchy, including automated installation via `omarchy-emacs`, isolated configuration (`~/.config/doom-emacs`), dedicated desktop launcher (`Doom Emacs.desktop`), installer/uninstaller scripts, default editor configuration (`EDITOR`/`VISUAL`), keybinding integration (`SUPER + SHIFT + N`), Walker / Omarchy menu entries, and live auto-theming for Doom Emacs.

---

### Features & Changes Included

1. **Installer (`bin/omarchy-install-editor-doom-emacs`)**:
   - Installs `omarchy-emacs` AUR package (bundled fonts & GTK/PGTK integration) + core dependencies (`git`, `ripgrep`, `fd`, `findutils`).
   - Clones Doom core into isolated **`~/.config/doom-emacs`** (leaving vanilla `~/.config/emacs` intact and conflict-free).
   - Runs Doom interactive setup targeting `EMACSDIR=~/.config/doom-emacs` and `DOOMDIR=~/.config/doom`.
   - Symlinks `~/.local/bin/doom` and creates a dedicated `Doom Emacs.desktop` launcher entry.
   - Automatically sets up Omarchy theme integration in `~/.config/doom/config.el`.

2. **Uninstaller (`bin/omarchy-remove-editor-doom-emacs`)**:
   - Safely removes `~/.config/doom-emacs`, `~/.local/bin/doom`, and `Doom Emacs.desktop`.
   - Resets default editor to `nvim` if Doom was active.
   - Prompts before removing user configuration (`~/.config/doom`) or the `omarchy-emacs` package.

3. **Default Editor Support (`bin/omarchy-default-editor` & `bin/omarchy-launch-editor`)**:
   - Registered `doom` / `doom-emacs` in `omarchy-default-editor` with the Doom Skull glyph (`󰗡`).
   - Updated `omarchy-launch-editor` to launch Doom using `--init-directory ~/.config/doom-emacs` in GUI and inline terminal modes (`-nw`).
   - `SUPER + SHIFT + N` shortcut seamlessly opens Doom Emacs when set as default.

4. **Walker / Omarchy Menu Entries (`default/omarchy/omarchy-menu.jsonc`)**:
   - **Install > Editor > Doom Emacs** (`install.editor.doom-emacs`)
   - **Setup > Defaults > Editor > Doom Emacs** (`setup.default.editor.doom`)
   - **Remove > Editor > Doom Emacs** (`remove.editor.doom-emacs`)

5. **Automated Truecolor Theming (`default/themed/doom-theme.el.tpl` & `bin/omarchy-theme-set-emacs`)**:
   - Generates `~/.local/state/omarchy/current/theme/doom-theme.el` on theme changes.
   - Hot-reloads active frames and evaluates full Omarchy color palette for Doom Emacs.

---

### Verification & Testing
- Ran `./test/cli`: **Passed**.
- Ran `./test/shell`: **Passed**.
- Verified `omarchy-install-editor-doom-emacs` execution, desktop entry, and menu visibility in Walker.
- Verified `omarchy-remove-editor-doom-emacs` cleanup and fallback default editor reset.
- Verified `SUPER + SHIFT + N` launching Doom Emacs.
- Verified live theme switching and color palette synchronization.
