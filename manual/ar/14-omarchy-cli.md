# Omarchy CLI

يُتحكّم في Omarchy عادة عبر اختصارات المفاتيح وقائمة Omarchy (`Super + Space`). لكن يمكنك أيضًا التحكّم فيه عبر `omarchy` CLI. هذا مفيد بشكل خاص عندما يكون لديك وكيل AI يعمل معك على تخصيص أو تكوين.

لـ CLI وصول إلى كل الأدوات الداخلية المستخدمة عبر القائمة وبخلاف ذلك. يمكنك رؤية كل شيء متاح بتشغيل `omarchy` في الطرفية.

يبدو شيئًا كهذا:

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

ويمكنك الغوص أعمق في كل مجموعة:

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

كل أمر يأخذ `--help` أيضًا، سواء سألت مجموعة كاملة (`omarchy capture --help`) أو أمرًا واحدًا (`omarchy capture screenshot --help`).

### فتح القائمة من الطرفية

قائمة Omarchy قابلة للبرمجة النصية أيضًا، وهو ما هو مفيد لروابط مفاتيحك الخاصة. `omarchy menu` يفتحها في الجذر، ويمكنك القفز مباشرة إلى أي نقطة في الشجرة بتسميتها: `omarchy menu summon style.theme` يذهب مباشرة إلى منتقي السمات، و`omarchy menu toggle system` يفتح قائمة النظام ويغلقها مرة أخرى إذا كانت مفتوحة بالفعل، و`omarchy menu close` يضعها بعيدًا.
