# Omarchy CLI

Omarchy se obvykle ovládá pomocí klávesových zkratek a menu Omarchy (`Super + Space`). Ovládat ho ale můžete i prostřednictvím CLI `omarchy`. To se hodí zejména tehdy, když s vámi na úpravách nebo konfiguraci pracuje AI agent.

CLI má přístup ke všem interním nástrojům, které se používají jak přes menu, tak i jinak. Vše, co je k dispozici, uvidíte po spuštění `omarchy` v terminálu.

Vypadá to nějak takto:

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

A u každé skupiny můžete jít ještě hlouběji:

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

Každý příkaz přijímá i `--help`, ať už se zeptáte celé skupiny (`omarchy capture --help`), nebo jednoho příkazu (`omarchy capture screenshot --help`).

### Otevření menu z terminálu

Menu Omarchy lze ovládat i skriptem, což se hodí pro vaše vlastní klávesové zkratky. `omarchy menu` ho otevře na kořenové úrovni a pojmenováním můžete skočit rovnou na libovolné místo ve stromu: `omarchy menu summon appearance.theme` přejde přímo do výběru motivu, `omarchy menu toggle system` otevře systémové menu a zase ho zavře, pokud už je otevřené, a `omarchy menu close` ho schová.
