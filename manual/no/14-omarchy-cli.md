# Omarchy CLI

Omarchy styres vanligvis via hurtigtastene og Omarchy-menyen (`Super + Space`). Men du kan også styre den via `omarchy`-CLI-en. Dette er spesielt nyttig når du lar en AI-agent jobbe sammen med deg med tilpasning eller konfigurering.

CLI-en har tilgang til alle de interne verktøyene som brukes både via menyen og ellers. Du kan se alt som er tilgjengelig ved å kjøre `omarchy` i terminalen.

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
  omarchy-debug               Print debugging information

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
  ...
```

For diagnostikk kjører du `omarchy-debug --no-sudo --print` direkte. Den skriver ut diagnostikk og skriver `/tmp/omarchy-debug.log` uten å be om sudo, også ved pakkeinstallasjoner der `omarchy debug` kan feile med "Unknown Omarchy command".

Og du kan gå dypere inn i hver gruppe:

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

Hver kommando tar `--help` også, enten du spør en hel gruppe (`omarchy capture --help`) eller en enkeltkommando (`omarchy capture screenshot --help`).

### Åpne menyen fra terminalen

Omarchy-menyen kan også styres med skript, noe som er hendig for dine egne tastatursnarveier. `omarchy menu` åpner den på rotnivå, og du kan hoppe rett til ethvert punkt i treet ved å navngi det: `omarchy menu summon appearance.theme` går rett til temavelgeren, `omarchy menu toggle system` åpner systemmenyen og lukker den igjen hvis den allerede er oppe, og `omarchy menu close` legger den bort.
