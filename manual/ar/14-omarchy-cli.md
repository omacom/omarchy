# Omarchy CLI

عادةً ما يتم التحكّم في Omarchy عبر مفاتيح الاختصار وقائمة Omarchy ‏(`Super + Space`). لكن يمكنك أيضًا التحكّم فيه عبر واجهة سطر الأوامر `omarchy` CLI. وهذا مفيد بشكل خاص عندما تجعل وكيل ذكاء اصطناعي يعمل معك على التخصيص أو الإعداد.

تتمتّع واجهة سطر الأوامر بإمكانية الوصول إلى جميع الأدوات الداخلية المستخدمة سواء عبر القائمة أو بغير ذلك. يمكنك رؤية كل ما هو متاح بتشغيل `omarchy` في الطرفية.

يبدو الأمر على نحو شبيه بهذا:

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

ويمكنك التعمّق أكثر في كل مجموعة:

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

يقبل كل أمر أيضًا `--help`، سواء طلبت مجموعة كاملة (`omarchy capture --help`) أو أمرًا واحدًا (`omarchy capture screenshot --help`).

### فتح القائمة من الطرفية

قائمة Omarchy قابلة للبرمجة النصية أيضًا، وهو أمر مفيد لاختصارات لوحة المفاتيح الخاصة بك. يفتح `omarchy menu` القائمة من الجذر، ويمكنك الانتقال مباشرة إلى أي نقطة في الشجرة بتسميتها: ينقلك `omarchy menu summon appearance.theme` مباشرة إلى منتقي السمات، ويفتح `omarchy menu toggle system` قائمة النظام ويغلقها مجددًا إذا كانت مفتوحة بالفعل، ويغلق `omarchy menu close` القائمة ويخفيها.
