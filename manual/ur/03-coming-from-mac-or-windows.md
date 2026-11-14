# Mac یا Windows سے آنا

اگر آپ نے برسوں macOS یا Windows پر گزارے ہیں، تو آپ کی انگلیاں سو ایسی چیزیں جانتی ہیں جنہیں آپ کا دماغ بھول چکا ہے کہ اس نے کبھی سیکھی تھیں۔ یہ باب وہی ترجمے کی پرت ہے: Omarchy میں وہ جبلتیں کہاں جاتی ہیں۔ خصوصیات خود دوسری جگہوں پر تفصیل سے بیان کی گئی ہیں — یہ صرف نقشہ ہے۔

### Super ہر چیز کا مرکز ہے

Cmd یا Windows key کے گرد بنی آپ کی تمام پٹھوں کی یادداشت ایک ہی key پر منتقل ہو جاتی ہے: Super۔ PC keyboard پر یہی Windows key ہے، اور یہ Omarchy میں تقریباً ہر hotkey کا مرکز ہے۔

Spotlight یا Raycast یا Start-menu والا آپ کا اضطراری عمل `Super + Space` بن جاتا ہے۔ اس سے Omarchy menu کھلتا ہے، جو apps لانچ کرتا ہے، settings بدلتا ہے، software انسٹال کرتا ہے، اسکرین capture کرتا ہے — تقریباً ہر کام کرتا ہے۔ فلٹر کرنے کے لیے بس ٹائپ کرنا شروع کر دیں۔ `Super + Alt + Space` تمام apps کو ایک ہی grid پر دکھاتا ہے، بالکل Launchpad کی طرح۔ دیکھیں [نیویگیشن](04-navigation.md)۔

### نہ کوئی dock ہے اور نہ desktop icons

کوئی چیز ایسی نہیں جس پر کلک کر کے کچھ لانچ کیا جائے، اور desktop پر سجانے کے لیے کوئی icons نہیں ہیں۔ Apps کسی hotkey سے شروع ہوتی ہیں (`Super + Return` terminal کے لیے، `Super + Shift + Return` browser کے لیے، اور `Super + K` ہر اس چیز کی فہرست کے لیے جو mapped ہے) یا menu سے۔ UI کا واحد مستقل حصہ [اوپر والی بار](05-the-top-bar.md) ہے، جو وہ سب سنبھالتی ہے جو پہلے menu bar، system tray، اور Notification Center آپ کے لیے کرتے تھے — اور اس پر موجود تقریباً ہر widget بائیں، دائیں، اور درمیانی کلک پر کچھ نہ کچھ کرتا ہے۔

### Windows خود اپنی جگہ بنا لیتی ہیں

سب سے بڑی ذہنی تبدیلی: آپ windows کو گھسیٹ کر ادھر ادھر نہیں کرتے اور نہ انہیں اسکرین کے نصف حصوں پر snap کرتے ہیں۔ کوئی window کھولیں تو وہ پوری اسکرین لے لیتی ہے۔ دوسری کھولیں تو وہ اسکرین کو آپس میں بانٹ لیتی ہیں۔ آپ کبھی کسی window کو دوسری کے نیچے سے نکالنے کی کوشش نہیں کرتے، کیونکہ windows ایک دوسرے پر چڑھتی ہی نہیں۔

جب آپ کو واقعی floating window کی ضرورت ہو، تو `Super + T` فعال window کو tiling سے باہر نکال دیتا ہے (اور واپس بھی لے آتا ہے)۔ لیکن پہلے tiling کو ایک حقیقی موقع دیں — یہی اس سارے نظام کا دل ہے۔ [نیویگیشن](04-navigation.md) آپ کو اس میں سے گزار کر لے جاتا ہے۔

Workspaces مانوس محسوس ہوں گے: یہ macOS Spaces یا Windows virtual desktops ہیں، فرق صرف یہ ہے کہ آپ انہیں واقعی استعمال کریں گے، کیونکہ `Super + 1/2/3/4` سیدھا کسی ایک پر لے جاتا ہے اور `Super + Shift + 1/2/3/4` فعال window کو وہاں بھیج دیتا ہے۔ کوئی animation کی تاخیر نہیں، بس فوری چھلانگیں۔ اس کا مطلب ہے کہ شاید آپ کو متعدد monitors کی ضرورت ہی نہ پڑے، اگر آپ پہلے اس کے عادی تھے۔

### Copy اور paste بس کام کرتے ہیں

