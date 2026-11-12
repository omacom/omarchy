# نیویگیشن

Omarchy میں سب کچھ کی بورڈ کے ذریعے ہوتا ہے — _سب کچھ!_ جب سسٹم پہلی بار شروع ہوتا ہے، تو آپ لفظی طور پر صرف ماؤس سے کچھ بھی نہیں کر سکتے۔ لیکن آپ Omarchy Menu ظاہر کرنے کے لیے `Super + Space` دبا سکتے ہیں اور یہاں سے آپ تقریباً سب کچھ کر سکتے ہیں۔

لیکن Omarchy menu زیادہ تر وقت سسٹم چلانے کا مرکزی طریقہ بننے کے لیے ہے ہی نہیں۔ ہم اس سے بھی تیز ہو سکتے ہیں! تمام اہم ترین ایپلیکیشنز براہ راست انفرادی hotkeys سے بندھی ہوئی ہیں۔ آپ `Super + Return` سے terminal شروع کرتے ہیں اور `Super + Shift + Return` سے browser۔ ایک کے بعد دوسرا کر کے دیکھیں، اور آپ کو Hyprland کی tiling کا جادو عملی طور پر نظر آئے گا:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

پھر آپ `Super + J` دبا کر انہیں ساتھ ساتھ رکھنے کے بجائے ایک کے اوپر ایک رکھ سکتے ہیں:

 ![navigation-stacked](images/navigation-stacked.webp)

`Super + J` دوبارہ دبائیں تو وہ اپنی ساتھ ساتھ والی جگہوں پر واپس آ جائیں گی۔ پھر browser میں ہوتے ہوئے windows کا تبادلہ کرنے کے لیے `Super + Shift + Arrow Right` آزمائیں۔

اب Activity monitor شروع کرنے کے لیے `Super + Shift + T` آزمائیں۔ وہ ایک floating window کے طور پر ظاہر ہوگا۔ آپ `Super + T` استعمال کر کے اسے tile کر سکتے ہیں (اور اسے دوبارہ دبانے سے وہ دوبارہ floating ہو جائے گا)۔ اب file manager کھولنے کے لیے `Super + Shift + F` دبائیں۔ آپ کے پاس ایک صاف ستھرا چار طرفہ setup ہوگا:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

آپ `Super + Arrow` سے اس window کی طرف جاتے ہیں جسے آپ active کرنا چاہتے ہیں۔ اس سے focus بدل جائے گا اور cursor نئی application کے مرکز میں چلا جائے گا۔ کسی screen کے کنارے پر، یہ اس طرف موجود monitor پر آگے بڑھ جاتا ہے۔

اگر آپ `Super + Shift + 2` دبائیں تو آپ موجودہ focused application کو دوسرے workspace پر لے جائیں گے۔ `Super + Shift + 1` اسے واپس لے آتی ہے۔ (اور `Super + Shift + Alt + 2` موجودہ focused application کو دوسرے workspace پر لے جائے گی، اس پر جائے بغیر)۔

ایک سے زیادہ monitors ہوں تو ہر monitor کے اپنے workspaces 1 سے 10 تک ہوتے ہیں۔ `Super + 2` آپ کو اس monitor کے دوسرے workspace پر لے جاتی ہے جس پر آپ ہیں، اور ہر monitor کی اوپری bar اس کے اپنے workspaces اور وہ workspace دکھاتی ہے جو وہ دکھا رہا ہے۔ `Super + Tab` اس monitor کے workspaces میں چکر لگاتی ہے جس پر آپ ہیں۔ `Super + Shift + Ctrl + Arrows` آپ کی موجودہ window کو اس سمت کے monitor پر، اس workspace پر لے جاتی ہے جو وہ دکھا رہا ہے، اور `Super + Shift + Alt + Arrows` آپ کے موجودہ workspace کو اس سمت کے monitor پر لے جاتی ہے، جہاں اگر وہی نمبر خالی ہو تو وہ اسی نمبر کو لے لیتا ہے۔ monitor کو unplug کرنے پر وہ اپنے workspaces اپنے پاس رکھتا ہے: وہ دوسری screen کے workspaces میں شامل ہو جاتے ہیں، ان کے بعد نمبر پاتے ہیں جو اس کے پاس پہلے سے موجود ہیں، اور monitor کے واپس آنے پر اپنے پرانے نمبروں کے تحت واپس چلے جاتے ہیں۔

اگر آپ `Super` دبائے رکھیں اور ماؤس سے کسی window پر click کریں تو آپ اس کی جگہ دوبارہ ترتیب دے سکیں گے۔ اگر آپ `Super` دبائے رکھیں اور ماؤس کا دایاں button استعمال کریں تو آپ window کا سائز آزادانہ طور پر بدل سکتے ہیں۔

آپ `Super + W` یا `Super + Q` سے کوئی window بند کرتے ہیں (اور `Ctrl + Alt + Delete` سے تمام windows بند کرتے ہیں)۔

