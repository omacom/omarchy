# Omarchy CLI

Karaniwang kinokontrol ang Omarchy sa pamamagitan ng mga hotkey at ng menu ng Omarchy (`Super + Space`). Ngunit maaari mo rin itong kontrolin sa pamamagitan ng `omarchy` CLI. Partikular itong nakakatulong kapag mayroon kang isang AI agent na nakikipagtulungan sa iyo sa pag-customize o configuration.

Ang CLI ay may access sa lahat ng internal tooling na ginagamit parehong sa pamamagitan ng menu at kung hindi man. Makikita mo ang lahat ng available sa pamamagitan ng pagpapatakbo ng `omarchy` sa terminal.

Mukha itong ganito:

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

Tumatanggap din ang bawat command ng `--help`, magtanong ka man sa isang buong grupo (`omarchy capture --help`) o sa isang nag-iisang command (`omarchy capture screenshot --help`).

### Pagbubukas ng menu mula sa terminal

Ang menu ng Omarchy ay scriptable din, na madaling gamitin para sa sarili mong mga keybinding. Binubuksan ito ng `omarchy menu` sa root, at maaari kang tumalon nang diretso sa anumang punto sa tree sa pamamagitan ng pagpapangalan dito: ang `omarchy menu summon style.theme` ay dumidiretso sa tagapili ng tema, ang `omarchy menu toggle system` ay binubuksan ang menu ng sistema at isinasara ito ulit kung nakataas na ito, at ang `omarchy menu close` ay inaalis ito.
