# Omarchy CLI

Omarchy kwa kawaida hudhibitiwa kupitia njia za mkato za kibodi na menyu ya Omarchy (`Super + Space`). Lakini pia unaweza kuudhibiti kupitia CLI ya `omarchy`. Hii ni muhimu sana unapokuwa na agent ya AI inayofanya kazi pamoja nawe kwenye ubinafsishaji au usanidi.

CLI ina ufikiaji wa zana zote za ndani zinazotumika kupitia menyu na vinginevyo. Unaweza kuona kila kinachopatikana kwa kuendesha `omarchy` kwenye terminal.

Inaonekana kitu kama hiki:

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

Na unaweza kuchimba zaidi katika kila kikundi:

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

Kila amri pia inakubali `--help`, iwe unauliza kikundi kizima (`omarchy capture --help`) au amri moja (`omarchy capture screenshot --help`).

### Kufungua menyu kutoka kwenye terminal

Menyu ya Omarchy pia inaweza kuendeshwa kwa script, jambo ambalo ni muhimu kwa keybindings zako mwenyewe. `omarchy menu` huifungua katika mzizi, na unaweza kuruka moja kwa moja hadi sehemu yoyote kwenye mti kwa kuitaja: `omarchy menu summon appearance.theme` huenda moja kwa moja hadi kichaguzi cha mandhari, `omarchy menu toggle system` hufungua menyu ya mfumo na kuifunga tena ikiwa tayari iko wazi, na `omarchy menu close` huifunga.
