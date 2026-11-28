# O‘z mavzuingizni yaratish

O‘z mavzularingizni `~/.config/omarchy/themes` ga qo‘shishingiz mumkin. Shunchaki mavjudlaridan birini asos qilib nusxalab oling (`/usr/share/omarchy/themes` ga qarang), so‘ng ko‘nglingiz tusaganchalik o‘zgartiring. Mavzuingiz shu papka ichida bo‘lsa bas, u mavzu tanlash menyusiga kiritiladi.

Tahrirlashingiz kerak bo‘lgan asosiy fayl — `colors.toml`. U terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt ilovalari, klaviatura orqa yoritgichi, kiritish usuli, ekranni ulashish tanlovchisi, ilova piktogrammalari, bir nechta AI vositalari (Claude, Pi, Hermes, T3 Code, Herdr) va butun Omarchy qobig‘i (yuqori panel, menyu, bildirishnomalar, OSD va qulf ekrani) uchun konfiguratsiyalar yaratishda ishlatiladigan ranglar to‘plamini belgilaydi.

Qo‘shib berilgan Aether ilovasidan ham foydalanib, ranglar bilan o‘ynash va fon rasmlarini qidirish uchun qulay GUI interfeysi orqali yangi mavzu yaratishingiz mumkin. Uni shunchaki `Super + Alt + Space` orqali ilovalar to‘ridan ishga tushiring.

### O‘rnatilgan mavzu nimalarni o‘z ichiga olishi mumkin

`~/.config/omarchy/themes` da o‘zingiz yozgan mavzu xohlagan narsangizni o‘z ichiga olishi mumkin — bu sizning mashinangiz va sizning faylingiz, Omarchy hammasini qo‘llaydi.

`omarchy theme install` bilan birovning repo sidan o‘rnatgan mavzuingiz rangga oid hamma narsani saqlab qoladi va mashinangizda kod ishga tushiradigan bir hovuch fayllarni yo‘qotadi: istalgan `.lua` fayli, terminal konfiguratsiyalari (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) va `vscode.json`. Mavzuning `hyprland.lua` fayli — kompozitoringiz kirish paytida ishga tushiradigan Lua, terminal konfiguratsiyasi terminalingiz ishga tushiradigan dasturni nomlaydi, `vscode.json` esa o‘rnatiladigan VSCode kengaytmasini nomlaydi. Birovning mavzusini o‘rnatish ish stolingiz qanday ko‘rinishini o‘zgartirishi kerak, hech qachon u nima ishga tushirishini emas.

Qolgan hamma narsa mavzu muallifi yozganidek aynan ishlayveradi — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, fon rasmlari va oldindan ko‘rishlar hammasi saqlanib qoladi. Faqat tashlab yuborilganlari mashinangizda `colors.toml` dan qayta yaratiladi.

Omarchy ikkisini mavzuning ichida o‘zining git repo si bor-yo‘qligiga qarab farqlaydi, `omarchy theme install` klonlaganda aynan shuni qoldiradi. Shunday qilib, o‘zingiz yozgan mavzu sizniki bo‘lib qoladi, internetdan tortib olganingiz esa ranglar bo‘lib qoladi.

### Yorug‘ rejim

Agar yorug‘ rejim mavzusini yaratayotgan bo‘lsangiz, `colors.toml` faylingizning tepasiga `mode = "light"` deb qo‘ying. Shunda u barcha ilovalar uchun avtomatik ravishda yorug‘ rejim bilan juftlanadi. (Mavzuingiz ildiziga `light.mode` nomli bo‘sh fayl tashlashning eski usuli ham hanuz ishlaydi.)

### Yuklanish va kirish ekranlari

Yuklanish paytida disk parolini so‘raydigan ekran va kirish ekrani Omarchy logotipini mavzuingizning `background` i ustiga uning `accent` rangida chizadi, parol maydoni uning `foreground` rangida, noto‘g‘ri parol uchun esa `red` bilan. Ular uchun qo‘shimcha hech narsa jo‘natish kerak emas: Omarchy endi mavzuning `unlock.png` yoki `preview-unlock.png` fayllaridan foydalanmaydi. Apple Silicon Mac larda disk paroli ekrani mavzu qanday bo‘lishidan qat’i nazar Omarchy ning standart ko‘rinishini saqlab qoladi.

### Omarchy qamrab olmaydigan ilovalarni mavzulashtirish

Agar o‘sha ro‘yxatda bo‘lmagan ilovadan foydalansangiz, shablon yordamida Omarchy ga uni mavzulashtirishni o‘zingiz o‘rgatishingiz mumkin. `~/.config/omarchy/themed/` ga u yaratadigan konfiguratsiya nomi va qo‘shimcha `.tpl` kengaytmasi bilan nomlangan fayl tashlang va konfiguratsiyani `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` dan `{{ color15 }}` gacha va palitraning qolgan qismini o‘rinbosarlar sifatida yozing. Har safar mavzuni almashtirganingizda, fayl o‘sha mavzuning ranglari bilan qayta yaratiladi.

O‘sha papkada nusxa olish uchun to‘liq izohlangan `alacritty.toml.tpl.sample` bor — unda foydalanishingiz mumkin bo‘lgan har bir o‘zgaruvchi, shuningdek ranglarini `#` siz yoki o‘nlik RGB sifatida istaydigan ilovalar uchun `_strip` va `_rgb` modifikatorlari ro‘yxati keltirilgan. Sizning shablonlaringiz Omarchy nikidan ustun turadi, shu bois bundan o‘rnatilgan ilovaning qanday mavzulanishini bekor qilish uchun ham foydalanishingiz mumkin.

### Mavzuingizni tarqatish

Agar mavzuingizni boshqalar ham foydalanishi uchun tarqatmoqchi bo‘lsangiz, uni GitHub kabi ommaviy git serveriga joylashingiz kerak. So‘ng odamlar uni o‘sha URL yordamida Omarchy menyusidagi _Install > Style > Theme_ orqali o‘rnatishi mumkin. `omarchy-[themename]-theme` nomlash tartibiga amal qilish tavsiya etiladi, chunki o‘rnatilgandan keyin mavzu tanlash menyusida mavzu to‘g‘ri tarzda, shunchaki `[themename]` ko‘rinishida chiqadi.

O‘sha qolgan `[themename]` mavzuning katalog nomiga aylanadi, shuning uchun u Omarchy xavfsiz ishlata oladigan nom bo‘lishi kerak: u harf, raqam yoki tagchiziq bilan boshlanishi kerak, qolgan qismida esa harflar, raqamlar, `.`, `_`, `+` va `-` bo‘lishi mumkin. Bosh harflar siz uchun kichik harflarga aylantiriladi, lekin boshqa hamma narsa — bo‘sh joy, qo‘shtirnoq, inglizcha bo‘lmagan belgi — katalog nomiga aylantirilmasdan, o‘rnatish vaqtidayoq rad etiladi. Shunday qilib, `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` va `omarchy-c++-theme` larning hammasi muammosiz o‘rnatiladi.

Yodda tuting, u repo dan o‘rnatilgach, u bilan keladigan istalgan `.lua`, terminal konfiguratsiyasi yoki `vscode.json` tashlab yuboriladi, shuning uchun mavzuni shular atrofida qurmang.

Mavzuingizni [omarchy-site repo](https://github.com/omacom-io/omarchy-site) ga pull request yuborish orqali [qo‘shimcha mavzular sahifasi](https://omarchy.org/themes/) ga qo‘shtirishingiz mumkin.
