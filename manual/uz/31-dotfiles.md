# Dotfiles

Omarchy asosan `~/.config` ichida joylashgan dotfayllar deb ataladigan fayllar orqali sozlanadi. Ular sizning o'zgartirishlaringiz uchun sizning fayllaringiz hisoblanadi. `/usr/share/omarchy` ichida joylashgan fayllar Omarchy'ning o'ziga tegishli va siz ularga aralashmasligingiz kerak. Agar `/usr/share/omarchy` ichida biror narsani o'zgartirishingiz kerak bo'lsa, buning o'rniga qiymatni `~/.config` ichida qayta belgilashingiz kerak.

Asosiy sozlamalarni Omarchy menyusidan (`Super + Space`) to'g'ridan-to'g'ri tahrirlash mumkin, masalan, _Setup > Keyboard > Keybindings_, _Setup > Input_ va _Setup > Config > [file]_. Shu tarzda qilganingizda, sozlamalarni tahrirlagandan keyin qayta ishga tushirilishi kerak bo'lgan har qanday jarayon muharrirdan chiqqaningizdan keyin avtomatik ravishda qayta ishga tushiriladi (standart holatda Neovim — `:wq`, esingizdami! — lekin buni _Setup > Defaults > Editor_ orqali o'zgartirishingiz mumkin).

Quyida `~/.config` ichidagi asosiy fayllar ro'yxati va ular nimani boshqarishi keltirilgan:

