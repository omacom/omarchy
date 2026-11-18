# O'z mavzungizni yaratish

Siz o'z mavzularingizni `~/.config/omarchy/themes` ga qo'shishingiz mumkin. Shunchaki mavjudlaridan birini asos sifatida nusxalang (`/usr/share/omarchy/themes` ga qarang), keyin ko'nglingiz tusaganchalik sozlab chiqing. Mavzungiz shu papka ichida bo'lsa bas, u mavzu tanlash menyusiga kiritiladi.

Sozlashingiz kerak bo'lgan asosiy fayl — `colors.toml`. U keyin terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian va butun Omarchy qobig'i (yuqori panel, menyu, bildirishnomalar, OSD va qulf ekrani) uchun konfiguratsiyalar yaratishda ishlatiladigan ranglar to'plamini belgilaydi.

Yangi mavzu yaratish uchun kiritilgan Aether ilovasidan ham foydalanishingiz mumkin: undagi yoqimli GUI interfeysi orqali ranglar bilan o'ynab ko'rasiz va fonlarni qidirasiz. Uni shunchaki `Super + Alt + Space` tugmalari bilan ilovalar panjarasidan ishga tushiring.

### O'rnatilgan mavzu nimalarni o'z ichiga olishi mumkin

`~/.config/omarchy/themes` ichida o'zingiz yozgan mavzu nimani xohlasangiz, shuni o'z ichiga olishi mumkin — bu sizning mashinangiz va sizning faylingiz, Omarchy esa uning hammasini qo'llaydi.

Boshqa birovning reposidan `omarchy theme install` bilan o'rnatgan mavzungiz rangga oid hamma narsani saqlab qoladi, mashinangizda kod ishga tushiradigan bir hovuch fayllarni esa yo'qotadi: har qanday `.lua` fayli, terminal konfiguratsiyalari (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) va `vscode.json`. Mavzuning `hyprland.lua` fayli — kompozitoringiz tizimga kirishda ishga tushiradigan Lua, terminal konfiguratsiyasi terminalingiz qaysi dasturni boshlashini nomlaydi, `vscode.json` esa o'rnatiladigan VSCode kengaytmasini nomlaydi. Birovning mavzusini o'rnatish ish stolingiz qanday ko'rinishini o'zgartirishi kerak, u nima ishga tushirishini hech qachon emas.

Qolgan hamma narsa mavzu muallifi yozganidek aynan ishlayveradi — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, fonlar va oldindan ko'rishlar hammasi saqlanadi. Faqat tashlab yuborilgan narsalargina mashinangizda `colors.toml` dan qayta yaratiladi.

Omarchy bu ikkisini mavzuning ichida o'zining git reposi bor-yo'qligiga qarab ajratadi, `omarchy theme install` klonlaganda aynan shuni ortda qoldiradi. Shunday qilib, o'zingiz yozgan mavzu sizniki bo'lib qoladi, internetdan tortib olgani esa ranglar bo'lib qoladi.

### Yorug' rejim

Agar yorug' rejim mavzusini yaratayotgan bo'lsangiz, `colors.toml` faylingizning tepasida `mode = "light"` deb o'rnating. Shunda u barcha ilovalar uchun avtomatik ravishda yorug' rejim bilan juftlanadi. (Mavzungizning ildiziga `light.mode` deb atalgan bo'sh fayl tashlashdan iborat eski usul ham hali ishlaydi.)

### Qulfni ochish tasviri

`unlock.png` va `preview-unlock.png` tasvirlari bilan ta'minlangan mavzular _Appearance > Unlock_ ostida ro'yxatga olinadi. `unlock.png` faylingiz yaxshisi shaffof png bo'lishi kerak. Oldindan ko'rish tasvirini esa `omarchy plymouth preview` yordamida yaratishingiz mumkin.

### Omarchy qamrab olmaydigan ilovalarni mavzulashtirish

Agar o'sha ro'yxatda yo'q ilovadan foydalansangiz, shablon yordamida Omarchy ga uni mavzulashtirishni o'zingiz o'rgatishingiz mumkin. `~/.config/omarchy/themed/` ichiga u yaratadigan konfiguratsiya nomi ortidan `.tpl` kengaytmasi qo'shilgan fayl tashlang va konfiguratsiyani `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` dan `{{ color15 }}` gacha va palitraning qolgan qismini o'rinbosarlar sifatida yozing. Har safar mavzuni almashtirganingizda, fayl o'sha mavzuning ranglari bilan qayta yaratiladi.

O'sha papkada nusxa olish uchun to'liq izohlangan `alacritty.toml.tpl.sample` bor — unda foydalanishingiz mumkin bo'lgan har bir o'zgaruvchi, shuningdek, ranglarini `#` siz yoki o'nlik RGB ko'rinishida xohlaydigan ilovalar uchun `_strip` va `_rgb` modifikatorlari ro'yxati keltirilgan. Shablonlaringiz Omarchy nikidan ustun turadi, shu bois bundan ichki ilova qanday mavzulashtirilishini bekor qilish uchun ham foydalanishingiz mumkin.

### Mavzungizni tarqatish

Agar mavzungizni boshqalar ham foydalanishi uchun tarqatmoqchi bo'lsangiz, uni GitHub kabi ommaviy git serveriga joylashingiz kerak. Shunda odamlar uni o'sha URL yordamida Omarchy menyusidagi _Install > Style > Theme_ orqali o'rnatishlari mumkin. `omarchy-[themename]-theme` nomlash kelishuviga amal qilish tavsiya etiladi, chunki shunda mavzu o'rnatilgandan keyin mavzu tanlash menyusida to'g'ri, shunchaki `[themename]` sifatida ko'rinadi.

Qoldiq `[themename]` mavzuning papka nomiga aylanadi, shuning uchun u Omarchy xavfsiz tarzda qo'ldan qo'lga uzata oladigan nom bo'lishi kerak: u harf, raqam yoki tagchiziq bilan boshlanishi kerak, qolgan qismida esa harflar, raqamlar, `.`, `_`, `+` va `-` bo'lishi mumkin. Bosh harflar siz uchun kichik harflarga aylantiriladi, lekin boshqa har qanday narsa — probel, qo'shtirnoq, inglizcha bo'lmagan belgi — papka nomiga aylantirilmay, o'rnatish paytida rad etiladi. Shunday qilib, `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` va `omarchy-c++-theme` larning hammasi hech qanday muammosiz o'rnatiladi.

Esda tuting: u repodan o'rnatilgandan keyin, u bilan birga keladigan har qanday `.lua`, terminal konfiguratsiyasi yoki `vscode.json` tashlab yuboriladi, shuning uchun mavzuni ana shular atrofida qurmang.

Mavzungizni [omarchy-site repo](https://github.com/omacom-io/omarchy-site) ga pull request yuborish orqali [qo'shimcha mavzular sahifasi](https://omarchy.org/themes/) ga qo'shishingiz mumkin.
