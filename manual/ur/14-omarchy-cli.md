# Omarchy CLI

Omarchy کو عام طور پر hotkeys اور Omarchy menu (`Super + Space`) کے ذریعے کنٹرول کیا جاتا ہے۔ لیکن آپ اسے `omarchy` CLI کے ذریعے بھی کنٹرول کر سکتے ہیں۔ یہ خاص طور پر اس وقت مددگار ہوتا ہے جب آپ کسی AI agent سے customization یا configuration پر اپنے ساتھ کام کروا رہے ہوں۔

CLI کو ان تمام internal tooling تک رسائی حاصل ہے جو menu کے ذریعے اور اس کے علاوہ بھی استعمال ہوتی ہیں۔ آپ terminal میں `omarchy` چلا کر ہر دستیاب چیز دیکھ سکتے ہیں۔

یہ کچھ اس طرح نظر آتا ہے:

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

اور آپ ہر group میں مزید گہرائی تک جا سکتے ہیں:

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

ہر command `--help` بھی لیتا ہے، چاہے آپ پورے group سے پوچھیں (`omarchy capture --help`) یا کسی ایک command سے (`omarchy capture screenshot --help`)۔

### Terminal سے menu کھولنا

Omarchy menu کو script بھی کیا جا سکتا ہے، جو آپ کی اپنی keybindings کے لیے کارآمد ہے۔ `omarchy menu` اسے root پر کھولتا ہے، اور آپ اس کا نام دے کر tree میں سیدھا کسی بھی مقام پر جا سکتے ہیں: `omarchy menu summon appearance.theme` سیدھا theme picker پر جاتا ہے، `omarchy menu toggle system` system menu کھولتا ہے اور اگر وہ پہلے سے کھلا ہو تو اسے پھر سے بند کر دیتا ہے، اور `omarchy menu close` اسے ہٹا دیتا ہے۔
