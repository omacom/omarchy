# آغاز کرنا

Omarchy کو ایک ISO استعمال کر کے انسٹال کیا جاتا ہے۔ آپ full-disk انسٹال کے درمیان انتخاب کر سکتے ہیں، جو پوری ڈرائیو پر قبضہ کر لیتا ہے، یا free-space انسٹال کے درمیان، جو Omarchy کو ڈرائیو پر موجود غیر مختص جگہ میں رکھتا ہے — اسی طرح آپ Windows یا کسی دوسرے OS کے ساتھ dual boot کرتے ہیں (دیکھیں [dual-boot انسٹال](50-dual-boot-install.md) — نوٹ کریں کہ آپ کو پہلے Windows میں BitLocker بند کرنا ہوگا)۔ کسی بھی صورت میں، انسٹالیشن بطور ڈیفالٹ مکمل encryption پر ہوتی ہے، اور full-disk آپشن منتخب ڈرائیو کو صاف کر دے گا، اس لیے موجودہ ڈرائیو استعمال کرنے سے پہلے backup لینا یقینی بنائیں!

پہلے [Omarchy ISO ڈاؤن لوڈ کریں](https://omarchy.org/)، اسے ایک USB stick پر رکھیں (Mac/Windows پر [balenaEtcher](https://etcher.balena.io/) یا Linux پر [caligula](https://github.com/ifd3f/caligula) استعمال کریں)، اور stick سے boot کریں۔

_آپ کو BIOS میں Secure Boot اور/یا TPM بند کرنا ہوگا۔ Omarchy انسٹال کر سکنے کے لیے آپ کو انہیں بند کرنا ہوگا۔ یہ Microsoft کی security اسکیمیں ہیں جو Windows اور Microsoft سے وابستہ Linux distributions کے لیے بنی ہیں۔_

پھر configuration کے سوالات کے جواب دیں، اور اس طرح ان کی تصدیق کریں:

 ![install-config](images/install-config.webp)

پھر اپنی انسٹالیشن کے لیے ایک ڈرائیو منتخب کریں، اور آرام سے بیٹھ کر انسٹالیشن کا شو دیکھیں۔ یہ تیز ترین جدید مشینوں پر ایک منٹ سے کم میں مکمل ہو سکتا ہے، لیکن پرانے کمپیوٹر پر بھی اسے 5 منٹ سے زیادہ نہیں لگنا چاہیے۔

 ![install-done](images/install-done.webp)

اب آپ Omarchy کے لیے تیار ہیں!

### wired یا 2.4ghz کی بورڈ استعمال کریں!

full-disk encryption آپ کو startup پر Bluetooth کی بورڈ سے password درج کرنے نہیں دے گی۔ بالکل اسی طرح جیسے آپ PC پر BIOS میں داخل ہونے کے لیے Bluetooth کی بورڈ استعمال نہیں کر سکتے۔ آپ کو ایسے کی بورڈ کی ضرورت ہوگی جو یا تو 2.4ghz dongle استعمال کرتا ہو یا cable (جو ویسے بھی latency کے لیے کہیں بہتر ہے!)۔ مجھے ذاتی طور پر [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard) بہت پسند ہے!

### کسی دوسرے مالک کے لیے انسٹال کرنا

اگر آپ کسی اور کے لیے مشین سیٹ اپ کر رہے ہیں — خاندان کے کسی فرد، نئے ملازم، خریدار کے لیے — تو آپ کو ان کی طرف سے ذاتی سوالات کے جواب نہیں دینے چاہئیں۔ انسٹالر کی بالکل پہلی اسکرین (keyboard selection) پر `Ctrl + C` دبائیں، اور Omarchy اس کے بجائے مشین کو کسی دوسرے مالک کے لیے تیار کرنے کی پیشکش کرے گا۔ سسٹم فوراً انسٹال ہو جاتا ہے، لیکن تمام ذاتی سیٹ اپ — keyboard layout، username، password — اس وقت تک مؤخر رہتا ہے جب تک مشین پہلی بار boot نہ ہو۔ ڈرائیو اب بھی بطور ڈیفالٹ encrypted ہوتی ہے، اور وہ password جو نیا مالک اس پہلی boot پر منتخب کرتا ہے وہی encryption password بھی بن جاتا ہے۔ (جس مشین کو آپ پہلے سے استعمال کر رہے ہیں اسے دوبارہ انسٹال کیے بغیر بھی حوالے کیا جا سکتا ہے — دیکھیں [کمپیوٹر کو reset کرنا](48-security.md)۔)

### بغیر نگرانی انسٹالز

ISO مکمل طور پر خود بھی انسٹال ہو سکتا ہے — کوئی keyboard نہیں، کوئی wizard نہیں — جب اسے اس کی configuration دوسری ڈرائیو پر دی جائے۔ یہی طریقہ ہے Omarchy کو VMs اور fleet مشینوں کے لیے base image کے طور پر استعمال کرنے کا۔ دیکھیں [بغیر نگرانی انسٹالز](51-unattended-installs.md)۔

### بغیر encryption انسٹالیشنز

Omarchy بطور ڈیفالٹ encryption کے ساتھ انسٹال ہوتا ہے۔ یہ کسی بھی ایسے کمپیوٹر کے لیے محفوظ، ذمہ دارانہ انتخاب ہے جو ممکنہ طور پر گم یا چوری ہو سکتا ہے۔ آپ نہیں چاہتے کہ جس کسی کو بھی آپ کے hardware تک رسائی حاصل ہو وہ آپ کا data حاصل کر سکے!

لیکن خاص حالات میں، جیسے محفوظ کمپیوٹرز پر remote Omarchy انسٹالز یا حساس data کے بغیر عارضی انسٹالیشنز کے لیے، آپ بغیر encryption انسٹال کرنا چاہ سکتے ہیں۔ آپ disk formatting کی تصدیق پر `Ctrl + C` دبا کر بغیر encryption والی انسٹالیشن پر switch کر سکتے ہیں۔

### زبان

Omarchy 50 زبانیں بولتا ہے — وہی مجموعہ جو omarchy.org کا ہے — اور انگریزی ڈیفالٹ ہے۔ تبدیل کرنے کے لیے، Omarchy menu کھولیں اور _Setup > Language_ پر جائیں، یا terminal میں `omarchy language <code>` چلائیں (`omarchy language list` codes دکھاتا ہے)۔ menu، desktop، اور Omarchy کی اپنی notifications فوراً زبان بدل دیتی ہیں، اور اس کے بعد آپ جو بھی application کھولتے ہیں وہ بھی اسی کی پیروی کرتی ہے۔ جو apps پہلے سے کھلی تھیں وہ انہیں restart کرنے کے بعد تبدیل ہوتی ہیں۔

### اگر آپ پھنس جائیں تو مدد

اگر آپ پھنس جائیں، تو آپ کو عام طور پر [کمیونٹی Discord](https://omarchy.org/discord) پر _#omarchy-help_ چینل میں مدد کے لیے تیار کوئی نہ کوئی مل جاتا ہے۔
