# Omarchy CLI

Omarchy обычно управляется через горячие клавиши и меню Omarchy (`Super + Space`). Но управлять им можно и через CLI `omarchy`. Это особенно полезно, когда вы вместе с AI-агентом работаете над кастомизацией или настройкой.

У CLI есть доступ ко всему внутреннему инструментарию, который используется и через меню, и помимо него. Посмотреть всё, что доступно, можно, запустив `omarchy` в терминале.

Выглядит это примерно так:

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

И по каждой группе можно копнуть глубже:

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

`--help` есть и у каждой команды, будь то целая группа (`omarchy capture --help`) или отдельная команда (`omarchy capture screenshot --help`).

### Открытие меню из терминала

Меню Omarchy тоже можно скриптовать, что удобно для ваших собственных сочетаний клавиш. `omarchy menu` открывает его в корне, а назвав точку дерева, можно сразу перейти прямо к ней: `omarchy menu summon appearance.theme` сразу открывает выбор темы, `omarchy menu toggle system` открывает системное меню и снова закрывает его, если оно уже открыто, а `omarchy menu close` убирает его.
