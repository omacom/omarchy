# Omarchy CLI

Omarchy عام طور پر ہاٹ کیز اور Omarchy مینیُو (`Super + Space`) کے ذریعے کنٹرول کیا جاتا ہے۔ لیکن آپ اسے `omarchy` CLI کے ذریعے بھی کنٹرول کر سکتے ہیں۔ یہ خاص طور پر اس وقت مددگار ہوتا ہے جب آپ AI ایجنٹ کو کسٹمائزیشن یا کنفیگریشن پر اپنے ساتھ کام کرا رہے ہوں۔

CLI کو ان تمام داخلی ٹولز تک رسائی حاصل ہے جو مینیُو کے ذریعے بھی استعمال ہوتے ہیں اور دوسری جگہ بھی۔ آپ ٹرمینل میں `omarchy` چلا کر دستیاب سب کچھ دیکھ سکتے ہیں۔

یہ کچھ اس طرح لگتا ہے:

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

اور آپ ہر گروپ پر مزید گہرائی میں جا سکتے ہیں:

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

ہر کمانڈ `--help` بھی لیتی ہے، چاہے آپ پورا گروپ پوچھیں (`omarchy capture --help`) یا کوئی ایک کمانڈ (`omarchy capture screenshot --help`)۔

### ٹرمینل سے مینیُو کھولنا

Omarchy مینیُو بھی اسکرپٹ کے قابل ہے، جو آپ کی اپنی کی بائنڈنگز کے لیے سودمند ہے۔ `omarchy menu` اسے جڑ پر کھولتا ہے، اور آپ اس کا نام دے کر درخت میں کسی بھی مقام پر براہ راست جا سکتے ہیں: `omarchy menu summon style.theme` سیدھا تھیم پِکر پر جاتا ہے، `omarchy menu toggle system` سسٹم مینیُو کھولتا ہے اور اگر یہ پہلے سے اوپر ہے تو اسے دوبارہ بند کر دیتا ہے، اور `omarchy menu close` اسے ہٹا دیتا ہے۔