آپ `Super + F` سے full screen بھی جا سکتے ہیں یا `Super + Alt + F` سے صرف full-width (اوپری bar برقرار رکھتے ہوئے) یا `Super + Ctrl + F` سے کسی window کے اندر full-screen بھی (YouTube کے لیے بہترین!)۔

### Dwindle بمقابلہ scrolling layout

Omarchy کا default layout dwindle کہلاتا ہے۔ یہ ایک ہی workspace پر آپ کی کھولی ہوئی تمام windows کو ہر وقت نظر آتا رکھتا ہے، چاہے اس کے لیے انہیں سکڑنا ہی کیوں نہ پڑے۔

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

لیکن آپ کسی workspace کو scrolling layout میں بدلنے کا انتخاب بھی کر سکتے ہیں جہاں windows display کے نظر آنے والے کنارے سے آگے، ساتھ ساتھ قطار میں لگی ہوتی ہیں۔ آپ `Super + L` کے ذریعے ایک workspace کو اس layout میں بدلتے ہیں۔

`Super + L` دوبارہ دبانے سے workspace floating ہو جاتا ہے، جہاں windows آزادانہ طور پر ایک دوسرے پر چڑھتی ہیں اور آپ خود انہیں رکھتے ہیں، اور تیسری بار دبانے سے وہ dwindle پر واپس آ جاتا ہے۔ `Super + Alt + L` ان میں دوسری طرف سے گزرتی ہے۔ جو window ویسے ہی float کرتی ہے — جسے آپ نے `Super + T` سے باہر نکالا ہو، یا کوئی app جو ہمیشہ floating کھلتی ہو — وہ workspace کے tiling پر واپس جانے پر بھی floating ہی رہتی ہے۔ اوپری bar آپ کے موجودہ workspace کو اس کے layout کے ساتھ نشان زد کرتی ہے: dwindle کے لیے ایک مربع، scrolling کے لیے ایک دائرہ، اور floating کے لیے ایک مثلث۔ اس نشان پر click کرنے سے بھی layout میں چکر لگتا ہے۔

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

یہ انتخاب فی workspace ہے، اور یہ برقرار رہتا ہے۔ تو آپ workspace 1 کو browsing کے لیے dwindle پر اور workspace 2 کو code کے لیے scrolling پر رکھ سکتے ہیں، اور restart کے بعد وہ اسی طرح واپس آئیں گے۔

اگر آپ scrolling layout کو default کے طور پر استعمال کرنا چاہتے ہیں تو آپ اسے `~/.config/hypr/looknfeel.lua` میں مقرر کر سکتے ہیں:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Floating workspaces

ایک floating workspace روایتی desktop کی طرح کام کرتا ہے: windows ایک دوسرے پر چڑھتی ہیں، اور آپ خود انہیں حرکت دیتے اور ان کا سائز مقرر کرتے ہیں۔ ہر window کو آپ کی theme کے رنگوں میں ایک titlebar ملتی ہے، جس میں minimize، maximize اور close کرنے کے buttons ہوتے ہیں۔ `Super + M` focused window کو بھی minimize کر دیتی ہے۔ minimized window dock میں انتظار کرتی ہے؛ اسے واپس لانے کے لیے اس کی app پر click کریں۔ کسی window کو آگے لانے کے لیے اس پر click کریں۔ اس کا سائز کسی بھی کنارے یا کونے سے بدلیں۔ اوپری bar کو نظر میں رکھتے ہوئے window کو maximize کرنے کے لیے titlebar پر double-click کریں، اور اس کا پرانا سائز واپس پانے کے لیے دوبارہ کریں۔ Chrome اور دیگر Chromium-based browsers، Disks اور Document Viewer titlebar کو چھوڑ دیتے ہیں اور اس کے بجائے اپنا header استعمال کرتے ہیں؛ `Super + Alt + F` انہیں maximize کرتی ہے، اور `Super + M` انہیں minimize کرتی ہے۔

ایک floating workspace ایک dock بھی دکھاتا ہے، جس میں آپ کی pinned apps، جو کچھ چل رہا ہے وہ سب، اور apps button کے پیچھے ہر app کی ایک grid ہوتی ہے، جسے `Super + Alt + Space` اور Omarchy menu میں _Apps_ بھی کھولتے ہیں۔ کسی app کو uninstall کرنے کے لیے grid پر اس پر right-click کریں، یا `Delete` دبائیں۔ کسی app کو کھولنے کے لیے، یا اس کی window کو آگے لانے کے لیے اس پر click کریں؛ دوبارہ click کرنے سے اس کی windows میں چکر لگتا ہے۔ Middle-click ایک نئی window کھولتی ہے۔ کسی icon کو dock کے ساتھ گھسیٹ کر اسے حرکت دیں؛ کسی چلتی ہوئی app کو دوسروں کے درمیان گھسیٹ کر رکھنے سے وہ وہیں رہتی ہے۔ کسی app کو dock میں رکھنے، اسے وہاں سے نکالنے، یا اسے quit کرنے کے لیے right-click کریں۔ dock fullscreen window کے راستے سے ہٹ جاتی ہے۔ apps button پر right-click کر کے dock کو کسی دوسرے کنارے پر لے جائیں یا اسے اس وقت تک چھپا رکھیں جب تک pointer اس کے کنارے تک نہ پہنچے۔ یہ جگہ _Appearance > Dock > Dock Position_ کے تحت بھی ہے، اور `omarchy dock position left` اور `omarchy dock autohide on` دونوں کو terminal سے مقرر کرتے ہیں۔ جو apps آپ dock میں رکھتے ہیں وہ اس وقت ماند پڑ جاتی ہیں جب وہ چل نہیں رہی ہوتیں۔

