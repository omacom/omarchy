# Mac سپورٹ

Omarchy میں **Intel Macs** کے لیے built-in سپورٹ موجود ہے۔ اس وقت چند معلوم حدود ہیں، لیکن جب تک آپ ان سے واقف ہیں اور آپ کو ان پر کوئی اعتراض نہیں؛ آپ Omarchy لوڈ کر کے اپنے پرانے Macs میں نئی جان ڈال سکتے ہیں۔

براہ کرم نوٹ کریں کہ M-series Mac پر انسٹال کرنا اس وقت براہ راست سپورٹ نہیں کیا جاتا۔ آپ ہمارے [Discord](https://discord.gg/tXFUdasqhY) میں #omarchy-on-other میں اس کی صورتحال کے بارے میں مزید جان سکتے ہیں۔

ایک سادہ ٹیسٹ میں، ہم صرف Omarchy انسٹال کر کے 2019 MacBook Pro پر 36% کارکردگی میں اضافہ حاصل کرنے میں کامیاب رہے۔

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Mac پر Omarchy انسٹال کرنا

Omarchy فی الحال **واحد** OS کے طور پر انسٹال ہونے کو ہی سپورٹ کرتا ہے۔ انسٹالیشن کے دوران، ڈرائیو صاف کر دی جائے گی اور MacOS مزید بوٹ کے قابل نہیں رہے گا۔

اگر آپ چاہیں تو بعد میں Internet Recovery کے ذریعے اسے پھر بھی بحال کر سکتے ہیں۔

اس حصے کے لیے، ہم فرض کریں گے کہ آپ پہلے ہی [Getting Started](02-getting-started.md) کا جائزہ لے چکے ہیں اور آپ کی USB ڈرائیو تیار ہے۔ اگر نہیں تو آگے بڑھیں اور ابھی یہ کر لیں۔

#### Secure Boot غیر فعال کریں

بوٹ ایبل USB کے ساتھ ساتھ OS کو بھی بوٹ کرنے کے لیے Apple کے Secure Boot کو غیر فعال کرنا ضروری ہے۔ اسے غیر فعال کرنے کے لیے درج ذیل اقدامات کریں:

1. اپنا Mac بند کریں
2. اسے آن کریں اور _فوری طور پر_ Command-R دبا کر رکھیں جب تک آپ کو لوڈنگ اسکرین دکھائی نہ دے
3. اپنا صارف منتخب کریں اور اشارہ ملنے پر اپنا پاس ورڈ درج کریں
4. ریکوری اسکرین میں آنے کے بعد، مینو بار سے **Utilities > Startup Security Utility** منتخب کریں
5. تصدیق کے لیے اشارہ ملنے پر اپنا پاس ورڈ درج کریں
6. Secure Boot اختیارات میں سے "No Security" منتخب کریں
7. External Boot اختیارات میں سے "Allow booting from external or removable media" منتخب کریں

#### انسٹالیشن شروع کریں

1. USB ڈرائیو داخل کریں
2. اپنا Mac ری اسٹارٹ کریں اور _فوری طور پر_ Option دبا کر رکھیں جب تک آپ کو بوٹ ڈیوائسز کی اسکرین دکھائی نہ دے
3. نارنجی EFI Boot ڈیوائس منتخب کریں
4. [معمول کے مطابق انسٹال](02-getting-started.md) کے ساتھ آگے بڑھیں

انسٹالر Mac ہارڈویئر کا پتہ لگاتا ہے اور ضروری اصلاحات خود بخود لاگو کرتا ہے: Broadcom Wi-Fi ڈرائیورز اور فرم ویئر، ان MacBook ماڈلز پر SPI کی بورڈ ڈرائیور جنہیں اس کی ضرورت ہوتی ہے، اور انہی ماڈلز کے لیے NVMe سسپینڈ اصلاح۔

### معلوم حدود

کمیونٹی کے ارکان ان چیلنجز کے حل پر مسلسل کام کر رہے ہیں لہذا اگر یہ آپ کے لیے مسئلہ ہیں، تو ہمارے [Discord](https://discord.gg/tXFUdasqhY) میں #omarchy-on-other میں شامل ہوں اور دیکھیں کہ آیا ان کو حل کرنے کے لیے کوئی تازہ ترین طریقے موجود ہیں۔

#### T1 Chip والی ڈیوائسز

Apple T1 chip 2016 کے آخر میں متعارف کرائی گئی تھی اور خصوصی طور پر Touch Bar والے پہلی نسل کے MacBook Pro ماڈلز میں استعمال ہوئی تھی۔
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### معلوم مسائل

- Touch Bar غیر فعال ہے
- آواز کام نہیں کر رہی

#### T2 Chip والی ڈیوائسز

Apple T2 Security Chip 2017 میں متعارف کرائی گئی تھی۔ 2020 سے شروع ہونے والی Apple silicon (M-series chips) کی طرف منتقلی کے ساتھ T2 chip بند کر دی گئی تھی۔

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

ان ماڈلز پر، انسٹالر خود بخود پیچ شدہ `linux-t2` کرنل، T2 آڈیو کنفیگریشن، Apple کے Broadcom Wi-Fi/Bluetooth فرم ویئر، اور `t2fanrd` کے ذریعے فین کنٹرول سیٹ اپ کرتا ہے۔ Touch Bar کرنل کی built-in Boot Camp طرز کی سپورٹ پر چلتی ہے۔

#### iMac Retina 5K (2017)

2017 کے 27-inch iMac میں کوئی T2 chip نہیں ہے، لہذا انسٹالر اسے دوسرے Intel Macs کی طرح سیٹ اپ کرتا ہے۔

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### معلوم مسائل

- ڈسپلے اپنے اصل 5120×2880 پر نہیں چلتا: پینل دو ٹائلز پر مشتمل ہے، اور اسٹاک ڈرائیور صرف ایک کو روشن کرتا ہے
- آواز کام نہیں کر رہی
- چمک کے کنٹرول کا کوئی اثر نہیں ہوتا
- Sleep مشین کو ہینگ کر دیتی ہے؛ صرف پاور سائیکل ہی اسے بحال کرتا ہے

اس ماڈل کے لیے ایک کمیونٹی پیچر ڈسپلے، آواز اور چمک کو ٹھیک کرتا ہے: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3)۔
