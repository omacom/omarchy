# کی بورڈ، ماؤس، ٹریک پیڈ

Hyprland آپ کو اپنے تمام ان پٹس کو بڑی تفصیل سے ترتیب دینے دیتا ہے۔ آپ کی بورڈ ریپیٹ کو سپرسونک حد تک تیز کر سکتے ہیں یا ٹریک پیڈ سے نیچرل اسکرولنگ کروا سکتے ہیں۔ آپ یہ سب کچھ `~/.config/hypr/input.lua` میں تبدیل کرتے ہیں، جس تک آپ Omarchy مینو (`Super + Space`) میں _Setup > Input_ کے ذریعے بھی پہنچ سکتے ہیں۔ وہاں آپ جو کچھ بھی سیٹ کریں گے، وہ Omarchy کی ڈیفالٹس کی جگہ لے لے گا۔

یہاں ایک مثال ہے:

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

آپ Hyprland ویکی پر ان پٹس کے لیے [تمام ان پٹ آپشنز دیکھ سکتے ہیں](https://wiki.hypr.land/Configuring/Basics/Variables/#input)۔

CapsLock ایک عام Caps Lock کے طور پر کام کرتا ہے، اور `Shift + CapsLock` [فوری ایموجیز](07-hotkeys.md#quick-emojis) اور [دیگر تکمیلات](07-hotkeys.md#quick-completions) کے لیے کمپوز کی ہے۔ اگر آپ کمپوز کی کہیں اور رکھنا چاہتے ہیں تو `kb_options` میں `omarchy:shift_caps_compose` کو تبدیل کر دیں۔ مثال کے طور پر، یہ کمپوز کی کو Right Alt پر منتقل کر دیتا ہے:

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
| تین انگلیاں بائیں / دائیں | پچھلا / اگلا ورک اسپیس، بشمول خالی ورک اسپیسز |
| تین انگلیاں اوپر | AI کنسول ٹوگل کریں |
| تین انگلیاں نیچے | Omarchy مینو کھولیں |
| چار انگلیاں بائیں / دائیں | فعال ونڈو کو پچھلے / اگلے ورک اسپیس پر منتقل کریں |
| چار انگلیاں نیچے | فل اسکرین ٹوگل کریں |

کسی ایک کو تبدیل کرنے کے لیے، اپنا [ٹچ پیڈ اشارہ](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) شامل کرنے سے پہلے اسے `~/.config/hypr/input.lua` میں اَن سیٹ کریں، کیونکہ Hyprland ایک ہی انگلیوں اور ایک ہی سمت پر دو اشارے قبول نہیں کرے گا:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy کے تمام اشارے بند کرنے کے لیے، Omarchy کی ڈیفالٹس لوڈ ہونے سے پہلے، `~/.config/hypr/hyprland.lua` کے اوپری حصے کے قریب `omarchy_default_gestures = false` سیٹ کریں۔

ہیپٹک ٹچ پیڈ والے Dell XPS لیپ ٹاپس پر، آپ _Trigger > Hardware > Touchpad Haptics_ کے تحت کلک کی طاقت کو low، mid یا high پر بھی سیٹ کر سکتے ہیں۔

### چینی، جاپانی اور دیگر زبانوں میں ٹائپنگ

جب انسٹالر آپ سے آپ کے کی بورڈ کے بارے میں پوچھے تو Japanese، Korean، Chinese (Simplified, Pinyin)، Taiwan (Zhuyin) یا Hong Kong (Cangjie) منتخب کریں۔ Omarchy کی بورڈ اور اس سے میل کھاتا ان پٹ انجن خود بخود ترتیب دے دیتا ہے، بشمول آف لائن فرسٹ بوٹ سیٹ اپ کے دوران۔ Japanese میں Mozc استعمال ہوتا ہے، Korean میں معیاری ٹو سیٹ Hangul استعمال ہوتا ہے، Simplified Chinese میں Pinyin استعمال ہوتا ہے، Taiwan میں Chewing کی معیاری Zhuyin ترتیب استعمال ہوتی ہے، اور Hong Kong میں Hong Kong حروف کی شکلوں کے ساتھ Cangjie استعمال ہوتا ہے۔ Japanese (US keyboard) US کی بورڈ لے آؤٹ کے ساتھ Mozc فراہم کرتا ہے۔ Hangul، Zhuyin اور Cangjie کیز اپنی معیاری جگہوں پر ہی رہتی ہیں، چاہے آپ Dvorak، Colemak یا AZERTY کے ساتھ لاطینی حروف ہی کیوں نہ ٹائپ کریں۔ اگر آپ نے اس سے پہلے Hangul یا Chewing شامل کیا تھا تو اس کی کیز کو وہاں منتقل کرنے کے لیے اسے _Setup > Typing > Input Methods_ کے تحت غیر منتخب کر کے دوبارہ منتخب کریں؛ Omarchy اس انجن کو چھوڑ دیتا ہے جس کے ساتھ آپ پہلے سے ٹائپ کر رہے ہیں۔

ٹائپنگ Latin موڈ میں شروع ہوتی ہے۔ ترتیب شدہ ان پٹ طریقوں میں چکر لگانے کے لیے `Super + I` دبائیں، اور واپس چکر لگانے کے لیے `Super + Shift + I` دبائیں۔ Pinyin جیسے کسی ان پٹ طریقے سے نکل کر لاطینی حروف میں جانے کے لیے اکیلے `Shift` کو ٹیپ کریں، اور واپس جانے کے لیے اسے دوبارہ ٹیپ کریں، بالکل اسی طرح جیسے Sogou، Microsoft Pinyin اور macOS کام کرتے ہیں؛ `Shift` کے ساتھ کوئی حرف اب بھی بڑا حرف ٹائپ کرتا ہے۔ جاپانی کی بورڈز پر، 全角/半角 ان پٹ کو ٹوگل کرتا ہے، 変換 اسے آن کرتا ہے، اور 無変換 اسے آف کرتا ہے۔ Korean کے ساتھ، 한/영 Hangul کو تبدیل کرتا ہے اور 한자 Hanja میں تبدیل کرتا ہے، چاہے آپ کے کی بورڈ میں اس کے لیے مخصوص کیز ہوں یا وہ ان کے لیے Right Alt اور Right Ctrl بھیجتا ہو، جیسا کہ بہت سے لیپ ٹاپس کرتے ہیں، اس لیے وہاں Right Alt اور Right Ctrl سادہ موڈیفائرز نہیں ہیں؛ ڈکٹیشن پش ٹو ٹاک F9 پر ہی رہتا ہے۔ `Ctrl + Space` Tmux اور Herdr کے لیے دستیاب رہتا ہے؛ `Shift + CapsLock` کمپوز کی ہی رہتا ہے۔

جب آپ کے پاس متعدد کی بورڈ لے آؤٹس یا ان پٹ طریقے ہوں تو کی بورڈ انڈیکیٹر بار کے دائیں طرف ظاہر ہوتا ہے۔ ان پٹ زبانیں تبدیل کرنے کے لیے اس پر کلک کریں؛ Japanese میں ہیراگانا کے لیے あ دکھایا جاتا ہے۔ جاپانی حروف کے انتخاب کے لیے، Japanese پر جائیں، `nihongo` جیسا کوئی لفظ ٹائپ کریں، پھر Space دو بار دبائیں۔ اپنی پسند قبول کرنے کے لیے Enter دبائیں۔ اگر آپ کے پاس متعدد کی بورڈ لے آؤٹس بھی ہیں تو ان میں چکر لگانے کے لیے انڈیکیٹر پر رائٹ کلک کریں۔

English اور French جیسے لے آؤٹس منتخب کرنے کے لیے _Setup > Typing > Keyboard Layouts_ استعمال کریں، انہی انتخابوں میں سے جو انسٹالیشن کے دوران پیش کیے گئے تھے۔ کون سے کمپوزیشن انجن فعال ہیں، یہ منتخب کرنے کے لیے _Setup > Typing > Input Methods_ استعمال کریں۔ دونوں پکرز Omarchy مینو کے اندر کھلتے ہیں اور آپ کے موجودہ انتخاب نشان زد ہوتے ہیں۔ کسی انتخاب کو ٹوگل کرنے کے لیے کلک کریں یا Enter دبائیں؛ ہر تبدیلی فوری طور پر نافذ ہوتی ہے۔ کسی ان پٹ طریقے کو غیر منتخب کرنے سے وہ اسے اَن انسٹال کیے بغیر چکر سے ہٹ جاتا ہے؛ کی بورڈ دستیاب رہتا ہے۔

وہی پکرز کھولنے کے لیے `omarchy setup keyboard` یا `omarchy setup input` چلائیں۔ کمانڈ لائن سے ایک زبان شامل کرنے کے لیے `omarchy setup input mozc`، `hangul`، `pinyin`، `chewing` یا `cangjie5` استعمال کریں۔ Quick، Boshiamy اور Array اسی پیکیج میں Cangjie کے ساتھ آتے ہیں اور Input Methods پکر میں ظاہر ہوتے ہیں۔ آپ کی حسبِ ضرورت سوئچنگ کیز محفوظ رہتی ہیں۔ متبادل انجن لے آؤٹس یا کیز کے لیے، `omarchy pkg add fcitx5-configtool` کے ساتھ `fcitx5-configtool` انسٹال کریں اور اسے ٹرمینل سے لانچ کریں۔ ان پٹ زبان منتخب کرنے سے ڈیسک ٹاپ کی زبان تبدیل نہیں ہوتی۔ _Setup > Language_ کے تحت Japanese، Korean یا Chinese منتخب کرنے سے، جب آپ کے پاس ابھی کوئی ان پٹ طریقہ نہ ہو تو اس کا ان پٹ طریقہ شامل ہو جاتا ہے۔

ان پٹ طریقوں یا کی بورڈ لے آؤٹس میں چکر لگانے کے لیے `Super + I` استعمال کریں، اور دوسری طرف واپس جانے کے لیے `Super + Shift + I` استعمال کریں، اس لیے تین ترتیب شدہ ہونے کی صورت میں آپ دو پڑوسیوں کے درمیان آ جا سکتے ہیں۔ ان پٹ انڈیکیٹر بار کے دائیں طرف صرف اسی وقت ظاہر ہوتا ہے جب ایک سے زیادہ ان پٹ طریقے یا لے آؤٹس ترتیب دیے گئے ہوں۔ یہ ڈیسک ٹاپ بائنڈنگ آپ کی موجودہ Fcitx سوئچنگ کیز کے ساتھ ساتھ کام کرتی ہے؛ آپ اسے `~/.config/hypr/bindings.lua` میں اوور رائیڈ کر سکتے ہیں۔ ان پٹ انجن اور کمپوز سیکوینسز ہر سیشن میں پہلے سے چل رہی [Fcitx5](https://fcitx-im.org/) سروس استعمال کرتے ہیں۔

### ALT کو SUPER کے طور پر استعمال کریں

کچھ کی بورڈز پر، پرائمری میٹا کی (Windows/cmd کی) کو SUPER کے طور پر استعمال کرنا آسان نہیں ہوتا۔ آپ اس تبدیلی کے ذریعے اس کے بجائے ALT استعمال کر سکتے ہیں:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
