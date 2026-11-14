# Omarchy CLI

Omarchy зазвичай керують за допомогою гарячих клавіш і меню Omarchy (`Super + Space`). Але керувати нею можна також через CLI `omarchy`. Це особливо корисно, коли агент ШІ працює з вами над кастомізацією чи конфігурацією.

CLI має доступ до всіх внутрішніх інструментів, які використовуються як через меню, так і в інший спосіб. Ви можете побачити все доступне, запустивши `omarchy` у терміналі.

Виглядає це приблизно так:

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

І ви можете заглибитися в кожну групу:

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

Кожна команда також приймає `--help`, незалежно від того, чи запитуєте ви цілу групу (`omarchy capture --help`), чи окрему команду (`omarchy capture screenshot --help`).

### Відкриття меню з термінала

Меню Omarchy також можна скриптувати, що зручно для ваших власних прив'язок клавіш. `omarchy menu` відкриває його в корені, і ви можете переходити прямо до будь-якої точки дерева, назвавши її: `omarchy menu summon appearance.theme` веде прямо до вибору теми, `omarchy menu toggle system` відкриває системне меню і знову закриває його, якщо воно вже відкрите, а `omarchy menu close` прибирає його.
