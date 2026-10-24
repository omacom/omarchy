# Omarchy CLI

Az Omarchyt általában a billentyűparancsokkal és az Omarchy menüvel (`Super + Space`) vezérlik. De az `omarchy` CLI-n keresztül is vezérelheted. Ez különösen hasznos, amikor egy AI-agenttel dolgozol együtt testreszabási vagy konfigurációs feladatokon.

A CLI hozzáfér az összes belső eszközhöz, amelyet mind a menün keresztül, mind máshol használnak. Mindent láthatsz, ami rendelkezésre áll, ha terminálban futtatod az `omarchy` parancsot.

Valahogy így néz ki:

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

És minden csoportban mélyebbre merülhetsz:

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

Minden parancs elfogadja a `--help` kapcsolót is, akár egy egész csoporttól kérdezed (`omarchy capture --help`), akár egyetlen parancstól (`omarchy capture screenshot --help`).

### A menü megnyitása a terminálból

Az Omarchy menü szkriptelhető is, ami jól jön a saját billentyűhozzárendeléseidhez. Az `omarchy menu` a gyökérnél nyitja meg, és a fában egyenesen bármely pontra ugorhatsz, ha megnevezed: az `omarchy menu summon style.theme` egyenesen a témaválasztóhoz megy, az `omarchy menu toggle system` megnyitja a rendszermenüt, és ismét bezárja, ha már nyitva van, az `omarchy menu close` pedig elteszi.
