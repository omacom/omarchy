# تھیمز

Omarchy تیئیس خوبصورت تھیمز کے ساتھ آتا ہے۔ آپ Omarchy Menu (`Super + Space`) میں _Appearance > Theme_ کے ذریعے ان میں سے انتخاب کر سکتے ہیں یا `Super + Ctrl + T` استعمال کر کے براہ راست تھیم منتخب کرنے والے تک جا سکتے ہیں۔

ہر تھیم ڈیسک ٹاپ، ٹرمینل، neovim، ایکٹیویٹی اسکرین (btop)، آپ کے براؤزر (Chrome، Chromium، Edge یا Brave)، اور پورے Omarchy شیل کو اسٹائل دیتی ہے: ٹاپ بار، مینو، اطلاعات، OSD، اور لاک اسکرین۔ (Obsidian کے لیے، آپ کو ایپ کے اندر _Appearance > Themes_ کے ذریعے دستی طور پر Omarchy تھیم منتخب کرنی ہوگی)۔

تھیمز میں پس منظر کی تصاویر کا ایک سیٹ ہوتا ہے جن میں سے آپ `Super + Ctrl + W` استعمال کر کے انتخاب کر سکتے ہیں۔

آپ [اضافی تھیمز کے صفحے](https://omarchy.org/themes/) پر مزید تھیمز بھی تلاش کر سکتے ہیں یا حتیٰ کہ [اپنی خود کی تھیم بھی بنا سکتے ہیں](43-making-your-own-theme.md)۔

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

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### ایپ آئیکنز

ایپ لانچر اور ڈاک میں موجود آئیکنز آپ کی تھیم کے رنگوں میں بنائے جاتے ہیں، اس لیے وہ اس کے ساتھ ہی بدل جاتے ہیں۔ وہ ایک آئیکن سیٹ سے آتے ہیں، جسے آپ تھیم سے الگ _Appearance > Icons_ کے تحت، ہر سیٹ کے پیش نظاروں سے، بالکل اسی طرح منتخب کرتے ہیں جیسے آپ تھیم منتخب کرتے ہیں:

- _Papercraft_ ڈیفالٹ ہے: جو کچھ بھی انسٹال ہو کر آتا ہے، ایک ہی اسٹائل میں بنایا گیا۔ وہ ایپس جو اپنے لوگو سے پہچانی جاتی ہیں، جیسے Chrome، HEY، یا YouTube، اپنی شکل برقرار رکھتی ہیں اور تھیم کے رنگ اختیار کر لیتی ہیں۔
- _Arcade_ انہی ایپس کو 8-bit پکسل آرٹ کے طور پر بناتا ہے، جیسے کوئی پرانا گیم کنسول بناتا۔
- _Original_ ہر ایپ کو اسی آئیکن کے ساتھ دکھاتا ہے جو اس کے بنانے والے نے اسے دیا تھا۔

آپ _Install > Style > Icons_ (یا `omarchy icons install <git url>`) کے ساتھ کسی اور کا بنایا ہوا آئیکن سیٹ انسٹال کر سکتے ہیں، اور اسے _Remove > Icons_ کے تحت دوبارہ ہٹا سکتے ہیں۔ _Update > Extra Icons_ آپ کے انسٹال کردہ سیٹس کا تازہ ترین ورژن حاصل کرتا ہے۔

اپنا خود کا بنانے کے لیے، اپنے آئیکنز `~/.config/omarchy/icons/<name>/` میں رکھیں، ہر ایپ کے لیے ایک فائل، جس کا نام ایپ کی `.desktop` فائل کی `Icon=` لائن کے مطابق رکھا گیا ہو۔ `.svg` پر ختم ہونے والی فائل جیسی ہے ویسی ہی دکھائی جاتی ہے۔ `.svg.tpl` پر ختم ہونے والی فائل تھیم کے رنگوں میں بنائی جاتی ہے: جہاں رنگ آتا ہو وہاں `{{ icon_main }}`، `{{ icon_mark }}`، `{{ icon_paper }}`، `{{ icon_body }}`، `{{ icon_edge }}`، `{{ icon_ink }}` یا `{{ icon_shadow }}` لکھیں۔ `/usr/share/omarchy/icons/papercraft/` میں موجود ڈیفالٹ سیٹ آغاز کے لیے ایک اچھی جگہ ہے۔ منتخب کرنے والے میں اپنا سیٹ دکھانے کے لیے ایک `preview.png` شامل کریں؛ اس کے بغیر، Omarchy آپ کے آئیکنز سے ایک پیش نظارہ بناتا ہے۔ ڈیفالٹ سیٹ کے کسی ایک آئیکن کو بدلنے کے لیے، اپنا ورژن `~/.config/omarchy/icons/papercraft/` میں رکھیں۔

### بوٹ اور لاگ ان

وہ اسکرین جو کمپیوٹر شروع ہونے پر آپ سے آپ کا ڈرائیو پاس ورڈ مانگتی ہے، اور لاگ ان اسکرین، بھی تھیم کی پیروی کرتی ہیں۔ ہر بار جب آپ تھیمز بدلتے ہیں، وہ اس کا پس منظر، متن، ایکسینٹ، اور سرخ رنگ اختیار کر لیتی ہیں، اس لیے منتخب کرنے کے لیے کوئی الگ ان لاک ڈیزائن نہیں ہے۔ Apple Silicon Macs پر، ڈرائیو پاس ورڈ اسکرین تھیم چاہے کوئی بھی ہو Omarchy کی ڈیفالٹ شکل برقرار رکھتی ہے۔
