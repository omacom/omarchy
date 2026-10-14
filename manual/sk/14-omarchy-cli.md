# Omarchy CLI

Omarchy sa zvyčajne ovláda cez klávesové skratky a menu Omarchy (`Super + Space`). Ale môžete ho ovládať aj cez `omarchy` CLI. To je obzvlášť užitočné, keď s vami AI agent pracuje na prispôsobení alebo konfigurácii.

CLI má prístup ku všetkým interným nástrojom, ktoré sa používajú cez menu aj inak. Všetko, čo je k dispozícii, uvidíte spustením `omarchy` v termináli.

Vyzerá to asi takto:

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

A môžete sa ponoriť hlbšie do každej skupiny:

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

Každý príkaz tiež prijíma `--help`, či už sa pýtate celej skupiny (`omarchy capture --help`) alebo jedného príkazu (`omarchy capture screenshot --help`).

### Otvorenie menu z terminálu

Menu Omarchy je tiež skriptovateľné, čo je šikovné pre vaše vlastné klávesové väzby. `omarchy menu` ho otvára v koreni a môžete skočiť priamo do ktoréhokoľvek bodu v strome tým, že ho pomenujete: `omarchy menu summon style.theme` ide priamo na výber tém, `omarchy menu toggle system` otvára systémové menu a znova ho zatvorí, ak je už otvorené, a `omarchy menu close` ho odloží.
