# Omarchy CLI

Omarchy sa zvyčajne ovláda pomocou klávesových skratiek a ponuky Omarchy (`Super + Space`). Môžete ho však ovládať aj cez `omarchy` CLI. To je obzvlášť užitočné, keď s vami na prispôsobení alebo konfigurácii spolupracuje AI agent.

CLI má prístup ku všetkým interným nástrojom, ktoré sa používajú cez ponuku aj inak. Všetko, čo je k dispozícii, si môžete pozrieť spustením príkazu `omarchy` v termináli.

Vyzerá to približne takto:

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

A do každej skupiny sa môžete ponoriť hlbšie:

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

Každý príkaz podporuje aj `--help`, či už sa pýtate na celú skupinu (`omarchy capture --help`) alebo na jeden príkaz (`omarchy capture screenshot --help`).

### Otvorenie ponuky z terminálu

Ponuka Omarchy sa dá ovládať aj skriptami, čo sa hodí pre vaše vlastné klávesové skratky. Príkaz `omarchy menu` ju otvorí v koreňovom zobrazení a pomenovaním môžete prejsť rovno na ľubovoľné miesto v strome: `omarchy menu summon appearance.theme` prejde priamo do výberu témy, `omarchy menu toggle system` otvorí systémovú ponuku a znova ju zatvorí, ak už je otvorená, a `omarchy menu close` ju skryje.
