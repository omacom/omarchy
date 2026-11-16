# Shell plaginlari

Omarchy ish stoli `omarchy-shell` deb ataluvchi bitta uzoq yashovchi Quickshell jarayoni sifatida ishlaydi va ekranda koʻrgan deyarli hamma narsa uning ichidagi plagindir. Panel plagindir. Undan tushadigan panellar, emoji tanlagich va almashish buferi boshqaruvchisi kabi toʻliq ekran ustqoplamalari, Omarchy menyusining oʻzi, qulflash ekrani, polkit dialogi va batareyangizni kuzatuvchi hamda kechasi ekraningizni isituvchi boshsiz xizmatlar ham shunday.

Bu shunchaki amalga oshirish tafsiloti emas. Bu siz ish stolining qismlarini oʻchirishingiz, ularni almashtirishingiz yoki Omarchy manbasining bir qatoriga tegmasdan oʻzingiznikini yozishingiz mumkinligini anglatadi.

Birinchi tomon plaginlari Omarchy bilan keladi va `$OMARCHY_PATH/shell/plugins/` da yashaydi. Oʻzingiz qoʻshgan har qanday narsa — oʻz tajribalaringiz yoki GitHub da topgan biror narsangiz — `~/.config/omarchy/plugins/` da yashaydi. Ikkalasi ham boshlangʻichda bir xil tarzda topiladi, lekin oʻrnatilganlar ishonchli shell interfeyslarini oladi, uchinchi tomon plaginlari esa oʻz xizmati va hayot aylanishi bilan cheklangan interfeys oladi. Oʻrnatilganlarning klonlari faqat asl xulq-atvor uchun kerak boʻlgan manbaga xos konfiguratsiya va UI chaqiruvlarini saqlaydi.

## Sizda nima borligini koʻrish

```
omarchy plugin list
```

Bu har bir topilgan plaginni uning id si, yoqilganligi, birinchi tomon yoki uchinchi tomon ekanligi, uning turlari va koʻrinish nomi bilan chop etadi. Agar uni boshqa narsaga berayotgan boʻlsangiz, `--json` ni qoʻshing.

Plagin id lari nom maydoniga ega. Oʻrnatilganlarning hammasi `omarchy.` bilan boshlanadi — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — va oʻsha nom maydoni zaxiralangan, shuning uchun uchinchi tomon plagini hech qachon uni daʼvo qila olmaydi.

## Ularni yoqish va oʻchirish

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Yoki menyudan foydalaning: _Sozlash > Plugins_ da Enable, Disable, Add, Clone va Remove bor, har biri faqat oʻsha amal uchun mantiqiy boʻlgan plaginlarni taklif qiluvchi tanlagich bilan.

Yoqilgan holat `~/.config/omarchy/shell.json` da saqlanadi va qoida ikki turdagi plagin uchun biroz farq qiladi. Uchinchi tomon plagini uning id si oʻsha faylning qayeridadir paydo boʻlganda aynan yoqilgan boʻladi — panel tartibi yozuvi sifatida, `plugins[]` dagi yozuv sifatida yoki `bar.id` sifatida. Panel vidjetlari boʻlmagan birinchi tomon plaginlari teskari ravishda: ular standart tarzda yoniq va faqat `disabledPlugins[]` da roʻyxatga olinishi orqali oʻchadi.

Toʻliq panel plagini umuman oʻchirilgan holatga ega emas. Har doim aynan bitta panel bor, shuning uchun uni boshqasini yoqish orqali almashtirasiz. Panel vidjeti joylashuvi [yuqori panel](05-the-top-bar.md) da qoplangan.

## Git dan plagin qoʻshish

Uchinchi tomon plagini shunchaki ildizida `manifest.json` ga ega git repo dir.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

