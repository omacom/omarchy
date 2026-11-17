# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) GitHub Desktop جیسی کسی ایپلیکیشن کا ایک دلچسپ متبادل ہے، اور یہ ٹرمینل کے اندر چلتا ہے۔

آپ اسے براہ راست چلا سکتے ہیں، اس کے لیے git کے زیر انتظام کسی بھی directory میں جائیں اور `lazygit` چلائیں۔ یا آپ اسے Neovim کے اندر چلا سکتے ہیں جہاں اسے `Space G G` سے شروع کیا جا سکتا ہے۔

آپ `Tab` استعمال کر کے مختلف panes کے درمیان آ جا سکتے ہیں۔ Files pane میں، آپ `Space` استعمال کر کے staging کے لیے files منتخب کرتے ہیں، اور پھر آپ `c` استعمال کر کے ایک نیا commit بنا سکتے ہیں۔ آپ `?` استعمال کر کے دستیاب تمام commands دیکھ سکتے ہیں۔

## Btop

[Btop](https://github.com/aristocratos/btop) ایک خوبصورت resource manager ہے جو memory، CPU، disk، اور network کے استعمال کو دکھاتا ہے۔ یہ تمام فعال processes کی فہرست بھی دیتا ہے، اور آپ کو ان کا انتظام کرنے کی اجازت دیتا ہے۔

Omarchy اسے Activity Monitor کہتا ہے، اور آپ اسے app launcher سے یا `Super + Shift + T` دبا کر شروع کرتے ہیں۔ یہ ایک floating window کے طور پر کھلتا ہے، جسے آپ `Super + T` سے tile کر سکتے ہیں۔

## Herdr

[Herdr](https://github.com/omacom-io/herdr) ایک terminal workspace manager ہے جو آپ کو workspaces، tabs، اور panes دیتا ہے، اور ان سب کو ایک persistent session میں چلتا رکھتا ہے جس سے آپ detach ہو کر بعد میں واپس آ سکتے ہیں۔

آپ اسے (یا اپنے موجودہ session سے دوبارہ منسلک ہونے کے لیے) app launcher سے یا `Super + Ctrl + Return` سے شروع کرتے ہیں۔ Omarchy ایک Herdr configuration فراہم کرتا ہے جو اس کی Tmux config کی عکاسی کرتی ہے، اس لیے یہاں بھی prefix key `Ctrl + Space` ہے۔ آپ `Super + Ctrl + K` سے تمام keybindings دیکھ سکتے ہیں۔

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) سسٹم کی معلومات دکھاتا ہے، جیسے kernel version، uptime، theme، CPU، memory، اور بہت کچھ۔ یہ مقبول neofetch tool کا جانشین ہے۔

Omarchy نے اسے Omarchy menu (`Super + Space`) میں _About_ کے طور پر شامل کیا ہے۔

## Cliamp

[Cliamp](https://www.cliamp.stream/) Winamp 2.x سے متاثر ایک retro terminal music player ہے، جو lo-fi beats کے لیے built-in radio stations کے ساتھ مکمل ہے۔ اسے `Super + Shift + Alt + M` سے، یا Omarchy menu میں _Apps_ کے تحت لانچ کریں۔ مکمل keybinding فہرست کے لیے `?` دبائیں۔

## Wi-Fi اور Bluetooth کا کیا ہوگا؟

آپ کو Wi-Fi اور Bluetooth کے لیے TUIs نہیں ملیں گے — یہ کام Omarchy shell کے ہیں۔ نیٹ ورکس دیکھنے اور منسلک ہونے کے لیے اوپر والی bar میں Wi-Fi آئیکن پر کلک کریں (یا `Super + Ctrl + N` دبائیں)، اور devices کو pair اور connect کرنے کے لیے Bluetooth آئیکن پر کلک کریں (یا `Super + Ctrl + B` دبائیں)۔ مکمل تفصیل کے لیے [نیٹ ورکنگ](35-networking.md) دیکھیں۔

## اپنا خود کا شامل کرنا

کوئی بھی terminal program مکمل app جیسا برتاؤ حاصل کر سکتا ہے۔ Omarchy menu (`Super + Space`) میں _Install > TUI_ پر جائیں، اسے ایک نام، ایک launch command، ایک window style، اور ایک آئیکن دیں، اور یہ کسی بھی دوسری application کی طرح app launcher میں نظر آئے گا۔ آپ اسے _Remove > TUI_ کے تحت دوبارہ ہٹا سکتے ہیں۔
