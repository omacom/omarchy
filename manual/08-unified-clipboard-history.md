# Unified Clipboard & History

Usually on Linux, you need `Ctrl + Shift + C/V` to copy'n'paste in the terminal and `Ctrl + C/V` to do it everywhere else. That's hard to get used to for anyone who hasn't been born and bred on Linux! So too is the switch from super to ctrl, if you're coming from the Mac.

Omarchy tackles both problems with unified clipboard hotkeys that work (almost) everywhere. They are:

| Hotkey | Command |
| ------- | ----------- |
| Super + A | Select all |
| Super + C | Copy |
| Super + X | Cut |
| Super + V | Paste |
| Super + Ctrl + V | Clipboard history |

_Note that most agent harnesses will use `Ctrl + V` for pasting images, but `Super + V` for pasting text._

Use `Super + A`, then `Super + C` to copy everything in a focused text field or other app that supports `Ctrl + A`. In a terminal, `Ctrl + A` moves to the start of the command line instead of selecting its text.

### Clipboard history

The clipboard history is provided by the Omarchy shell and works for both text and images. You trigger it by `Super + Ctrl + V`, select your entry with return, and then that'll be placed on the clipboard ready to paste on `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

You can also search the history just by starting to type:

 ![clipboard-history-search](images/clipboard-history-search.webp)

The picker recognises text, images, files, links, email addresses and colours, and can filter by those types with `Ctrl + P`.

### Clipboard history keys

| Key | Action |
| --- | ------ |
| Return | Paste the selected entry |
| Ctrl + Return | Copy it without pasting |
| Alt + Return | Open a link, email, file or image |
| Ctrl + K | Open the action panel |
| Ctrl + P | Cycle the type filter |
| Ctrl + . | Pin or unpin the selection |
| Ctrl + E | Rename the selection |
| Ctrl + O | Open the selected link, email, file or image |
| Delete | Delete the selected entry |
| Shift + Delete | Delete the whole history after confirmation |
| Escape | Clear the search, then close the picker |

The action panel adds copy-text-from-image (OCR), copy-text-from-QR-code, colour format copies, edit content, delete recent entries by time window and a shortcut to the settings file.

Pinned entries stay at the top and are exempt from retention.

### Clipboard history settings

The picker writes its settings to `~/.config/omarchy/clipboard.json`. Open it from the action panel's **Open Settings** row.

```json
{
  "retentionDays": 0,
  "maxEntries": 500,
  "primaryAction": "paste",
  "textRecognition": true,
  "disabledApps": ["KeePassXC", "org.keepassxc.KeePassXC", "Bitwarden", "1Password"]
}
```

`retentionDays` is `0` for unlimited. `maxEntries` caps unpinned entries; `0` is unlimited. Set `primaryAction` to `"copy"` if Return should copy instead of paste. `textRecognition` runs Tesseract on new images so their text is searchable. `disabledApps` lists Hyprland window classes that are never recorded; apps that mark the clipboard as sensitive are always skipped.

Deleting the whole history, or entries from a recent time window, first writes a backup to `~/.local/state/omarchy/clipboard-history.json.bak`.
