# Reminders

Omarchy has a built-in way to set simple reminders based on a countdown timer and with a message. When a reminder fires, its notification stays on screen until you dismiss it, so a reminder you stepped away from is still there when you come back. You can do this via `Super + Ctrl + R`, seeing all the ones set via `Super + Ctrl + Alt + R`, and clearing all via `Super + Ctrl + Shift + R`. Everything also accessible via _Trigger > Reminder_. You can also use the cli with `omarchy reminder 7 'Tea ready'`.

Pass `--urgency` (`low`, `normal`, or `critical`) to change how the fired notification behaves: `omarchy reminder -u normal 7 'Tea ready'` lets it time out on its own instead of waiting to be dismissed.

 ![reminders](images/reminders.webp)
