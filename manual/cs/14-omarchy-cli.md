# CLI Omarchy

Omarchy se obvykle ovládá klávesovými zkratkami a nabídkou Omarchy (`Super + Space`). Můžete ho ale ovládat také prostřednictvím CLI `omarchy`. To je obzvlášť užitečné, když s vámi na přizpůsobení nebo konfiguraci pracuje AI agent.

CLI má přístup ke všem interním nástrojům, které se používají jak přes nabídku, tak jinak. Vše, co je k dispozici, uvidíte spuštěním `omarchy` v terminálu.

Vypadá to asi takto:

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

A u každé skupiny se můžete ponořit hlouběji:

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

Každý příkaz přijímá také `--help`, ať už se ptáte celé skupiny (`omarchy capture --help`) nebo jednotlivého příkazu (`omarchy capture screenshot --help`).

### Otevření nabídky z terminálu

Nabídka Omarchy je také skriptovatelná, což se hodí pro vaše vlastní klávesové zkratky. `omarchy menu` ji otevře v kořenu a můžete skočit přímo na libovolný bod ve stromu jeho pojmenováním: `omarchy menu summon style.theme` jde přímo do výběru motivu, `omarchy menu toggle system` otevře systémovou nabídku a zase ji zavře, pokud už je nahoře, a `omarchy menu close` ji uklidí.
