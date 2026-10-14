# Dotfayllar

Omarchy asosan `~/.config` da yashovchi dotfayllar deb ataluvchilar orqali sozlanadi. Ular oʻzgarishlaringiz uchun sizning fayllaringiz hisoblanadi. `/usr/share/omarchy` da yashovchi fayllar Omarchy ning oʻziga tegishli va siz ularni buzib oʻtirmasligingiz kerak. Agar `/usr/share/omarchy` dagi biror narsani oʻzgartirishingiz kerak boʻlsa, uning oʻrniga qiymatni `~/.config` da ustiga yozishingiz kerak.

Asosiy konfiguratsiyalarni Omarchy menyusidan (`Super + Space`) toʻgʻridan-toʻgʻri tahrirlash mumkin, masalan _Sozlash > Monitors_, _Sozlash > Keybindings_, _Sozlash > Input_ va _Sozlash > Config > [file]_. Buni shu tarzda qilganingizda, konfiguratsiya tahrirlaridan keyin qayta ishga tushishi kerak boʻlgan har qanday jarayon muharrirdan chiqqaningizdan keyin avtomatik boʻladi (standart tarzda Neovim — `:wq`, esda tuting! — lekin buni _Sozlash > Defaults > Editor_ orqali oʻzgartirishingiz mumkin).

Mana `~/.config` dagi asosiy fayllar roʻyxati va ular nimani boshqarishi:

