# Omarchy CLI

Omarchy paprastai valdoma per sparčiuosius klavišus ir Omarchy meniu (`Super + Space`). Bet taip pat galite ją valdyti per `omarchy` CLI. Tai ypač naudinga, kai AI agentas dirba su jumis prie pritaikymo ar konfigūracijos.

CLI turi prieigą prie visų vidinių įrankių, kurie naudojami tiek per meniu, tiek kitaip. Viską, kas prieinama, galite pamatyti terminale paleisdami `omarchy`.

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

Ir galite gilintis į kiekvieną grupę:

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

Kiekviena komanda taip pat priima `--help`, nesvarbu, ar klausiate visos grupės (`omarchy capture --help`), ar vienos komandos (`omarchy capture screenshot --help`).

### Meniu atidarymas iš terminalo

Omarchy meniu taip pat galima užprogramuoti scenarijais, o tai patogu jūsų pačių klavišų susiejimams. `omarchy menu` atidaro jį šaknyje, ir galite šokti tiesiai į bet kurį medžio tašką jį įvardydami: `omarchy menu summon style.theme` eina tiesiai į temų parinkiklį, `omarchy menu toggle system` atidaro sistemos meniu ir vėl jį uždaro, jei jis jau atidarytas, o `omarchy menu close` jį padeda.
