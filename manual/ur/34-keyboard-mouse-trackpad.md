# کی بورڈ، ماؤس، ٹریک پیڈ

Hyprland آپ کو اپنے تمام ان پٹ کو بہت تفصیل سے ترتیب دینے دیتا ہے۔ آپ کی بورڈ ریپیٹ کو سپر سونک حد تک تیز کر سکتے ہیں یا ٹریک پیڈ کو نیچرل اسکرولنگ استعمال کرنے پر مجبور کر سکتے ہیں۔ آپ یہ سب کچھ `~/.config/hypr/input.lua` میں تبدیل کرتے ہیں، جس تک آپ Omarchy مینو (`Super + Space`) میں _Setup > Input_ کے ذریعے بھی پہنچ سکتے ہیں۔ وہاں آپ جو کچھ بھی سیٹ کریں گے وہ Omarchy کے ڈیفالٹس کی جگہ لے لے گا۔

یہ ایک مثال ہے:

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

آپ ان پٹ کے لیے Hyprland ویکی پر [ان پٹ کے تمام آپشنز دیکھ سکتے ہیں](https://wiki.hypr.land/Configuring/Basics/Variables/#input)۔

CapsLock ایک عام Caps Lock کے طور پر کام کرتا ہے، اور `Shift + CapsLock` [فوری ایموجیز](07-hotkeys.md#quick-emojis) اور [دیگر تکمیلات](07-hotkeys.md#quick-completions) کے لیے کمپوز کی ہے۔ اگر آپ کمپوز کی کو کہیں اور رکھنا چاہتے ہیں تو `kb_options` میں `omarchy:shift_caps_compose` کو تبدیل کریں۔ مثال کے طور پر، اس سے کمپوز کی Right Alt پر منتقل ہو جاتی ہے:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### ٹریک پیڈ اشارے

ڈیسک ٹاپ پر گھومنے کے لیے ٹریک پیڈ پر سوائپ کریں:

| اشارہ | عمل |
| --- | --- |
| تین انگلیاں بائیں / دائیں | پچھلا / اگلا ورک اسپیس، خالی ورک اسپیسز سمیت |
| تین انگلیاں اوپر | AI کنسول کو ٹوگل کریں |
| تین انگلیاں نیچے | Omarchy مینو کھولیں |
| چار انگلیاں بائیں / دائیں | فعال ونڈو کو پچھلے / اگلے ورک اسپیس پر منتقل کریں |
| چار انگلیاں نیچے | فل اسکرین کو ٹوگل کریں |

کسی ایک کو تبدیل کرنے کے لیے، اپنا [ٹچ پیڈ اشارہ](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) شامل کرنے سے پہلے اسے `~/.config/hypr/input.lua` میں ان سیٹ کریں، کیونکہ Hyprland ایک ہی انگلیوں اور ایک ہی سمت پر دو اشارے قبول نہیں کرے گا:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy کے تمام اشارے بند کرنے کے لیے، Omarchy کے ڈیفالٹس لوڈ ہونے سے پہلے، `~/.config/hypr/hyprland.lua` کے اوپری حصے کے قریب `omarchy_default_gestures = false` سیٹ کریں۔

ہیپٹک ٹچ پیڈ والے Dell XPS لیپ ٹاپس پر، آپ _Trigger > Hardware > Touchpad Haptics_ کے تحت کلک کی طاقت کو low، mid یا high پر بھی سیٹ کر سکتے ہیں۔

### چینی، جاپانی اور دیگر زبانوں میں ٹائپنگ

جب انسٹالر آپ سے آپ کے کی بورڈ کے بارے میں پوچھے تو Japanese، Korean، Chinese (Simplified, Pinyin)، Taiwan (Zhuyin) یا Hong Kong (Cangjie) منتخب کریں۔ Omarchy کی بورڈ اور متعلقہ ان پٹ انجن کو خود بخود ترتیب دیتا ہے، بشمول آف لائن فرسٹ بوٹ سیٹ اپ کے دوران۔ Japanese میں Mozc استعمال ہوتا ہے، Korean میں معیاری ٹو سیٹ Hangul استعمال ہوتا ہے، Simplified Chinese میں Pinyin استعمال ہوتا ہے، Taiwan میں Chewing کی معیاری Zhuyin ترتیب استعمال ہوتی ہے، اور Hong Kong میں Hong Kong کی حروف کی شکلوں کے ساتھ Cangjie استعمال ہوتا ہے۔ Japanese (US keyboard) US کی بورڈ لے آؤٹ کے ساتھ Mozc فراہم کرتا ہے۔ Hangul، Zhuyin اور Cangjie کیز اپنی معیاری جگہوں پر رہتی ہیں، چاہے آپ Dvorak، Colemak یا AZERTY کے ساتھ Latin حروف ہی کیوں نہ ٹائپ کریں۔ اگر آپ نے اس سے پہلے Hangul یا Chewing شامل کیا تھا تو اس کی کیز کو وہاں منتقل کرنے کے لیے اسے _Setup > Typing > Input Methods_ کے تحت غیر منتخب کر کے دوبارہ منتخب کریں؛ Omarchy اس انجن کو چھوڑ دیتا ہے جس کے ساتھ آپ پہلے سے ٹائپ کر رہے ہیں۔

ٹائپنگ Latin موڈ میں شروع ہوتی ہے۔ ترتیب شدہ ان پٹ طریقوں میں چکر لگانے کے لیے `Super + I` دبائیں، اور پیچھے کی طرف چکر لگانے کے لیے `Super + Shift + I` دبائیں۔ Pinyin جیسے ان پٹ طریقے سے نکل کر Latin حروف میں جانے کے لیے `Shift` کو اکیلا تھپتھپائیں، اور واپس جانے کے لیے اسے دوبارہ تھپتھپائیں، بالکل اسی طرح جیسے Sogou، Microsoft Pinyin اور macOS کام کرتے ہیں؛ `Shift` کے ساتھ کوئی حرف دبانے سے پھر بھی بڑا حرف ٹائپ ہوتا ہے۔ Japanese کی بورڈز پر، 全角/半角 ان پٹ کو ٹوگل کرتا ہے، 変換 اسے آن کرتا ہے، اور 無変換 اسے آف کرتا ہے۔ Korean کے ساتھ، 한/영 Hangul کو تبدیل کرتا ہے اور 한자 Hanja میں تبدیل کرتا ہے، چاہے آپ کے کی بورڈ میں اس کے لیے مخصوص کیز ہوں یا وہ ان کے لیے Right Alt اور Right Ctrl بھیجتا ہو، جیسا کہ بہت سے لیپ ٹاپس کرتے ہیں، اس لیے وہاں Right Alt اور Right Ctrl سادہ موڈیفائرز نہیں ہیں؛ اس کے بجائے ڈکٹیشن Alt + Space کے ساتھ ٹوگل ہوتی ہے۔ `Ctrl + Space` Tmux اور Herdr کے لیے دستیاب رہتا ہے؛ `Shift + CapsLock` کمپوز کی ہی رہتا ہے۔

جب آپ کے پاس متعدد کی بورڈ لے آؤٹ یا ان پٹ طریقے ہوتے ہیں تو کی بورڈ انڈیکیٹر بار کے دائیں طرف ظاہر ہوتا ہے۔ ان پٹ زبانیں تبدیل کرنے کے لیے اس پر کلک کریں؛ Japanese ہیراگانا کے لیے あ دکھاتا ہے۔ Japanese حروف کے انتخاب کے لیے، Japanese پر سوئچ کریں، کوئی لفظ ٹائپ کریں جیسے `nihongo`، پھر Space دو بار دبائیں۔ اپنا انتخاب قبول کرنے کے لیے Enter دبائیں۔ اگر آپ کے پاس متعدد کی بورڈ لے آؤٹ بھی ہیں تو ان میں چکر لگانے کے لیے انڈیکیٹر پر دائیں کلک کریں۔

English اور French جیسے لے آؤٹ منتخب کرنے کے لیے _Setup > Typing > Keyboard Layouts_ استعمال کریں، انہی انتخابوں میں سے جو انسٹالیشن کے دوران پیش کیے جاتے ہیں۔ کون سے کمپوزیشن انجن فعال ہیں یہ منتخب کرنے کے لیے _Setup > Typing > Input Methods_ استعمال کریں۔ دونوں پکر Omarchy مینو کے اندر کھلتے ہیں اور آپ کے موجودہ انتخاب نشان زد ہوتے ہیں۔ کسی انتخاب کو ٹوگل کرنے کے لیے کلک کریں یا Enter دبائیں؛ ہر تبدیلی فوراً لاگو ہو جاتی ہے۔ کسی ان پٹ طریقے کو غیر منتخب کرنے سے وہ اسے ان انسٹال کیے بغیر سائیکل سے ہٹا دیتا ہے؛ کی بورڈ دستیاب رہتا ہے۔

وہی پکر کھولنے کے لیے `omarchy setup keyboard` یا `omarchy setup input` چلائیں۔ کمانڈ لائن سے ایک زبان شامل کرنے کے لیے، `omarchy setup input mozc`، `hangul`، `pinyin`، `chewing` یا `cangjie5` استعمال کریں۔ Quick، Boshiamy اور Array Cangjie کے ساتھ ایک ہی پیکج میں آتے ہیں اور Input Methods پکر میں ظاہر ہوتے ہیں۔ آپ کی حسب ضرورت سوئچنگ کیز محفوظ رہتی ہیں۔ متبادل انجن لے آؤٹ یا کیز کے لیے، `omarchy pkg add fcitx5-configtool` کے ساتھ `fcitx5-configtool` انسٹال کریں اور اسے ٹرمینل سے لانچ کریں۔ ان پٹ زبان منتخب کرنے سے ڈیسک ٹاپ کی زبان تبدیل نہیں ہوتی۔ _Setup > Language_ کے تحت Japanese، Korean یا Chinese منتخب کرنے سے، جب آپ کے پاس ابھی تک کوئی ان پٹ طریقہ نہ ہو، اس کا ان پٹ طریقہ شامل ہو جاتا ہے۔

ان پٹ طریقوں یا کی بورڈ لے آؤٹ میں چکر لگانے کے لیے `Super + I` استعمال کریں، اور دوسری سمت واپس جانے کے لیے `Super + Shift + I` استعمال کریں، اس لیے تین ترتیب شدہ ہونے پر آپ دو پڑوسیوں کے درمیان آ جا سکتے ہیں۔ ان پٹ انڈیکیٹر بار کے دائیں طرف صرف اسی وقت ظاہر ہوتا ہے جب ایک سے زیادہ ان پٹ طریقہ یا لے آؤٹ ترتیب دیا گیا ہو۔ یہ ڈیسک ٹاپ بائنڈنگ آپ کی موجودہ Fcitx سوئچنگ کیز کے ساتھ ساتھ کام کرتی ہے؛ آپ اسے `~/.config/hypr/bindings.lua` میں اوور رائیڈ کر سکتے ہیں۔ ان پٹ انجن اور کمپوز سیکوینسز ہر سیشن میں پہلے سے چل رہی [Fcitx5](https://fcitx-im.org/) سروس استعمال کرتے ہیں۔

### ALT کو SUPER کے طور پر استعمال کریں

کچھ کی بورڈز پر، پرائمری میٹا کی (Windows/cmd کی) کو SUPER کے طور پر استعمال کرنا آسان نہیں ہوتا۔ آپ اس تبدیلی کو استعمال کر کے اسے اس کے بجائے ALT بنا سکتے ہیں:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
