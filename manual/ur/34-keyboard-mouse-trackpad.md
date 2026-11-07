# کی بورڈ، ماؤس، ٹریک پیڈ

Hyprland آپ کو اپنے تمام ان پٹس کو بڑی تفصیل سے ترتیب دینے دیتا ہے۔ آپ کی بورڈ ریپیٹ کو صوتی رفتار سے بھی تیز کر سکتے ہیں یا ٹریک پیڈ کو نیچرل اسکرولنگ استعمال کرنے پر لگا سکتے ہیں۔ آپ یہ سب کچھ `~/.config/hypr/input.lua` میں تبدیل کرتے ہیں، جس تک آپ Omarchy مینو (`Super + Space`) میں _Setup > Input_ کے ذریعے بھی پہنچ سکتے ہیں۔ وہاں آپ جو کچھ بھی سیٹ کریں گے، وہ Omarchy کی ڈیفالٹس کی جگہ لے لے گا۔

اس کی ایک مثال یہ ہے:

```lua
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,dk",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",

    -- Change speed of keyboard repeat
    repeat_rate = 40,
    repeat_delay = 600,

    -- Increase sensitivity for mouse/trackpad (default: 0)
    sensitivity = 0.35,

    touchpad = {
      -- Use natural (inverse) scrolling
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner
      clickfinger_behavior = true,

      -- Control the speed of your scrolling
      scroll_factor = 0.3,
    },
  },
})

-- Scroll faster in the terminal
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
```

