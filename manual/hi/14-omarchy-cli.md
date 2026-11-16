# Omarchy CLI

Omarchy को आमतौर पर hotkeys और Omarchy menu (`Super + Space`) के ज़रिए नियंत्रित किया जाता है। लेकिन आप इसे `omarchy` CLI के ज़रिए भी नियंत्रित कर सकते हैं। यह विशेष रूप से तब मददगार होता है जब आप किसी AI agent से अपने साथ customization या configuration पर काम करवा रहे हों।

CLI के पास उन सभी internal tooling तक पहुँच है जिनका उपयोग menu के ज़रिए और अन्य तरीकों से भी किया जाता है। terminal में `omarchy` चलाकर आप देख सकते हैं कि क्या-क्या उपलब्ध है।

यह कुछ इस तरह दिखता है:

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

और आप हर group में और गहराई तक जा सकते हैं:

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

हर command `--help` भी लेता है, चाहे आप पूरे group से पूछें (`omarchy capture --help`) या किसी एक command से (`omarchy capture screenshot --help`)।

### terminal से menu खोलना

Omarchy menu को script भी किया जा सकता है, जो आपकी अपनी keybindings के लिए उपयोगी है। `omarchy menu` इसे root पर खोलता है, और आप इसका नाम बताकर tree में किसी भी बिंदु पर सीधे जा सकते हैं: `omarchy menu summon appearance.theme` सीधे theme picker पर जाता है, `omarchy menu toggle system` system menu खोलता है और अगर वह पहले से खुला हो तो उसे फिर से बंद कर देता है, और `omarchy menu close` उसे बंद करके हटा देता है।
