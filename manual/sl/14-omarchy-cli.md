# Omarchy CLI

Omarchy se običajno upravlja z bližnjičnimi tipkami in menijem Omarchy (`Super + Space`). Upravljate pa ga lahko tudi prek CLI `omarchy`. To je še posebej priročno, kadar pri prilagajanju ali konfiguriranju sodelujete z agentom umetne inteligence.

CLI ima dostop do vseh notranjih orodij, ki se uporabljajo tako prek menija kot tudi drugače. Vse, kar je na voljo, si lahko ogledate tako, da v terminalu zaženete `omarchy`.

Videti je približno takole:

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
  ascii          Text drawn as ASCII art
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

Za diagnostiko neposredno zaženite `omarchy-debug --no-sudo --print`. Izpiše diagnostiko in zapiše `/tmp/omarchy-debug.log`, ne da bi zahteval sudo, tudi pri namestitvah paketov, pri katerih lahko `omarchy debug` odpove s sporočilom "Unknown Omarchy command".

V vsako skupino pa se lahko poglobite še bolj:

```
~ ❯ omarchy capture
Capture commands — Screenshots and screen recording:
  omarchy capture qr                                                                                                                                                                                                       Decode a QR code from a screenshot region
  omarchy capture screenrecording [--fullscreen] [--with-desktop-audio] [--with-microphone-audio] [--with-webcam] [--webcam-device=<device>] [--webcam-size=<small|medium|large>] [--resolution=<size>] [--stop-recording] [--status]  Start or stop screen recording
  omarchy capture screenrecording with webcam                                                                                                                                                                              Pick a webcam and start a screen recording with it
  omarchy capture screenshot [smart|region|windows|fullscreen|scroll] [copy|save]                                                                                                                                          Take a screenshot
  omarchy capture text                                                                                                                                                                                                     Extract text from a screenshot region with OCR
  omarchy capture webcam resize <smaller|larger|reset|small|medium|large>                                                                                                                                                  Resize the active webcam recording overlay
```

Vsak ukaz sprejme tudi `--help`, ne glede na to, ali vprašate celotno skupino (`omarchy capture --help`) ali en sam ukaz (`omarchy capture screenshot --help`).

### Odpiranje menija iz terminala

Meni Omarchy je mogoče upravljati tudi s skriptami, kar pride prav pri vaših lastnih vezavah tipk. `omarchy menu` ga odpre v korenu, neposredno na katero koli točko v drevesu pa lahko skočite tako, da jo poimenujete: `omarchy menu summon appearance.theme` vas pripelje naravnost do izbirnika tem, `omarchy menu toggle system` odpre sistemski meni in ga znova zapre, če je že odprt, `omarchy menu close` pa ga pospravi.
