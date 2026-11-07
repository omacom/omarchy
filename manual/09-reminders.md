# Reminders

Omarchy has a built-in way to set simple reminders based on a countdown timer or a time of day, and with a message. You can do this via `Super + Ctrl + R`, seeing all the ones set via `Super + Ctrl + Alt + R`, and clearing all via `Super + Ctrl + Shift + R`. Everything also accessible via _Trigger > Reminder_. You can also use the cli with `omarchy reminder 7 'Tea ready'` or `omarchy reminder 3:30pm 'Call mom'`.

The prompt takes minutes (`15`), hours and minutes (`1h30m`), or a time of day (`3:30pm`, `15:30`, `noon`, `tomorrow 9am`), and previews when the reminder will go off as you type. A time that has already passed today is set for tomorrow.

 ![reminders](images/reminders.webp)