Mac پر آپ کے پاس ہر جگہ Cmd + C تھا۔ Windows پر آپ کے پاس ہر جگہ Ctrl + C تھا — سوائے terminal کے، جہاں یہ آپ کے program کو ختم کر دیتا ہے۔ Omarchy آپ کو `Super + C`، `Super + X`، اور `Super + V` دیتا ہے، اور یہ ہر جگہ کام کرتے ہیں، terminal سمیت۔ shell کے لیے کوئی الگ اضطراری عمل سیکھنے کی ضرورت نہیں۔

Windows والو: آپ کی Win + V clipboard history `Super + Ctrl + V` پر موجود ہے، اور یہ متن کے ساتھ ساتھ تصاویر بھی رکھتی ہے۔ دیکھیں [unified clipboard & history](08-unified-clipboard-history.md)۔

### ترجمے کی جدول

| آپ جس کی طرف ہاتھ بڑھاتے ہیں | Omarchy میں |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy menu |
| AirDrop | LocalSend، بذریعہ `Super + Ctrl + S` — دیکھیں [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` یا `Print Screen` — دیکھیں [screenshots & recording](12-screenshots-recording.md) |
| Notification Center | Notification history، `Super + Shift + Alt + ,` پر |
| Time Machine (سسٹم کے لیے) | ہر update پر خودکار [system snapshots](47-system-snapshots.md) |
| App Store / کوئی installer ڈاؤن لوڈ کرنا | menu میں _Install_، یا `omarchy pkg add` — دیکھیں [other packages](29-other-packages.md) |
| System Settings / Control Panel | menu میں _Setup_، جو سادہ config files میں ترمیم کرتا ہے — دیکھیں [dotfiles](31-dotfiles.md) |

### کچھ چیزیں واقعی مختلف ہیں

بہت سی settings متن والی files میں رہتی ہیں جن میں آپ ترمیم کرتے ہیں، ایسے panels میں نہیں جن میں کلک کرتے پھریں۔ یہ اس وقت تک قدیم لگتا ہے جب تک آپ کو احساس نہ ہو کہ اس کا مطلب ہے کہ ہر تبدیلی دیکھی جا سکتی ہے، آپ کی اگلی machine پر copy کی جا سکتی ہے، اور version control میں رکھی جا سکتی ہے۔ _Setup_ menu آپ کو سیدھا درست file میں پہنچا دیتا ہے اور جب آپ کام مکمل کر لیتے ہیں تو جس چیز کو restart کرنے کی ضرورت ہو اسے restart کر دیتا ہے۔

Updates ایک ہی command سے آتی ہیں — _Update > Omarchy_ — جو Omarchy کو خود بھی update کرتی ہے اور سسٹم کے ہر package کو بھی، اور پہلے ایک snapshot لیتی ہے۔ بے ترتیب اوقات میں تنگ کرنے والے فی app updaters نہیں ہیں۔ دیکھیں [updates](30-updates.md)۔

Software ڈاؤن لوڈ کیے گئے installers سے نہیں، ایک package manager سے آتا ہے۔

اور جب آپ کوئی window بند کرتے ہیں، تو app واقعی بند ہو جاتی ہے۔ macOS والی وہ کیفیت نہیں ہے جہاں program بغیر کسی window کے چلتا رہتا ہے۔ `Super + W` — یا `Super + Q`، اگر آپ اسی انگلیوں کی یادداشت کے ساتھ آئے ہیں — کا مطلب ہے ختم۔

### Mac hardware پر

Omarchy Intel Macs پر اچھی طرح چلتا ہے — دیکھیں [Mac support](44-mac-support.md)۔ اور keyboard آپ کے ساتھ نرمی برتتا ہے: Omarchy کسی چیز کو remap نہیں کرتا، اور Linux Command key کو Super کے طور پر لیتا ہے، اس لیے Super بالکل وہیں بیٹھتا ہے جہاں Cmd ہمیشہ تھا۔ آپ کے انگوٹھے کو یہ تبدیلی محسوس ہی نہیں ہو گی۔

### اسے دو ہفتے دیں

جبلتیں آپ کی توقع سے زیادہ تیزی سے منتقل ہو جاتی ہیں۔ [hotkeys](07-hotkeys.md) والا باب ایک بار سرسری طور پر دیکھ لیں، اور جب بھی کوئی binding بھول جائے تو `Super + K` دبائیں — یہ آپ کو وہ سب دکھا دیتا ہے۔ یہ واحد hotkey ہے جو آپ کو واقعی یاد کرنی ہے۔