| Fayl | Maqsad |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Asosiy Hyprland sozlamasi. Omarchy standart sozlamalarini hamda quyidagi bekor qilish fayllaringizni yuklaydi. [Hyprland sozlamalari haqida ko'proq bilib oling](https://wiki.hypr.land/Configuring/). |
| `~/.config/hypr/bindings.lua` | O'zingizning tugmalar birikmalaringiz va standartlarini bekor qilishlaringiz. |
| `~/.config/hypr/monitors.lua` | Monitor paneli qamrab olmaydigan monitor sozlamalari, masalan, aylantirish, qo'shimcha rejimlar yoki monitorni o'chirilgan holda saqlash. |
| `~/.config/hypr/input.lua` | Klaviatura tartibingiz, sichqoncha va trekpad sozlamalaringizni boshqaradi. |
| `~/.config/hypr/looknfeel.lua` | Bo'shliqlar, chegaralar, animatsiyalar va tashqi ko'rinishning qolgan qismini boshqaradi. |
| `~/.config/hypr/autostart.lua` | Sessiya bilan ishga tushiriladigan qo'shimcha jarayonlarni boshqaradi. |
| `~/.config/omarchy/shell.json` | Omarchy shell'ini boshqaradi: panel o'rni, tartibi va vidjetlari, shuningdek ekran saqlagichi, qulflash va bo'sh turish vaqtlari. |
| `~/.config/foot/foot.ini` | Terminalingizni boshqaradi (foot standart hisoblanadi). |
| `~/.XCompose` | Tez kirish emoji'laringizni va ism/email avtoto'ldirishingizni belgilaydi. O'zgartirishlar kiritgandan keyin `omarchy-restart-xcompose` ni ishga tushirishni unutmang. |

Agar o'z sozlamangizni moslashtirish uchun ko'p o'zgartirishlar kiritsangiz, barcha ushbu dotfayllarni zaxiralab qo'yish yaxshi fikrdir. [Stow — buni qilishning ajoyib usuli](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### O'z ilovalaringizni sessiya bilan ishga tushirish

Har safar tizimga kirganingizda biror narsa ishlashini istasangiz — sinxronlash demoni, chat ilovasi, o'z skriptingiz — uni `~/.config/hypr/autostart.lua` ga qo'ying:

```lua
o.launch_on_start("my-service")
```

Bu buyruqni sessiyaning bir qismi sifatida ishga tushiradi, shuning uchun siz tizimdan yana chiqqaningizda u to'g'ri tarzda tozalanadi.

### Tizim hodisalarida skriptlarni ishga tushirish

Omarchy bir nechta lahzalarda xuklarni ishga tushiradi va siz ularga o'z skriptlaringizni ulashingiz mumkin. Ular `~/.config/omarchy/hooks/<event>.d/` ichida joylashgan, har bir hodisa uchun bitta katalog mavjud va `.sample` bilan tugamaydigan u yerdagi har bir fayl hodisa sodir bo'lganda bash bilan ishlaydi:

| Hodisa | Qachon ishlaydi |
| ----- | ------------ |
| `post-boot` | Ish stoli ishga tushgandan so'ng darhol |
| `post-update` | `omarchy update` oxiriga yaqin, paketlar, migratsiyalar va xizmatlarni qayta ishga tushirishdan keyin, mise vositalari yangilanishidan oldin |
| `pre-refresh-pacman` | `omarchy refresh pacman` paket sozlamasini qayta sinxronlashtirgandan keyin, paketlarni yangilashdan oldin; kanal almashinuvi uni xuddi shu yangilash bosqichida ishga tushiradi |
| `theme-set` | Mavzu o'zgargandan keyin (mavzu nomi `$1` da) |
| `font-set` | Shrift o'zgargandan keyin (shrift nomi `$1` da) |
| `battery-low` | Batareya quvvati kam qolganda (foiz `$1` da) |

`pre-refresh-pacman` xuki — maxsus repozitoriylar yoki `IgnorePkg` satrlari uchun joy, chunki u paket tranzaksiyasidan oldin ishlaydi. Ikkalasi ham sizning foydalanuvchingiz sifatida ishlaydi. `post-update` `omarchy update`'ning sudo avtorizatsiyasi hali ham yangi bo'lgan paytda ishlaydi, shuning uchun `sudo` dan foydalanadigan xuk parolingizni qayta so'ramaydi; `pre-refresh-pacman` esa `omarchy refresh pacman` o'zi sudo dan foydalangandan so'ng darhol ishlaydi.

Ushbu kataloglarning har birida allaqachon xukning shaklini ko'rsatadigan `.sample` fayli mavjud — uni ishga tushirish uchun nomdan `.sample` ni olib tashlang. Boshqa joyda yozgan skriptingizni o'rnatish uchun `omarchy hook install post-boot ~/my-hook` dan foydalaning, bu uni nusxalaydi va bajariladigan qilib qo'yadi.

### O'z menyu yozuvlaringizni qo'shish

Omarchy menyusini (`Super + Space`) `~/.config/omarchy/extensions/omarchy-menu.jsonc` ni tahrirlash orqali o'z satrlaringiz bilan kengaytirish mumkin. Yozuvlar nuqtali id bo'yicha kalitlanadi va aynan id ularni daraxtga joylashtiradi, shuning uchun `personal` ildiz menyuda ko'rinadi va `personal.notes` uning ichida ko'rinadi:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Mavjud id ni qayta ishlating va siz yangi satr qo'shish o'rniga o'sha satrni bekor qilasiz. Fayl barcha mavjud maydonlar izohlar sifatida hujjatlashtirilgan holda yetkaziladi.

### O'z shell eksportlaringiz, funksiyalaringiz va aliaslaringizni qo'shish

Omarchy qulay aliaslar va foydali funksiyalar to'plami bilan yetkaziladi, lekin o'zingiznikini qo'shishni istash juda keng tarqalgan holat. Aliaslar, funksiyalar va eksportlarni ham `~/.bashrc` ga qo'shishingiz kerak. Bu fayl yangilanishlarda ustiga yozilmaydi. Agar Omarchy standartlaridan birortasini o'zgartirmoqchi bo'lsangiz, ularni ham shu yerga xavfsiz qo'shishingiz mumkin.

### Ish stoli uchun muhit o'zgaruvchilarini sozlash

Ish stoli sessiyasi eksportlari `~/.config/uwsm/env.d/` ga tegishli. Bu fayllar ish stolingiz ishga tushishidan oldin ishlaydi, shuning uchun shell xatosi sizni kirish ekraniga qaytarib yuborishi mumkin. Ularni tahrirlayotganda ishlaydigan terminalni ochiq holda saqlang. Bekor qilishni o'chirish uchun uni `env.d` dan tashqariga ko'chiring. Agar o'zgartirish kirishga to'sqinlik qilsa, [kirishni tiklash](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) bo'limiga qarang.

### Ichki Omarchy fayllarini o'zgartirish

Qarang, bu sizning kompyuteringiz. U bilan xohlaganingizni qilishingiz mumkin, lekin `/usr/share/omarchy` ichidagi fayllarga to'g'ridan-to'g'ri o'zgartirish kiritmaslikni maslahat beraman. Ular Omarchy pacman paketiga tegishli, shuning uchun o'zgartirishlaringiz keyingi yangilanishda shunchaki ustiga yozib yuboriladi. Buning o'rniga yoqtirmaydigan har qanday standart qiymatlarni `~/.config/*` papkasida bekor qilib qo'yganingiz ma'qul.

Shu tarzda deyarli hamma narsani o'zgartirishingiz mumkin, masalan, standart tugmalar birikmalarini. Shunchaki `~/.config/hypr/bindings.lua` ni tahrirlang, masalan, [Obsidian](https://obsidian.md/) ni [Joplin](https://joplinapp.org/) bilan almashtirish uchun (`omarchy-pkg-add joplin-bin` bilan o'rnating):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` almashtiruvchisini qo'shishdan oldin mavjud birikmani olib tashlaydi. U `o.bind` bilan bir xil argumentlarni oladi, jumladan ishga tushirish yordamchilari va birikma parametrlarini ham. Birikma qo'shish uchun `o.bind` dan, almashtirmasdan birini olib tashlash uchun esa `hl.unbind` dan foydalaning.

Agar ichki Omarchy fayllarini buzib o'zgartirishda turib olsangiz, _Update > Channel > Dev_ orqali dev kanaliga o'ting. Bu Omarchy ni `~/omarchy` ichidagi manba kodining git nusxasiga bog'laydi, uni esa ko'nglingiz tusaganchalik o'zgartirishga erkinsiz. Bu yerda sizga nima qilish kerakligini aytadigan hech kim yo'q!

### Har qanday o'zgartirishlarni tiklash

Agar sozlamalarni chalkashtirib yuborsangiz, ularni Omarchy menyusidagi _Update > Config_ orqali har doim standart holatga qaytarishingiz mumkin. Yoki hammasini tiklash uchun `omarchy reinstall configs` ni ishga tushirish orqali.
