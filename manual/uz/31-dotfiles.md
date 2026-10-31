# Dotfiles

Omarchy asosan `~/.config` ichida joylashgan dotfiles deb ataladigan fayllar orqali sozlanadi. Ular sizning oʻzgartirishlaringiz uchun sizning fayllaringiz deb hisoblanadi. `/usr/share/omarchy` ichida joylashgan fayllar Omarchy’ning oʻziga tegishli, va siz ularga aralashmasligingiz kerak. Agar `/usr/share/omarchy` ichida biror narsani oʻzgartirishingiz kerak boʻlsa, uning qiymatini oʻrniga `~/.config` ichida bekor qilishingiz kerak.

Asosiy konfiguratsiyalarni toʻgʻridan-toʻgʻri Omarchy menyusidan (`Super + Space`) tahrirlashingiz mumkin, masalan _Setup > Keybindings_, _Setup > Input_ va _Setup > Config > [file]_. Shunday qilganingizda, konfiguratsiyani tahrirlagandan keyin qayta ishga tushirilishi kerak boʻlgan har qanday jarayon muharrirni yopishingiz bilan avtomatik ravishda qayta ishga tushadi (standart holatda Neovim — `:wq`, esingizdami! — lekin buni _Setup > Defaults > Editor_ orqali oʻzgartirishingiz mumkin).

