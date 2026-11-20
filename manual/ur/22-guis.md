# GUIs

## Files

Files (Folio) گرافیکل فائل مینیجر ہے۔ `Super + Shift + F` اسے کھولتا ہے، اور `Super + Shift + Alt + F` اسے اس ڈائریکٹری میں کھولتا ہے جس میں آپ کا ٹرمینل اس وقت موجود ہے، جس سے کافی کلک کرنے کی بچت ہو جاتی ہے۔ `Ctrl + L` سے آپ راستہ ٹائپ کر سکتے ہیں، اور کسی بھی فائل پر `Space` دبانے سے اسے کھولے بغیر پوری جسامت میں اس کا پیش منظر دیکھا جا سکتا ہے۔

USB اسٹک یا SD کارڈ لگائیں تو یہ خودکار طور پر ماؤنٹ ہو جاتا ہے، اس لیے یہ بس سائیڈ بار میں نظر آنے لگتا ہے۔ اس سے زیادہ پیچیدہ کاموں — ڈرائیو کو فارمیٹ کرنا، SMART صحت جانچنا، پارٹیشن بنانا — کے لیے ایپ لانچر (`Super + Space`) سے _Disks_ چلائیں۔

ڈبل کلک کرنے پر سمجھدار defaults لاگو ہوتے ہیں: تصویریں، ویڈیوز اور موسیقی Omaview میں، PDFs Document Viewer میں، Markdown Omawrite میں، اور سادہ متن اس ایڈیٹر میں کھلتا ہے جو _Setup > Default > Editor_ کے تحت منتخب کیا گیا ہو۔

## Disktree

