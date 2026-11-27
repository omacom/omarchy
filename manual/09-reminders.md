# Reminders

Omarchy has a built-in way to set simple reminders based on a countdown timer and with a message. You can do this via `Super + Ctrl + R`, seeing all the ones set via `Super + Ctrl + Alt + R`, and clearing all via `Super + Ctrl + Shift + R`. Everything also accessible via _Trigger > Reminder_. You can also use the cli with `omarchy reminder 7 'Tea ready'`.

The prompt and the cli also accept a clock time instead of minutes: `omarchy reminder 14:30 'Standup'` or `omarchy reminder 2:30pm 'Pick up kids'`. A time that already passed today rolls over to tomorrow.

 ![reminders](images/reminders.webp)