آپ ان پٹس کے لیے Hyprland ویکی پر [تمام ان پٹ آپشنز دیکھ سکتے ہیں](https://wiki.hypr.land/Configuring/Basics/Variables/#input)۔

CapsLock ایک عام Caps Lock کے طور پر کام کرتا ہے، اور `Shift + CapsLock` [فوری ایموجیز](07-hotkeys.md#quick-emojis) اور [دیگر تکمیل](07-hotkeys.md#quick-completions) کے لیے compose کی ہے۔ اگر آپ compose کی کو کہیں اور رکھنا چاہتے ہیں، تو `kb_options` میں `omarchy:shift_caps_compose` کو تبدیل کر دیں۔ مثال کے طور پر، اس سے compose کی Right Alt پر منتقل ہو جاتی ہے:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### فنکشن کیز

لیپ ٹاپ کی بورڈ کی اوپری قطار بطور ڈیفالٹ میڈیا کیز (والیوم، برائٹنس وغیرہ) بھیجتی ہے، اور `Fn` دبا کر رکھنے سے F1-F12 ملتے ہیں؛ `Fn + Esc` اسے اس وقت تک الٹی حالت میں لاک کر دیتا ہے جب تک آپ اسے دوبارہ نہ دبائیں۔ زیادہ تر کی بورڈز وہ لاک خود یاد رکھتے ہیں۔ ASUS لیپ ٹاپس اور Apple طرز کے کی بورڈز یہ کام Linux پر چھوڑ دیتے ہیں، جو ہر بوٹ پر انہیں میڈیا کیز پر شروع کرتا ہے۔ اس کے بجائے انہیں F1-F12 پر شروع کروانے کے لیے `omarchy keyboard toprow fnkeys` چلائیں (اور واپس جانے کے لیے `omarchy keyboard toprow mediakeys`)؛ کچھ لیپ ٹاپس پر اس کا اثر ری بوٹ کے بعد ہوتا ہے۔ Apple Silicon Macs اپنی سیٹنگ خود رکھتے ہیں۔

### ٹریک پیڈ اشارے

ڈیسک ٹاپ پر گھومنے کے لیے ٹریک پیڈ پر سوائپ کریں:

| اشارہ | عمل |
| --- | --- |
| تین انگلیاں بائیں / دائیں | پچھلا / اگلا ورک اسپیس، خالی ورک اسپیسز سمیت |
| تین انگلیاں اوپر | AI کنسول ٹوگل کریں |
| تین انگلیاں نیچے | Omarchy مینو کھولیں |
| چار انگلیاں بائیں / دائیں | فعال ونڈو کو پچھلے / اگلے ورک اسپیس پر منتقل کریں |
| چار انگلیاں نیچے | فل اسکرین ٹوگل کریں |

کسی ایک اشارے کو تبدیل کرنے کے لیے، اپنا [touchpad gesture](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) شامل کرنے سے پہلے اسے `~/.config/hypr/input.lua` میں unset کریں، کیونکہ Hyprland ایک ہی انگلیوں اور ایک ہی سمت پر دو اشارے قبول نہیں کرے گا:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy کے تمام اشارے بند کرنے کے لیے، Omarchy کی ڈیفالٹس لوڈ ہونے سے پہلے، `~/.config/hypr/hyprland.lua` کے اوپری حصے کے قریب `omarchy_default_gestures = false` سیٹ کریں۔

Dell XPS لیپ ٹاپس پر جن میں haptic ٹچ پیڈ ہو، آپ _Trigger > Hardware > Touchpad Haptics_ کے تحت کلک کی طاقت کو low، mid، یا high پر بھی سیٹ کر سکتے ہیں۔

### چینی، جاپانی اور دیگر زبانوں میں ٹائپنگ

جب انسٹالر آپ کے کی بورڈ کے بارے میں پوچھے تو Japanese، Korean، Chinese (Simplified, Pinyin)، Taiwan (Zhuyin)، یا Hong Kong (Cangjie) منتخب کریں۔ Omarchy کی بورڈ اور اس سے مطابقت رکھنے والے ان پٹ انجن کو خود بخود ترتیب دیتا ہے، بشمول آف لائن first-boot سیٹ اپ کے دوران۔ Japanese میں Mozc استعمال ہوتا ہے، Korean میں معیاری two-set Hangul، Simplified Chinese میں Pinyin، Taiwan میں Chewing کی معیاری Zhuyin ترتیب، اور Hong Kong میں Hong Kong کیریکٹر فارمز کے ساتھ Cangjie استعمال ہوتا ہے۔ Japanese (US keyboard) US کی بورڈ لے آؤٹ کے ساتھ Mozc فراہم کرتا ہے۔ Hangul، Zhuyin، اور Cangjie کیز اپنی معیاری جگہوں پر رہتی ہیں، چاہے آپ Dvorak، Colemak، یا AZERTY کے ساتھ Latin حروف ٹائپ کریں۔ اگر آپ نے اس سے پہلے Hangul یا Chewing شامل کیا تھا، تو اس کی کیز کو وہاں منتقل کرنے کے لیے _Setup > Keyboard > Input Methods_ کے تحت اسے غیر منتخب کر کے دوبارہ منتخب کریں؛ Omarchy اس انجن کو چھوڑ دیتا ہے جس کے ساتھ آپ پہلے سے ٹائپ کر رہے ہوں۔

ٹائپنگ Latin موڈ میں شروع ہوتی ہے۔ ترتیب شدہ ان پٹ میتھڈز میں چکر لگانے کے لیے `Super + I` دبائیں، اور واپس چکر لگانے کے لیے `Super + Shift + I` دبائیں۔ Pinyin جیسے ان پٹ میتھڈ سے نکل کر Latin حروف میں جانے کے لیے صرف `Shift` کو Tap کریں، اور واپس جانے کے لیے اسے دوبارہ Tap کریں، بالکل اسی طرح جیسے Sogou، Microsoft Pinyin، اور macOS کام کرتے ہیں؛ `Shift` کے ساتھ کوئی حرف اب بھی بڑا حرف ٹائپ کرتا ہے۔ Japanese کی بورڈز پر، 全角/半角 ان پٹ کو ٹوگل کرتا ہے، 変換 اسے آن کرتا ہے، اور 無変換 اسے آف کرتا ہے۔ Korean کے ساتھ، 한/영 Hangul کو سوئچ کرتا ہے اور 한자 Hanja میں تبدیل کرتا ہے، چاہے آپ کے کی بورڈ میں اس کے لیے مخصوص کیز ہوں یا وہ ان کے لیے Right Alt اور Right Ctrl بھیجتا ہو، جیسا کہ کئی لیپ ٹاپس کرتے ہیں، اس لیے Right Alt اور Right Ctrl وہاں سادہ موڈیفائرز نہیں ہیں؛ اس کے بجائے dictation Alt + Space کے ساتھ ٹوگل ہوتی ہے۔ `Ctrl + Space` Tmux اور Herdr کے لیے دستیاب رہتا ہے؛ `Shift + CapsLock` compose کی ہی رہتی ہے۔

جب آپ کے پاس متعدد کی بورڈ لے آؤٹس یا ان پٹ میتھڈز ہوں تو کی بورڈ انڈیکیٹر بار کے دائیں طرف ظاہر ہوتا ہے۔ ان پٹ زبانیں سوئچ کرنے کے لیے اس پر کلک کریں؛ Japanese میں hiragana کے لیے あ دکھائی دیتا ہے۔ Japanese کیریکٹر کے انتخاب کے لیے، Japanese پر سوئچ کریں، کوئی لفظ جیسے `nihongo` ٹائپ کریں، پھر Space کو دو بار دبائیں۔ اپنی پسند قبول کرنے کے لیے Enter دبائیں۔ اگر آپ کے پاس متعدد کی بورڈ لے آؤٹس بھی ہیں، تو ان میں چکر لگانے کے لیے انڈیکیٹر پر دائیں کلک کریں۔

انہی انتخابوں میں سے جو انسٹالیشن کے دوران پیش کیے گئے تھے، English اور French جیسے لے آؤٹس منتخب کرنے کے لیے _Setup > Keyboard > Keyboard Inputs_ استعمال کریں۔ یہ منتخب کرنے کے لیے کہ کون سے composition انجن فعال ہیں، _Setup > Keyboard > Input Methods_ استعمال کریں۔ دونوں پکرز Omarchy مینو کے اندر کھلتے ہیں اور آپ کے موجودہ انتخاب چیک شدہ نظر آتے ہیں۔ کسی انتخاب کو ٹوگل کرنے کے لیے کلک کریں یا Enter دبائیں؛ ہر تبدیلی فوری طور پر لاگو ہو جاتی ہے۔ کسی ان پٹ میتھڈ کو غیر منتخب کرنے سے وہ ان انسٹال ہوئے بغیر چکر سے نکل جاتا ہے؛ کی بورڈ دستیاب رہتا ہے۔

وہی پکرز کھولنے کے لیے `omarchy setup keyboard` یا `omarchy setup input` چلائیں۔ کمانڈ لائن سے ایک زبان شامل کرنے کے لیے `omarchy setup input mozc`، `hangul`، `pinyin`، `chewing`، یا `cangjie5` استعمال کریں۔ Quick، Boshiamy، اور Array Cangjie کے ساتھ ایک ہی پیکیج میں آتے ہیں اور Input Methods پکر میں ظاہر ہوتے ہیں۔ آپ کی حسبِ ضرورت سوئچنگ کیز محفوظ رہتی ہیں۔ متبادل انجن لے آؤٹس یا کیز کے لیے، `omarchy pkg add fcitx5-configtool` کے ساتھ `fcitx5-configtool` انسٹال کریں اور اسے ٹرمینل سے لانچ کریں۔ ان پٹ زبان منتخب کرنے سے ڈیسک ٹاپ کی زبان تبدیل نہیں ہوتی۔ _Setup > Language_ کے تحت Japanese، Korean، یا Chinese منتخب کرنے سے، جب آپ کے پاس ابھی کوئی ان پٹ میتھڈ نہ ہو، اس کا ان پٹ میتھڈ شامل ہو جاتا ہے۔

ان پٹ میتھڈز یا کی بورڈ لے آؤٹس میں چکر لگانے کے لیے `Super + I` استعمال کریں، اور دوسری طرف واپس جانے کے لیے `Super + Shift + I` استعمال کریں، اس لیے تین ترتیب شدہ چیزوں کے ساتھ آپ دو پڑوسیوں کے درمیان آگے پیچھے جا سکتے ہیں۔ ان پٹ انڈیکیٹر بار کے دائیں طرف صرف اسی وقت ظاہر ہوتا ہے جب ایک سے زیادہ ان پٹ میتھڈ یا لے آؤٹ ترتیب دیا گیا ہو۔ یہ ڈیسک ٹاپ بائنڈنگ آپ کی موجودہ Fcitx سوئچنگ کیز کے ساتھ ساتھ کام کرتی ہے؛ آپ اسے `~/.config/hypr/bindings.lua` میں اوور رائیڈ کر سکتے ہیں۔ ان پٹ انجن اور compose کی ترتیبات ہر سیشن میں پہلے سے چل رہی [Fcitx5](https://fcitx-im.org/) سروس استعمال کرتی ہیں۔

### ALT کو SUPER کے طور پر استعمال کریں

کچھ کی بورڈز پر، بنیادی meta کی (Windows/cmd کی) کو SUPER کے طور پر استعمال کرنا آسان نہیں ہوتا۔ آپ اس تبدیلی کو استعمال کر کے اسے اس کے بجائے ALT بنا سکتے ہیں:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
