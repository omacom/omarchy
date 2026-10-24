# Oʻz mavzuingizni yaratish

Siz oʻzingizning mavzularingizni `~/.config/omarchy/themes` ga qoʻshishingiz mumkin. Faqat mavjudlaridan birini asos sifatida nusxalang (`/usr/share/omarchy/themes` ga qarang), keyin koʻngildagidek sozlang. Mavzuingiz ushbu jild ichida ekan, u mavzu tanlash menyusiga kiritiladi.

Siz sozlashingiz kerak boʻlgan asosiy fayl `colors.toml`. Bu keyinchalik terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian va butun Omarchy shell (yuqori panel, menyu, bildirishnomalar, OSD va qulf ekrani) uchun konfiguratsiyalarni yaratish uchun ishlatiladigan ranglar toʻplamini belgilaydi.

Siz shuningdek ranglar bilan oʻynash va fonlarni qidirish uchun ajoyib GUI interfeysi yordamida yangi mavzu yaratish uchun kiritilgan Aether ilovasidan foydalanishingiz mumkin. Uni `Super + Alt + Space` da ilova katagidan boshlang.

### Oʻrnatilgan mavzu nimani oʻz ichiga olishi mumkin

`~/.config/omarchy/themes` da oʻzingiz yozgan mavzu istagan narsangizni oʻz ichiga olishi mumkin — bu sizning mashinangiz va sizning faylingiz va Omarchy hammasini qoʻllaydi.

`omarchy theme install` bilan boshqa birovning reposidan oʻrnatgan mavzuingiz rang boʻlgan hamma narsani saqlab qoladi va mashinangizda kod ishga tushiradigan bir nechta faylni yoʻqotadi: har qanday `.lua` fayl, terminal konfiguratsiyalari (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) va `vscode.json`. Mavzuning `hyprland.lua` si sizning kompozitoringiz kirishda ishlatadigan Lua, terminal konfiguratsiyasi terminalingiz boshlaydigan dasturni nomlaydi va `vscode.json` oʻrnatiladigan VSCode kengaytmasini nomlaydi. Birovning mavzuni oʻrnatish ish stoliningiz koʻrinishini oʻzgartirishi kerak, u nima ishga tushirishini hech qachon emas.

Boshqa hamma narsa mavzu muallifi yozganidek ishlaydi — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, fonlar va oldindan koʻrishlar hammasi saqlanadi. Faqat tushirib qoldirilgan narsa mashinangizda `colors.toml` dan qayta yaratiladi.

Omarchy ikkisini mavzuning ichida oʻzining git reposi bor-yoʻqligi boʻyicha ajratadi, `omarchy theme install` klonlanganda ortda qoldiradigan narsa. Shunday qilib siz yozgan mavzu siznikicha qoladi va internetdan olganingiz ranglar bilan qoladi.

### Ochiq rejim

Agar siz ochiq rejim mavzu yaratayotgan boʻlsangiz, `colors.toml` ingizning yuqori qismida `mode = "light"` ni oʻrnating. Keyin u barcha ilovalar uchun ochiq rejim bilan avtomatik juftlashadi. (Mavzuningiz ildizida `light.mode` deb nomlangan boʻsh faylni tashlashning eski usuli ham ishlaydi.)

### Belgi ranglari

Agar fayl menejeri belgilarini mavzuingizga rang bilan moslashtirmoqchi boʻlsangiz, foydalanishni istagan belgi toʻplamining nomi bilan `icons.theme` deb nomlangan faylni qoʻshing. Standart holatda, variantlar: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Ochish rasmi

`unlock.png` va `preview-unlock.png` rasmlari bilan taʼminlangan mavzular _Uslub > Qulfdan ochish_ ostida roʻyxatga olinadi. Sizning `unlock.png` ingiz afzal shaffof png boʻlishi kerak. Va siz `omarchy plymouth preview` yordamida oldindan koʻrish rasmini yaratishingiz mumkin.

### Omarchy qamrab olmaydigan ilovalarni mavzulash

Agar siz ushbu roʻyxatda boʻlmagan ilovadan foydalansangiz, shablon bilan Omarchy ni oʻzingiz mavzulashga oʻrgatishingiz mumkin. `~/.config/omarchy/themed/` ga u yaratadigan konfiguratsiya nomi va `.tpl` kengaytmasi bilan nomlangan faylni tashlang va konfiguratsiyani `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` dan `{{ color15 }}` gacha va palitraning qolgan qismi oʻrnbosarlar sifatida yozing. Mavzularni har safar almashtirganingizda, fayl oʻsha mavzuning ranglari bilan qayta yaratiladi.

Ushbu jildda nusxalash uchun toʻliq izohlangan `alacritty.toml.tpl.sample` mavjud — u foydalanishingiz mumkin boʻlgan har bir oʻzgaruvchini, plyus ranglarini `#` siz yoki oʻnlik RGB sifatida istagan ilovalar uchun `_strip` va `_rgb` modifikatorlarini roʻyxatlaydi. Shablonlaringiz Omarchy nikiga nisbatan ustunlikka ega, shuning uchun siz buni ichki ilova qanday mavzulanishini bekor qilish uchun ham ishlatishingiz mumkin.

### Mavzuingizni tarqatish

Agar mavzuingizni boshqalar foydalana olishi uchun tarqatishni istasangiz, uni GitHub kabi ommaviy git serverga qoʻyishingiz kerak. Keyin odamlar uni ushbu URL dan foydalanib Omarchy menyusidagi _Oʻrnatish > Uslub > Mavzu_ yordamida oʻrnatishlari mumkin. `omarchy-[themename]-theme` nomlash shartnomasiga amal qilishingiz tavsiya etiladi, chunki mavzu oʻrnatishdan keyin mavzu tanlash menyusida shunchaki `[themename]` sifatida toʻgʻri koʻrsatiladi.

Bu ortda qolgan `[themename]` mavzuning katalog nomi boʻladi, shuning uchun Omarchy uni xavfsiz ravishda uzata oladigan ismga ega boʻlishi kerak: u harf, raqam yoki pastki chiziq bilan boshlanishi kerak va qolgani harflar, raqamlar, `.`, `_`, `+` va `-` ni ushlab turishi mumkin. Katta harflar siz uchun kichik harflarga tushiriladi, ammo boshqa har narsa — boʻsh joy, tirnoq, inglizcha boʻlmagan belgi — katalog nomiga aylantirilish oʻrniga oʻrnatish vaqtida rad etiladi. Shunday qilib `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` va `omarchy-c++-theme` hammasi yaxshi oʻrnatiladi.

Shuni esda tutingki, u repodan oʻrnatilgach, u joʻnatadigan har qanday `.lua`, terminal konfiguratsiyasi yoki `vscode.json` tushirib qoldiriladi, shuning uchun mavzuni ularning atrofida qurmang.

Mavzuingizni [omarchy-site repo](https://github.com/omacom-io/omarchy-site) ga pull request yuborish orqali [qoʻshimcha mavzular sahifasiga](https://omarchy.org/themes/) qoʻshdirishingiz mumkin.
