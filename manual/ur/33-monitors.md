# مانیٹرز

Omarchy بطور ڈیفالٹ فرض کرتا ہے کہ آپ 2x کی صلاحیت رکھنے والے retina-class ڈسپلے پر چل رہے ہیں۔ یہی وہ چیز ہے جو آپ کو وہ عمدہ، کرسپ پروگرامر فونٹس حاصل کرنے کے لیے درکار ہے۔ یہی وہ چیز ہے جس کے لیے تقریباً تمام نئے پریمیم لیپ ٹاپس جن میں high-resolution اسکرینیں ہیں، بہتر بنائے گئے ہیں۔ یہی وہ چیز ہے جسے آپ 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) یا 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) پر چلانا چاہیں گے۔

لیکن اگر آپ 218 یا اس سے زیادہ PPI والے ڈسپلے پر نہیں چل رہے، تو آپ مانیٹر کی سیٹنگز تبدیل کرنا چاہیں گے۔ مثال کے طور پر، اگر آپ کے پاس 27" یا 32" 4K ہے، تو آپ ٹاپ بار میں موجود مانیٹر پینل سے اس کے لیے fractional scale منتخب کر سکتے ہیں، یا `~/.config/hypr/monitors.lua` کھول کر اور اس کمبی نیشن کے لیے تجویز کردہ سیٹنگ پر سوئچ کر کے ہر مانیٹر کے لیے ڈیفالٹ سیٹ کر سکتے ہیں:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

