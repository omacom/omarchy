# Omarchy CLI

Omarchy paprastai valdoma sparčiaisiais klavišais ir Omarchy meniu (`Super + Space`). Bet ją galite valdyti ir per `omarchy` CLI. Tai ypač naudinga, kai kartu su jumis prie tinkinimo ar konfigūravimo dirba dirbtinio intelekto agentas.

CLI suteikia prieigą prie visų vidinių įrankių, naudojamų ir per meniu, ir kitais būdais. Viską, kas prieinama, galite pamatyti terminale paleidę `omarchy`.

Tai atrodo maždaug taip:

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

Diagnostikai paleiskite tiesiogiai `omarchy-debug --no-sudo --print`. Komanda išveda diagnostiką ir įrašo `/tmp/omarchy-debug.log` neprašydama sudo, taip pat ir diegiant paketus, kai `omarchy debug` gali nepavykti su pranešimu "Unknown Omarchy command".

O kiekvieną grupę galite nagrinėti išsamiau:

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

Kiekviena komanda taip pat priima `--help` – nesvarbu, ar klausiate visos grupės (`omarchy capture --help`), ar vienos komandos (`omarchy capture screenshot --help`).

### Meniu atidarymas iš terminalo

Omarchy meniu taip pat galima valdyti scenarijais, o tai patogu kuriant savo klavišų susiejimus. `omarchy menu` atidaro jį nuo šaknies, o jūs galite iš karto pereiti į bet kurią medžio vietą ją pavadindami: `omarchy menu summon appearance.theme` nukelia tiesiai į temos pasirinkimą, `omarchy menu toggle system` atidaro sistemos meniu ir vėl jį uždaro, jei jis jau atidarytas, o `omarchy menu close` jį paslepia.