U biror narsa qilishidan oldin, u sizga ochiq aytadiki, plaginlar uzoq yashovchi shell jarayoningiz ichida ixtiyoriy, sandboxsiz kod sifatida ishlaydi, sizga URL ni koʻrsatadi va tasdiqlashni soʻraydi. Buni jiddiy qabul qiling. Uchinchi tomon plagin interfeysi autentifikatsiya xizmatlarini toʻgʻridan-toʻgʻri ochmaydi va almashtirish paneli sozlangan autentifikatsiya boʻlmagan UI uchun faqat cheklangan imkoniyatlar oladi. Vizual plaginlar baribir shellning QML sahnasini ulashadi va oddiy ona obʼektlarni aylanib oʻtishi mumkin, barcha plagin kodi esa foydalanuvchi hisobingiz yeta oladigan hamma narsa bilan ishlaydi. Autentifikatsiya holati oʻsha xizmatlarni yetib boʻlmaydigan host obʼekt grafidan tashqarida saqlash orqali alohida himoyalanadi. Faqat ishlatishga tayyor boʻlgan repolarni qoʻshing va ularni yoqishdan oldin oʻqing.

Almashtirish paneli oʻrnatilgan vidjetlarni chizishi mumkin, lekin xizmatga tayangan uchinchi tomon vidjetlari u yerda kamaygan funksionallikka ega boʻlishi mumkin, chunki panel boshqa plaginning jonli xizmat obʼektini soʻray olmaydi. Agar bunday vidjetga sherik xizmati kerak boʻlsa, oʻrnatilgan `omarchy.bar` ga qayting.

Keyin u reponi oraliq katalogga klonlaydi, manifestni tekshiradi, agar boshqa plagin allaqachon oʻsha id ni daʼvo qilsa oʻrnatishni rad etadi va uni `~/.config/omarchy/plugins/<id>/` ga koʻchiradi. `--enable` siz u hozir uni yoqishni xohlaysizmi deb soʻraydi va siz yoʻq deyib avval kodni oʻqib chiqishingiz mumkin. U hech qachon plagindan biror narsani ishga tushirmaydi, hech qachon oʻrnatish hookini bajarmaydi va hech qachon sudo soʻramaydi — u fayllarni klonlaydi, manifestni tekshiradi va IPC orqali bitni aylantiradi.

Yangilash oʻsha bir xil checkoutning fast-forward tortilishidir:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Id siz u sizda bor har bir git tomonidan boshqariladigan plaginni yangilaydi. U fargini qoʻllashdan oldin koʻrsatadi, agar u fast-forward qilib oʻta olmaydigan mahalliy oʻzgarishlaringiz boʻlsa yangilashni rad etadi va yangi reviziya tekshirishdan oʻtmasa qaytarib beradi.

```
omarchy plugin remove acme.weather
```

Olib tashlash avval plaginni oʻchiradi, keyin agar u git checkout boʻlsa uni oʻchiradi (repo baribir yuqori oqimda) yoki agar u symlink boʻlsa uni uzadi. Git repori yoʻq qoʻlda yasalgan plagin jildi toʻgʻridan-toʻgʻri oʻchirish oʻrniga plaginlar katalogi ichidagi vaqt tamgʻalangan zaxiraga koʻchiriladi.

## Uni oʻzgartirish uchun oʻrnatilganni klonlash

Bu mening sevimli qismim. Agar oʻrnatilgan vidjetning qanday ishlashini oʻzgartirmoqchi boʻlsangiz, `$OMARCHY_PATH` ostidagi fayllarni tahrirlamang — ular paketga tegishli va keyingi yangilanish ularni ustiga yozadi. Uning oʻrniga uni klonlang:

```
omarchy plugin clone omarchy.clock
```

Bu butun plaginni `~/.config/omarchy/plugins/dhh.clock` ga nusxalaydi (sizning foydalanuvchi nomingiz, menikimas), uni "My Clock" deb qayta nomlaydi, yoqadi va shellni oʻrnatilgandan sizning nusxangizga oʻtkazadi — mavjud panel vidjetining joyi va sozlamalarini saqlab qoladi. Yangi katalogni darhol `$EDITOR` ingizda ochish uchun `--edit` ni qoʻshing, menyuning _Sozlash > Plugins > Clone Plugin_ i siz uchun shuni qiladi.

