# Omarchy CLI

Omarchy обикновено се управлява чрез клавишните комбинации и менюто на Omarchy (`Super + Space`). Но можеш да го управляваш и чрез CLI-то `omarchy`. Това е особено полезно, когато AI агент работи с теб върху персонализиране или конфигурация.

CLI-то има достъп до всички вътрешни инструменти, които се използват както чрез менюто, така и иначе. Можеш да видиш всичко налично, като изпълниш `omarchy` в терминала.

Изглежда нещо подобно:

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

И можеш да навлезеш по-дълбоко във всяка група:

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

Всяка команда също приема `--help`, независимо дали питаш цяла група (`omarchy capture --help`) или единична команда (`omarchy capture screenshot --help`).

### Отваряне на менюто от терминала

Менюто на Omarchy също може да се скриптира, което е удобно за собствените ти клавишни комбинации. `omarchy menu` го отваря в корена и можеш да скочиш директно до всяка точка в дървото, като я назовеш: `omarchy menu summon style.theme` отива директно на селектора за теми, `omarchy menu toggle system` отваря системното меню и го затваря отново, ако вече е отворено, а `omarchy menu close` го прибира.