اگر آپ 1080p یا 1440p ڈسپلے استعمال کر رہے ہیں، تو آپ شاید صرف 1x scaling ہی استعمال کرنا چاہیں گے، اور GTK اور X11 ایپس کے لیے بھی یہی، تو آپ یہ استعمال کر سکتے ہیں:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` میں تبدیلیاں ان ایپلیکیشنز پر لاگو ہوتی ہیں جو تبدیلی کے بعد اسٹارٹ ہوتی ہیں (اور GTK صرف مکمل اعداد ہی قبول کرتا ہے، اس لیے اسے اپنے مانیٹر scale کے قریب ترین integer پر رکھیں)۔ اس لیے یہ یقینی بنائیں کہ تبدیلی کے بعد آپ ان ونڈوز کو بند کر دیں جو آپ کے پاس oversized ہیں (یا `Ctrl + Alt + Del` کے ساتھ تمام ونڈوز بند کر دیں!)۔

آپ `Super + /` استعمال کر کے بڑے مانیٹر scaling تناسب (1x, 1.25x, 1.6x, 2x, 3x, 4x) میں تیزی سے اوپر بھی جا سکتے ہیں اور `Super + Alt + /` استعمال کر کے نیچے بھی، یا ٹاپ بار میں موجود مانیٹر پینل سے ایک منتخب کر سکتے ہیں۔ یہ صرف اس مانیٹر کو تبدیل کرتے ہیں جس پر آپ فوکس ہیں، اس لیے لیپ ٹاپ اسکرین اور بیرونی ڈسپلے ہر ایک کا اپنا scale ہو سکتا ہے۔ یہ پینل ہر مانیٹر کی resolution، refresh rate اور rotation بھی سیٹ کرتا ہے۔ آپ کے انتخاب اس physical مانیٹر کے لیے `~/.local/state/omarchy/monitors/settings` میں محفوظ کیے جاتے ہیں، اس لیے یہ reboot کے بعد بھی برقرار رہتے ہیں اور مانیٹر کے ساتھ اس پورٹ یا ڈاک تک جاتے ہیں جس میں یہ اگلی بار پلگ ان ہو۔ یہ `~/.config/hypr/monitors.lua` میں اسی مانیٹر کے لیے کسی بھی rule پر فوقیت رکھتے ہیں، جسے Omarchy کبھی edit نہیں کرتا۔ اگر آپ اپنے مانیٹرز کو مکمل طور پر اس فائل میں سیٹ کرنا پسند کریں، تو اس میں `omarchy_monitor_panel_settings = false` شامل کر دیں، اور پینل کی تبدیلیاں صرف اس وقت تک رہیں گی جب تک Hyprland reload نہ ہو جائے۔ چونکہ `GDK_SCALE` تمام اسکرینوں کے لیے ایک ہی value ہے، اس لیے منتخب کردہ scale اسے سب سے کم scale والے مانیٹر سے سیٹ کرتا ہے، اس لیے X11 ایپس زیادہ گھنے ڈسپلے پر تھوڑی چھوٹی نکلتی ہیں بجائے اس کے کہ دوسرے پر oversized ہو جائیں۔

### متن کو بڑا یا چھوٹا کرنا

مانیٹر scaling ہر چیز کا سائز تبدیل کرتی ہے۔ اگر آپ صرف بڑا یا چھوٹا _متن_ چاہتے ہیں، تو اس کے لیے ایک ہی knob ہے:

```
omarchy display text size 14
```

یہ 9 اور 20 کے درمیان pixel size لیتا ہے، اور Omarchy shell، GTK ایپلیکیشنز، اور آپ کے ٹرمینل کو ایک ساتھ move کرتا ہے، اس لیے پورا ڈیسک ٹاپ تناسب میں رہتا ہے۔ آپ کہاں ہیں یہ دیکھنے کے لیے اسے بغیر argument کے چلائیں، اور ڈیفالٹ پر واپس جانے کے لیے `omarchy display text size reset` چلائیں۔ Foot واحد straggler ہے: اس کے پاس اپنی config کو reload کرنے کا کوئی طریقہ نہیں ہے، اس لیے چلنے والے ٹرمینلز اپنا پرانا سائز برقرار رکھتے ہیں جب تک آپ نیا نہ کھولیں۔

### لیپ ٹاپ ڈسپلے کو extend اور mirror کرنا

جب آپ اپنے لیپ ٹاپ سے بیرونی اسکرین کنیکٹ کرتے ہیں، تو ڈسپلے خودکار طور پر extend ہو جاتا ہے۔ لیکن آپ ٹاپ بار میں موجود مانیٹر پینل میں _Extend_ | _Mirror_، Omarchy مینو میں _Trigger > Hardware_، یا `Super + Ctrl + Alt + Delete` کے ساتھ اسے اس کی بجائے mirroring پر تبدیل کر سکتے ہیں۔ یہ خاص طور پر مددگار ہے اگر وہ بیرونی اسکرین پروجیکٹر ہے، اور آپ کام کرتے ہوئے کچھ دکھانا چاہتے ہیں۔

جب آپ extend کر رہے ہوں، تو لیپ ٹاپ کا ڈھکن بند کرنے سے اندرونی اسکرین خودکار طور پر بند ہو جائے گی۔ ڈھکن کھولنے سے یہ واپس آن ہو جائے گی۔ آپ Omarchy مینو میں _Trigger > Hardware_ یا `Super + Ctrl + Delete` استعمال کر کے اسے manually بھی کنٹرول کر سکتے ہیں۔

### متعدد اسکرینوں کو ترتیب دینا

Hyprland متعدد اسکرینوں کے ساتھ بہت اچھا کام کرتا ہے۔ ٹاپ بار میں موجود مانیٹر پینل انہیں وہیں کھینچتا ہے جہاں وہ بیٹھی ہیں: ایک کو دوسری کے کنارے کے خلاف drag کریں تاکہ اسے وہاں move کریں، اور یہ ترتیب ہر مانیٹر کی دیگر سیٹنگز کے ساتھ محفوظ ہو جاتی ہے۔ کسی بھی ایسی چیز کے لیے جو پینل کور نہیں کرتا، [Hyprland مانیٹر دستاویزات](https://wiki.hypr.land/Configuring/Basics/Monitors/) میں انہیں ترتیب دینے کے بارے میں مزید پڑھیں۔ Omarchy میں، یہ `~/.config/hypr/monitors.lua` میں `hl.monitor` entries کے طور پر جاتے ہیں — یہ فائل مانیٹر کو بند رکھنے، ایسے modes جو پینل پیش نہیں کرتا، 10-bit رنگ، اور variable refresh rate کے لیے commented مثالیں کے ساتھ آتی ہے۔

ہر مانیٹر کے اپنے workspaces 1 سے 10 ہوتے ہیں، اس لیے `Super + 1` کا ہمیشہ مطلب اس مانیٹر کا پہلا workspace ہوتا ہے جس پر آپ ہیں۔ پردے کے پیچھے، Hyprland اب بھی تمام مانیٹروں میں workspaces کو نمبر دیتا ہے: آپ کی لیپ ٹاپ اسکرین (یا پہلا مانیٹر) کو 1–10 ملتے ہیں، اگلے مانیٹر کو 11–20، اور اسی طرح آگے، اور ہر مانیٹر ہر بار جب آپ اسے پلگ ان کرتے ہیں اپنا block برقرار رکھتا ہے۔ اگر آپ کسی مخصوص مانیٹر کے لیے [workspace rules](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) یا window rules لکھتے ہیں تو ان نمبروں کو استعمال کریں، اس لیے workspace 12 آپ کے دوسرے مانیٹر کا دوسرا workspace ہے۔ `~/.local/state/omarchy/monitors/workspaces` فہرست دیتا ہے کہ ہر مانیٹر کے پاس کون سا block ہے۔

Arrow keys ان مانیٹروں کے پار کام کرتی ہیں جو آپ کے layout میں کنارہ share کرتے ہیں۔ ایسی اسکرینیں جو صرف کونے پر چھوتی ہیں، یا جن کے درمیان gap ہے، پڑوسی نہیں ہیں، اس لیے ان کے درمیان جانے کے لیے `Ctrl + Alt + Tab` استعمال کریں۔

| Hotkey | مانیٹروں کے پار |
| --- | --- |
| `Super + Arrow` | جب اس سمت میں کوئی ونڈو باقی نہ رہ جائے تو فوکس اس طرف والے مانیٹر پر move کرتا ہے |
| `Super + Shift + Arrow` | اس طرف والے مانیٹر پر موجود ونڈو کے ساتھ swap کرتا ہے |
| `Super + Alt + Arrow` | ونڈو کو اس طرف والے مانیٹر پر موجود group میں move کرتا ہے |
| `Super + Shift + Ctrl + Arrow` | ونڈو کو اس طرف والے مانیٹر پر، اس workspace پر move کرتا ہے جو یہ دکھا رہا ہے |
| `Super + Shift + Alt + Arrow` | workspace کو اس طرف والے مانیٹر پر move کرتا ہے، اگر یہ free ہے تو اس کا نمبر برقرار رکھتا ہے |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | فوکس کو اگلے یا پچھلے مانیٹر پر move کرتا ہے، layout کچھ بھی ہو |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | اسی مانیٹر پر رہیں جس پر آپ ہیں |

آپ [Hyprmon](https://github.com/erans/hyprmon/) بھی دیکھ سکتے ہیں، اگر آپ متعدد اسکرینوں کی positioning میں مدد کے لیے TUI چاہتے ہیں۔

### چمک کو کنٹرول کرنا

مانیٹر کی چمک brightness up/down کے لیے مخصوص function keys سے کنٹرول کی جاتی ہے۔ اگر آپ انہیں دباتے ہوئے shift کو دبا کر رکھیں، تو آپ maximum یا minimum چمک پر چلے جائیں گے۔ یہ keys اس ڈسپلے کو کنٹرول کرتی ہیں جس پر آپ فوکس ہیں، اس لیے بیرونی مانیٹر جو DDC/CI بولتے ہیں انہیں لیپ ٹاپ اسکرین کی طرح ہی adjust کیا جاتا ہے۔

### Apple Displays

اگر آپ Apple ڈسپلے استعمال کر رہے ہیں، تو باقاعدہ keyboard brightness keys بھی خودکار طور پر کام کریں گی، اگر آپ Apple ڈسپلے پر فوکس ہیں۔ یہ `asdcontrol` کمانڈ کے ذریعے ہوتا ہے۔

نوٹ کریں کہ اگر آپ Apple 6K XDR ڈسپلے استعمال کر رہے ہیں، تو آپ کو اپنی `hyprctl monitors` فہرست میں phantom اسکرین نظر آ سکتی ہے۔ آپ `~/.config/hypr/monitors.lua` میں `hl.monitor({ output = "DP-2", disabled = true })` جیسی کسی چیز کے ساتھ اسے بند کر سکتے ہیں۔

Intel مشینوں پر، آپ کو Apple ڈسپلے سے باقاعدہ Thunderbolt کیبل استعمال کر کے کنیکٹ ہونا چاہیے۔ دیگر مشینوں پر جن میں Thunderbolt نہیں ہے، آپ کو عام طور پر اسے کام کرنے کے لیے [DP + USB-A -> USB-C کیبل](https://www.amazon.com/dp/B0BNX7MS6N) استعمال کرنی پڑے گی۔
