# نیویگیشن

Omarchy میں سب کچھ کی بورڈ کے ذریعے ہوتا ہے — _سب کچھ!_ جب سسٹم پہلی بار شروع ہوتا ہے، تو آپ لفظی طور پر صرف ماؤس سے کچھ نہیں کر سکتے۔ لیکن آپ `Super + Space` دبا کر Omarchy Menu ظاہر کر سکتے ہیں اور یہاں سے آپ تقریباً سب کچھ کر سکتے ہیں۔

لیکن Omarchy menu کا مقصد زیادہ تر وقت سسٹم چلانے کا مرکزی طریقہ بننا ہے ہی نہیں۔ ہم اس سے زیادہ تیز ہو سکتے ہیں! تمام اہم ترین applications براہ راست انفرادی hotkeys کے ساتھ منسلک ہیں۔ آپ terminal کو `Super + Return` سے اور browser کو `Super + Shift + Return` سے شروع کرتے ہیں۔ ایک کے بعد دوسرا کر کے دیکھیں، اور آپ کو Hyprland کی tiling کا جادو عمل میں نظر آئے گا:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

پھر آپ `Super + J` دبا کر انہیں ساتھ ساتھ رکھنے کے بجائے ایک کے اوپر دوسرے کو رکھ سکتے ہیں:

 ![navigation-stacked](images/navigation-stacked.webp)

انہیں ساتھ ساتھ والی پوزیشنوں پر واپس لانے کے لیے دوبارہ `Super + J` دبائیں۔ پھر browser پر ہوتے ہوئے windows کو آپس میں بدلنے کے لیے `Super + Shift + Arrow Right` آزمائیں۔

اب Activity monitor شروع کرنے کے لیے `Super + Shift + T` آزمائیں۔ وہ ایک floating window کے طور پر ظاہر ہوگا۔ آپ `Super + T` کے ذریعے اسے tile کر سکتے ہیں (اور اسے دوبارہ floating بنانے کے لیے وہی دوبارہ دبائیں)۔ اب files manager کھولنے کے لیے `Super + Shift + F` دبائیں۔ آپ کے پاس ایک صاف ستھری چار طرفہ ترتیب ہوگی:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

آپ `Super + Arrow` کے ذریعے اس window تک جاتے ہیں جسے آپ active کرنا چاہتے ہیں۔ اس سے focus بدل جائے گا اور cursor نئی application کے مرکز میں چلا جائے گا۔ screen کے کنارے پر، یہ اس طرف موجود monitor تک آگے جاری رہتا ہے۔

اگر آپ `Super + Shift + 2` دبائیں گے، تو آپ موجودہ focused application کو دوسرے workspace پر منتقل کر دیں گے۔ `Super + Shift + 1` اسے واپس منتقل کر دیتا ہے۔ (اور `Super + Shift + Alt + 2` موجودہ focused application کو اس پر switch کیے بغیر دوسرے workspace پر منتقل کر دے گا)۔

ایک سے زیادہ monitors کے ساتھ، ہر monitor کے اپنے workspaces 1 تا 10 ہوتے ہیں۔ `Super + 2` آپ کو اس monitor کے دوسرے workspace پر لے جاتا ہے جس پر آپ ہیں، اور ہر monitor کی top bar اس کے اپنے workspaces اور وہ workspace دکھاتی ہے جو وہ دکھا رہا ہے۔ `Super + Tab` اس monitor کے workspaces میں cycle کرتا ہے جس پر آپ ہیں۔ `Super + Shift + Ctrl + Arrows` آپ کی موجودہ window کو اس سمت کے monitor پر، اس workspace پر منتقل کر دیتا ہے جو وہ دکھا رہا ہے، اور `Super + Shift + Alt + Arrows` آپ کے موجودہ workspace کو اس سمت کے monitor پر منتقل کر دیتا ہے، جہاں وہی نمبر ملتا ہے اگر وہ خالی ہو۔ monitor کو unplug کرنے پر وہ اپنے workspaces برقرار رکھتا ہے: وہ دوسری screen کے workspaces کے ساتھ شامل ہو جاتے ہیں، اس کے پہلے سے موجود workspaces کے بعد نمبر لے کر، اور monitor کے واپس آنے پر اپنے پرانے نمبروں کے تحت واپس چلے جاتے ہیں۔

اگر آپ `Super` دبائے رکھیں اور ماؤس سے کسی window پر click کریں، تو آپ اس کی جگہ دوبارہ ترتیب دے سکیں گے۔ اگر آپ `Super` دبائے رکھیں اور ماؤس کا right button استعمال کریں، تو آپ window کا سائز آزادانہ طور پر بدل سکتے ہیں۔

آپ کسی window کو `Super + W` یا `Super + Q` سے بند کرتے ہیں (اور تمام windows کو `Ctrl + Alt + Delete` سے بند کرتے ہیں)۔

