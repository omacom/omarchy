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

### Managing entries

The picker can also remove entries and do more than paste:

| Key | Action |
| --- | --- |
| `Del` | Remove the selected entry from the history |
| `Shift + Del` | Clear the entire history (with a confirmation) |
| `Shift + Return` | Copy the selected entry to the clipboard without pasting |
| `Alt + Return` | Open the entry: URLs open in the browser, images in the screenshot viewer, other text in the editor |
| `Up` / `Down` | Move the selection |
| `PageUp` / `PageDown` | Move the selection six entries |
| `Home` / `End` | Jump to the first / last entry |
| `Esc` | Clear the search, or close the picker |
