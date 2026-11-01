# Dotfile'lar

Omarchy asosan `~/.config` da joylashgan dotfile'lar deb ataladigan fayllar orqali sozlanadi. Ular sizning o'zgarishlaringiz uchun sizning fayllaringiz hisoblanadi. `/usr/share/omarchy` da joylashgan fayllar Omarchy'ning o'ziga tegishli va ular bilan o'ynashmasligingiz kerak. Agar `/usr/share/omarchy` dagi biror narsani o'zgartirishingiz kerak bo'lsa, buning o'rniga qiymatni `~/.config` da override qilishingiz kerak.

Asosiy configlarni Omarchy menyusidan (`Super + Space`) to'g'ridan-to'g'ri tahrirlashingiz mumkin, masalan _Setup > Keybindings_, _Setup > Input_ va _Setup > Config > [file]_. Shu tarzda qilganingizda, config tahrirlaridan keyin qayta ishga tushirilishi kerak bo'lgan har qanday jarayon editorni yopganingizdan keyin avtomatik ravishda qayta ishga tushiriladi (standart bo'yicha Neovim — `:wq`, esingizdami! — lekin buni _Setup > Defaults > Editor_ orqali o'zgartirishingiz mumkin).

Quyida `~/.config` dagi asosiy fayllar va ular nimani boshqarishi ro'yxati keltirilgan:

