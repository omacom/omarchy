# مانیٹرز

Omarchy بطور ڈیفالٹ یہ فرض کرتا ہے کہ آپ 2x کے قابل retina-class ڈسپلے پر چل رہے ہیں۔ اچھے، صاف programmer fonts حاصل کرنے کے لیے آپ کو یہی چاہیے۔ تقریباً تمام نئے premium لیپ ٹاپس جن میں high-resolution اسکرینیں ہیں، اسی کے لیے optimized ہیں۔ آپ 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) یا 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) پر یہی چلانا چاہیں گے۔

لیکن اگر آپ PPI 218 یا اس سے زیادہ والے ڈسپلے پر نہیں چل رہے، تو آپ مانیٹر کی settings تبدیل کرنا چاہیں گے۔ مثال کے طور پر، اگر آپ کے پاس 27" یا 32" 4K ہے، تو آپ top bar میں موجود monitor panel سے اس کے لیے fractional scale منتخب کر سکتے ہیں، یا `~/.config/hypr/monitors.lua` کھول کر اور اس combo کے لیے تجویز پر switch کر کے ہر مانیٹر کے لیے default مقرر کر سکتے ہیں:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

اگر آپ 1080p یا 1440p ڈسپلے استعمال کر رہے ہیں، تو غالباً آپ صرف 1x scaling استعمال کرنا چاہیں گے، اور GTK اور X11 apps کے لیے بھی یہی، لہٰذا آپ یہ استعمال کر سکتے ہیں:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` میں تبدیلیاں اس تبدیلی کے بعد شروع کی گئی applications پر لاگو ہوتی ہیں (اور GTK صرف whole numbers کو مانتا ہے، لہٰذا اسے اپنے monitor scale کے قریب ترین integer پر رکھیں)۔ لہٰذا اس بات کو یقینی بنائیں کہ تبدیلی کے بعد جو windows آپ کے پاس بڑی ہو گئی ہیں انہیں آپ بند کر دیں (یا `Ctrl + Alt + Del` سے تمام windows بند کر دیں!)۔

آپ `Super + /` استعمال کر کے اوپر جانے اور `Super + Alt + /` استعمال کر کے نیچے آنے کے ذریعے بھی بڑے monitor scaling ratios (1x, 1.25x, 1.6x, 2x, 3x, 4x) میں تیزی سے آگے بڑھ سکتے ہیں، یا top bar میں موجود monitor panel سے ایک منتخب کر سکتے ہیں۔ یہ صرف اس مانیٹر کو تبدیل کرتے ہیں جس پر آپ focused ہیں، لہٰذا لیپ ٹاپ اسکرین اور external ڈسپلے ہر ایک کا اپنا scale ہو سکتا ہے۔ panel ہر مانیٹر کی resolution بھی مقرر کرتا ہے۔ آپ کے انتخاب اس physical مانیٹر کے لیے `~/.local/state/omarchy/monitors/settings` میں محفوظ ہوتے ہیں، لہٰذا وہ reboot کے بعد بھی برقرار رہتے ہیں اور مانیٹر کے ساتھ اس port یا dock تک جاتے ہیں جہاں اسے آگے لگایا جائے۔ وہ `~/.config/hypr/monitors.lua` میں اسی مانیٹر کے لیے کسی بھی rule پر فوقیت رکھتے ہیں، جسے Omarchy کبھی edit نہیں کرتا۔ اگر آپ اپنے مانیٹرز کو مکمل طور پر اسی file میں مقرر کرنا پسند کرتے ہیں، تو اس میں `omarchy_monitor_panel_settings = false` شامل کر دیں، اور panel کی تبدیلیاں صرف اس وقت تک رہیں گی جب تک Hyprland reload نہ ہو جائے۔ چونکہ `GDK_SCALE` تمام اسکرینوں کے لیے ایک ہی value ہے، لہٰذا منتخب کردہ scale اسے سب سے کم scale والے مانیٹر سے مقرر کرتا ہے، لہٰذا X11 apps دوسری اسکرین پر oversized ہونے کے بجائے زیادہ گھنی اسکرین پر تھوڑی چھوٹی نکلتی ہیں۔

### متن کو بڑا یا چھوٹا کرنا

Monitor scaling ہر چیز کا size تبدیل کر دیتی ہے۔ اگر آپ کو صرف بڑا یا چھوٹا _text_ چاہیے، تو اس کے لیے ایک ہی knob ہے:

```
omarchy display text size 14
```

یہ 9 اور 20 کے درمیان pixel size لیتا ہے، اور Omarchy shell، GTK applications، اور آپ کے terminal کو ایک ساتھ حرکت دیتا ہے، لہٰذا پورا desktop تناسب میں رہتا ہے۔ آپ کہاں ہیں یہ دیکھنے کے لیے اسے بغیر کسی argument کے چلائیں، اور default پر واپس جانے کے لیے `omarchy display text size reset` چلائیں۔ Foot واحد straggler ہے: اس کے پاس اپنی config reload کرنے کا کوئی طریقہ نہیں، لہٰذا چلتے ہوئے terminals اپنا پرانا size اس وقت تک رکھتے ہیں جب تک آپ نیا نہ کھولیں۔

### لیپ ٹاپ ڈسپلے کو توسیع دینا اور mirror کرنا

جب آپ اپنے لیپ ٹاپ سے external اسکرین connect کرتے ہیں، تو ڈسپلے خود بخود extended ہو جاتا ہے۔ لیکن آپ Omarchy menu میں _Trigger > Hardware_ یا `Super + Ctrl + Alt + Delete` استعمال کر کے اسے اس کے بجائے mirroring میں تبدیل کر سکتے ہیں۔ یہ خاص طور پر مددگار ہے اگر وہ external اسکرین projector ہے، اور آپ کام کرتے ہوئے کچھ دکھانا چاہتے ہیں۔

جب آپ extend کر رہے ہوں، تو لیپ ٹاپ کا lid بند کرنے سے internal اسکرین خود بخود بند ہو جائے گی۔ lid کھولنے سے وہ واپس آن ہو جائے گی۔ آپ Omarchy menu میں _Trigger > Hardware_ یا `Super + Ctrl + Delete` استعمال کر کے اسے دستی طور پر بھی control کر سکتے ہیں۔

### متعدد اسکرینوں کو ترتیب دینا

Hyprland متعدد اسکرینوں کے ساتھ بہت اچھا کام کرتا ہے۔ top bar میں موجود monitor panel انہیں وہیں کھینچتا ہے جہاں وہ بیٹھی ہیں: ایک کو دوسری کے side سے لگا کر drag کر کے اسے وہاں منتقل کریں، اور ترتیب ہر مانیٹر کی دیگر settings کے ساتھ محفوظ ہو جاتی ہے۔ panel جس چیز کا احاطہ نہیں کرتا اس کے لیے، انہیں ترتیب دینے کے طریقے کے بارے میں [Hyprland مانیٹر دستاویزات](https://wiki.hypr.land/Configuring/Basics/Monitors/) میں مزید پڑھیں۔ Omarchy میں، یہ `~/.config/hypr/monitors.lua` میں `hl.monitor` entries کے طور پر جاتے ہیں — file کسی مخصوص مانیٹر کو resolution، position، اور rotation پر pin کرنے کے لیے commented مثالوں کے ساتھ آتی ہے۔

ہر مانیٹر کے اپنے workspaces 1 سے 10 تک ہوتے ہیں، لہٰذا `Super + 1` کا ہمیشہ مطلب اس مانیٹر کا پہلا workspace ہوتا ہے جس پر آپ ہیں۔ پردے کے پیچھے، Hyprland پھر بھی تمام مانیٹرز میں workspaces کو number دیتا ہے: آپ کی لیپ ٹاپ اسکرین (یا پہلا مانیٹر) کو 1–10 ملتے ہیں، اگلے مانیٹر کو 11–20، اور اسی طرح آگے، اور ہر مانیٹر جب بھی آپ اسے plug کرتے ہیں اپنا block رکھتا ہے۔ اگر آپ کسی مخصوص مانیٹر کے لیے [workspace rules](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) یا window rules لکھتے ہیں تو وہ numbers استعمال کریں، لہٰذا workspace 12 آپ کے دوسرے مانیٹر کا دوسرا workspace ہے۔ `~/.local/state/omarchy/monitors/workspaces` فہرست دیتا ہے کہ کس مانیٹر کے پاس کون سا block ہے۔

Arrow keys ان مانیٹرز کے درمیان کام کرتی ہیں جو آپ کے layout میں ایک edge share کرتے ہیں۔ وہ اسکرینیں جو صرف ایک corner پر چھوتی ہیں، یا جن کے درمیان gap ہے، پڑوسی نہیں ہیں، لہٰذا ان کے درمیان جانے کے لیے `Ctrl + Alt + Tab` استعمال کریں۔

| Hotkey | مانیٹرز کے درمیان |
| --- | --- |
| `Super + Arrow` | جب اس سمت میں کوئی window باقی نہ رہے تو focus اس side پر موجود مانیٹر پر منتقل کر دیتا ہے |
| `Super + Shift + Arrow` | اس side پر موجود مانیٹر پر ایک window کے ساتھ swap کرتا ہے |
| `Super + Alt + Arrow` | window کو اس side پر موجود مانیٹر پر ایک group میں منتقل کرتا ہے |
| `Super + Shift + Ctrl + Arrow` | window کو اس side پر موجود مانیٹر پر، اس workspace پر منتقل کرتا ہے جو وہ دکھا رہا ہے |
| `Super + Shift + Alt + Arrow` | workspace کو اس side پر موجود مانیٹر پر منتقل کرتا ہے، اگر وہ free ہو تو اس کا number برقرار رکھتا ہے |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | layout چاہے کچھ بھی ہو، focus اگلے یا پچھلے مانیٹر پر منتقل کرتا ہے |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | اسی مانیٹر پر رہتے ہیں جس پر آپ ہیں |

آپ [Hyprmon](https://github.com/erans/hyprmon/) بھی دیکھ سکتے ہیں، اگر آپ متعدد اسکرینوں کی positioning میں مدد کے لیے TUI چاہتے ہیں۔

### چمک کو کنٹرول کرنا

Monitor brightness کو brightness up/down کے لیے مخصوص function keys سے control کیا جاتا ہے۔ اگر آپ انہیں دباتے ہوئے shift کو دبا کر رکھیں، تو آپ maximum یا minimum brightness پر چلے جائیں گے۔ keys اس ڈسپلے کو control کرتی ہیں جس پر آپ focused ہیں، لہٰذا DDC/CI بولنے والے external مانیٹرز کو لیپ ٹاپ اسکرین کی طرح ہی adjust کیا جاتا ہے۔

### Apple Displays

اگر آپ Apple ڈسپلے استعمال کر رہے ہیں، تو باقاعدہ keyboard brightness keys بھی خود بخود کام کریں گی، اگر آپ Apple ڈسپلے پر focused ہیں۔ یہ `asdcontrol` command کے ذریعے کیا جاتا ہے۔

نوٹ کریں کہ اگر آپ Apple 6K XDR ڈسپلے استعمال کر رہے ہیں، تو آپ کو اپنی `hyprctl monitors` فہرست میں ایک phantom اسکرین نظر آ سکتی ہے۔ آپ اسے `~/.config/hypr/monitors.lua` میں `hl.monitor({ output = "DP-2", disabled = true })` جیسی کسی چیز سے بند کر سکتے ہیں۔

Intel مشینوں پر، آپ کو Apple ڈسپلے سے باقاعدہ Thunderbolt کیبل استعمال کر کے connect کرنا چاہیے۔ Thunderbolt کے بغیر دیگر مشینوں پر، اسے کام کرنے کے لیے آپ کو عام طور پر [DP + USB-A -> USB-C کیبل](https://www.amazon.com/dp/B0BNX7MS6N) استعمال کرنا پڑے گا۔
