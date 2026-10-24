# CLI Omarchy

Omarchy обычно управляется через сочетания клавиш и меню Omarchy (`Super + Space`). Но ей также можно управлять через CLI `omarchy`. Это особенно полезно, когда ИИ-агент работает с вами над настройкой или конфигурацией.

CLI имеет доступ ко всем внутренним инструментам, используемым как через меню, так и иным образом. Всё доступное можно увидеть, выполнив `omarchy` в терминале.

Это выглядит примерно так:

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

И можно углубиться в каждую группу:

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

Каждая команда также принимает `--help`, спрашиваете ли вы целую группу (`omarchy capture --help`) или одну команду (`omarchy capture screenshot --help`).

### Открытие меню из терминала

Меню Omarchy также поддаётся скриптингу, что удобно для ваших собственных привязок клавиш. `omarchy menu` открывает его в корне, а вы можете перейти прямо к любой точке дерева, назвав её: `omarchy menu summon style.theme` переходит прямо к выбору темы, `omarchy menu toggle system` открывает системное меню и снова закрывает его, если оно уже открыто, а `omarchy menu close` убирает его.
