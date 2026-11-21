# What's new

After an update into a new feature release, the update icon next to the clock turns into a sparkle. Clicking it opens a short tour of the release: one page per feature, with its hotkey and a button that opens it, ending on a link to the release post. The tour stays under _Update > What's New_ in the menu, and `omarchy update whats new` opens it from a terminal.

## Where the notes live

Each feature release has one file, `default/omarchy/whats-new/<major>.<minor>.jsonc`, shared by its release candidates and patch releases: `4.5.jsonc` serves 4.5.0rc1 through 4.5.3. JSONC here is what the menu reads: JSON plus whole-line `//` comments, no trailing commas.

```jsonc
{
  "post": "https://omarchy.org/news/2026/11/omarchy-4-5/",
  "items": [
    {
      "icon": "󰥔",
      "title": "Elsewhen world clock",
      "body": "Pin cities on a globe and name the people in each, right next to the clock.",
      "keys": "Super + Ctrl + Alt + E",
      "try": { "label": "Open Elsewhen", "action": "omarchy-shell shell summon omarchy.elsewhen" }
    },
    {
      "changed": true,
      "icon": "󰍬",
      "title": "Dictation moved to Alt + Space",
      "body": "Tap Alt + Space to start and stop, or hold Right Alt to talk.",
      "keys": "Alt + Space",
      "when": "omarchy-default-dictation >/dev/null 2>&1"
    }
  ]
}
```

| Field | Meaning |
|---|---|
| `post` | The release post, opened from the last page |
| `changed` | Something that moved under the user rather than something new; tagged "Changed". List these first |
| `icon` | Nerd Font glyph shown above the title |
| `title` | The feature in a few words |
| `body` | A sentence or two on what it does and how to reach it |
| `keys` | Its hotkey as the user presses it, keys joined with ` + `; each becomes a keycap |
| `when` | Shell condition, like a menu guard; the item is left out when it fails (hardware without the feature, an app that isn't installed) |
| `try` | A button: its label, and a command written like a menu action. It closes the tour and runs the command |

Only what someone updating can act on or would trip over belongs here, about a screen's worth of reading per item. The full list of changes, fixes and security work stays in the release post.

`title`, `body` and `try.label` are translated. `python3 scripts/i18n-sync.py extract-apply` copies them into `default/i18n/en/whats-new.json`, keyed by their English text the way the keybindings catalog is, and the `Sync translations` workflow fills the other 49 languages from there (see [`i18n.md`](i18n.md)). `test/shell.d/i18n-test.sh` fails while the English catalog and the notes disagree.

## When to write them

`omarchy-release ship` tags the commit the last release candidate was cut from, so the notes have to be on `quattro` before that candidate: write them while the release candidates are being tested, alongside the release post. RC testers see the tour on each candidate, which is also how the notes get reviewed. A patch release that adds something worth telling can extend its release's file on the patch branch.

## Who sees it, and when

`omarchy-update-whats-new-notes --pending` answers whether the tour is waiting: it is when the installed `omarchy` package belongs to a release with notes, and the user hasn't seen them (`omarchy-done check whats-new-<release>`). The update icon (`shell/plugins/bar/widgets/SystemUpdate.qml`) asks when the shell starts, which every update ends with and every login begins with, so a `pacman -Syu` that bypassed `omarchy update` is caught at the next login too. An update waiting to be installed keeps the icon first.

- Closing the tour or reading it to the end marks the release seen (`omarchy-update-whats-new-seen`), and the icon goes back to hiding. A Try button leaves it unseen, so the icon stays to come back to.
- New installs mark their release seen during user provisioning (`install/user/whats-new.sh`): the first-run welcome introduces Omarchy instead.
- Edge and dev run `omarchy-dev` and move between releases every day, so they aren't prompted; the menu entry shows them the newest notes.
- A release without notes of its own shows nothing unasked, and the menu falls back to the newest notes there are.

The tour itself is the `omarchy.whats-new` panel plugin (`shell/plugins/whats-new/`), summoned by `omarchy-update-whats-new [release]`. It reads everything from `omarchy-update-whats-new-notes`, which evaluates the guards and applies the translations, so the shell only renders.
