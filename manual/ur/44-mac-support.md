# Mac کی معاونت

## Apple Silicon کے لیے Omarchy

Apple Silicon کے لیے Omarchy ایک باضابطہ Omacom حل ہے، جو پہلی بار Omarchy 4.5 کے ساتھ جاری ہوا۔ یہ macOS کے ساتھ ساتھ انسٹال ہوتا ہے، اور جب آپ کا Mac شروع ہوتا ہے تو آپ دونوں میں سے انتخاب کرتے ہیں۔

Omarchy Mac کے بارے میں کوئی اطلاع موصول ہوئی ہے؟ [Omarchy Mac سے آنا](#coming-from-omarchy-mac) پر جائیں۔

یہ ان Macs پر چلتا ہے:

| Mac | Chips |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4 اور اس سے نئے Macs ابھی معاونت یافتہ نہیں ہیں۔ M4 کی معاونت edge channel پر جانچ میں ہے اور اگلی آئے گی۔ انسٹالر کوئی تبدیلی کرنے سے پہلے آپ کے Mac کی جانچ کرتا ہے۔

کسی بھی Apple Silicon Mac پر، بشمول M4 اور اس سے نئے، آپ [Try Omarchy](https://github.com/omacom/try-omarchy) کے ساتھ ایک virtual machine میں Omarchy چلا سکتے ہیں۔

### آپ کو کیا چاہیے

- macOS 15 Sequoia یا اس سے بعد کا ورژن، اور ایک administrator اکاؤنٹ
- Omarchy کے لیے خالی ڈسک جگہ۔ انسٹالر ایک سائز تجویز کرتا ہے اور آپ کو اسے تبدیل کرنے دیتا ہے۔
- اپنے Mac کا backup، بجلی، اور ایک انٹرنیٹ کنکشن۔ انسٹالیشن کئی گیگا بائٹس ڈاؤن لوڈ کرتی ہے۔

### انسٹال کرنا

آپ macOS سے انسٹال کرتے ہیں۔ [Homebrew](https://brew.sh) کے ساتھ Omarchy Installer انسٹال کریں:

```sh
brew install omacom/mac/omarchy
```

یا تازہ ترین Omarchy Installer اس کے [ریلیزز صفحے](https://github.com/omacom/omarchy-mac-installer/releases) سے ڈاؤن لوڈ کریں اور اسے کھولیں۔

انسٹالر آپ کے Mac کی جانچ کرتا ہے، آپ کو منصوبہ دکھاتا ہے، اور macOS پارٹیشن کو سکڑ کر Omarchy کے لیے جگہ بناتا ہے۔ macOS ڈسک پر برقرار رہتا ہے اور کسی USB ڈرائیو کی ضرورت نہیں ہے۔ جب پہلا مرحلہ مکمل ہو جائے تو یہ آپ کو macOS Recovery میں سیٹ اپ مکمل کرنے کا طریقہ بتاتا ہے: شٹ ڈاؤن کریں، power بٹن کو اس وقت تک دبائے رکھیں جب تک "Loading startup options" نظر نہ آئے، Omarchy منتخب کریں، اور مراحل پر عمل کریں۔

پہلی بار boot ہونے پر، Omarchy ایک password مانگتا ہے جو اس کی ڈسک کو خفیہ کرتا ہے۔ کوئی recovery key نہیں ہے: اگر آپ password بھول جائیں تو آپ کی Omarchy فائلیں بحال نہیں ہو سکتیں۔

بعد میں Omarchy اور macOS کے درمیان سوئچ کرنے کے لیے، شٹ ڈاؤن کریں، پھر power بٹن کو اس وقت تک دبائے رکھیں جب تک startup options نظر نہ آئیں اور ایک منتخب کریں۔

### Omarchy Mac سے آنا

Omarchy Mac اب Apple Silicon کے لیے Omarchy کا حصہ ہے، اور ہر وہ Mac جو اسے چلاتا تھا معاونت یافتہ ہے۔ آپ کی موجودہ انسٹالیشن چلتی رہے گی، اور اس کے سسٹم پیکجز اب بھی اپ ڈیٹ ہوتے رہیں گے، لیکن اسے مزید Omarchy اپ ڈیٹس نہیں ملیں گی۔ کوئی آخری تاریخ نہیں ہے اور جگہ پر ہی اپ گریڈ کا کوئی طریقہ نہیں ہے: آپ بیک اپ لیتے ہیں، پرانی انسٹالیشن ہٹاتے ہیں، نئی انسٹال کرتے ہیں، اور بحال کرتے ہیں۔ مراحل 2 سے 5 macOS میں ہوتے ہیں، اس لیے دوبارہ شروع کرنے سے پہلے یہ صفحہ اپنے فون پر کھول لیں۔

1. **Omarchy سے، Mac سے باہر بیک اپ لیں۔** پرانی انسٹالیشن ہٹانے سے یہ مٹ جائے گی، اور macOS Omarchy ڈسک کو نہیں پڑھ سکتا۔ اپنے home فولڈر کو کسی بیرونی ڈرائیو یا دوسرے کمپیوٹر پر کاپی کریں، بشمول SSH اور GPG کیز، براؤزر پروفائلز اور غیر push شدہ کام۔ `pacman -Qqe > ~/packages.txt` کے ساتھ اپنی پیکج فہرست محفوظ کریں۔ macOS کا بھی بیک اپ لیں، کیونکہ ہٹانا اور انسٹال کرنا دونوں اس کی ڈسک کا سائز تبدیل کرتے ہیں۔
2. **اپنے Mac کو macOS میں شروع کریں۔** شٹ ڈاؤن کریں، power بٹن کو اس وقت تک دبائے رکھیں جب تک startup options نظر نہ آئیں، اور macOS منتخب کریں۔
3. **Omarchy Installer انسٹال کریں** جیسا کہ [انسٹال کرنا](#installing) میں دکھایا گیا ہے۔
4. **پرانی انسٹالیشن ہٹائیں۔** Omarchy Installer کھولیں اور Installation > Remove Omarchy منتخب کریں۔ یہ دکھاتا ہے کہ یہ کیا حذف کرے گا اور جگہ macOS کو واپس کر دیتا ہے۔ اگر یہ آپ کی انسٹالیشن کو نہیں پہچانتا تو یہ ڈسک میں تبدیلی کیے بغیر رک جاتا ہے۔ partitions کو ہاتھ سے حذف کرنے کے بجائے [Discord](https://discord.gg/tXFUdasqhY) میں مدد مانگیں، جس سے macOS مٹ سکتا ہے۔
5. **Apple Silicon کے لیے Omarchy انسٹال کریں** انسٹالر کے ساتھ۔
6. **اپنی فائلیں بحال کریں۔** تمام `~/.config` کو نئی defaults پر کاپی کرنے کے بجائے اپنی ترتیبات کو ایک ایک حصہ کر کے واپس لائیں، کیونکہ پرانی ترتیبات انہیں override کر سکتی ہیں۔

### جاننا مفید ہے

- M1 اور M2 MacBooks پر، ڈھکن کھول کر یا power بٹن دبا کر نیند سے جگائیں۔
- سوالات یا مسائل: ہمارے [Discord](https://discord.gg/tXFUdasqhY) میں پوچھیں۔

[انسٹالر کی README](https://github.com/omacom/omarchy-mac-installer#readme) release channels، انسٹالر کو اپ ڈیٹ کرنے اور Omarchy ہٹانے کا احاطہ کرتی ہے۔

## Intel والے Macs

ایک سادہ جانچ میں، ہم صرف Omarchy انسٹال کر کے 2019 MacBook Pro پر 36% کارکردگی میں اضافہ حاصل کرنے میں کامیاب رہے۔

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Mac پر Omarchy انسٹال کرنا

Omarchy فی الحال صرف **واحد** OS کے طور پر انسٹال ہونے کی معاونت کرتا ہے۔ انسٹالیشن کے دوران، ڈرائیو صاف ہو جائے گی اور MacOS مزید boot کے قابل نہیں رہے گا۔

اگر آپ چاہیں تو آپ اسے بعد میں Internet Recovery کے ذریعے پھر بھی بحال کر سکتے ہیں۔

اس حصے کے لیے، ہم فرض کریں گے کہ آپ نے پہلے ہی [آغاز کرنا](02-getting-started.md) کا جائزہ لے لیا ہے اور آپ کی USB ڈرائیو تیار ہے۔ اگر نہیں تو آگے بڑھیں اور ابھی یہ کر لیں۔

#### Secure Boot غیر فعال کریں

Boot کے قابل USB کو، اور ساتھ ہی OS کو، boot کرنے کے لیے Apple کے Secure Boot کو غیر فعال کرنا ضروری ہے۔ اسے غیر فعال کرنے کے لیے درج ذیل کریں:

1. اپنے Mac کو بند کریں
2. اسے آن کریں اور _فوراً_ Command-R کو اس وقت تک دبا کر رکھیں جب تک آپ کو loading اسکرین نظر نہ آئے
3. اپنا صارف منتخب کریں اور کہا جائے تو اپنا password درج کریں
4. recovery اسکرین میں آنے کے بعد، menubar سے **Utilities > Startup Security Utility** منتخب کریں
5. تصدیق کے لیے کہا جائے تو اپنا password درج کریں
6. Secure Boot کے اختیارات میں سے "No Security" منتخب کریں
7. External Boot کے اختیارات میں سے "Allow booting from external or removable media" منتخب کریں

#### انسٹالیشن شروع کریں

1. USB ڈرائیو لگائیں
2. اپنے Mac کو دوبارہ شروع کریں اور _فوراً_ Option کو اس وقت تک دبا کر رکھیں جب تک آپ کو boot ڈیوائسز کی اسکرین نظر نہ آئے
3. نارنجی EFI Boot ڈیوائس منتخب کریں
4. [معمول کے مطابق انسٹال](02-getting-started.md) کے ساتھ آگے بڑھیں

انسٹالر Mac hardware کا پتہ لگاتا ہے اور مطلوبہ اصلاحات خودکار طور پر لاگو کرتا ہے: Broadcom Wi-Fi ڈرائیورز اور firmware، ان MacBook ماڈلز پر SPI کی بورڈ ڈرائیور جنہیں اس کی ضرورت ہے، اور انہی ماڈلز کے لیے ایک NVMe suspend اصلاح۔

### معلوم حدود

کمیونٹی کے اراکین ان چیلنجز کے حل پر مسلسل کام کر رہے ہیں، اس لیے اگر یہ آپ کے لیے مسئلہ ہوں تو ہمارے [Discord](https://discord.gg/tXFUdasqhY) میں #omarchy-on-other میں شامل ہوں اور دیکھیں کہ انہیں حل کرنے کے کوئی تازہ ترین طریقے موجود ہیں یا نہیں۔

#### T1 Chip والی ڈیوائسز

Apple T1 chip 2016 کے آخر میں متعارف ہوا تھا اور خصوصی طور پر Touch Bar والے پہلی نسل کے MacBook Pro ماڈلز میں استعمال ہوا تھا۔
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### معلوم مسائل

- Touch Bar کام نہیں کرتا
- آواز کام نہیں کرتی

#### T2 Chip والی ڈیوائسز

Apple T2 Security Chip 2017 میں متعارف ہوا تھا۔ T2 chip 2020 سے شروع ہونے والی Apple silicon (M-series chips) کی طرف منتقلی کے ساتھ بند کر دیا گیا تھا۔

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

ان ماڈلز پر، انسٹالر خودکار طور پر patched `linux-t2` kernel، T2 آڈیو ترتیب، Apple کے Broadcom Wi-Fi/Bluetooth firmware، اور `t2fanrd` کے ذریعے fan کنٹرول سیٹ اپ کرتا ہے۔ Touch Bar kernel کی بلٹ ان Boot Camp طرز کی معاونت پر چلتا ہے۔

#### iMac Retina 5K (2017)

2017 کے 27-inch iMac میں کوئی T2 chip نہیں ہے، اس لیے انسٹالر اسے دوسرے Intel Macs کی طرح سیٹ اپ کرتا ہے۔

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### معلوم مسائل

- ڈسپلے اپنے اصل 5120×2880 پر نہیں چلتا: پینل دو tiles پر مشتمل ہے، اور stock ڈرائیور صرف ایک کو روشن کرتا ہے
- آواز کام نہیں کرتی
- چمک کا کنٹرول کوئی اثر نہیں کرتا
- Sleep مشین کو ہینگ کر دیتی ہے؛ صرف ایک power cycle ہی اسے بحال کرتا ہے

اس ماڈل کے لیے ایک کمیونٹی patcher ڈسپلے، آواز اور چمک کو ٹھیک کرتا ہے: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
