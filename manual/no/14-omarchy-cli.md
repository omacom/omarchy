# Omarchy CLI

Omarchy styres vanligvis gjennom hurtigtastene og Omarchy-menyen (`Super + Space`). Men du kan også styre det gjennom `omarchy` CLI. Dette er særlig nyttig når du har en AI-agent som jobber sammen med deg med tilpasning eller konfigurasjon.

CLI-en har tilgang til all intern verktøystøtte som brukes både via menyen og ellers. Du kan se alt som er tilgjengelig ved å kjøre `omarchy` i terminalen.

Det ser omtrent slik ut:

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

Og du kan dykke dypere ned i hver gruppe:

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

Alle kommandoer tar også `--help`, enten du spør en hel gruppe (`omarchy capture --help`) eller en enkeltkommando (`omarchy capture screenshot --help`).

### Åpne menyen fra terminalen

Omarchy-menyen kan også skriptes, noe som er hendig for dine egne tastebindinger. `omarchy menu` åpner den på rotnivå, og du kan hoppe rett til ethvert punkt i treet ved å navngi det: `omarchy menu summon appearance.theme` går rett til temavelgeren, `omarchy menu toggle system` åpner systemmenyen og lukker den igjen hvis den allerede er oppe, og `omarchy menu close` legger den bort.
