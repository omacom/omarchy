# CLI של Omarchy

Omarchy נשלטת בדרך כלל דרך קיצורי המקלדת ותפריט Omarchy (`Super + Space`). אבל אפשר גם לשלוט בה דרך ה-CLI של `omarchy`. זה שימושי במיוחד כאשר סוכן AI עובד איתכם על התאמה אישית או הגדרה.

ל-CLI יש גישה לכל הכלים הפנימיים שנמצאים בשימוש הן דרך התפריט והן בדרכים אחרות. אפשר לראות את כל מה שזמין על ידי הרצת `omarchy` בטרמינל.

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
  omarchy debug               Print debugging information

Groups:
  agent          AI coding agents, their usage, and subscription accounts
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
  debug          Diagnostics and support logs
  ...
```

ואפשר לצלול עמוק יותר בכל קבוצה:

```
~ ❯ omarchy capture
Capture commands — Screenshots and screen recording:
  omarchy capture qr                                                                                                                                                                                                       Decode a QR code from a screenshot region
  omarchy capture screenrecording [--fullscreen] [--with-desktop-audio] [--with-microphone-audio] [--with-webcam] [--webcam-device=<device>] [--webcam-size=<small|medium|large>] [--resolution=<size>] [--stop-recording]  Start or stop screen recording
  omarchy capture screenrecording with webcam                                                                                                                                                                              Pick a webcam and start a screen recording with it
  omarchy capture screenshot [smart|region|windows|fullscreen|scroll] [copy|save]                                                                                                                                          Take a screenshot
  omarchy capture text                                                                                                                                                                                                     Extract text from a screenshot region with OCR
  omarchy capture webcam resize <smaller|larger|reset|small|medium|large>                                                                                                                                                  Resize the active webcam recording overlay
```

כל פקודה מקבלת גם את `--help`, בין אם שואלים קבוצה שלמה (`omarchy capture --help`) או פקודה בודדת (`omarchy capture screenshot --help`).

### פתיחת התפריט מהטרמינל

תפריט Omarchy ניתן גם לתסריט, מה שנחמד לשיוכי המקשים שלכם. הפקודה `omarchy menu` פותחת אותו בשורש, ואפשר לקפוץ ישירות לכל נקודה בעץ על ידי ציון שמה: `omarchy menu summon style.theme` עובר ישר לבורר ערכות הנושא, `omarchy menu toggle system` פותח את תפריט המערכת וסוגר אותו שוב אם הוא כבר פתוח, ו-`omarchy menu close` מסלק אותו.
