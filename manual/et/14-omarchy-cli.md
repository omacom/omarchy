# Omarchy CLI

Omarchyt juhitakse tavaliselt kiirklahvide ja Omarchy menüü kaudu (`Super + Space`). Kuid saad seda juhtida ka `omarchy` CLI kaudu. See on eriti abiks, kui sul on AI agent, kes töötab sinuga kohandamise või seadistamise kallal.

CLI-l on juurdepääs kogu sisemisele tööriistakastile, mida kasutatakse nii menüü kui ka muul viisil. Saad näha kõike saadaolevat, käivitades terminalis `omarchy`.

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

Ja saad igasse rühma sügavamale sukelduda:

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

Iga käsk võtab ka `--help`, olenemata sellest, kas küsid tervet rühma (`omarchy capture --help`) või ühte käsku (`omarchy capture screenshot --help`).

### Menüü avamine terminalist

Omarchy menüü on samuti skriptitav, mis on sinu enda klahviseoste jaoks käepärane. `omarchy menu` avab selle juure juures ja saad hüpata otse puu mis tahes punkti, nimetades selle: `omarchy menu summon style.theme` läheb otse teemavalija juurde, `omarchy menu toggle system` avab süsteemi menüü ja sulgeb selle uuesti, kui see juba üleval on, ja `omarchy menu close` paneb selle ära.
