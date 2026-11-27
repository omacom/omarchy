# اپ ڈیٹس

Omarchy مینیو (`Super + Space`) میں _Update > Omarchy_ کے ذریعے Omarchy اور آپ کے پیکیجز کو اپ ڈیٹ رکھا جاتا ہے۔

Omarchy خود [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs) سے باقاعدہ pacman پیکیجز کے طور پر انسٹال ہوتا ہے، اس لیے ایک اپ ڈیٹ [تازہ ترین Omarchy ریلیز](https://github.com/omacom/omarchy/releases) انسٹال کرتی ہے، آپ کے سسٹم کو تازہ ترین کے ساتھ ہم آہنگ کرنے کے لیے کوئی بھی زیرِ التوا migrations چلاتی ہے، اور [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) اور [AUR](https://aur.archlinux.org/) سے تمام سسٹم پیکیجز اپ ڈیٹ کرتی ہے (اگر آپ نے کوئی AUR پیکیجز انسٹال کیے ہوں)۔

جب نئی ریلیزز آتی ہیں، تو آپ کی گھڑی کے دائیں جانب ایک دائرے والے تیر کا آئیکن ظاہر ہوگا۔ اس پر کلک کریں اور اپ ڈیٹ کا عمل شروع ہو جائے گا۔

![update-available](images/update-available.webp)

### چار چینلز

Omarchy کو چار چینلز کے ساتھ اپ ڈیٹ کیا جاتا ہے: stable، RC، edge، اور dev۔ نئی انسٹالیشنز stable چینل سے شروع ہوتی ہیں، جو [سرکاری ریلیزز](https://github.com/omacom/omarchy/releases/) کے ساتھ ساتھ [stable Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror) کو بھی فالو کرتا ہے جو تازہ ترین سے ایک ماہ پیچھے چلتا ہے، تاکہ ہم کسی بھی نئی عدم مطابقت کو، جس کے لیے config میں تبدیلیوں کی ضرورت ہو، لوگوں کے لیے مسائل پیدا کرنے سے پہلے پکڑ سکیں۔

لیکن اگر آپ ان ممکنہ مسائل کو تلاش کرنے میں مدد کرنا چاہتے ہیں، تو آپ edge چینل پر چل سکتے ہیں۔ اس سے آپ کے Omarchy پیکیجز تازہ ترین development builds کو فالو کرتے رہیں گے، اور آپ تازہ ترین Arch پیکیجز جیسے ہی دستیاب ہوں انہیں اپ ڈیٹ کر سکیں گے۔ آپ کو یہ صرف اسی صورت میں کرنا چاہیے جب آپ Linux کے تجربہ کار ہوں، اور جانتے ہوں کہ مسائل والے سسٹم کو کیسے بحال کرنا ہے۔

کسی بھی نئی بڑی ریلیز سے پہلے، ہم RC چینل کا استعمال کرتے ہوئے حتمی جانچ کریں گے۔ اگر آپ حتمی پالش میں مدد کرنے میں دلچسپی رکھتے ہیں، تو Discord پر #omarchy-release-candidates میں آ کر ہمارے ساتھ وقت گزاریں۔

آخر میں، dev چینل ہے، جو Omarchy کو براہِ راست `~/omarchy` میں موجود source code کے git checkout سے جوڑتا ہے، edge پیکیجز کے ساتھ ملا کر۔ آپ کو یہ چینل صرف اسی صورت میں استعمال کرنا چاہیے جب آپ تجربہ کار Linux صارف ہوں، براہِ راست Omarchy پر کام کر رہے ہوں، اور خرابی برداشت کرنے کے لیے تیار ہوں۔

آپ Omarchy مینیو سے _Update > Channel_ کا استعمال کرتے ہوئے چینلز کے درمیان سوئچ کر سکتے ہیں (یا terminal میں `omarchy channel set <stable|rc|edge|dev>`، اور آپ کہاں ہیں یہ دیکھنے کے لیے `omarchy channel current` کے ساتھ)۔

### کرنلز تبدیل کرنا

Omarchy اپنا `linux-omarchy` کرنل بوٹ کرتا ہے، لیکن آپ اس کے ساتھ دوسرے کرنل بھی انسٹال رکھ سکتے ہیں، جیسے stock Arch `linux` کرنل یا کوئی تجرباتی build جسے آپ آزما رہے ہوں۔ جب ایک سے زیادہ ہوں، تو Omarchy مینیو میں _Update > Kernel_ انہیں فہرست میں دکھاتا ہے اور جو بطورِ default بوٹ ہوتا ہے اس کے ساتھ ایک check کا نشان ہوتا ہے۔ کوئی دوسرا منتخب کریں، ایک بار اپنا password درج کریں، اور یہ اگلی restart کے بعد بوٹ ہو جائے گا۔ دوسرے کرنلز boot مینیو میں رہتے ہیں، اس لیے اگر نیا default آپ کو پریشانی دے تو آپ پھر بھی ہاتھ سے ایک منتخب کر سکتے ہیں۔ Terminal میں، موجودہ default دیکھنے کے لیے `omarchy kernel`، جو انسٹال ہے اس کے لیے `omarchy kernel list`، اور سوئچ کرنے کے لیے `omarchy kernel set <kernel>` ہے۔

### Firmware اپ ڈیٹس

صرف آپ کے پیکیجز ہی پرانے نہیں ہوتے۔ بہت سے laptops اور peripherals BIOS، SSD، اور dock firmware Linux Vendor Firmware Service کے ذریعے بھیجتے ہیں، اور Omarchy مینیو میں _Update > Firmware_ آپ کے hardware کے لیے جو بھی انتظار میں ہے وہ fetch اور انسٹال کر دے گا۔ یہ پہلی بار چلانے پر `fwupd` انسٹال کرتا ہے۔ بہت سا firmware صرف reboot کے دوران ہی لکھا جا سکتا ہے، اس لیے اگر آپ سے reboot کے لیے کہا جائے تو حیران نہ ہوں۔

جب آپ کو خود BIOS میں کوئی setting تبدیل کرنے کی ضرورت ہو، تو system مینیو (`Super + Escape`) میں `Alt` دبائے رکھیں اور _Reboot_ بدل کر _Reboot to BIOS_ ہو جائے گا، جو boot پر صحیح key پکڑے بغیر براہِ راست firmware setup میں restart کر دیتا ہے۔ Terminal سے، یہ `omarchy system firmware` ہے۔

### براہِ راست pacman/yay اپ ڈیٹس کے بارے میں انتباہ

اگر آپ پہلے سے Arch سے واقف ہیں، تو آپ کا دل چاہ سکتا ہے کہ بس خود `pacman -Syu` یا `yay -Syu` چلا دیں، لیکن اگر آپ ایسا کرتے ہیں، تو آپ وہ snapshot، migrations، اور configuration اپ ڈیٹس چھوڑ دیں گے جو Omarchy نئے پیکیجز کے ساتھ مل کر چلاتا ہے۔ اسی لیے Omarchy درحقیقت براہِ راست system upgrade کو روک دے گا اور اس کے بجائے آپ کو `omarchy update` کی طرف بھیج دے گا۔ (اگر آپ واقعی جانتے ہیں کہ آپ کیا کر رہے ہیں، تو guard آپ کو بتائے گا کہ اسے ایک ہی transaction کے لیے کیسے bypass کرنا ہے۔)

### خراب اپ ڈیٹس کو واپس پلٹنا

اگر اپ ڈیٹ کرنے کے بعد آپ کو کبھی کوئی مسئلہ پیش آئے، تو آپ اپنے سسٹم کو اپ ڈیٹ سے پہلے لیے گئے snapshot پر واپس لے جا سکتے ہیں۔ بس restart کریں اور boot loading مینیو میں اپ ڈیٹ شروع کرنے سے پہلے والا snapshot منتخب کریں۔

![bootloader](images/bootloader.webp)

اگر کسی طرح آپ کی configuration files خراب ہو گئی ہوں، تو آپ terminal میں `omarchy reinstall` کا استعمال کرتے ہوئے Omarchy reinstall بھی انجام دے سکتے ہیں۔ یہ تمام default Omarchy پیکیجز دوبارہ انسٹال کر دے گا، آپ کو stable پر رکھ دے گا (Apple Silicon پر edge) اور جو پیکیجز بہت نئے ہیں انہیں downgrade کر دے گا، اور تمام configuration files کو reset کر دے گا۔ نوٹ کریں کہ ایسا کرنے سے Omarchy defaults میں آپ کی تمام user config تبدیلیاں overwrite ہو جائیں گی!
