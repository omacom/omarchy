# O'z mavzungizni yaratish

Siz o'z mavzularingizni `~/.config/omarchy/themes` ga qo'shishingiz mumkin. Shunchaki mavjudlaridan birini asos qilib nusxa oling (`/usr/share/omarchy/themes` ga qarang), so'ng ko'nglingiz tusaguncha o'zgartiring. Mavzungiz shu papka ichida bo'lar ekan, u mavzu tanlash menyusida ko'rsatiladi.

O'zgartirishingiz kerak bo'lgan asosiy fayl — `colors.toml`. U terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian va butun Omarchy qobig'i (yuqori panel, menyu, bildirishnomalar, OSD va qulf ekrani) uchun konfiguratsiyalar yaratishda ishlatiladigan ranglar to'plamini belgilaydi.

Yangi mavzu yaratish uchun kiritilgan Aether ilovasidan ham foydalanishingiz mumkin — unda ranglar bilan o'ynash va fon rasmlarini qidirish uchun yoqimli GUI interfeysi bor. Uni `Super + Alt + Space` tugmalari orqali ilovalar panjarasidan ishga tushiring.

### O'rnatilgan mavzu nimalarni o'z ichiga olishi mumkin

`~/.config/omarchy/themes` ichida o'zingiz yozgan mavzu xohlagan narsangizni o'z ichiga olishi mumkin — bu sizning mashinangiz va sizning faylingiz, Omarchy barchasini qo'llaydi.

`omarchy theme install` bilan birovning repozitoriyasidan o'rnatgan mavzungiz rangga oid hamma narsani saqlab qoladi, mashinangizda kod ishga tushiradigan bir hovuch fayllarni esa yo'qotadi: har qanday `.lua` fayli, terminal konfiguratsiyalari (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) va `vscode.json`. Mavzuning `hyprland.lua` fayli — kompozitoringiz kirish paytida ishga tushiradigan Lua, terminal konfiguratsiyasi terminalingiz ishga tushiradigan dasturni nomlaydi, `vscode.json` esa o'rnatiladigan VSCode kengaytmasini nomlaydi. Birovning mavzusini o'rnatish ish stolingiz qanday ko'rinishini o'zgartirishi kerak, u nima ishga tushirishini emas.

Qolgan hamma narsa mavzu muallifi yozganidek aniq ishlaydi — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, fon rasmlari va oldindan ko'rish tasvirlari saqlanib qoladi. Faqat tashlab yuborilgan narsalar mashinangizda `colors.toml` dan qayta yaratiladi.

Omarchy bu ikkisini mavzuning ichida o'z git repozitoriyasi bor-yo'qligiga qarab ajratadi, `omarchy theme install` klonlaganida aynan shuni qoldiradi. Shunday qilib, o'zingiz yozgan mavzu sizniki bo'lib qoladi, internetdan tortib olganingiz esa faqat ranglar bo'lib qoladi.

### Yorug' rejim

Agar yorug' rejimli mavzu yaratayotgan bo'lsangiz, `colors.toml` faylining tepasiga `mode = "light"` deb yozing. Shunda u barcha ilovalar uchun avtomatik ravishda yorug' rejim bilan juftlashtiriladi. (Mavzungiz ildiziga `light.mode` nomli bo'sh fayl tashlashdan iborat eski usul ham hamon ishlaydi.)

### Belgi ranglari

Fayl menejeri belgilarini mavzungizga moslab bo'yashni istasangiz, foydalanmoqchi bo'lgan belgilar to'plami nomi yozilgan `icons.theme` nomli fayl qo'shing. Odatiy holatda variantlar quyidagilar: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Qulfni ochish tasviri

`unlock.png` va `preview-unlock.png` tasvirlari bilan ta'minlangan mavzular _Appearance > Unlock_ ostida ro'yxatga olinadi. `unlock.png` faylingiz imkon qadar shaffof png bo'lgani ma'qul. Oldindan ko'rish tasvirini esa `omarchy plymouth preview` yordamida yaratishingiz mumkin.

### Omarchy qamrab olmaydigan ilovalarni mavzulashtirish

Agar o'sha ro'yxatda bo'lmagan ilovadan foydalansangiz, Omarchy ga uni o'zingiz mavzulashtirishni o'rgatishingiz mumkin — shablon yordamida. `~/.config/omarchy/themed/` ichiga u yaratadigan konfiguratsiya nomi va ustiga `.tpl` kengaytmasi bilan nomlangan fayl tashlang, konfiguratsiyani esa `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` dan `{{ color15 }}` gacha va palitraning qolgan qismini to'ldiruvchilar sifatida yozing. Har safar mavzuni almashtirganingizda, fayl o'sha mavzuning ranglari bilan qayta yaratiladi.

O'sha papkada nusxa olish uchun to'liq izohlangan `alacritty.toml.tpl.sample` bor — unda foydalanishingiz mumkin bo'lgan har bir o'zgaruvchi, shuningdek, ranglarini `#` siz yoki o'nlik RGB ko'rinishida xohlaydigan ilovalar uchun `_strip` va `_rgb` modifikatorlari sanab o'tilgan. Shablonlaringiz Omarchy nikidan ustun turadi, shuning uchun bundan o'rnatilgan ilova qanday mavzulashtirilishini bekor qilish uchun ham foydalanishingiz mumkin.

### Mavzungizni tarqatish

Mavzungizni boshqalar ham foydalanishi uchun tarqatmoqchi bo'lsangiz, uni GitHub kabi ochiq git serveriga joylashingiz kerak. Shunda odamlar uni shu URL yordamida Omarchy menyusida _Install > Style > Theme_ orqali o'rnatishlari mumkin. `omarchy-[themename]-theme` nomlash tartibiga amal qilish tavsiya etiladi, chunki o'rnatilgandan so'ng mavzu tanlash menyusida mavzu shunchaki `[themename]` sifatida to'g'ri ko'rsatiladi.

O'sha qolib ketgan `[themename]` mavzuning katalog nomiga aylanadi, shuning uchun u Omarchy xavfsiz uzata oladigan nom bo'lishi kerak: u harf, raqam yoki tagchiziq bilan boshlanishi kerak, qolgani esa harflar, raqamlar, `.`, `_`, `+` va `-` ni o'z ichiga olishi mumkin. Bosh harflar siz uchun kichik harflarga aylantiriladi, lekin boshqa hamma narsa — bo'sh joy, qo'shtirnoq, inglizcha bo'lmagan belgi — katalog nomiga aylantirish o'rniga o'rnatish paytida rad etiladi. Shunday qilib, `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` va `omarchy-c++-theme` ning hammasi muammosiz o'rnatiladi.

Esda tuting: mavzu repozitoriyadan o'rnatilgach, u bilan birga keladigan har qanday `.lua`, terminal konfiguratsiyasi yoki `vscode.json` tashlab yuboriladi, shuning uchun mavzuni shular atrofida qurmang.

Mavzungizni [omarchy-site repozitoriyasiga](https://github.com/omacom-io/omarchy-site) pull request yuborish orqali [qo'shimcha mavzular sahifasiga](https://omarchy.org/themes/) qo'shtirishingiz mumkin.