Foydalanuvchi nomi prefiksi kloningiz id sini sizniki qilib saqlaydi, shuning uchun uni ulashish boshqalarniki bilan toʻqnashmaydi. Asl oʻrnatilgan id ga qilingan chaqiruvlar kloningizga yoʻnaltiriladi, shuning uchun `omarchy.clock` ga ishora qilgan hech narsani yangilash kerak emas. Va agar uni tartibsiz qilib qoʻysangiz, `omarchy plugin remove dhh.clock` oʻrnatilganni qaytarib qoʻyadi.

`~/.config/omarchy/plugins/` ostidagi istalgan joydagi faylni saqlash plagin kodini avtomatik qayta yuklaydi, shuning uchun muharrirni ochiq qoldirib, oʻzgarishlaringiz tushishini kuzatishingiz mumkin.

## Oʻzingiznikini yozish

Plagin `manifest.json` va biroz QML ga ega katalogdir. Manifest `schemaVersion: 1`, `id`, `name`, `version`, bir yoki bir nechta `kinds` va har bir tur uchun QML fayliga ishora qiluvchi `entryPoints` obʼektini eʼlon qiladi:

| Tur | U nima |
|------|------------|
| `bar-widget` | Faol panel boʻlimga tushira oladigan komponent |
| `panel` | Doimiy yoki chaqirilgan suzuvchi oyna |
| `overlay` | Toʻliq ekran ustqoplama |
| `menu` | Chaqirilgan menyu yuzasi |
| `service` | UI si yoʻq boshsiz singleton |
| `bar` | Oʻrnatilganni almashtiruvchi toʻliq panel |

Plagin bir vaqtning oʻzida bir nechta turni eʼlon qilishi mumkin — media plagini ham `service`, ham `bar-widget` dir. Panel vidjetlari koʻrinish nomi, kategoriyasi, ixtiyoriy `defaultSection` va panelda bittadan koʻp boʻlish mantiqiymi yoki yoʻqligini aytuvchi `allowMultiple` bilan qoʻshimcha `barWidget` blokini oladi. Koʻpchilik vidjetlar uni `false` ga belgilaydi; kengaytiruvchilar va koʻrsatkichlar uni `true` ga belgilaydi.

Biror narsani chop etishdan oldin uni tekshiring:

```
omarchy plugin validate ./my-plugin
```

Bu shell yuklash vaqtida bajaradigan bir xil tekshiruvlarni ishga tushiradi: sxema versiyasi, talab qilinadigan maydonlar, zaxiralanmagan id, xavfsiz nisbiy yoʻllar boʻlgan va haqiqatan ham mavjud boʻlgan kirish nuqtalari, daʼvo qilgan har bir turingiz uchun kirish nuqtasi va jild ichida hech qanday symlinklar yoʻqligi.

Plagin dasturlash uchun [shell maʼlumotnoma](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) va [birinchi tomon plagin katalogi](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md) ga qarang.

## Oʻzingiznikini dunyo bilan ulashish

Oʻzingizga yoqqan narsani yasaganingizdan soʻng, uni ommaviy git reporiga qoʻying. Bu butun tarqatish mexanizmidir — har kim keyin URL ingizga qarshi `omarchy plugin add` ni ishga tushirib, uni soniyalar ichida ishlatishi mumkin.

Odamlar uni haqiqatan ham topishiga yordam berish uchun uni [plugins.omarchy.org](https://plugins.omarchy.org) da roʻyxat qiling. Bu Omarchy shell plaginlari uchun bozor va siz yozmoqchi boʻlgan vidjetni kimdir allaqachon yasagan-yasamagani haqida hayron boʻlganingizda qarash kerak boʻlgan birinchi joy. Boshlashdan oldin uni koʻrib chiqing!