جب ڈرائیو بھر جائے اور سمجھ نہ آئے کہ کیا چیز اسے کھا رہی ہے، تو ایپ لانچر (`Super + Space`) سے [Disktree](https://github.com/tobi/disktree) چلائیں۔ یہ آپ کی ہوم ڈائریکٹری کا گرافیکل treemap دکھاتا ہے۔ بڑے blocks زیادہ جگہ لیتے ہیں؛ کی بورڈ یا ماؤس سے ڈائریکٹریوں کے اندر جائیں، جو کچھ ہٹانا ہے اسے نشان زد کریں، اور کچھ بھی ہٹانے سے پہلے اپنے انتخاب کا جائزہ لیں۔ پوری ڈسک کو اسکین کرنے کے لیے `disktree --disk` چلائیں۔

## Obsidian

[Obsidian](https://obsidian.md/) ایک مفت اور نہایت قابلِ توسیع نوٹ لینے والی ایپلیکیشن ہے جو ذخیرے کے لیے سادہ Markdown فائلیں استعمال کرتی ہے۔

Obsidian تمام مقاصد کے لیے مفت ہے، بشمول ذاتی، تجارتی اور غیر منفعتی استعمال۔

Obsidian iOS اور Android پر موبائل ایپس کے ساتھ [ہم آہنگی کے لیے تجارتی ایڈ آن](https://obsidian.md/sync) بھی پیش کرتا ہے۔ (https://obsidian.md/pricing)۔

آپ `Super + Shift + O` سے Obsidian شروع کرتے ہیں۔ تھیم کی ہم آہنگی استعمال کرنے کے لیے، آپ کو settings کے تحت `Omarchy` تھیم منتخب کرنا ہوگا۔

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) Omarchy کی اپنی نہایت سادہ Markdown لکھنے والی ایپ ہے۔ نہ vaults، نہ plugins، بس آپ اور الفاظ۔

آپ `Super + Shift + W` سے Omawrite شروع کرتے ہیں۔

## Pinta

[Pinta](https://www.pinta-project.com/) تصویری ترمیم کا ایک بنیادی ٹول ہے جو cropping، resizing اور دیگر بنیادی تبدیلیوں کے لیے بہترین ہے۔ بس اس سے Photoshop کا متبادل ہونے کی توقع نہ رکھیں۔ لیکن اس میں Magic Wand اور layers اب بھی موجود ہیں!

آپ ایپلیکیشن لانچر (`Super + Space`) کے ذریعے Pinta شروع کرتے ہیں۔

## Aether

[Aether](https://github.com/bjarneo/aether) ایک تھیمنگ ایپلیکیشن ہے جو پس منظر کی تصویر سے رنگ نکال کر انہیں ایک مکمل، مربوط تھیم میں بدل سکتی ہے۔ یہ [اپنا تھیم خود بنانے](43-making-your-own-theme.md) کا سب سے آسان طریقہ ہے۔

آپ ایپلیکیشن لانچر (`Super + Space`) کے ذریعے Aether شروع کرتے ہیں۔

## LocalSend

[LocalSend](https://localsend.org/) آپ کو اسی نیٹ ورک پر ایپ چلانے والے دوسرے آلات کو فائلیں بھیجنے دیتا ہے، جیسے Apple کا AirDrop۔ البتہ یہ cross-platform ہے، اس لیے آپ Windows، macOS، Android، iOS اور یقیناً Linux سے اور ان کی طرف فائلیں بھیج سکتے ہیں۔

آپ `Super + Ctrl + S` پر یا Omarchy مینیو میں _Trigger > Share_ کے تحت Share مینیو کھول سکتے ہیں۔ یہ آپ کو چار اختیارات دیتا ہے:

- **Clipboard** جو کچھ آپ نے کاپی کیا ہو اسے بطور متن فائل بھیجتا ہے۔ کسی link یا snippet کو خود کو ای میل کیے بغیر اپنے فون پر پہنچانے کے لیے بہترین ہے۔
- **File** فائل منتخب کرنے والا کھولتا ہے جہاں آپ ایک ساتھ کئی فائلیں منتخب کر سکتے ہیں۔
- **Folder** پوری ڈائریکٹری بھیجتا ہے۔
- **Receive** اصل LocalSend کھولتا ہے تاکہ کوئی دوسرا آلہ آپ کو کچھ بھیج سکے۔

یہی کام ٹرمینل سے `omarchy share clipboard`، `omarchy share file [path]` اور `omarchy share folder [path]` کے ساتھ بھی ہوتا ہے۔ راستہ چھوڑ دیں تو آپ کو picker مل جاتا ہے۔

آپ فائل مینیجر سے بھی براہِ راست بھیج سکتے ہیں: Files میں کسی بھی انتخاب پر دایاں کلک کریں اور اسے LocalSend کے ساتھ شیئر کریں۔

Omarchy کی firewall ڈیفالٹ طور پر LocalSend کی port کے سوا بند ہوتی ہے، اس لیے یہ نئی تنصیب پر فوراً کام کرتا ہے۔ [سیکیورٹی](48-security.md) دیکھیں۔

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ایک مکمل office package ہے جس میں word processor، spreadsheet، presentations، drawing ایپلیکیشن اور بہت کچھ شامل ہے۔ یہ Microsoft Office کی فائلوں کے ساتھ مطابقت رکھتا ہے، اس لیے ان Word دستاویزات کو کھول سکنے کا یہ بہترین طریقہ ہے۔

آپ ایپلیکیشن لانچر (`Super + Space`) کے ذریعے LibreOffice شروع کرتے ہیں۔

## Hype

[Hype](https://github.com/omacom/hype) Omarchy کی اپنی نہایت سادہ presentation ایپ ہے۔ آپ کی deck ایک ہی Markdown فائل ہوتی ہے جس کے پاس اس کی تصویریں اور ویڈیوز ہوتی ہیں: ہر slide کو ایک live preview کے نیچے لکھیں، slides کو گھسیٹ کر ترتیب میں لائیں، پھر fullscreen پیش کریں یا PDF اور PowerPoint میں export کریں۔ یہ آپ کا Omarchy تھیم بھی اٹھا لیتی ہے۔

آپ ایپلیکیشن لانچر (`Super + Space`) کے ذریعے Hype شروع کرتے ہیں۔ ہر shortcut دیکھنے کے لیے اس کے اندر `?` دبائیں۔

## Signed

[Signed](https://github.com/omacom/signed) PDFs پر دستخط کرنے اور انہیں بھرنے کا Omarchy کا اپنا نہایت سادہ طریقہ ہے۔ اپنے محفوظ کیے گئے دستخط، متن اور آج کی تاریخ کو صفحے پر کہیں بھی رکھیں، پھر اصل کے ساتھ دستخط شدہ کاپی محفوظ کریں۔ طریقہ جاننے کے لیے [PDFs بھرنا](27-filling-out-pdfs.md) دیکھیں۔

آپ ایپلیکیشن لانچر (`Super + Space`) کے ذریعے Signed شروع کرتے ہیں، یا فائل مینیجر سے کوئی PDF اس کے ساتھ کھولتے ہیں۔

## Game Vibes

Game Vibes، ایپلیکیشن لانچر (`Super + Space`) میں، وہ جگہ ہے جہاں Omarchy کے چھوٹے کھیل رہتے ہیں: Checkmate، دوست کے خلاف یا built-in مخالف کے خلاف 3D شطرنج کا کھیل؛ Cards، Klondike solitaire؛ اور Neon Swarm، ایک arcade shooter۔ ہر ایک ایک ہی web page ہے جو آپ کے تھیم کی پیروی کرتا ہے۔ تیروں اور `Enter` سے ایک منتخب کریں، اور کھیل کی title screen سے `Esc` دبا کر یا توقف کے دوران `Q` دبا کر فہرست پر واپس آئیں۔ یہ پوری screen پر کھلتا ہے: `Super + F` اسے window بنا دیتا ہے، اور `Super + W` اسے بند کر دیتا ہے۔

جو کھیل آپ کسی agent کے ساتھ بناتے ہیں وہ بھی یہاں نظر آتے ہیں: agents panel میں _Make something cool → Game_ منتخب کریں اور ایک کھیل بیان کریں، یا Game Vibes میں پہلے سے موجود کسی کھیل کا نام لیں تاکہ اس پر کام جاری رکھا جائے۔ agent اسے `~/Games/vibes` میں کاپی کر دیتا ہے، جہاں یہ آپ کا ہو جاتا ہے کہ آپ اسے بدلیں، اور مکمل ہونے پر اسے کھول دیتا ہے۔ آپ یہ کاپی خود `omarchy games vibes copy <game>` سے بنا سکتے ہیں۔ کوئی کھیل جو کوئی اور شیئر کرے وہ تھیم کی طرح install ہوتا ہے: _Install > Gaming > Game Vibes_ منتخب کریں اور اس کا git پتہ paste کریں، یا `omarchy games vibes install <git-repo-url>` چلائیں۔ _Remove > Gaming_ کسی کھیل کو دوبارہ نکال دیتا ہے، اور _Update > Game Vibes Games_ نئے versions حاصل کرتا ہے۔ کھیل web سے three.js load کرتے ہیں، اس لیے شروع ہونے کے لیے انہیں connection درکار ہوتا ہے۔

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) Omarchy کا اپنا نہایت سادہ calculator ہے، جو floating window میں کھلتا ہے۔

آپ `Super + Shift + Q` سے Omacalc شروع کرتے ہیں (یا calculator key سے، اگر آپ کے کی بورڈ پر موجود ہو)۔

## Signal

[Signal](https://signal.org/) E2E خفیہ کردہ پیغام رسانی کا بانی ہے، اور ہر اس شخص کے لیے بہترین مواصلاتی اختیار ہے جو بڑی ٹیک کمپنیوں کے گروہ میں سے کسی ایک کے ذریعے جانا پسند نہ کرے۔

آپ `Super + Shift + G` سے Signal شروع کرتے ہیں۔ یہ base install کا حصہ نہیں ہے، اس لیے پہلی بار جب آپ یہ دبائیں گے تو Omarchy اسے آپ کے لیے install کرنے کی پیشکش کرے گا (یہ Omarchy مینیو میں _Install > Service_ کے تحت بھی موجود ہے)۔

## Omaview

[Omaview](https://github.com/omacom/omaview) Omarchy کا اپنا نہایت سادہ picture viewer اور media player ہے: آپ کی تصاویر، ویڈیوز اور موسیقی کے لیے ایک ہی window۔ کوئی تصویر کھولیں تو تیر والی keys اس کے folder کی باقی چیزوں میں قدم بہ قدم لے جاتی ہیں، `N` اور `P` یہی کام ہر چیز کے لیے کرتے ہیں، اور `Ctrl + M` پورا folder بطور grid دکھاتا ہے۔ یہ HEIC، AVIF اور JPEG XL تصویریں بھی دکھاتا ہے، اور کسی بھی طویل چیز میں وہیں سے دوبارہ شروع کرتا ہے جہاں آپ نے چھوڑا تھا۔

Fullscreen کے لیے `F` دبائیں، تصویر کو Omasnap میں edit کرنے یا ویڈیو کو Omacut میں trim کرنے کے لیے `E`، تصویر print کرنے کے لیے `Ctrl + P`، اور فائل کو Trash میں منتقل کرنے کے لیے `Delete` دبائیں (`Ctrl + Z` اسے واپس لے آتا ہے)۔ ہر shortcut دیکھنے کے لیے اس کے اندر `?` دبائیں۔

آپ ایپلیکیشن لانچر (`Super + Space`) کے ذریعے بطور _Media Viewer_ Omaview شروع کرتے ہیں، یا فائل مینیجر میں بس کسی تصویر، ویڈیو یا گانے پر ڈبل کلک کرتے ہیں۔

## Omacut

[Omacut](https://github.com/omacom-io/omacut) Omarchy کا اپنا نہایت سادہ video trimmer ہے۔ جب آپ کو بس کسی clip کے شروع اور آخر کو کاٹنا ہو، تو یہ پورا video editor چلانے سے بہتر ہے۔

آپ ایپلیکیشن لانچر (`Super + Space`) کے ذریعے Omacut شروع کرتے ہیں۔

## Monologue

[Monologue](https://github.com/omacom/monologue) Omarchy کا اپنا نہایت سادہ webcam recorder ہے۔ اپنا کیمرا اور مائیکروفون ایک بار منتخب کریں، پھر record کرنے کے لیے `Space` دبائیں، اور اسی take کو pause کرنے اور دوبارہ شروع کرنے کے لیے پھر دبائیں۔ یہ ہمیشہ آپ کے کیمرے کی سب سے زیادہ resolution پر record کرتا ہے، live مائیکروفون meter کے ساتھ تاکہ آپ شروع کرنے سے پہلے اپنے levels جانچ سکیں۔

take روکیں تو یہ فوراً ایک built-in ایڈیٹر میں کھل جاتا ہے۔ کسی clip کو تقسیم کرنے کے لیے اس پر ڈبل کلک کریں، ہر ٹکڑے کو trim کرنے کے لیے handles گھسیٹیں، اور جو حصے آپ نہیں چاہتے انہیں ہٹا دیں۔ پھر اسے بطور MP4 محفوظ کریں۔ آپ کی اصل recording اس وقت تک رکھی جاتی ہے جب تک آپ اسے discard نہ کر دیں، اس لیے آپ ہمیشہ واپس آ کر اسے مختلف انداز میں کاٹ سکتے ہیں۔

آپ ایپلیکیشن لانچر (`Super + Space`) کے ذریعے Monologue شروع کرتے ہیں۔
