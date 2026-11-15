# تھیمز

Omarchy بائیس خوبصورت تھیمز کے ساتھ آتا ہے۔ آپ Omarchy Menu (`Super + Space`) میں _Appearance > Theme_ کے ذریعے ان میں سے انتخاب کر سکتے ہیں یا `Super + Ctrl + T` استعمال کر کے براہ راست تھیم سلیکٹر پر جا سکتے ہیں۔

ہر تھیم ڈیسک ٹاپ، ٹرمینل، neovim، سرگرمی اسکرین (btop)، Chromium، اور پورے Omarchy شیل کو اسٹائل دیتی ہے: ٹاپ بار، مینو، نوٹیفکیشنز، OSD، اور لاک اسکرین۔ (Obsidian کے لیے، آپ کو ایپ کے اندر _Appearance > Themes_ کے ذریعے دستی طور پر Omarchy تھیم منتخب کرنا ہوگی)۔

تھیمز کے پاس پس منظر کی تصاویر کا ایک سیٹ ہوتا ہے جن میں سے آپ `Super + Ctrl + W` استعمال کر کے انتخاب کر سکتے ہیں۔

آپ [اضافی تھیمز کے صفحے](https://omarchy.org/themes/) پر مزید تھیمز بھی تلاش کر سکتے ہیں یا یہاں تک کہ [اپنی تھیم خود بنا سکتے ہیں](43-making-your-own-theme.md)۔

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

### ایپ آئیکنز

ایپ لانچر اور ڈاک میں آئیکنز آپ کی تھیم کے رنگوں میں بنائے جاتے ہیں، اس لیے وہ اس کے ساتھ بدل جاتے ہیں۔ وہ ایک آئیکن سیٹ سے آتے ہیں، جسے آپ _Appearance > Icons_ کے تحت تھیم سے الگ منتخب کرتے ہیں:

- _Papercraft_ ڈیفالٹ ہے: جو کچھ بھی انسٹال شدہ آتا ہے، سب ایک ہی انداز میں بنایا گیا ہے۔ وہ ایپس جو اپنے لوگو سے پہچانی جاتی ہیں، جیسے Chrome، HEY، یا YouTube، اپنی شکل برقرار رکھتی ہیں اور تھیم کے رنگ اپنا لیتی ہیں۔
- _Arcade_ انہی ایپس کو 8-bit پکسل آرٹ کے طور پر بناتا ہے، جیسے کوئی پرانا گیم کنسول بناتا۔
- _Original_ ہر ایپ کو اس آئیکن کے ساتھ دکھاتا ہے جو اس کے بنانے والے نے اسے دیا تھا۔

آپ کسی اور کے بنائے ہوئے آئیکن سیٹ کو _Install > Style > Icons_ کے ساتھ (یا `omarchy icons install <git url>`) انسٹال کر سکتے ہیں، اور اسے _Remove > Icons_ کے تحت دوبارہ ہٹا سکتے ہیں۔ _Update > Extra Icons_ آپ کے انسٹال کردہ سیٹس کا تازہ ترین ورژن حاصل کرتا ہے۔

اپنا سیٹ بنانے کے لیے، اپنے آئیکنز کو `~/.config/omarchy/icons/<name>/` میں رکھیں، ہر ایپ کے لیے ایک فائل، جس کا نام ایپ کی `.desktop` فائل کی `Icon=` لائن کے مطابق رکھا گیا ہو۔ `.svg` پر ختم ہونے والی فائل جیسی ہے ویسی ہی دکھائی جاتی ہے۔ `.svg.tpl` پر ختم ہونے والی فائل تھیم کے رنگوں میں بنائی جاتی ہے: جہاں رنگ آنا ہو وہاں `{{ icon_main }}`، `{{ icon_mark }}`، `{{ icon_paper }}`، `{{ icon_body }}`، `{{ icon_edge }}`، `{{ icon_ink }}` یا `{{ icon_shadow }}` لکھیں۔ `/usr/share/omarchy/icons/papercraft/` میں موجود ڈیفالٹ سیٹ شروع کرنے کے لیے ایک اچھی جگہ ہے۔ ڈیفالٹ سیٹ کے کسی ایک آئیکن کو بدلنے کے لیے، اپنا ورژن `~/.config/omarchy/icons/papercraft/` میں رکھیں۔

### ان لاکس

تھیمز کا ایک حسب ضرورت ان لاک ڈیزائن بھی ہو سکتا ہے، جو بوٹ ڈکرپشن کے عمل کے لیے استعمال ہوتا ہے۔ آپ ان میں سے ایک کو _Appearance > Unlock_ کے تحت منتخب کر سکتے ہیں۔ وہ اس طرح نظر آتے ہیں:

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