آپ `Super + F` سے full screen بھی جا سکتے ہیں یا `Super + Alt + F` سے صرف full-width (top bar برقرار رکھتے ہوئے) یا `Super + Ctrl + F` سے کسی window کے اندر full-screen بھی جا سکتے ہیں (YouTube کے لیے بہترین!)۔

### Dwindle بمقابلہ scrolling layout

Omarchy کی default layout کو dwindle کہا جاتا ہے۔ یہ آپ کے کسی ایک workspace پر کھولی گئی تمام windows کو ہر وقت نظر آنے کی حالت میں رکھتی ہے، چاہے اسے انہیں چھوٹا ہی کیوں نہ کرنا پڑے۔

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

لیکن آپ کسی workspace کو scrolling layout میں بدلنے کا انتخاب بھی کر سکتے ہیں جہاں windows ساتھ ساتھ قطار میں لگی ہوتی ہیں، display کے نظر آنے والے کنارے سے آگے تک۔ آپ `Super + L` کے ذریعے کسی ایک workspace کو اس layout میں بدلتے ہیں۔

دوبارہ `Super + L` دبانے سے workspace floating ہو جاتا ہے، جہاں windows آزادانہ طور پر ایک دوسرے پر overlap کرتی ہیں اور آپ انہیں خود رکھتے ہیں، اور تیسری بار دبانے سے یہ wapas dwindle پر آ جاتا ہے۔ `Super + Alt + L` ان میں دوسری سمت سے گزرتا ہے۔ کوئی window جو ویسے بھی float کرتی ہے — جسے آپ نے `Super + T` سے باہر نکالا ہو، یا کوئی app جو ہمیشہ floating کھلتی ہے — workspace کے tiling پر واپس جانے پر floating ہی رہتی ہے۔ top bar آپ کے موجودہ workspace کو اس کی layout کے ساتھ نشان زد کرتی ہے: dwindle کے لیے ایک square، scrolling کے لیے ایک circle، اور floating کے لیے ایک triangle۔ اس نشان پر click کرنے سے بھی layout cycle ہوتی ہے۔

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

یہ انتخاب ہر workspace کے لیے الگ ہے، اور یہ برقرار رہتا ہے۔ تو آپ workspace 1 کو browsing کے لیے dwindle پر اور workspace 2 کو code کے لیے scrolling پر رکھ سکتے ہیں، اور restart کے بعد بھی وہ اسی طرح واپس آئیں گے۔

اگر آپ scrolling layout کو default کے طور پر استعمال کرنا چاہتے ہیں، تو آپ اسے `~/.config/hypr/looknfeel.lua` میں set کر سکتے ہیں:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Floating workspaces

ایک floating workspace روایتی desktop کی طرح کام کرتا ہے: windows ایک دوسرے پر overlap کرتی ہیں، اور آپ انہیں خود منتقل اور ان کا سائز تبدیل کرتے ہیں۔ ہر window کو آپ کے theme کے رنگوں میں ایک titlebar ملتی ہے، جس میں minimize، maximize، اور close کے buttons ہوتے ہیں۔ `Super + M` focused window کو بھی minimize کر دیتا ہے۔ ایک minimized window dock میں انتظار کرتی ہے؛ اسے واپس لانے کے لیے اس کی app پر click کریں۔ کسی window کو آگے لانے کے لیے اس پر click کریں۔ اس کا سائز کسی بھی کنارے یا کونے سے بدلیں۔ top bar کو نظر میں رکھتے ہوئے window کو maximize کرنے کے لیے titlebar پر double-click کریں، اور اس کا پرانا سائز واپس پانے کے لیے دوبارہ double-click کریں۔

ایک floating workspace ایک dock بھی دکھاتا ہے، جس میں آپ کی pinned apps، چلنے والی ہر چیز، اور apps button کے پیچھے ہر app کا ایک grid ہوتا ہے، جسے `Super + Alt + Space` اور Omarchy menu میں _Apps_ بھی کھولتے ہیں۔ اسے uninstall کرنے کے لیے grid پر کسی app پر right-click کریں، یا `Delete` دبائیں۔ کسی app کو کھولنے، یا اس کی window کو آگے لانے کے لیے اس پر click کریں؛ اس کی windows میں cycle کرنے کے لیے دوبارہ click کریں۔ Middle-click ایک نئی window کھولتا ہے۔ کسی icon کو dock کے ساتھ drag کر کے اسے منتقل کریں؛ ایک چلتی ہوئی app کو دوسری apps کے درمیان drag کرنے سے وہ وہیں رہتی ہے۔ کسی app کو dock میں رکھنے، اسے باہر نکالنے، یا اسے quit کرنے کے لیے right-click کریں۔ dock کسی fullscreen window کی راہ سے ہٹ جاتا ہے۔ dock کو کسی دوسرے کنارے پر منتقل کرنے یا اسے اس وقت تک چھپانے کے لیے جب تک pointer اس کے کنارے تک نہ پہنچے، apps button پر right-click کریں۔ یہ پوزیشن _Appearance > Dock > Dock Position_ کے تحت بھی موجود ہے، اور `omarchy dock position left` اور `omarchy dock autohide on` دونوں کو terminal سے set کرتے ہیں۔ جو apps آپ dock میں رکھتے ہیں وہ اس وقت faded ہوتی ہیں جب وہ چل نہیں رہی ہوتیں۔

