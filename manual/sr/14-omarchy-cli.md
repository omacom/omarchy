# Omarchy CLI

Omarchy се обично контролише преко пречица и Omarchy менија (`Super + Space`). Али можете га контролисати и преко `omarchy` CLI-ја. Ово је посебно корисно кад AI агент ради с вама на прилагођавању или конфигурацији.

CLI има приступ свим интерним алатима који се користе и преко менија и иначе. Све што је доступно можете видети покретањем `omarchy` у терминалу.

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

И можете заронити дубље у сваку групу:

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

Свака команда такође прихвата `--help`, било да питате целу групу (`omarchy capture --help`) или једну команду (`omarchy capture screenshot --help`).

### Отварање менија из терминала

Omarchy мени је такође скриптабилан, што је згодно за ваше сопствене пречице тастатуре. `omarchy menu` га отвара у корену, а можете скочити право на било коју тачку у стаблу именовањем: `omarchy menu summon style.theme` иде право на бирач тема, `omarchy menu toggle system` отвара системски мени и поново га затвара ако је већ отворен, а `omarchy menu close` га склања.
