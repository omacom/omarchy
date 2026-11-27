# برانڈنگ

Omarchy آپ کو boot unlock، screensaver، اور about screen کے لیے اپنی company کا logo یا ذاتی image سیٹ کرنے کی سہولت دیتا ہے۔

### Boot unlock

آپ `omarchy plymouth preview` استعمال کر کے دیکھ سکتے ہیں کہ آپ کا کسٹم logo اور colors کیسے نظر آئیں گے۔ یہ ایک background color، ایک text color، ایک logo png، اور preview image کے لیے ایک path لیتا ہے:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

پھر `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png` کے ساتھ setup apply کریں، جو SDDM login screen کو بھی وہی colors اور logo دے گا۔ اگر آپ واپس پلٹنا چاہیں تو `omarchy plymouth reset` استعمال کر سکتے ہیں۔

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Screensaver

آپ screensaver کے لیے استعمال ہونے والا logo _Appearance > Branding > Screensaver_ میں جا کر تبدیل کر سکتے ہیں۔ یہ ایک ASCII logo ہے، اس لیے آپ text کو براہ راست edit کر سکتے ہیں، لیکن آپ اسے png یا svg image بھی دے سکتے ہیں، اور ہم اسے ASCII میں تبدیل کر دیں گے۔ یہ کافی زبردست لگتا ہے۔

 ![branding-screensaver](images/branding-screensaver.webp)

اس menu میں تین entries ہیں:

- **Edit Text** آپ کے editor میں `~/.config/omarchy/branding/screensaver.txt` کھولتا ہے۔ جو چاہیں type یا paste کریں — ASCII art، اپنا نام، کوئی ناشائستہ لفظ۔ Save کر کے بند کریں، اور screensaver فوراً چل پڑتا ہے تاکہ آپ اسے دیکھ سکیں۔
- **Set From Image** png یا svg کے لیے ایک file picker کھولتا ہے، اسے ASCII میں تبدیل کرتا ہے، اور آپ کو نتیجہ دکھاتا ہے۔ واضح silhouette والے logos photos کے مقابلے میں کہیں بہتر کام کرتے ہیں۔
- **Restore Default** Omarchy logo واپس لگا دیتا ہے۔

### About screen

وہی تین options _Appearance > Branding > About_ میں اس _About_ screen کے لیے موجود ہیں جو آپ کو Omarchy menu سے ملتی ہے، اور یہ بالکل اسی طرح کام کرتی ہیں — file `~/.config/omarchy/branding/about.txt` ہے، اور ہر تبدیلی کے بعد About window سامنے آ جاتا ہے۔ About art کو screensaver کے مقابلے میں چھوٹے size میں تبدیل کیا جاتا ہے، کیونکہ اسے آپ کی پوری display بھرنے کے بجائے ایک window میں فٹ ہونا ہوتا ہے۔

جب window کھلا ہوتا ہے تو ہر چند seconds میں روشن سفید روشنی کی ایک پٹی art پر ترچھی گزرتی ہے اور پھر اسے دوبارہ ساکن چھوڑ دیتی ہے۔ آپ کے اپنے art کو بھی یہی ملتا ہے، بشرطیکہ اس کا ہر character ایک column چوڑا ہو — _Set From Image_ سے بننے والی ہر چیز ایسی ہی ہوتی ہے۔ emoji یا double-width characters سے بنا ہوا art اس کے بجائے ساکن رہتا ہے، اور اسی طرح وہ screen بھی اگر آپ اپنی خود کی fastfetch config رکھیں: ان صورتوں میں ساکن logo animation کی ناکامی نہیں ہے بلکہ اس کا راستے سے ہٹے رہنا ہے، کیونکہ ان پر چمک سرکانے سے line کا باقی حصہ غلط جگہ پر جا گرے گا۔

 ![branding-about](images/branding-about.webp)

### Converting images yourself

دونوں _Set From Image_ options بس `omarchy transcode ascii` کو call کر رہی ہوتی ہیں، جسے آپ براہ راست چلا سکتے ہیں اگر آپ conversion پر کنٹرول چاہتے ہیں:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

یہ terminal columns اور rows میں `--width` اور `--height`، `braille` (default، اور کہیں زیادہ باریک) یا `block` میں سے کسی ایک کا `--mode`، یہ فیصلہ کرنے کے لیے کہ کون سے pixels logo کا حصہ شمار ہوں گے ایک `--threshold` percentage، اور جب آپ کا logo dark background پر light ہو تو اس کے لیے `--invert` لیتا ہے۔ اگر کوئی conversion ایک دھبے کی صورت میں نکلے تو عام طور پر threshold ہی وہ knob ہے جسے گھمانا چاہیے۔

### Words instead of a logo

`omarchy ascii` Delta Corps Priest 1 میں text بناتا ہے، وہی FIGlet font جس میں خود Omarchy wordmark بنا ہوا ہے، اس لیے screensaver تصویر دکھانے کے بجائے کچھ کہہ سکتا ہے:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

یہ text کو arguments کے طور پر لیتا ہے، یا جب کوئی argument نہ دیا گیا ہو تو اسے pipe سے پڑھتا ہے۔ font میں صرف حروف اور spaces ہیں — یہ digits یا punctuation کے بغیر بنایا گیا تھا — اس لیے اس کے علاوہ ہر چیز کو چھوڑ دیا جاتا ہے اور stderr پر اس کا نام لیا جاتا ہے، خاموشی سے نگلا نہیں جاتا۔
