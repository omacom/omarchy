# Unified Clipboard & History

Usually on Linux, you need `Ctrl + Shift + C/V` to copy'n'paste in the terminal and `Ctrl + C/V` to do it everywhere else. That's hard to get used to for anyone who hasn't been born and bred on Linux! So too is the switch from super to ctrl, if you're coming from the Mac.

Omarchy tackles both problems with unified clipboard hotkeys that work (almost) everywhere. They are:

| Hotkey | Command |
| ------- | ----------- |
| Super + C | Copy |
| Super + X | Cut |
| Super + V | Paste |
| Super + Ctrl + V | Clipboard history |

_Note that most agent harnesses will use `Ctrl + V` for pasting images, but `Super + V` for pasting text._

### Clipboard history

The clipboard history is provided by the Omarchy shell and works for both text and images. You trigger it by `Super + Ctrl + V`, select your entry with return, and then that'll be placed on the clipboard ready to paste on `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

You can also search the history just by starting to type:

 ![clipboard-history-search](images/clipboard-history-search.webp)

Press `Delete` to remove the selected entry, or `Shift + Delete` to clear the history after confirmation. Removing an image also removes its saved clipboard copy when no history entry refers to it. Clearing history does not change the current clipboard, original image files, backups, or filesystem snapshots; it is not secure erasure.

History keeps up to 500 entries, with these limits:

| Limit | Size |
| ------- | ----------- |
| Text per entry, measured as UTF-8 | 1 MiB |
| Saved history, including JSON escaping and metadata | 8 MiB |
| Captured image | 16 MiB |
| Retained captured images in total | 128 MiB |

Older entries are removed when a total limit is reached. An oversized copy is omitted from history with a notification; it remains available on the current clipboard. Accepted entries keep their complete contents, including trailing newlines. Password-manager copies marked as sensitive are skipped, but applications that do not mark their secrets can still put those secrets into history.

History is stored privately under `$XDG_STATE_HOME/omarchy`, or `~/.local/state/omarchy` when that variable is unset. If existing history exceeds the limits or cannot be read, recording pauses and the original history file is preserved. You can save a copy of that file before opening the picker and pressing `Shift + Delete` to clear it and resume recording. Clear remains available even when the paused history cannot be displayed.
