# Omarchy CLI

Omarchy обикновено се управлява чрез клавишните комбинации и менюто на Omarchy (`Super + Space`). Но можете да го управлявате и чрез `omarchy` CLI. Това е особено полезно, когато AI агент работи с вас по персонализиране или конфигуриране.

CLI има достъп до всички вътрешни инструменти, които се използват както чрез менюто, така и по друг начин. Можете да видите всичко налично, като изпълните `omarchy` в терминала.

Изглежда приблизително така:

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

И можете да навлезете по-дълбоко във всяка група:

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

Всяка команда приема и `--help`, независимо дали питате цяла група (`omarchy capture --help`) или отделна команда (`omarchy capture screenshot --help`).

### Отваряне на менюто от терминала

Менюто на Omarchy също може да се скриптира, което е удобно за вашите собствени клавишни комбинации. `omarchy menu` го отваря в основата, а можете да прескочите директно до всяка точка от дървото, като я назовете: `omarchy menu summon appearance.theme` отива директно до избора на тема, `omarchy menu toggle system` отваря системното меню и го затваря отново, ако вече е отворено, а `omarchy menu close` го прибира.
