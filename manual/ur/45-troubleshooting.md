# خرابیوں کا ازالہ

### میں نے اپ ڈیٹ کر کے اپنا سسٹم خراب کر دیا!

سب سے پہلے [اپنے سسٹم کو واپس لے جانے](47-system-snapshots.md) کی کوشش کریں، اس ورژن پر جو آپ کی حالیہ اپ ڈیٹ سے پہلے تھا۔ اگر اس سے کام نہ بنے تو Discord میں #omarchy-help پر اپنے مسئلے کے ساتھ `omarchy-debug` استعمال کریں۔ اور اگر یہ سب بھی ناکام ہو جائے تو آپ `omarchy-reinstall` استعمال کر کے ڈیفالٹ configs اور packages دوبارہ انسٹال کر سکتے ہیں۔

### میرے ڈسپلے پر کچھ apps اتنی بڑی کیوں نظر آتی ہیں؟

Omarchy یہ فرض کرتا ہے کہ ڈسپلے 2x high-resolution ہے، اس لیے وہ `GDK_SCALE` کو 2 پر سیٹ کر دیتا ہے جب تک آپ monitor panel میں کوئی scale منتخب نہ کر لیں۔ اگر آپ 1x ڈسپلے پر ہیں اور GTK یا X11 apps بہت بڑی نظر آتی ہیں تو monitor panel میں اس کے لیے 1x منتخب کریں، یا `~/.config/hypr/monitors.lua` میں `hl.env("GDK_SCALE", "1")` شامل کر دیں (اور پھر جو app بہت بڑی نظر آ رہی ہے اسے دوبارہ شروع کریں)۔ دیکھیں [monitors پر manual](33-monitors.md)۔

Spotify کے لیے، آپ UI کو چھوٹا کرنے کے لیے `Ctrl + Minus` استعمال کر سکتے ہیں (اور اسے بڑا کرنے کے لیے `Ctrl + Plus`)۔

### میرے تمام Super key binds نے کام کرنا کیوں بند کر دیا؟

کچھ ASUS ROG اور TUF laptops پر، `Fn + Super` ایک آسانی سے نظر انداز ہو جانے والا chord ہے جو firmware Windows-key lock کو toggle کرتا ہے (یہ gaming کے لیے بنایا گیا ہے تاکہ آپ غلطی سے game نہ چھوڑ دیں)۔ اسکرین پر کچھ بھی آپ کو نہیں بتاتا کہ یہ ہو گیا ہے۔ جب lock آن ہو تو Super بالکل کچھ بھی emit نہیں کرتا — اس لیے Super استعمال کرنے والا ہر Omarchy bind بس رک جاتا ہے، اور یوں لگتا ہے جیسے Hyprland خراب ہو گیا ہو۔

`~/.config/hypr/` میں کھوج شروع کرنے سے پہلے ایک بار `Fn + Super` دبائیں، اور اگر اس سے Super واپس نہ آئے تو اسے دوبارہ دبائیں تاکہ آپ lock کو آن نہ چھوڑ دیں۔ یہ Fn-lock نہیں ہے، جو صرف یہ بدلتا ہے کہ F-key والی قطار کیا کرتی ہے۔

### میرا Wi-Fi، Bluetooth، آڈیو، یا trackpad اچانک کام کرنا بند ہو گیا ہے

Reboot کرنے سے پہلے، خراب subsystem کو اکیلے دوبارہ شروع کر کے دیکھیں۔ Omarchy menu میں _Update > Hardware_ کے پاس Wi-Fi، Bluetooth، Audio، اور Trackpad ہیں، اور ان میں سے کسی ایک کو reload کرنا "یہ پانچ منٹ پہلے کام کر رہا تھا" جیسی زیادہ تر صورتوں کو ٹھیک کر دیتا ہے — کوئی Bluetooth headset جو دوبارہ connect نہ ہو رہا ہو، کوئی trackpad جو suspend کے بعد بند ہو گیا ہو، وہ آواز جو آپ کے monitor کو unplug کرنے پر غائب ہو گئی ہو۔

### میرے external speakers آواز کیوں نہیں چلا رہے؟

شاید اس لیے کہ وہ primary output کے طور پر سیٹ نہیں ہیں۔ Bar کے دائیں طرف speaker icon پر click کریں، اور اس سے volume popup کھل جائے گا جہاں آپ output device منتخب کر سکتے ہیں (اور فی app volumes بھی mix کر سکتے ہیں)۔

### میرے laptop speakers کی آواز ٹھیک نہیں لگتی

کچھ laptops پر، Omarchy خودکار طور پر ایک speaker tuning لاگو کرتا ہے جو built-in speakers کے frequency response کو درست کرتی ہے۔ `omarchy audio tuning status` آپ کو بتاتا ہے کہ آیا آپ کی machine پر کوئی tuning فعال ہے، اور `omarchy audio tuning off` اسے بند کر دیتا ہے اگر آپ speakers کو ویسا ہی سننا چاہتے ہیں جیسے وہ ہیں۔

### میں اپنے password سے login یا sudo کیوں نہیں کر سکتا؟

شاید آپ نے اسے بہت بار غلط لکھا ہے اور آپ lock out ہو گئے ہیں۔ اگر یہ lock screen پر ہو رہا ہے تو آپ نیا TTY شروع کرنے کے لیے `CTRL + ALT + F2` دبا سکتے ہیں جہاں آپ root کے طور پر login کر سکتے ہیں، پھر `faillock --reset --user [your-username]` چلائیں۔ اس سے lockout reset ہو جائے گا، اور آپ آگے بڑھنے کے لیے تیار ہیں۔

### 1Password SSH Agent / CLI کے لیے میری 1Password authorization prompts کیوں ظاہر نہیں ہو رہیں؟

یہ 2 وجوہات کی بنا پر ہو سکتا ہے:

بھرپور approval prompt کے ظاہر ہونے کے لیے، Settings > Advanced > Use Hardware Acceleration آن ہونا ضروری ہے۔ _نوٹ: اس کے کام شروع کرنے کے لیے reboot درکار ہے۔_

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

یا اگر آپ نے boot up ہونے کے بعد سے 1Password launch نہیں کیا ہے تو prompt ظاہر نہیں ہوگا۔
