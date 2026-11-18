# Omarchy CLI

Omarchy обычно управляется через горячие клавиши и меню Omarchy (`Super + Space`). Но им также можно управлять через CLI `omarchy`. Это особенно полезно, когда вы работаете с AI-агентом над кастомизацией или настройкой.

CLI имеет доступ ко всем внутренним инструментам, которые используются как через меню, так и иным образом. Вы можете увидеть всё доступное, выполнив `omarchy` в терминале.

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

Для диагностики запустите напрямую `omarchy-debug --no-sudo --print`. Он выводит диагностику и записывает `/tmp/omarchy-debug.log`, не запрашивая sudo, в том числе при установке пакетов, где `omarchy debug` может завершиться ошибкой "Unknown Omarchy command".

И вы можете углубиться в каждую группу:

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

Каждая команда также принимает `--help`, независимо от того, запрашиваете ли вы целую группу (`omarchy capture --help`) или отдельную команду (`omarchy capture screenshot --help`).

### Открытие меню из терминала

Меню Omarchy также можно вызывать из скриптов, что удобно для ваших собственных сочетаний клавиш. `omarchy menu` открывает его в корне, и вы можете перейти сразу к любому пункту дерева, назвав его: `omarchy menu summon appearance.theme` открывает прямо выбор темы, `omarchy menu toggle system` открывает системное меню и снова закрывает его, если оно уже открыто, а `omarchy menu close` убирает его.
