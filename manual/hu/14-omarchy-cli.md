# Omarchy CLI

Az Omarchy általában gyorsbillentyűkkel és az Omarchy menüvel (`Super + Space`) vezérelhető. De az `omarchy` CLI-n keresztül is vezérelheted. Ez különösen hasznos, amikor egy AI ügynök segít neked a testreszabásban vagy a konfigurációban.

A CLI hozzáfér minden belső eszközhöz, amelyet a menün keresztül és egyéb módon is használnak. Mindent megnézhetsz, ami elérhető, ha futtatod az `omarchy` parancsot a terminálban.

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

És minden csoportba mélyebben is beleáshatod magad:

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

Minden parancs elfogadja a `--help` kapcsolót is, akár egy egész csoportot kérdezel le (`omarchy capture --help`), akár egyetlen parancsot (`omarchy capture screenshot --help`).

### A menü megnyitása a terminálból

Az Omarchy menü szkriptelhető is, ami jól jön a saját billentyűkiosztásaidhoz. Az `omarchy menu` a gyökérnél nyitja meg, és közvetlenül a fa bármely pontjára ugorhatsz, ha megnevezed: az `omarchy menu summon appearance.theme` egyenesen a témaválasztóhoz visz, az `omarchy menu toggle system` megnyitja a rendszermenüt, és újra bezárja, ha már nyitva van, az `omarchy menu close` pedig elteszi.