نئے workspaces، اور کوئی بھی ایسا workspace جسے آپ نے `Super + L` سے اس کا اپنا layout نہیں دیا، default layout استعمال کرتے ہیں۔ default بدلنے سے windows کے بغیر ہر workspace اس پر reset ہو جاتا ہے، جبکہ جس پر windows ہوں وہ اپنا موجودہ layout برقرار رکھتا ہے۔ dock میں minimize کی گئی window اب بھی اس workspace پر ایک window شمار ہوتی ہے جسے اس نے چھوڑا تھا۔ اسے _Appearance > Workspace Layout_ کے تحت منتخب کریں: Tiling، Scrolling، یا Floating۔ `omarchy-hyprland-workspace-layout-default scrolling` اسے terminal سے مقرر کرتی ہے۔

### Windows کو گروپ کرنا

`Super + G` استعمال کر کے windows کو گروپ کیا جا سکتا ہے۔ جب آپ کسی group میں ہوں، تو اس کے active ہوتے ہوئے آپ جو بھی window شروع کریں گے وہ اس group سے تعلق رکھے گی۔ آپ `Super + Ctrl + Arrow Left/Right` استعمال کر کے ان گروپ شدہ windows کے درمیان جا سکتے ہیں یا ترتیب میں گروپ شدہ windows پر براہ راست جانے کے لیے `Super + Alt + 1/2/3/4` استعمال کر سکتے ہیں۔

آپ `Super + Alt + G` سے کسی window کو grouping سے باہر لے جا سکتے ہیں یا `Super + G` دوبارہ دبا کر پورے group کو ختم کر سکتے ہیں۔ آخر میں، آپ `Super + Alt + Arrows` سے group کے باہر کی windows کو اس کے اندر لے جا سکتے ہیں۔

### Windows کو pop کرنا

آپ `Super + O` سے کسی window کو اس کی workspace allocation سے pop out کر سکتے ہیں۔ اس سے وہ ایک floating window کے طور پر pin ہو جائے گی جو آپ جس workspace پر بھی جائیں آپ کے ساتھ رہتی ہے۔ video players اور اس جیسی چیزوں کے لیے بہترین۔

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad workspace

ایک خاص full-size scratchpad workspace ہے جو آپ کے موجودہ workspace کے اوپر آ جاتی ہے۔ آپ `Super + S` استعمال کر کے اس پر موجود چیزوں تک پہنچتے ہیں، اور `Super + Alt + S` استعمال کر کے وہاں windows رکھتے ہیں۔

یہ controls یا کسی terminal کے لیے اچھا کام کرتی ہے جس کے ساتھ آپ موجودہ workspace چھوڑے بغیر تیزی سے interact کرنا چاہتے ہیں۔

### Quake console

آخر میں، ایک آدھی اونچائی والی Quake console ہے جو آپ کے موجودہ workspace کے اوپر نیچے آ جاتی ہے۔ اسے `Super + Grave` سے toggle کریں، اور `Super + Shift + Grave` استعمال کر کے وہاں کوئی window رکھیں۔

یہ آپ کے default agent کے ساتھ کھلتی ہے جو چلنے کے لیے تیار ہوتا ہے۔ جب console میں ایک ہی window ہوتی ہے تو یہ screen پر پھیلنے کے بجائے ایک مرکز میں موجود panel کے طور پر نیچے آتی ہے۔ اس پر دوسری app رکھیں تو یہ واپس full width پر چلی جاتی ہے، تاکہ دونوں کو ساتھ ساتھ بیٹھنے کی جگہ ملے۔

کسی window کو scratchpad یا console دونوں میں سے کسی سے ہٹانے کے لیے، اسے `Super + Shift + 1` جیسی کسی چیز کے ساتھ براہ راست کسی دوسرے workspace پر بھیج دیں۔

### اس کی عادت پڑنے میں کچھ وقت لگتا ہے!

اس طرح اپنے desktop پر navigate کرنے کی عادت ڈالنے میں تھوڑا وقت لگتا ہے، لیکن جب آپ کو اس کی عادت پڑ جائے گی تو روایتی ماؤس سے چلنے والے desktop تجربے پر واپس جانا مشکل ہو جائے گا!
