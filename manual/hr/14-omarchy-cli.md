# Omarchy CLI

Omarchyjem se obično upravlja putem tipkovničkih prečaca i Omarchy izbornika (`Super + Space`). No njime možete upravljati i putem `omarchy` CLI-ja. To je posebno korisno kada s vama na prilagodbi ili konfiguraciji radi AI agent.

CLI ima pristup svim internim alatima koji se koriste i putem izbornika i inače. Sve što je dostupno možete vidjeti pokretanjem naredbe `omarchy` u terminalu.

Izgleda otprilike ovako:

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

A možete i dublje zaroniti u svaku grupu:

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

Svaka naredba prima i `--help`, bilo da pitate cijelu grupu (`omarchy capture --help`) ili jednu naredbu (`omarchy capture screenshot --help`).

### Otvaranje izbornika iz terminala

Omarchy izbornik može se i skriptirati, što je zgodno za vlastite tipkovničke prečace. `omarchy menu` otvara ga na korijenu, a možete i skočiti izravno na bilo koju točku u stablu tako da je imenujete: `omarchy menu summon appearance.theme` ide izravno na birač tema, `omarchy menu toggle system` otvara izbornik sustava i ponovno ga zatvara ako je već otvoren, a `omarchy menu close` ga sklanja.