| Fayl                  | Maqsadi              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Asosiy Hyprland konfiguratsiyasi. Omarchy standartlarini hamda quyidagi ustiga yozish fayllaringizni yuklaydi. [Hyprland konfiguratsiyalari haqida koʻproq bilib oling](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Oʻzingizning tugmalar birikmalaringiz va standartlarning ustiga yozuvlari. |
| `~/.config/hypr/monitors.lua` | Monitorlaringiz, aniqligi va joyini boshqaradi. |
| `~/.config/hypr/input.lua` | Klaviatura tartibingiz, sichqoncha va sensor panel sozlamalarini boshqaradi. |
| `~/.config/hypr/looknfeel.lua` | Oraliqlar, chegaralar, animatsiyalar va koʻrinishning qolgan qismini boshqaradi. |
| `~/.config/hypr/autostart.lua` | Sessiya bilan boshlangan qoʻshimcha jarayonlarni boshqaradi. |
| `~/.config/omarchy/shell.json` | Omarchy shellini boshqaradi: panel joyi, tartibi va vidjetlari, plyus ekran saqlagich, qulflash va boʻsh vaqt vaqtlari. |
| `~/.config/foot/foot.ini` | Terminalingizni boshqaradi (foot standartdir). |
| `~/.XCompose` | Tezkor kirish emoji va ism/elektron pochta avtomatik toʻldirishini belgilaydi. Oʻzgarishlarni qilgandan keyin `omarchy-restart-xcompose` ni ishga tushirishga ishonch hosil qiling. |

Agar oʻz sozlamangizni moslashtirish uchun koʻp oʻzgarishlar qilib qoʻysangiz, bu dotfayllarning hammasini zaxiralab qoʻyish yaxshi fikr. [Stow buni qilishning ajoyib usulidir](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Oʻz ilovalaringizni sessiya bilan boshlash

Agar biror narsa har safar kirganingizda ishlashini istasangiz — sinxronlash demoni, chat ilovasi, oʻz skriptingiz — uni `~/.config/hypr/autostart.lua` ga qoʻying:

```lua
o.launch_on_start("my-service")
```

Bu buyruqni sessiyaning bir qismi sifatida boshlaydi, shuning uchun siz yana chiqqaningizda u toʻgʻri tozalanadi.

### Tizim hodisalarida skriptlarni ishga tushirish

Omarchy bir hovuch paytlarda hooklar chaqiradi va siz ularga oʻz skriptlaringizni osishingiz mumkin. Ular `~/.config/omarchy/hooks/<event>.d/` da yashaydi, har bir hodisa uchun bitta katalog va hodisa sodir boʻlganda u yerdagi har bir bajariladigan fayl ishlaydi:

| Hodisa | Qachon ishlaydi |
| ----- | ------------ |
| `post-boot` | Ish stoli boshlanishidan darhol keyin |
| `post-update` | `omarchy update` ning oxiriga yaqin, paketlar, migratsiyalar va xizmat qayta ishga tushirishlaridan keyin, mise vositalari yangilanishidan oldin |
| `pre-refresh-pacman` | `omarchy refresh pacman` paket konfiguratsiyasini qayta sinxronlashdan keyin, paketlarni yangilashidan oldin; kanal almashishi uni oʻsha bir xil yangilash bosqichida ishga tushiradi |
| `theme-set` | Mavzu oʻzgarishidan keyin (mavzu nomi `$1` da) |
| `font-set` | Shrift oʻzgarishidan keyin (shrift nomi `$1` da) |
| `battery-low` | Batareya kamayganda (foiz `$1` da) |

`pre-refresh-pacman` hook maxsus repozitoriylar yoki `IgnorePkg` qatorlari tegishli boʻlgan joydir, chunki u paket tranzaksiyasidan oldin ishlaydi. Ikkala yangilanishga oid hook ham Omarchy keshlangan sudo ruxsatini tozalagandan keyin sizning foydalanuvchingiz sifatida ishlaydi, shuning uchun `sudo` dan foydalanuvchi hookka oʻz ruxsati kerak va parolingizni soʻrashi mumkin.

Oʻsha kataloglarning har biri allaqachon hook shaklini koʻrsatuvchi `.sample` faylini saqlaydi — uni ishga tushirish uchun nomidan `.sample` ni olib tashlang. Boshqa joyda yozgan skriptni oʻrnatish uchun `omarchy hook install post-boot ~/my-hook` dan foydalaning, u uni nusxalab kiritadi va bajariladigan qiladi.

### Oʻz menyu yozuvlaringizni qoʻshish

Omarchy menyusi (`Super + Space`) `~/.config/omarchy/extensions/omarchy-menu.jsonc` ni tahrirlash orqali oʻz qatorlaringiz bilan kengaytirilishi mumkin. Yozuvlar nuqtali id bilan kalitlangan va id ularni daraxtga joylashtiruvchi narsadir, shuning uchun `personal` ildiz menyusida paydo boʻladi va `personal.notes` uning ichida paydo boʻladi:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Mavjud id ni qayta ishlating va siz yangi qoʻshish oʻrniga oʻsha qatorni ustiga yozasiz. Fayl barcha mavjud maydonlar izoh sifatida hujjatlashtirilgan holda keladi.

### Oʻz shell eksportlari, funksiyalari va aliaslaringizni qoʻshish

Omarchy bir qator ergonomik aliaslar va foydali funksiyalar bilan keladi, lekin oʻzingiznikini qoʻshishni xohlash juda keng tarqalgan. Siz aliaslar, funksiyalar va eksportlarni ham `~/.bashrc` ga qoʻshishingiz kerak. Bu fayl yangilanishlarda ustiga yozilmaydi. Agar Omarchy standartlarining birortasini oʻzgartirishni istasangiz, ularni bu yerda ham xavfsiz qoʻshishingiz mumkin.

### Ichki Omarchy fayllarini oʻzgartirish

Qarang, bu sizning kompyuteringiz. U bilan xohlaganingizni qilishingiz mumkin, lekin men `/usr/share/omarchy` dagi fayllarga toʻgʻridan-toʻgʻri oʻzgarishlar qilishga qarshi maslahat bergan boʻlardim. Ular Omarchy pacman paketiga tegishli, shuning uchun oʻzgarishlaringiz shunchaki keyingi yangilanishda ustiga yoziladi. Uning oʻrniga sizga yoqmagan har qanday standart qiymatlarni shunchaki `~/.config/*` jildida ustiga yozganingiz yaxshiroqdir.

Bu tarzda deyarli hamma narsani, masalan standart tugmalar birikmalarini oʻzgartirishingiz mumkin. Aytaylik, [Obsidian](https://obsidian.md/) ni [Joplin](https://joplinapp.org/) bilan almashtirish uchun shunchaki `~/.config/hypr/bindings.lua` ni tahrirlang (`omarchy-pkg-add joplin-bin` bilan oʻrnating):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` almashtirishini qoʻshishdan oldin mavjud bogʻlanishni olib tashlaydi. U `o.bind` bilan bir xil argumentlarni, jumladan ishga tushirish yordamchilari va bogʻlanish variantlarini oladi. Bogʻlanishni qoʻshish uchun `o.bind` dan yoki uni almashtirmasdan olib tashlash uchun `hl.unbind` dan foydalaning.

Agar ichki Omarchy fayllarini hack qilishda qatʼiy boʻlsangiz, _Yangilash > Channel > Dev_ orqali dev kanaliga oʻting. Bu Omarchy ni `~/omarchy` dagi manba kodining git checkout iga bogʻlaydi, uni koʻnglingizgacha oʻzgartirishingiz mumkin. Bu yerda sizga nima qilishni aytadigan hech kim yoʻq!

### Har qanday oʻzgarishlarni tiklash

Agar konfiguratsiyalarni tartibsiz qilib qoʻysangiz, ularni har doim Omarchy menyusidagi _Yangilash > Config_ orqali standartlarga qaytarishingiz mumkin. Yoki hamma narsani tiklash uchun `omarchy reinstall configs` ni ishga tushirish orqali.
