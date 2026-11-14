# Omarchy CLI

Karaniwang kinokontrol ang Omarchy sa pamamagitan ng mga hotkey at ng menu ng Omarchy (`Super + Space`). Ngunit maaari mo rin itong kontrolin sa pamamagitan ng `omarchy` CLI. Partikular itong nakakatulong kapag may AI agent kang katrabaho sa pag-customize o pag-configure.

May access ang CLI sa lahat ng internal tooling na ginagamit kapwa sa pamamagitan ng menu at sa iba pang paraan. Makikita mo ang lahat ng available sa pagpapatakbo ng `omarchy` sa terminal.

Ganito ang hitsura nito nang halos:

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

At maaari kang sumisid nang mas malalim sa bawat grupo:

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

Tumatanggap din ang bawat command ng `--help`, tanungin mo man ang buong grupo (`omarchy capture --help`) o isang command lang (`omarchy capture screenshot --help`).

### Pagbubukas ng menu mula sa terminal

Maaari ring i-script ang menu ng Omarchy, na madaling gamitin para sa sarili mong mga keybinding. Binubuksan ito ng `omarchy menu` sa root, at maaari kang dumiretso sa anumang punto sa tree sa pagbanggit nito: dumidiretso ang `omarchy menu summon appearance.theme` sa theme picker, binubuksan ng `omarchy menu toggle system` ang system menu at isinasara itong muli kung nakabukas na ito, at itinatago ito ng `omarchy menu close`.
