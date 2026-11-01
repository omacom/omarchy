# Omarchy CLI

Omarchy styres normalt via genvejstasterne og Omarchy-menuen (`Super + Space`). Men du kan også styre det via `omarchy` CLI'en. Det er særligt nyttigt, når du har en AI-agent til at arbejde sammen med dig om tilpasning eller konfiguration.

CLI'en har adgang til alle de interne værktøjer, der bruges både via menuen og på anden vis. Du kan se alt, hvad der er tilgængeligt, ved at køre `omarchy` i terminalen.

Det ser nogenlunde sådan her ud:

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

Og du kan dykke dybere ned i hver gruppe:

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

Alle kommandoer tager også `--help`, uanset om du spørger en hel gruppe (`omarchy capture --help`) eller en enkelt kommando (`omarchy capture screenshot --help`).

### Åbning af menuen fra terminalen

Omarchy-menuen kan også scriptes, hvilket er praktisk til dine egne genvejstaster. `omarchy menu` åbner den ved roden, og du kan springe direkte til ethvert punkt i træet ved at navngive det: `omarchy menu summon appearance.theme` går direkte til temavælgeren, `omarchy menu toggle system` åbner systemmenuen og lukker den igen, hvis den allerede er fremme, og `omarchy menu close` gemmer den væk.
