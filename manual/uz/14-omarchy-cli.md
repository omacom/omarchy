# Omarchy CLI

Omarchy odatda tezkor tugmalar va Omarchy menyusi (`Super + Space`) orqali boshqariladi. Lekin uni `omarchy` CLI orqali ham boshqarishingiz mumkin. Bu, ayniqsa, moslashtirish yoki konfiguratsiya ustida AI agent bilan birga ishlayotganingizda juda qo'l keladi.

CLI menyu orqali ham, boshqa yo'llar bilan ham ishlatiladigan barcha ichki vositalarga kira oladi. Mavjud hamma narsani terminalda `omarchy` ni ishga tushirib ko'rishingiz mumkin.

U taxminan shunday ko'rinadi:

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

Diagnostika uchun to'g'ridan-to'g'ri `omarchy-debug --no-sudo --print` ni ishga tushiring. U sudo so'ramasdan diagnostikani chop etadi va `/tmp/omarchy-debug.log` ga yozadi, jumladan `omarchy debug` "Unknown Omarchy command" xatosi bilan muvaffaqiyatsiz bo'lishi mumkin bo'lgan paket o'rnatishlarida ham.

Va har bir guruhga chuqurroq kirishingiz ham mumkin:

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

Har bir buyruq `--help` ni ham qabul qiladi, xoh butun guruhni so'rang (`omarchy capture --help`), xoh bitta buyruqni (`omarchy capture screenshot --help`).

### Menyuni terminaldan ochish

Omarchy menyusini skript orqali ham boshqarish mumkin, bu o'zingizning tugma birikmalaringiz uchun qulay. `omarchy menu` uni ildizdan ochadi, nomini aytish orqali esa daraxtning istalgan nuqtasiga to'g'ridan-to'g'ri sakrashingiz mumkin: `omarchy menu summon appearance.theme` to'g'ridan-to'g'ri mavzu tanlagichga o'tadi, `omarchy menu toggle system` tizim menyusini ochadi va agar u allaqachon ochiq bo'lsa, uni yana yopadi, `omarchy menu close` esa uni yopib qo'yadi.
