# Omarchy CLI

Omarchyt juhitakse tavaliselt kiirklahvide ja Omarchy menüü (`Super + Space`) kaudu. Aga seda saab juhtida ka `omarchy` CLI kaudu. See on eriti kasulik, kui lased AI agendil endaga koos kohandusi või seadistusi teha.

CLI-l on juurdepääs kõigile sisemistele tööriistadele, mida kasutatakse nii menüü kaudu kui ka muul viisil. Kõike, mis on saadaval, näed, kui käivitad terminalis `omarchy`.

See näeb välja umbes nii:

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

Ja iga rühma saad lähemalt uurida:

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

Iga käsk toetab ka `--help` valikut, olenemata sellest, kas küsid kogu rühma (`omarchy capture --help`) või üksikut käsku (`omarchy capture screenshot --help`).

### Menüü avamine terminalist

Ka Omarchy menüü on skriptitav, mis on mugav oma klahviseoste loomiseks. `omarchy menu` avab selle juurtasemel ja saad nime järgi hüpata otse ükskõik millisesse kohta puus: `omarchy menu summon appearance.theme` läheb otse teemavalijasse, `omarchy menu toggle system` avab süsteemimenüü ja sulgeb selle uuesti, kui see on juba avatud, ning `omarchy menu close` peidab selle ära.
