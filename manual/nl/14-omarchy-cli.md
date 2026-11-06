# Omarchy CLI

Omarchy wordt meestal bediend via de sneltoetsen en het Omarchy-menu (`Super + Space`). Maar je kunt het ook bedienen via de `omarchy` CLI. Dit is vooral handig wanneer je een AI-agent met je laat meewerken aan aanpassingen of configuratie.

De CLI heeft toegang tot alle interne tooling die zowel via het menu als anderszins wordt gebruikt. Je kunt alles zien wat beschikbaar is door `omarchy` in de terminal uit te voeren.

Het ziet er ongeveer zo uit:

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

En je kunt dieper in elke groep duiken:

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

Elke opdracht accepteert ook `--help`, of je nu een hele groep vraagt (`omarchy capture --help`) of een enkele opdracht (`omarchy capture screenshot --help`).

### Het menu openen vanuit de terminal

Het Omarchy-menu is ook scriptbaar, wat handig is voor je eigen toetsbindingen. `omarchy menu` opent het bij de root, en je kunt rechtstreeks naar elk punt in de boom springen door het te benoemen: `omarchy menu summon appearance.theme` gaat direct naar de themakiezer, `omarchy menu toggle system` opent het systeemmenu en sluit het weer als het al openstaat, en `omarchy menu close` bergt het weg.