Mana `~/.config` ichidagi asosiy fayllar va ular nimani boshqarishi roʻyxati:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Asosiy Hyprland konfiguratsiyasi. Omarchy standart sozlamalarini hamda pastdagi bekor qilish fayllaringizni yuklaydi. [Hyprland konfiguratsiyalari haqida koʻproq bilib oling](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Oʻzingizning klaviatura tugmalar birikmalaringiz va standartlarining bekor qilinishlari. |
| `~/.config/hypr/monitors.lua` | Monitor paneli qamrab olmaydigan monitor sozlamalari, masalan, aylantirish, qoʻshimcha rejimlar yoki monitorni oʻchiq holda saqlash. |
| `~/.config/hypr/input.lua` | Klaviatura tartibi, sichqoncha va trekpad sozlamalaringizni boshqaradi. |
| `~/.config/hypr/looknfeel.lua` | Boʻshliqlar, chegaralar, animatsiyalar va qolgan koʻrinishni boshqaradi. |
| `~/.config/hypr/autostart.lua` | Seans bilan birga ishga tushiriladigan qoʻshimcha jarayonlarni boshqaradi. |
| `~/.config/omarchy/shell.json` | Omarchy shell’ini boshqaradi: panel joylashuvi, tartibi va vidjetlari, shuningdek ekran saqlagichi, qulflash va boʻsh turish vaqt chegaralari. |
| `~/.config/foot/foot.ini` | Terminalingizni boshqaradi (standart holatda foot ishlatiladi). |
| `~/.XCompose` | Tez kirish emoji’laringizni va ism/email avtomatik toʻldirishingizni belgilaydi. Oʻzgartirishlar kiritgandan keyin `omarchy-restart-xcompose` buyrugʻini ishga tushirishni unutmang. |

Agar oʻz sozlashlaringizni moslashtirish uchun koʻp oʻzgartirishlar kiritadigan boʻlsangiz, barcha ushbu dotfiles’ni zaxiralab qoʻyish yaxshi fikr. [Stow — buni qilishning ajoyib usuli](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Seans bilan birga oʻz ilovalaringizni ishga tushirish

Agar har safar tizimga kirganingizda biror narsa ishga tushishini istasangiz — sinxronlash daemoni, suhbat ilovasi, oʻz skriptingiz — uni `~/.config/hypr/autostart.lua` ichiga qoʻying:

```lua
o.launch_on_start("my-service")
```

Bu buyruqni seansning bir qismi sifatida ishga tushiradi, shuning uchun siz tizimdan chiqqaningizda u toʻgʻri tozalanadi.

### Tizim hodisalarida skriptlarni ishga tushirish

Omarchy bir nechta lahzalarda xuklarni ishga tushiradi, va siz ularga oʻz skriptlaringizni osib qoʻyishingiz mumkin. Ular `~/.config/omarchy/hooks/<event>.d/` ichida joylashgan, har bir hodisa uchun bitta katalog, va u yerdagi har bir bajariladigan fayl hodisa sodir boʻlganda ishga tushadi:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Ish stoli ishga tushgandan soʻng darhol |
| `post-update` | `omarchy update` oxirlariga yaqin, paketlar, migratsiyalar va xizmatlar qayta ishga tushirilgandan keyin, mise vositalari yangilanishidan oldin |
| `pre-refresh-pacman` | `omarchy refresh pacman` paket konfiguratsiyasini qayta sinxronlagandan keyin, paketlarni yangilashidan oldin; kanal almashinuvi uni oʻsha yangilash bosqichining oʻzida ishga tushiradi |
| `theme-set` | Mavzu oʻzgargandan keyin (mavzu nomi `$1` ichida) |
| `font-set` | Shrift oʻzgargandan keyin (shrift nomi `$1` ichida) |
| `battery-low` | Batareya quvvati kam qolganda (foiz `$1` ichida) |

`pre-refresh-pacman` xuki — bu maxsus repozitoriylar yoki `IgnorePkg` qatorlari tegishli boʻlgan joy, chunki u paket tranzaksiyasidan oldin ishga tushadi. Ikkala yangilanish bilan bogʻliq xuk ham Omarchy keshlangan sudo ruxsatini tozalagandan keyin sizning foydalanuvchingiz sifatida ishga tushadi, shuning uchun `sudo` ishlatadigan xuk oʻz ruxsatiga muhtoj boʻladi va parolingizni soʻrashi mumkin.

Ushbu kataloglarning har birida allaqachon xukning shaklini koʻrsatadigan `.sample` fayli mavjud — uni ishga tushirish uchun nomidan `.sample` ni olib tashlang. Boshqa joyda yozgan skriptingizni oʻrnatish uchun `omarchy hook install post-boot ~/my-hook` buyrugʻini ishlating, u uni nusxalab kiritadi va bajariladigan qiladi.

### Oʻz menyu yozuvlaringizni qoʻshish

Omarchy menyusini (`Super + Space`) `~/.config/omarchy/extensions/omarchy-menu.jsonc` faylini tahrirlash orqali oʻz qatorlaringiz bilan kengaytirishingiz mumkin. Yozuvlar nuqtali id boʻyicha kalitlanadi, va id ularni daraxtda joylashtiradi, shuning uchun `personal` ildiz menyuda koʻrinadi va `personal.notes` uning ichida koʻrinadi:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Mavjud id’dan qayta foydalansangiz, yangi qator qoʻshish oʻrniga oʻsha qatorni bekor qilasiz. Fayl barcha mavjud maydonlar sharhlar sifatida hujjatlashtirilgan holda keladi.

### Oʻz shell eksportlaringiz, funksiyalaringiz va aliaslaringizni qoʻshish

Omarchy bir qancha ergonomik aliaslar va foydali funksiyalar bilan birga keladi, lekin oʻzingiznikini qoʻshishni istash juda keng tarqalgan holat. Aliaslar, funksiyalar va eksportlarni ham `~/.bashrc` ga qoʻshishingiz kerak. Bu fayl yangilanishlarda bekor qilinmaydi. Agar Omarchy standartlaridan birini oʻzgartirmoqchi boʻlsangiz, ularni ham bu yerga xavfsiz qoʻshishingiz mumkin.

### Ichki Omarchy fayllarini oʻzgartirish

Qarang, bu sizning kompyuteringiz. U bilan hohlaganingizni qilishingiz mumkin, lekin men `/usr/share/omarchy` ichidagi fayllarga toʻgʻridan-toʻgʻri oʻzgartirish kiritmaslikni maslahat berardim. Ular Omarchy pacman paketiga tegishli, shuning uchun oʻzgartirishlaringiz keyingi yangilanishda shunchaki bekor qilinadi. Buning oʻrniga, sizga yoqmagan har qanday standart qiymatlarni `~/.config/*` papkasida bekor qilganingiz yaxshiroq.

Shunday qilib deyarli hamma narsani oʻzgartirishingiz mumkin, masalan standart klaviatura birikmalarini. Faqat `~/.config/hypr/bindings.lua` ni tahrirlash kifoya, masalan [Obsidian](https://obsidian.md/) ni [Joplin](https://joplinapp.org/) bilan almashtirish uchun (`omarchy-pkg-add joplin-bin` bilan oʻrnating):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` oʻz oʻrniga keluvchini qoʻshishdan oldin mavjud birikmani olib tashlaydi. U `o.bind` bilan bir xil argumentlarni oladi, jumladan ishga tushirish yordamchilari va birikma variantlarini. Birikma qoʻshish uchun `o.bind` dan foydalaning, yoki uni almashtirmasdan olib tashlash uchun `hl.unbind` dan foydalaning.

Agar ichki Omarchy fayllarini buzib oʻynashga qat’iy ahd qilgan boʻlsangiz, _Update > Channel > Dev_ orqali dev kanaliga oʻting. Bu Omarchy’ni `~/omarchy` ichidagi manba kodining git nusxasiga bogʻlaydi, uni koʻnglingiz tusaganchalik oʻzgartirishingiz mumkin. Bu yerda sizga nima qilish kerakligini aytadigan hech kim yoʻq!

### Har qanday oʻzgarishlarni tiklash

Agar konfiguratsiyalarni oxir-oqibat chalkashtirib yuborsangiz, ularni har doim Omarchy menyusidagi _Update > Config_ orqali standartlarga qaytarishingiz mumkin. Yoki hammasini tiklash uchun `omarchy reinstall configs` buyrugʻini ishga tushirib.
