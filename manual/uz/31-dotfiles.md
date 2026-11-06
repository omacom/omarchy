# Dotfayllar

Omarchy asosan `~/.config` ichida joylashgan dotfayllar deb ataluvchi fayllar orqali sozlanadi. Ular sizning o'zgartirishlaringiz uchun sizning fayllaringiz hisoblanadi. `/usr/share/omarchy` ichida joylashgan fayllar Omarchy'ning o'ziga tegishli, ularga tegmasligingiz kerak. Agar `/usr/share/omarchy` ichidagi biror narsani o'zgartirishingiz kerak bo'lsa, o'rniga qiymatni `~/.config` ichida qayta belgilashingiz kerak.

Asosiy konfiguratsiyalarni to'g'ridan-to'g'ri Omarchy menyusidan (`Super + Space`) tahrirlash mumkin, masalan _Setup > Keyboard > Keybindings_, _Setup > Input_ va _Setup > Config > [file]_. Bu usulda qilganingizda, konfiguratsiya tahrirlaridan keyin qayta ishga tushirilishi kerak bo'lgan har qanday jarayon muharrirdan chiqqaningizdan keyin avtomatik ravishda qayta ishga tushiriladi (standart bo'yicha Neovim — `:wq`, esingizdami! — lekin buni _Setup > Defaults > Editor_ orqali o'zgartirishingiz mumkin).

Mana `~/.config` ichidagi asosiy fayllar va ular nimalarni boshqarishi ro'yxati:

