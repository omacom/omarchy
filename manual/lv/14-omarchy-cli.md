# Omarchy CLI

Omarchy parasti kontrolē, izmantojot karstās taustiņu kombinācijas un Omarchy izvēlni (`Super + Space`). Bet tu vari to kontrolēt arī, izmantojot `omarchy` CLI. Tas ir īpaši noderīgi, kad tev ir AI aģents, kas strādā ar tevi pie pielāgošanas vai konfigurēšanas.

CLI ir piekļuve visiem iekšējiem rīkiem, ko izmanto gan caur izvēlni, gan citādi. Tu vari redzēt visu, kas ir pieejams, palaižot `omarchy` terminālī.

Tas izskatās apmēram šādi:

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

Un tu vari iedziļināties katrā grupā:

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

Katru komandu var izsaukt arī ar `--help`, neatkarīgi no tā, vai tu jautā visai grupai (`omarchy capture --help`) vai vienai komandai (`omarchy capture screenshot --help`).

### Izvēlnes atvēršana no termināla

Omarchy izvēlne ir arī skriptējama, kas ir ērti tavām taustiņu piesaistēm. `omarchy menu` atver to saknē, un tu vari lekt tieši uz jebkuru punktu kokā, nosaucot to: `omarchy menu summon style.theme` dodas tieši uz tēmu atlasītāju, `omarchy menu toggle system` atver sistēmas izvēlni un atkal to aizver, ja tā jau ir augšā, un `omarchy menu close` to novāc.
