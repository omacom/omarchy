# Omarchy CLI

Omarchy کو عام طور پر ہاٹ کیز اور Omarchy مینو (`Super + Space`) کے ذریعے کنٹرول کیا جاتا ہے۔ لیکن آپ اسے `omarchy` CLI کے ذریعے بھی کنٹرول کر سکتے ہیں۔ یہ خاص طور پر اس وقت مددگار ہوتا ہے جب آپ کوئی AI agent اپنے ساتھ کسٹمائزیشن یا کنفیگریشن پر کام کرنے کے لیے لگا رہے ہوں۔

CLI کو ان تمام اندرونی ٹولز تک رسائی حاصل ہے جو مینو کے ذریعے اور اس کے علاوہ بھی استعمال ہوتے ہیں۔ آپ ٹرمینل میں `omarchy` چلا کر وہ سب کچھ دیکھ سکتے ہیں جو دستیاب ہے۔

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

اور آپ ہر گروپ میں مزید گہرائی میں بھی جا سکتے ہیں:

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

ہر کمانڈ `--help` بھی لیتی ہے، چاہے آپ پورے گروپ سے پوچھیں (`omarchy capture --help`) یا کسی ایک کمانڈ سے (`omarchy capture screenshot --help`)۔

### ٹرمینل سے مینو کھولنا

Omarchy مینو کو اسکرپٹ بھی کیا جا سکتا ہے، جو آپ کی اپنی کی بائنڈنگز کے لیے کارآمد ہے۔ `omarchy menu` اسے روٹ پر کھولتا ہے، اور آپ اس کا نام بتا کر ٹری میں کسی بھی مقام پر سیدھا جا سکتے ہیں: `omarchy menu summon appearance.theme` سیدھا تھیم منتخب کرنے والے حصے میں لے جاتا ہے، `omarchy menu toggle system` سسٹم مینو کھولتا ہے اور اگر وہ پہلے سے کھلا ہو تو اسے دوبارہ بند کر دیتا ہے، اور `omarchy menu close` اسے ہٹا دیتا ہے۔
