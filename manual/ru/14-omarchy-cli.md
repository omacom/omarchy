# Omarchy CLI

Обычно Omarchy управляют с помощью горячих клавиш и меню Omarchy (`Super + Space`). Но управлять им можно и через CLI `omarchy`. Это особенно полезно, когда ИИ-агент помогает вам с кастомизацией или настройкой.

У CLI есть доступ ко всем внутренним инструментам, которые используются как через меню, так и в других местах. Всё доступное можно посмотреть, выполнив `omarchy` в терминале.

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

Для диагностики запускайте `omarchy-debug --no-sudo --print` напрямую. Он выводит диагностику и записывает `/tmp/omarchy-debug.log`, не запрашивая sudo, в том числе при установке пакетов, где `omarchy debug` может завершиться ошибкой "Unknown Omarchy command".

И можно углубиться в каждую группу:

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

У каждой команды есть и `--help` — будь то для всей группы (`omarchy capture --help`) или для отдельной команды (`omarchy capture screenshot --help`).

### Открытие меню из терминала

Меню Omarchy тоже можно скриптовать, что удобно для собственных сочетаний клавиш. `omarchy menu` открывает его в корне, а назвав нужный пункт, можно сразу перейти к любому месту в дереве: `omarchy menu summon appearance.theme` сразу открывает выбор темы, `omarchy menu toggle system` открывает системное меню и снова закрывает его, если оно уже открыто, а `omarchy menu close` его убирает.
