# Omarchy CLI

Omarchyä käytetään yleensä pikanäppäimillä ja Omarchy-valikolla (`Super + Space`). Mutta voit hallita sitä myös `omarchy` CLI:n kautta. Tämä on erityisen hyödyllistä, kun työskentelet tekoälyagentin kanssa mukautusten tai määritysten parissa.

CLI:llä on pääsy kaikkiin sisäisiin työkaluihin, joita käytetään sekä valikon kautta että muuten. Näet kaiken saatavilla olevan ajamalla `omarchy` terminaalissa.

Se näyttää suunnilleen tältä:

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

Ja jokaiseen ryhmään voi sukeltaa syvemmälle:

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

Jokainen komento hyväksyy myös `--help`-vivun, kysyitpä sitä koko ryhmältä (`omarchy capture --help`) tai yksittäiseltä komennolta (`omarchy capture screenshot --help`).

### Valikon avaaminen terminaalista

Omarchy-valikko on myös skriptattavissa, mikä on kätevää omia näppäinsidoksiasi varten. `omarchy menu` avaa sen juuresta, ja voit hypätä suoraan mihin tahansa kohtaan puussa nimeämällä sen: `omarchy menu summon appearance.theme` menee suoraan teeman valitsimeen, `omarchy menu toggle system` avaa järjestelmävalikon ja sulkee sen uudelleen, jos se on jo auki, ja `omarchy menu close` sulkee sen.
