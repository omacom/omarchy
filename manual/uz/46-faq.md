# Tez-tez soʻraladigan savollar

### Klaviatura tartiblari orasida qanday almashaman?

`Left Alt + Right Alt` bilan tartiblar orasida almashish uchun `~/.config/hypr/input.lua` faylingizni tahrirlang va quyidagini qoʻshing:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Bir nechta tartibni sozlaganingizdan keyin panel joriy klaviatura tartibingizni avtomatik koʻrsatadi (va uni bosib ham almashishingiz mumkin).

### Soat formatini 12 soatlikka qanday oʻzgartiraman?

Umumiy formatlar, jumladan 12 soatliklari orasida almashish uchun paneldagi soatni oʻng tugma bilan bosing. Formatni bevosita ham oʻrnatishingiz mumkin:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Bu Yakshanba 10:55 AM koʻrinishida koʻrsatadi.

### Vaqt mintaqamni qanday oʻzgartiraman?

Omarchy menyusida _Sozlash > Mintaqa > Vaqt mintaqasi_ ni ishga tushiring va roʻyxatdan tanlang. Vaqt mintaqasi toʻgʻri boʻlsa-yu, soatning oʻzi adashgan boʻlsa, _Yangilash > Vaqt_ vaqt sinxronizatsiyasini siz uchun qayta ishga tushiradi.

### DNS imni qanday oʻzgartiraman, Wi-Fi imni qanday ulashaman yoki ulanish tezligimni qanday tekshiraman?

Bularning barchasi [tarmoq](35-networking.md) boʻlimida joylashgan.

### Diskim qanchalik tezligini qanday tekshiraman?

_Trigger > Tezlik testi > Disk tezligi testi_ diskingizdagi jonli oʻqish va yozish tezligini oʻlchaydi, yoki terminaldan `omarchy disk speedtest` ishlating.

### Printer qanday qoʻshaman?

Chop etish qutidan chiqqan holida sozlangan va ishlaydi, har bir printerni esa ilovalarni ishga tushirgichdagi (`Super + Space`) _Chop etish sozlamalari_ dan oʻzingiz qoʻshasiz.

_Qoʻshish_ ni tanlang va unga qidirishga bir oz vaqt bering: USB orqali ulangan printer va aksariyat tarmoq printerlari siz uchun topiladi. Sizniki roʻyxatda boʻlmasa, _Tarmoq printeri > Internet Printing Protocol (ipp)_ ni tanlang va uning manzilini kiriting — printerining oʻz displeyi yoki uning veb-sahifasi bu nima ekanini aytib beradi, odatda `ipp/print` navbati bilan `192.168.1.50` kabi narsa. Keyin _Oldinga_ drayver taklif qiladi, bunda zamonaviy printer drayversiz _IPP Everywhere_ profilida eng yaxshi ishlaydi, eskisi esa modelning oʻz drayverini xohlaydi.

Ilovalar birinchi boʻlib qaysi biriga murojaat qilishini tanlash uchun printerni oʻng tugma bilan bosib _Standart sifatida oʻrnatish_ ni, qogʻoz oʻlchami, ikki tomonlama chop etish va sifatni oʻrnatish uchun esa _Xususiyatlar_ ni tanlang.

Tarmoqdagi printerlar qoʻshilmasdan paydo boʻladigan avtomatik aniqlash qayta ishlanayotgani sababli vaqtincha oʻchirilgan, shuning uchun yuqoridagi birinchi qadam avtomatik emas, sizniki. PDF faylga chop etish umuman printersiz ham ishlaydi.

### Skrinshotlar yoki ekran yozuvlari saqlanadigan joyni qanday oʻzgartiraman?

Saqlangan skrinshotlar standart boʻyicha `~/Pictures/Screenshots` ga tushadi. Boshqa katalogdan foydalanish uchun buni `~/.config/uwsm/env.d/` ostidagi faylga qoʻshing (`~/.config/uwsm/env.d/capture` kabi):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Ekran yozuvlari uchun ham `OMARCHY_SCREENRECORD_DIR` yordamida xuddi shunday qilishingiz mumkin.

Omasnap skrinshotlar katalogini avtomatik yaratadi. Ekran yozuvlari katalogini oʻzingiz yarating, keyin atrof-muhitdagi har ikki oʻzgarish ham kuchga kirishi uchun Omarchy ni qayta ishga tushiring.

### Apple Studio Display da karnaylar + veb-kamerani qanday ishlataman?

USB C ni ulashning oʻzi kifoya deb oʻylashingiz mumkin, lekin afsuski unday emas. Uni ishonchli ishlatish uchun men topgan yechim — [WJESOG DisplayPort + USB-A => USB-C kabeli](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/) dan foydalanish. Keyin karnaylar ham, veb-kamera ham ajoyib ishlaydi.

Esda tuting, Omarchy da Apple Display lar (Studio ham, XDR ham) uchun oddiy klaviatura yorqinlik tugmalari yordamida oʻrnatilgan yorqinlik boshqaruvi bor.

### Barcha qoʻshimcha dasturlardan qanday qutulsam boʻladi?

Obsidian yoki LibreOffice yoki boshqa oldindan oʻrnatilgan narsalar kabi dasturlarni xohlamasangiz, ularni juda oson olib tashlashingiz mumkin.

Oʻrnatilgan har bir paketni koʻrish uchun _Olib tashlash > Paket_ ni ishga tushiring. Keyin olib tashlamoqchi boʻlgan har qanday paketni tab bilan tanlab, tanlagan hamma narsangizni olib tashlashni return bilan boshlashingiz mumkin.

Va xohlamagan oldindan oʻrnatilgan veb-ilovalardan istalganini olib tashlash uchun Omarchy menyusidan _Olib tashlash > Veb-ilova_ dan foydalanishingiz mumkin.

Yoki barcha oldindan oʻrnatilgan qoʻshimchalarni — veb-ilovalar, TUIs va ixtiyoriy ilovalarni — bir yoʻla supurib tashlash uchun _Olib tashlash > Oldindan oʻrnatilganlar_ ni ishga tushiring. Ularni ishga tushirgan tezkor tugmalar ham ular bilan birga yoʻqoladi, shuning uchun sizga `~/.config/hypr/bindings.lua` da oʻzingiznikilar bilan toʻldirish uchun toza bogʻlamlar varagʻi qoladi.

---

Xatolar va ishlamay qolgan narsalar uchun [Muammolarni bartaraf etish boʻlimi](45-troubleshooting.md) ga qarang.
