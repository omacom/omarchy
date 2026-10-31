# Omarchy CLI

Omarchy се обично контролише преко пречица на тастатури и Omarchy менија (`Super + Space`). Али њиме можете да управљате и преко `omarchy` CLI-ја. Ово је нарочито корисно када са вама на прилагођавању или конфигурисању ради AI агент.

CLI има приступ свим интерним алатима који се користе и преко менија и иначе. Све што је доступно можете да видите покретањем команде `omarchy` у терминалу.

Изгледа отприлике овако:

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

И можете да зароните дубље у сваку групу:

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

Свака команда прихвата и `--help`, било да питате целу групу (`omarchy capture --help`) или једну команду (`omarchy capture screenshot --help`).

### Отварање менија из терминала

Omarchy мени такође може да се контролише из скрипти, што је згодно за ваше сопствене пречице на тастатури. `omarchy menu` га отвара у корену, а можете да скочите право на било коју тачку у стаблу тако што ћете је навести по имену: `omarchy menu summon appearance.theme` иде право на бирач тема, `omarchy menu toggle system` отвара системски мени и поново га затвара ако је већ отворен, а `omarchy menu close` га склања.