| Fayl                  | Maqsadi              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Asosiy Hyprland konfiguratsiyasi. Omarchy standartlarini hamda quyidagi bekor qilish fayllaringizni yuklaydi. [Hyprland konfiguratsiyalari haqida ko'proq bilib oling](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | O'zingizning tugma birikmalaringiz va standartlarni bekor qilishlaringiz. |
| `~/.config/hypr/monitors.lua` | Monitor paneli qamrab olmaydigan monitor sozlamalari, masalan burish, qo'shimcha rejimlar yoki monitorni o'chirilgan holda saqlash. |
| `~/.config/hypr/input.lua` | Klaviatura tartibi, sichqoncha va trekpad sozlamalaringizni boshqaradi. |
| `~/.config/hypr/looknfeel.lua` | Bo'shliqlar, chegaralar, animatsiyalar va ko'rinishning qolgan qismini boshqaradi. |
| `~/.config/hypr/autostart.lua` | Sessiya bilan ishga tushiriladigan qo'shimcha jarayonlarni boshqaradi. |
| `~/.config/omarchy/shell.json` | Omarchy qobig'ini boshqaradi: panel o'rni, tartibi va vidjetlari, shuningdek ekran saqlagichi, qulflash va bo'sh turish vaqt cheklovlari. |
| `~/.config/foot/foot.ini` | Terminalingizni boshqaradi (standart bo'yicha foot). |
| `~/.XCompose` | Tez kirish emoji va ism/email avtomatik to'ldirishingizni belgilaydi. O'zgartirishlar kiritgandan keyin `omarchy-restart-xcompose` ni ishga tushirishni unutmang. |

Agar o'z sozlamalaringizni moslash uchun ko'p o'zgartirishlar kiritsangiz, barcha ushbu dotfayllarni zaxiralab qo'yish yaxshi fikr. [Stow buning ajoyib usuli](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Sessiya bilan o'z ilovalaringizni ishga tushirish

Har safar tizimga kirganingizda biror narsa ishga tushishini istasangiz — sinxronlash demoni, chat ilovasi, o'z skriptingiz — uni `~/.config/hypr/autostart.lua` ga qo'ying:

```lua
o.launch_on_start("my-service")
```

Bu buyruqni sessiyaning bir qismi sifatida ishga tushiradi, shuning uchun tizimdan yana chiqqaningizda u to'g'ri tozalanadi.

### Tizim hodisalarida skriptlarni ishga tushirish

Omarchy bir nechta paytlarda huklarni ishga tushiradi va siz ularga o'z skriptlaringizni ulashingiz mumkin. Ular `~/.config/omarchy/hooks/<event>.d/` ichida joylashgan, har bir hodisa uchun bitta katalog, va hodisa sodir bo'lganda u yerdagi har bir bajariladigan fayl ishga tushadi:

| Hodisa | Qachon ishga tushadi |
| ----- | ------------ |
| `post-boot` | Ish stoli ishga tushgandan so'ng darhol |
| `post-update` | `omarchy update` oxiriga yaqin, paketlar, migratsiyalar va xizmatlarni qayta ishga tushirishdan keyin, mise vositalari yangilanishidan oldin |
| `pre-refresh-pacman` | `omarchy refresh pacman` paket konfiguratsiyasini qayta sinxronlagandan keyin, paketlarni yangilashidan oldin; kanalni almashtirish uni o'sha yangilash bosqichida ishga tushiradi |
| `theme-set` | Mavzu o'zgargandan keyin (mavzu nomi `$1` da) |
| `font-set` | Shrift o'zgargandan keyin (shrift nomi `$1` da) |
| `battery-low` | Batareya quvvati kamayganda (foiz `$1` da) |

`pre-refresh-pacman` huki maxsus repozitoriylar yoki `IgnorePkg` qatorlari uchun mo'ljallangan, chunki u paket tranzaksiyasidan oldin ishga tushadi. Yangilanish bilan bog'liq ikkala huk ham Omarchy keshlangan sudo ruxsatini tozalagandan keyin sizning foydalanuvchingiz sifatida ishga tushadi, shuning uchun `sudo` dan foydalanadigan huk o'z ruxsatiga muhtoj va parolingizni so'rashi mumkin.

Ushbu kataloglarning har birida huk shaklini ko'rsatadigan `.sample` fayli allaqachon mavjud — uni ishga tushirish uchun nomidan `.sample` ni olib tashlang. Boshqa joyda yozgan skriptingizni o'rnatish uchun `omarchy hook install post-boot ~/my-hook` dan foydalaning, u uni nusxalaydi va bajariladigan qiladi.

### O'z menyu yozuvlaringizni qo'shish

Omarchy menyusini (`Super + Space`) `~/.config/omarchy/extensions/omarchy-menu.jsonc` ni tahrirlash orqali o'z qatorlaringiz bilan kengaytirish mumkin. Yozuvlar nuqtali id bilan belgilanadi va aynan id ularni daraxtda joylashtiradi, shuning uchun `personal` ildiz menyuda ko'rinadi va `personal.notes` uning ichida ko'rinadi:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Mavjud id ni qayta ishlating va siz yangi qator qo'shish o'rniga o'sha qatorni bekor qilasiz. Fayl barcha mavjud maydonlar izohlar sifatida hujjatlashtirilgan holda keladi.

### O'z qobiq eksportlaringiz, funksiyalaringiz va aliaslaringizni qo'shish

Omarchy bir qator qulay aliaslar va foydali funksiyalar bilan keladi, lekin o'zingiznikini qo'shishni istash juda keng tarqalgan. Aliaslar, funksiyalar va eksportlarning hammasini `~/.bashrc` ga qo'shishingiz kerak. Bu fayl yangilanishlarda ustiga yozilmaydi. Agar Omarchy standartlaridan birini o'zgartirmoqchi bo'lsangiz, ularni bu yerga ham xavfsiz qo'shishingiz mumkin.

### Ish stoli uchun muhit o'zgaruvchilarini o'rnatish

Ish stoli sessiyasi eksportlari `~/.config/uwsm/env.d/` ga tegishli. Bu fayllar ish stolingiz ishga tushishidan oldin ishga tushadi, shuning uchun qobiq xatosi sizni kirish ekraniga qaytarib yuborishi mumkin. Ularni tahrirlash paytida ishlaydigan terminalni ochiq saqlang. Bekor qilishni o'chirish uchun uni `env.d` dan tashqariga ko'chiring. Agar o'zgarish kirishga to'sqinlik qilsa, [kirishni tiklash](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) ga qarang.

### Ichki Omarchy fayllarini o'zgartirish

Qarang, bu sizning kompyuteringiz. U bilan xohlaganingizni qilishingiz mumkin, lekin `/usr/share/omarchy` ichidagi fayllarga to'g'ridan-to'g'ri o'zgartirish kiritmaslikni maslahat beraman. Ular Omarchy pacman paketiga tegishli, shuning uchun o'zgartirishlaringiz keyingi yangilanishda shunchaki ustiga yoziladi. Buning o'rniga yoqtirmagan standart qiymatlaringizni `~/.config/*` papkasida bekor qilib qo'yganingiz yaxshiroq.

Shu usulda deyarli hamma narsani, masalan standart tugma birikmalarini o'zgartirishingiz mumkin. Shunchaki `~/.config/hypr/bindings.lua` ni tahrirlang, aytaylik, [Obsidian](https://obsidian.md/) ni [Joplin](https://joplinapp.org/) bilan almashtirish uchun (`omarchy-pkg-add joplin-bin` bilan o'rnating):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` o'rnini bosuvchisini qo'shishdan oldin mavjud birikmani olib tashlaydi. U `o.bind` bilan bir xil argumentlarni oladi, jumladan ishga tushirish yordamchilari va birikma variantlarini. Birikma qo'shish uchun `o.bind` dan, almashtirmasdan olib tashlash uchun `hl.unbind` dan foydalaning.

Agar ichki Omarchy fayllarini buzib o'ynashga qat'iy qaror qilsangiz, _Update > Channel > Dev_ orqali dev kanaliga o'ting. Bu Omarchy ni `~/omarchy` ichidagi manba kodining git nusxasiga bog'laydi, uni ko'nglingiz tusaganchalik o'zgartirishingiz mumkin. Bu yerda sizga nima qilishni aytadigan hech kim yo'q!

### Har qanday o'zgartirishlarni tiklash

Agar konfiguratsiyalarni chalkashtirib yuborsangiz, ularni Omarchy menyusidagi _Update > Config_ orqali har doim standartlarga qaytarishingiz mumkin. Yoki hamma narsani tiklash uchun `omarchy reinstall configs` ni ishga tushiring.
