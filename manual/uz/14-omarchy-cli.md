# Omarchy CLI

Omarchy odatda tezkor tugmalar va Omarchy menyusi (`Super + Space`) orqali boshqariladi. Lekin uni `omarchy` CLI orqali ham boshqarishingiz mumkin. Bu, ayniqsa, moslashtirish yoki sozlashda AI agent siz bilan birga ishlayotganida juda qulay.

CLI menyu orqali ham, boshqa yoʻllar bilan ham ishlatiladigan barcha ichki vositalarga kira oladi. Mavjud boʻlgan hamma narsani terminalda `omarchy` ni ishga tushirib koʻrishingiz mumkin.

U taxminan shunday koʻrinadi:

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

Va har bir guruhni yanada chuqurroq oʻrganishingiz mumkin:

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

Har bir buyruq `--help` ni ham qabul qiladi, xoh butun guruhni soʻrang (`omarchy capture --help`), xoh bitta buyruqni (`omarchy capture screenshot --help`).

### Menyuni terminaldan ochish

Omarchy menyusini skript orqali ham boshqarish mumkin, bu oʻz tugma birikmalaringiz uchun qulay. `omarchy menu` uni ildizdan ochadi va siz nomini aytib, daraxtning istalgan nuqtasiga toʻgʻridan-toʻgʻri oʻtishingiz mumkin: `omarchy menu summon appearance.theme` toʻgʻridan-toʻgʻri tema tanlagichga oʻtadi, `omarchy menu toggle system` tizim menyusini ochadi va agar u allaqachon ochiq boʻlsa, uni yana yopadi, `omarchy menu close` esa uni yopib qoʻyadi.
