# Omarchy CLI

Az Omarchy-t általában a gyorsbillentyűkkel és az Omarchy menüvel (`Super + Space`) lehet vezérelni. De a `omarchy` CLI-n keresztül is vezérelheted. Ez különösen hasznos, amikor egy AI-ügynök dolgozik veled együtt a testreszabáson vagy a konfiguráción.

A CLI hozzáfér minden belső eszközhöz, amelyet a menün keresztül és egyébként is használnak. Mindent megnézhetsz, ami elérhető, ha a terminálban futtatod az `omarchy` parancsot.

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

Diagnosztikához futtasd közvetlenül az `omarchy-debug --no-sudo --print` parancsot. Kiírja a diagnosztikát, és sudo kérése nélkül ír a `/tmp/omarchy-debug.log` fájlba, beleértve azokat a csomagtelepítéseket is, ahol az `omarchy debug` az "Unknown Omarchy command" hibával elszállhat.

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

Minden parancs elfogadja a `--help` kapcsolót is, akár egy egész csoportról kérdezel (`omarchy capture --help`), akár egyetlen parancsról (`omarchy capture screenshot --help`).

### A menü megnyitása a terminálból

Az Omarchy menü szintén szkriptelhető, ami hasznos a saját billentyűparancsaidhoz. Az `omarchy menu` a gyökérnél nyitja meg, és közvetlenül a fa bármely pontjára ugorhatsz, ha megnevezed: az `omarchy menu summon appearance.theme` egyenesen a témaválasztóhoz visz, az `omarchy menu toggle system` megnyitja a rendszermenüt, és ha már nyitva van, újra be is zárja, az `omarchy menu close` pedig eltünteti.