| Fayl                  | Vazifasi              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hyprland asosiy configi. Omarchy standartlarini hamda quyidagi override fayllaringizni yuklaydi. [Hyprland configlari haqida ko'proq ma'lumot](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | O'z klaviatura yorliqlaringiz va standartlarni override qilishlaringiz. |
| `~/.config/hypr/monitors.lua` | Monitor paneli qamrab olmaydigan monitor sozlamalari, masalan aylantirish, qo'shimcha rejimlar yoki monitorni o'chirilgan holda saqlash. |
| `~/.config/hypr/input.lua` | Klaviatura tartibi, sichqoncha va trekpad sozlamalaringizni boshqaradi. |
| `~/.config/hypr/looknfeel.lua` | Bo'shliqlar, chegaralar, animatsiyalar va tashqi ko'rinishning qolgan qismini boshqaradi. |
| `~/.config/hypr/autostart.lua` | Sessiya bilan birga ishga tushiriladigan qo'shimcha jarayonlarni boshqaradi. |
| `~/.config/omarchy/shell.json` | Omarchy shell'ini boshqaradi: panel o'rni, tartibi va vidjetlari, shuningdek ekran saqlagichi, qulflash va bekor turish vaqtlarini. |
| `~/.config/foot/foot.ini` | Terminalingizni boshqaradi (standart terminal — foot). |
| `~/.XCompose` | Tez kirish emoji'laringizni va ism/email avtoto'ldirishini belgilaydi. O'zgarishlardan keyin `omarchy-restart-xcompose` ni ishga tushirishni unutmang. |

Agar o'z sozlamangizni moslash uchun ko'p o'zgarishlar kiritsangiz, barcha bu dotfile'larning zaxira nusxasini olish yaxshi fikr. [Stow — buni qilishning ajoyib usuli](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### O'z ilovalaringizni sessiya bilan birga ishga tushirish

Agar har safar tizimga kirganingizda biror narsa ishlashini istasangiz — sinxronlash daemon'i, chat ilovasi, o'z skriptingiz — uni `~/.config/hypr/autostart.lua` ga qo'ying:

```lua
o.launch_on_start("my-service")
```

Bu buyruqni sessiyaning bir qismi sifatida ishga tushiradi, shuning uchun tizimdan yana chiqqaningizda u to'g'ri tozalanadi.

### Tizim hodisalarida skriptlarni ishga tushirish

Omarchy bir nechta paytlarda hook'larni ishga tushiradi va siz ularga o'z skriptlaringizni ulashingiz mumkin. Ular `~/.config/omarchy/hooks/<event>.d/` da joylashgan, har bir hodisa uchun bitta katalog va hodisa sodir bo'lganda u yerdagi har bir bajariladigan fayl ishlaydi:

| Hodisa | Qachon ishlaydi |
| ----- | ------------ |
| `post-boot` | Ish stoli ishga tushgandan so'ng darhol |
| `post-update` | `omarchy update` oxiriga yaqin, paketlar, migratsiyalar va xizmatlarni qayta ishga tushirishdan keyin, mise vositalari yangilanishidan oldin |
| `pre-refresh-pacman` | `omarchy refresh pacman` paket configini qayta sinxronlagandan keyin, paketlarni yangilashidan oldin; kanalni almashtirish uni o'sha refresh bosqichining o'zida ishga tushiradi |
| `theme-set` | Mavzu o'zgargandan keyin (mavzu nomi `$1` da) |
| `font-set` | Shrift o'zgargandan keyin (shrift nomi `$1` da) |
| `battery-low` | Batareya quvvati kam qolganda (foiz `$1` da) |

`pre-refresh-pacman` hook'i maxsus repository'lar yoki `IgnorePkg` qatorlari tegishli bo'lgan joy, chunki u paket tranzaksiyasidan oldin ishlaydi. Yangilanishga oid ikkala hook ham Omarchy keshdagi sudo ruxsatini tozalagandan keyin sizning foydalanuvchingiz sifatida ishlaydi, shuning uchun `sudo` dan foydalanadigan hook o'z ruxsatiga muhtoj va parolingizni so'rashi mumkin.

Bu kataloglarning har birida allaqachon hook shaklini ko'rsatadigan `.sample` fayli bor — uni ishga tushirish uchun nomidan `.sample` ni olib tashlang. Boshqa joyda yozgan skriptingizni o'rnatish uchun `omarchy hook install post-boot ~/my-hook` dan foydalaning, u uni nusxalab olib, bajariladigan qiladi.

### O'z menyu elementlaringizni qo'shish

Omarchy menyusini (`Super + Space`) `~/.config/omarchy/extensions/omarchy-menu.jsonc` ni tahrirlash orqali o'z qatorlaringiz bilan kengaytirish mumkin. Elementlar nuqtali id bilan belgilanadi va id ularni daraxtda joylashtiradi, shuning uchun `personal` ildiz menyuda va `personal.notes` uning ichida paydo bo'ladi:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Mavjud id dan qayta foydalansangiz, yangi qator qo'shish o'rniga o'sha qatorni override qilasiz. Fayl barcha mavjud maydonlar izohlar sifatida hujjatlashtirilgan holda taqdim etiladi.

### O'z shell exportlaringiz, funksiyalaringiz va aliaslaringizni qo'shish

Omarchy bir qator qulay aliaslar va foydali funksiyalar bilan keladi, lekin o'zingiznikini qo'shishni istash juda odatiy hol. Aliaslar, funksiyalar va exportlarni ham `~/.bashrc` ga qo'shishingiz kerak. Bu fayl yangilanishlarda ustiga yozilmaydi. Omarchy standartlaridan birortasini o'zgartirmoqchi bo'lsangiz, ularni bu yerga ham xavfsiz qo'shishingiz mumkin.

### Ish stoli uchun muhit o'zgaruvchilarini o'rnatish

Ish stoli sessiyasi exportlari `~/.config/uwsm/env.d/` ga tegishli. Bu fayllar ish stolingiz ishga tushishidan oldin ishlaydi, shuning uchun shell xatosi sizni tizimga kirish ekraniga qaytarib yuborishi mumkin. Ularni tahrirlashda ishlaydigan terminalni ochiq saqlang. Override'ni o'chirish uchun uni `env.d` dan boshqa joyga ko'chiring. Agar o'zgarish tizimga kirishga to'sqinlik qilsa, [tizimga kirishni tiklash](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) ga qarang.

### Ichki Omarchy fayllarini o'zgartirish

Qarang, bu sizning kompyuteringiz. U bilan xohlaganingizni qilishingiz mumkin, lekin `/usr/share/omarchy` dagi fayllarga bevosita o'zgartirish kiritishni maslahat bermayman. Ular Omarchy pacman paketiga tegishli, shuning uchun o'zgarishlaringiz keyingi yangilanishda shunchaki ustiga yozib yuboriladi. Buning o'rniga, sizga yoqmagan istalgan standart qiymatlarni `~/.config/*` papkasida override qilganingiz ma'qul.

Shu yo'l bilan deyarli hamma narsani o'zgartirishingiz mumkin, masalan standart klaviatura yorliqlarini. Masalan, [Obsidian](https://obsidian.md/) o'rniga [Joplin](https://joplinapp.org/) ni qo'yish uchun `~/.config/hypr/bindings.lua` ni tahrirlang (`omarchy-pkg-add joplin-bin` bilan o'rnating):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` uning o'rnini bosuvchisini qo'shishdan oldin mavjud bog'lanishni olib tashlaydi. U `o.bind` bilan bir xil argumentlarni oladi, jumladan ishga tushirish yordamchilari va bog'lanish parametrlarini. Bog'lanish qo'shish uchun `o.bind` dan, uni almashtirmasdan olib tashlash uchun `hl.unbind` dan foydalaning.

Agar ichki Omarchy fayllarini kovlashtirishda qat'iy tursangiz, _Update > Channel > Dev_ orqali dev kanaliga o'ting. Bu Omarchy ni `~/omarchy` dagi manba kodining git checkout'iga bog'laydi va uni ko'nglingiz tusaganchalik o'zgartirishingiz mumkin. Bu yerda sizga nima qilishni aytadigan hech kim yo'q!

### Har qanday o'zgarishlarni qaytarish

Agar oxir-oqibat configlarni chalkashtirib yuborsangiz, ularni Omarchy menyusidagi _Update > Config_ orqali har doim standart holatiga qaytarishingiz mumkin. Yoki hammasini tiklash uchun `omarchy reinstall configs` ni ishga tushiring.
