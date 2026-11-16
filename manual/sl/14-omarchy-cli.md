# Omarchy CLI

Omarchy se običajno upravlja z bližnjicami na tipkovnici in menijem Omarchy (`Super + Space`). Lahko pa ga upravljate tudi prek CLI `omarchy`. To je še posebej priročno, ko vam agent z umetno inteligenco pomaga pri prilagajanju ali konfiguraciji.

CLI ima dostop do vseh notranjih orodij, ki se uporabljajo prek menija in drugje. Vse, kar je na voljo, si lahko ogledate tako, da v terminalu zaženete `omarchy`.

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

Za diagnostiko neposredno zaženite `omarchy-debug --no-sudo --print`. Izpiše diagnostiko in zapiše `/tmp/omarchy-debug.log`, ne da bi zahteval sudo, tudi pri namestitvah paketov, kjer lahko `omarchy debug` odpove z napako "Unknown Omarchy command".

V vsako skupino pa se lahko poglobite še bolj:

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

Vsak ukaz sprejme tudi `--help`, ne glede na to, ali vprašate celo skupino (`omarchy capture --help`) ali en sam ukaz (`omarchy capture screenshot --help`).

### Odpiranje menija iz terminala

Tudi meni Omarchy je mogoče upravljati s skripti, kar je priročno za vaše lastne bližnjice na tipkovnici. `omarchy menu` ga odpre v korenu, z imenovanjem pa lahko skočite naravnost na katero koli točko v drevesu: `omarchy menu summon appearance.theme` gre naravnost v izbirnik tem, `omarchy menu toggle system` odpre sistemski meni in ga znova zapre, če je že odprt, `omarchy menu close` pa ga pospravi.
