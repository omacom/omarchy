# CLI Omarchy

Mar as trice, thèid Omarchy a stiùireadh leis na iuchraichean-grad agus le clàr-taice Omarchy (`Super + Space`). Ach 's urrainn dhut a stiùireadh leis a' CLI `omarchy` cuideachd. Tha seo gu sònraichte feumail nuair a bhios àidseant AI ag obair còmhla riut air gnàthachadh no rèiteachadh.

Tha cothrom aig a' CLI air na h-innealan inntearnail uile a thèid a chleachdadh sa chlàr-taice agus ann an àiteachan eile. Chì thu a h-uile rud a tha ri fhaighinn ma ruitheas tu `omarchy` san tèirmineal.

Seallaidh e rudeigin coltach ri seo:

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

Agus 's urrainn dhut a dhol nas doimhne air gach buidheann:

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

Gabhaidh gach àithne `--help` cuideachd, co-dhiù a dh'fhaighnicheas tu de bhuidheann slàn (`omarchy capture --help`) no de dh'aon àithne (`omarchy capture screenshot --help`).

### A' fosgladh a' chlàir-thaice on tèirmineal

Gabhaidh clàr-taice Omarchy sgriobtadh cuideachd, rud a tha feumail airson nan ceanglaichean iuchrach agad fhèin. Fosglaidh `omarchy menu` e aig a' bhun, agus 's urrainn dhut leum dìreach gu puing sam bith sa chraobh le bhith ga h-ainmeachadh: thèid `omarchy menu summon appearance.theme` dìreach gu taghadair nan ùrlar, fosglaidh `omarchy menu toggle system` clàr-taice an t-siostaim agus dùinidh e a-rithist e ma tha e fosgailte mu thràth, agus cuiridh `omarchy menu close` air falbh e.
