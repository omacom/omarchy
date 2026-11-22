# O'z mavzungizni yaratish

O'z mavzularingizni `~/.config/omarchy/themes` ga qo'shishingiz mumkin. Mavjudlaridan birini asos qilib nusxalab oling (`/usr/share/omarchy/themes` ga qarang), so'ngra o'zingizga yoqqanicha o'zgartiring. Mavzungiz shu papka ichida bo'lsa bas, u mavzu tanlash menyusida paydo bo'ladi.

O'zgartirishingiz kerak bo'lgan asosiy fayl — `colors.toml`. U terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt ilovalari, klaviatura yoritgichi, kiritish usuli, ekranni ulashish tanlagichi, ilova piktogrammalari, bir nechta AI vositalari (Claude, Pi, Hermes, T3 Code, Herdr) va butun Omarchy qobig'i (yuqori panel, menyu, bildirishnomalar, OSD va qulflash ekrani) uchun konfiguratsiyalar yaratishda ishlatiladigan ranglar to'plamini belgilaydi.

Yangi mavzu yaratish uchun kiritilgan Aether ilovasidan ham foydalanishingiz mumkin, unda ranglar bilan o'ynash va fon rasmlarini qidirish uchun yoqimli GUI interfeysi bor. Uni `Super + Alt + Space` orqali ilovalar panjarasidan ishga tushiring, xolos.

### O'rnatilgan mavzu nimalarni o'z ichiga olishi mumkin

`~/.config/omarchy/themes` da o'zingiz yozgan mavzu xohlagan narsangizni o'z ichiga olishi mumkin — bu sizning kompyuteringiz va sizning faylingiz, Omarchy esa uning hammasini qo'llaydi.

`omarchy theme install` bilan birovning repozitoriyasidan o'rnatgan mavzungiz rangga tegishli hamma narsani saqlab qoladi, kompyuteringizda kod ishga tushiradigan bir nechta faylni esa yo'qotadi: har qanday `.lua` fayl, terminal konfiguratsiyalari (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) va `vscode.json`. Mavzuning `hyprland.lua` fayli — kompozitoringiz tizimga kirishda ishga tushiradigan Lua, terminal konfiguratsiyasi terminalingiz ishga tushiradigan dasturni nomlaydi, `vscode.json` esa o'rnatiladigan VSCode kengaytmasini nomlaydi. Birovning mavzusini o'rnatish ish stolingiz qanday ko'rinishini o'zgartirishi kerak, u nima ishga tushirishini hech qachon emas.

Qolgan hamma narsa mavzu muallifi yozganidek aynan ishlayveradi — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, fon rasmlari va oldindan ko'rishlar hammasi saqlanadi. Faqat tashlab yuborilganlari kompyuteringizda `colors.toml` dan qayta yaratiladi.

Omarchy ikkalasini mavzuning ichida o'z git repozitoriyasi bor-yo'qligiga qarab ajratadi, `omarchy theme install` klonlaganda ana shuni qoldiradi. Shunday qilib, o'zingiz yozgan mavzu sizniki bo'lib qoladi, internetdan tortib olganingiz esa ranglar bo'lib qoladi.

### Yorug' rejim

Agar yorug' rejim mavzusini yaratayotgan bo'lsangiz, `colors.toml` faylingizning yuqori qismiga `mode = "light"` ni o'rnating. Shunda u barcha ilovalar uchun avtomatik ravishda yorug' rejim bilan bog'lanadi. (Mavzungiz ildizida `light.mode` nomli bo'sh fayl qo'yishning eski usuli ham hali ishlaydi.)

### Qulfni ochish tasviri

`unlock.png` va `preview-unlock.png` tasvirlari bilan ta'minlangan mavzular _Tashqi ko'rinish > Qulfni ochish_ ostida ro'yxatga olinadi. `unlock.png` faylingiz yaxshisi shaffof png bo'lishi kerak. Oldindan ko'rish tasvirini esa `omarchy plymouth preview` yordamida yaratishingiz mumkin.

### Omarchy qamrab olmaydigan ilovalarni mavzulashtirish

Agar ro'yxatda bo'lmagan ilovadan foydalansangiz, Omarchy ga shablon yordamida uni o'zingiz mavzulashtirishni o'rgatishingiz mumkin. `~/.config/omarchy/themed/` ga u yaratadigan konfiguratsiya nomi va `.tpl` kengaytmasi bilan nomlangan fayl qo'ying, konfiguratsiyani esa `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` dan `{{ color15 }}` gacha va palitraning qolgan qismini to'ldiruvchilar sifatida yozing. Har safar mavzuni almashtirganingizda, fayl o'sha mavzu ranglari bilan qayta yaratiladi.

O'sha papkada nusxa olish uchun to'liq izohlangan `alacritty.toml.tpl.sample` bor — unda foydalanishingiz mumkin bo'lgan har bir o'zgaruvchi, shuningdek ranglarini `#` siz yoki o'nlik RGB sifatida xohlaydigan ilovalar uchun `_strip` va `_rgb` modifikatorlari ro'yxati keltirilgan. Shablonlaringiz Omarchy nikidan ustun turadi, shuning uchun bundan o'rnatilgan ilova qanday mavzulashtirilishini bekor qilish uchun ham foydalanishingiz mumkin.

### Mavzungizni tarqatish

Mavzungizni boshqalar ham foydalanishi uchun tarqatmoqchi bo'lsangiz, uni GitHub kabi ochiq git serveriga qo'yishingiz kerak. Shunda odamlar uni Omarchy menyusida _O'rnatish > Uslub > Mavzu_ orqali o'sha URL yordamida o'rnatishlari mumkin. `omarchy-[themename]-theme` nomlash tartibiga amal qilish tavsiya etiladi, chunki o'rnatilgandan keyin mavzu tanlash menyusida mavzu to'g'ri, shunchaki `[themename]` sifatida ko'rinadi.

Qoldiq `[themename]` mavzuning katalog nomiga aylanadi, shuning uchun u Omarchy xavfsiz uzata oladigan nom bo'lishi kerak: u harf, raqam yoki pastki chiziq bilan boshlanishi kerak, qolgani esa harflar, raqamlar, `.`, `_`, `+` va `-` ni o'z ichiga olishi mumkin. Bosh harflar siz uchun kichik harflarga aylantiriladi, lekin boshqa har qanday narsa — bo'sh joy, qo'shtirnoq, inglizcha bo'lmagan belgi — katalog nomiga aylantirilmasdan, o'rnatish vaqtida rad etiladi. Shunday qilib, `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` va `omarchy-c++-theme` larning hammasi muammosiz o'rnatiladi.

Esda tuting, repozitoriyadan o'rnatilgandan keyin u olib keladigan har qanday `.lua`, terminal konfiguratsiyasi yoki `vscode.json` tashlab yuboriladi, shuning uchun mavzuni shular atrofida qurmang.

Mavzungizni [omarchy-site repozitoriyasiga](https://github.com/omacom-io/omarchy-site) pull request yuborish orqali [qo'shimcha mavzular sahifasiga](https://omarchy.org/themes/) qo'shtirishingiz mumkin.
