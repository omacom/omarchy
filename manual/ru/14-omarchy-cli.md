# Omarchy CLI

Omarchy обычно рулится хоткеями и меню Omarchy (`Super + Space`). Но рулить можно и через CLI `omarchy`. Особенно удобно, когда рядом AI-агент помогает с кастомизацией или конфигами.

У CLI доступ ко всей внутренней тулзе — и через меню, и иначе. Что вообще есть — покажет запуск `omarchy` в терминале.

Выглядит примерно так:

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
  agent          AI coding agent usage data
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

А в каждую группу можно нырнуть глубже:

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

Каждый команде — свой `--help`: хоть группе целиком (`omarchy capture --help`), хоть одной команде (`omarchy capture screenshot --help`).

### Открыть меню из терминала

Меню Omarchy ещё и скриптуется — удобно для своих хоткеев. `omarchy menu` открывает в корне, а прыгнуть сразу в точку дерева можно по имени: `omarchy menu summon style.theme` ведёт прямиком в выбор темы, `omarchy menu toggle system` открывает системное меню и закрывает обратно, если уже открыто, а `omarchy menu close` убирает его.
