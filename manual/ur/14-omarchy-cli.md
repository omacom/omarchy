# Omarchy CLI

Omarchy کو عام طور پر ہاٹ کیز اور Omarchy مینیو (`Super + Space`) کے ذریعے کنٹرول کیا جاتا ہے۔ لیکن آپ اسے `omarchy` CLI کے ذریعے بھی کنٹرول کر سکتے ہیں۔ یہ خاص طور پر اس وقت مددگار ہوتا ہے جب آپ کسی AI ایجنٹ سے تخصیص یا ترتیب پر اپنے ساتھ کام کروا رہے ہوں۔

CLI کو ان تمام اندرونی اوزاروں تک رسائی حاصل ہے جو مینیو کے ذریعے بھی استعمال ہوتے ہیں اور دیگر طریقوں سے بھی۔ آپ ٹرمینل میں `omarchy` چلا کر سب کچھ دیکھ سکتے ہیں جو دستیاب ہے۔

یہ کچھ اس طرح دکھائی دیتا ہے:

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

تشخیص کے لیے، براہِ راست `omarchy-debug --no-sudo --print` چلائیں۔ یہ تشخیصی معلومات پرنٹ کرتا ہے اور sudo کے لیے پوچھے بغیر `/tmp/omarchy-debug.log` لکھتا ہے، بشمول ان پیکیج تنصیبات پر جہاں `omarchy debug` "Unknown Omarchy command" کے ساتھ ناکام ہو سکتی ہے۔

اور آپ ہر گروپ میں مزید گہرائی تک جا سکتے ہیں:

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

### ٹرمینل سے مینیو کھولنا

Omarchy مینیو اسکرپٹ کے قابل بھی ہے، جو آپ کی اپنی کی بائنڈنگز کے لیے کارآمد ہے۔ `omarchy menu` اسے روٹ پر کھولتا ہے، اور آپ اس کا نام بتا کر درخت میں کسی بھی مقام پر براہِ راست چھلانگ لگا سکتے ہیں: `omarchy menu summon appearance.theme` براہِ راست تھیم منتخب کرنے والے تک لے جاتا ہے، `omarchy menu toggle system` سسٹم مینیو کھولتا ہے اور اگر وہ پہلے سے کھلا ہو تو اسے دوبارہ بند کر دیتا ہے، اور `omarchy menu close` اسے ہٹا دیتا ہے۔
