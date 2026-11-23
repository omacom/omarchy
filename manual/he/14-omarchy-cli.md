# Omarchy CLI

בדרך כלל שולטים ב-Omarchy באמצעות מקשי הקיצור והתפריט של Omarchy (`Super + Space`). אבל אפשר גם לשלוט בה באמצעות ה-CLI של `omarchy`. זה מועיל במיוחד כשיש לך סוכן AI שעובד איתך על התאמה אישית או על הגדרות.

ל-CLI יש גישה לכל כלי העבודה הפנימיים שמשמשים גם דרך התפריט וגם בדרכים אחרות. אפשר לראות את כל מה שזמין על ידי הרצת `omarchy` במסוף.

זה נראה בערך כך:

```
~ ❯ omarchy
Omarchy command center

Usage:
  omarchy <command> [args...]
  omarchy commands [--all] [--json] [--check]
  omarchy <group> --help
  omarchy <group> <command> --help

Common commands:
  omarchy update              Update Omarchy and system packages
  omarchy theme list          List available themes
  omarchy theme set <name>    Apply a theme
  omarchy font list           List available fonts
  omarchy screenshot          Take a screenshot
  omarchy-debug               Print debugging information

Groups:
  agent          AI coding agents, their usage, and subscription accounts
  ascii          Text drawn as ASCII art
  audio          Audio input and output controls
  bar            Omarchy shell bar layout and settings
  battery        Battery status helpers
  bluetooth      Bluetooth device controls
  branch         Omarchy git branch management
  branding       About and screensaver branding
  brightness     Display and keyboard brightness
  capture        Screenshots and screen recording
  channel        Omarchy release channel management
  clipboard      Clipboard helpers
  cmd            Command and shortcut helpers
  config         System configuration helpers
  ...
```

לצורך אבחון, הריצו את `omarchy-debug --no-sudo --print` ישירות. זה מדפיס מידע אבחוני וכותב את `/tmp/omarchy-debug.log` מבלי לבקש sudo, כולל בהתקנות של חבילות שבהן `omarchy debug` עלול להיכשל עם "Unknown Omarchy command".

ואפשר גם לצלול עמוק יותר לתוך כל קבוצה:

```
~ ❯ omarchy capture
Capture commands — Screenshots and screen recording:
  omarchy capture qr                                                                                                                                                                                                       Decode a QR code from a screenshot region
  omarchy capture screenrecording [--fullscreen] [--with-desktop-audio] [--with-microphone-audio] [--with-webcam] [--webcam-device=<device>] [--webcam-size=<small|medium|large>] [--resolution=<size>] [--stop-recording] [--status]  Start or stop screen recording
  omarchy capture screenrecording with webcam                                                                                                                                                                              Pick a webcam and start a screen recording with it
  omarchy capture screenshot [smart|region|windows|fullscreen|scroll] [copy|save]                                                                                                                                          Take a screenshot
  omarchy capture text                                                                                                                                                                                                     Extract text from a screenshot region with OCR
  omarchy capture webcam resize <smaller|larger|reset|small|medium|large>                                                                                                                                                  Resize the active webcam recording overlay
```

כל פקודה מקבלת גם `--help`, בין אם שואלים על קבוצה שלמה (`omarchy capture --help`) ובין אם על פקודה בודדת (`omarchy capture screenshot --help`).

### פתיחת התפריט מהמסוף

גם את התפריט של Omarchy אפשר להפעיל בסקריפט, וזה נוח לקיצורי מקשים משלך. `omarchy menu` פותח אותו מהשורש, ואפשר לקפוץ ישר לכל נקודה בעץ אם נותנים לה שם: `omarchy menu summon appearance.theme` מגיע היישר לבורר ערכות הנושא, `omarchy menu toggle system` פותח את תפריט המערכת וסוגר אותו שוב אם הוא כבר פתוח, ו-`omarchy menu close` מסגיר אותו.