نئے workspaces، اور کوئی بھی workspace جسے آپ نے `Super + L` کے ساتھ اس کی اپنی layout نہیں دی، default layout استعمال کرتے ہیں۔ default بدلنے سے windows کے بغیر ہر workspace اس پر reset ہو جاتا ہے، جب کہ جس workspace پر windows ہوں وہ اپنی موجودہ layout برقرار رکھتا ہے۔ dock میں minimize کی گئی window اب بھی اس workspace پر ایک window شمار ہوتی ہے جہاں سے وہ گئی تھی۔ اسے _Appearance > Workspace Layout_ کے تحت منتخب کریں: Tiling، Scrolling، یا Floating۔ `omarchy-hyprland-workspace-layout-default scrolling` اسے terminal سے set کرتا ہے۔

### Windows کو group کرنا

Windows کو `Super + G` کے ذریعے group کیا جا سکتا ہے۔ جب آپ کسی group میں ہوں، تو اس کے active ہوتے ہوئے آپ جو بھی window شروع کریں گے وہ اس group سے تعلق رکھے گی۔ آپ `Super + Ctrl + Arrow Left/Right` کے ذریعے ان grouped windows کے درمیان جا سکتے ہیں یا ترتیب میں براہ راست grouped window پر جانے کے لیے `Super + Alt + 1/2/3/4` استعمال کر سکتے ہیں۔

آپ `Super + Alt + G` کے ذریعے کسی window کو grouping سے باہر منتقل کر سکتے ہیں یا دوبارہ `Super + G` دبا کر پورے group کو ختم کر سکتے ہیں۔ آخر میں، آپ `Super + Alt + Arrows` کے ذریعے group سے باہر کی windows کو اس میں منتقل کر سکتے ہیں۔

### Windows کو pop کرنا

آپ `Super + O` کے ذریعے کسی window کو اس کی workspace allocation سے pop out کر سکتے ہیں۔ اس سے وہ ایک floating window کے طور پر pin ہو جائے گی جو آپ جس workspace پر بھی جائیں آپ کے ساتھ رہتی ہے۔ video players اور اس جیسی چیزوں کے لیے بہترین۔

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad workspace

ایک خاص full-size scratchpad workspace ہے جو آپ کے موجودہ workspace کے اوپر overlay ہوتا ہے۔ آپ `Super + S` کے ذریعے اس پر موجود چیزوں تک رسائی حاصل کرتے ہیں، اور آپ `Super + Alt + S` کے ذریعے وہاں windows رکھتے ہیں۔

یہ controls یا کسی terminal کے لیے اچھا کام کرتا ہے جس کے ساتھ آپ موجودہ workspace چھوڑے بغیر جلدی سے interact کرنا چاہتے ہیں۔

### Quake console

آخر میں، ایک half-height Quake console ہے جو آپ کے موجودہ workspace کے اوپر نیچے آتا ہے۔ اسے `Super + Grave` کے ساتھ toggle کریں، اور `Super + Shift + Grave` کے ذریعے وہاں ایک window رکھیں۔

یہ آپ کے default agent کے ساتھ تیار حالت میں کھلتا ہے۔ جب console میں ایک ہی window ہوتی ہے، تو یہ screen کو گھیرنے کے بجائے ایک centered panel کے طور پر نیچے آتا ہے۔ اس پر دوسری app رکھیں اور یہ full width پر واپس چلا جاتا ہے، تاکہ دونوں کو ساتھ ساتھ بیٹھنے کی جگہ ملے۔

کسی window کو scratchpad یا console دونوں میں سے کسی سے بھی ہٹانے کے لیے، اسے `Super + Shift + 1` جیسی کسی ترکیب کے ساتھ براہ راست دوسرے workspace پر بھیجیں۔

### اس کی عادت پڑنے میں کچھ وقت لگتا ہے!

اپنے desktop کو اس طرح navigate کرنے کی عادت پڑنے میں تھوڑا وقت لگتا ہے، لیکن جب پڑ جائے گی، تو روایتی mouse-driven desktop تجربے پر واپس جانا مشکل ہو جائے گا!
