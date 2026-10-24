# CLI Omarchy

Omarchy se običajno nadzira prek bližnjic in menija Omarchy (`Super + Space`). Lahko pa ga nadzirate tudi prek CLI `omarchy`. To je še posebej koristno, kadar vam agent AI pomaga pri prilagajanju ali konfiguraciji.

CLI ima dostop do vsega notranjega orodjarjenja, ki se uporablja tako prek menija kot sicer. Vse, kar je na voljo, si lahko ogledate tako, da v terminalu zaženete `omarchy`.

Videti je nekako takole:

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

V vsako skupino se lahko poglobite:

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

Vsak ukaz sprejme tudi `--help`, ne glede na to, ali prosite za celotno skupino (`omarchy capture --help`) ali en sam ukaz (`omarchy capture screenshot --help`).

### Odpiranje menija iz terminala

Meni Omarchy je mogoče skriptati tudi, kar je priročno za lastne vezave tipk. `omarchy menu` ga odpre v korenu, skočite pa lahko naravnost na kateri koli točki drevesa, če ga poimenujete: `omarchy menu summon style.theme` gre naravnost do izbirnika teme, `omarchy menu toggle system` odpre sistemski meni in ga znova zapre, če je že odprt, `omarchy menu close` pa ga spravi stran.
