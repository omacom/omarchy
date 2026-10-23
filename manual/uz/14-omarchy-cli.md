# Omarchy CLI

Omarchy odatda hotkeylar va Omarchy menyusi (`Super + Space`) orqali boshqariladi. Lekin uni `omarchy` CLI orqali ham boshqarishingiz mumkin. Bu, ayniqsa, AI agent siz bilan moslashuv yoki konfiguratsiya ustida ishlayotganda foydali.

CLI menyu orqali ham, boshqacha ham ishlatiladigan barcha ichki vositalarga kira oladi. Mavjud boʻlgan hamma narsani terminalda `omarchy` ni ishga tushirish orqali koʻrishingiz mumkin.

U taxminan mana bunday koʻrinadi:

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

Va har bir guruhga chuqurroq kirishingiz mumkin:

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

Har bir buyruq `--help` ni ham oladi, siz butun guruhdan (`omarchy capture --help`) yoki bitta buyruqdan (`omarchy capture screenshot --help`) soʻrasangiz ham.

### Menyuni terminaldan ochish

Omarchy menyusi ham skriptlashtirilishi mumkin, bu oʻz tugmalar bogʻlanishlaringiz uchun qulay. `omarchy menu` uni ildizda ochadi va siz nom berish orqali daraxtning istalgan nuqtasiga toʻgʻridan-toʻgʻri sakrashingiz mumkin: `omarchy menu summon style.theme` toʻgʻridan-toʻgʻri mavzu tanlovchiga boradi, `omarchy menu toggle system` tizim menyusini ochadi va agar u allaqachon ochiq boʻlsa yana yopadi va `omarchy menu close` uni yigʻishtiradi.
