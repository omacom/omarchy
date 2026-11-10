# FAQ

### Men klaviatura tartiblari oʻrtasida qanday almashinaman?

`~/.config/hypr/input.lua` faylingizni tahrirlang va `Left Alt + Right Alt` dagi tartiblarni almashtirish uchun buni qoʻshing:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Siz bir nechta tartiblarni sozlaganingizdan keyin panel avtomatik sizning joriy klaviatura tartibingizni koʻrsatadi (va almashinish uchun uni bosishingiz ham mumkin).

### Soat formatini 12 soatlikga qanday oʻzgartiraman?

12 soatliklar ham ichida umumiy formatlarni aylanib chiqish uchun paneldagi soatni oʻng tugma bilan bosing. Formatni toʻgʻridan-toʻgʻri ham oʻrnatishingiz mumkin:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Bu Sunday 10:55 AM ni koʻrsatadi.

### Vaqt mintaqamni qanday oʻzgartiraman?

Omarchy menyusida _Yangilash > Vaqt mintaqasi_ ni ishga tushiring va roʻyxatdan tanlang. Agar vaqt mintaqasi toʻgʻri boʻlsa-yu, lekin soatning oʻzi surilib ketgan boʻlsa, _Yangilash > Vaqt_ siz uchun vaqt sinxronlashini qayta ishga tushiradi.

### DNS imni qanday oʻzgartiraman, Wi-Fiimni qanday ulashaman yoki ulanish tezligini qanday tekshiraman?

Ularning hammasi [tarmoqda](35-networking.md) yashaydi.

### Diskim qanchalik tezligini qanday tekshiraman?

_Ishga tushirish > Tezlik testi > Disk tezligi testi_ drayvingizda jonli oʻqish va yozish tezligini oʻlchaydi yoki terminaldan `omarchy disk speedtest`.

### Nega Chromium-da Google hisobimga kira olmayman?

Oddiy ochiq manbali Chromium qurilmasi Google hisobga kirish uchun talab qiladigan OAuth maʼlumotlari bilan kelmaydi. Ularni qoʻshish uchun Omarchy menyusida _Oʻrnatish > Xizmat > Chromium hisob_ ni ishga tushiring, brauzerni qayta ishga tushiring va kirish oʻtadi.

### Printerni qanday qoʻshaman?

Chop etish qutidan chiqqan zahoti sozlangan va ishlayapti va siz har bir printerni ilova ishga tushiruvchisidan (`Super + Space`) _Print Settings_ dan oʻzingiz qoʻshasiz.

_Add_ ni tanlang va unga qarash uchun bir daqiqa bering: USB orqali ulangan printer va aksariyat tarmoq printerlari siz uchun topiladi. Agar sizniki roʻyxatda boʻlmasa, _Network Printer > Internet Printing Protocol (ipp)_ ni tanlang va uning manzilini kiriting — printerning oʻz displeyi yoki uning veb sahifasi sizga bu nima ekanligini aytadi, odatda `192.168.1.50` ga oʻxshagan va `ipp/print` navbatiga ega narsa. Keyin _Forward_ drayverni taklif qiladi, u yerda zamonaviy printer drayversiz _IPP Everywhere_ profilida eng yaxshi ishlaydi va eskiriroqʻ modelning oʻz drayverini xohlaydi.

Printerni oʻng tugma bilan bosing va ilovalaringiz birinchisi qaysi biriga yetishini tanlash uchun _Set as Default_ ni va qogʻoz oʻlchami, duplex hamda sifatni oʻrnatish uchun _Properties_ ni tanlang.

Tarmoqdagi printerlar qoʻshilmasdan paydo boʻladigan avtomatik kashfiyot u qayta ishlanayotganda vaqtincha oʻirilgan, shuning uchun yuqoridagi birinchi qadam avtomatik emas, sizniki. PDF faylga chop etish hech qanday printersiz ishlaydi.

### Skrinshotlar yoki ekran yozuvlari qayerda saqlanishini qanday oʻzgartiraman?

Saqlangan skrinshotlar standart holatda `~/Pictures/Screenshots` ga ketadi. Boshqa katalogni ishlatish uchun, buni `~/.config/uwsm/env.d/` ostidagi faylga (`~/.config/uwsm/env.d/capture` kabi) qoʻshing:

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Siz `OMARCHY_SCREENRECORD_DIR` yordamida ekran yozuvlari uchun ham xuddi shunday qilishingiz mumkin.

Omasnap oʻzining skrinshot katalogini avtomatik yaratadi. Ekran yozish katalogini oʻzingiz yarating, keyin har qanday muhit oʻzgarishi kuchga kirishi uchun Omarchy ni qayta ishga tushiring.

### Apple Studio Display imdagi karnaylar + vebkamerani qanday ishlataman?

Siz USB C ni shunchaki ulaganda hammasi ishlashi kerak deb oʻylasangiz ham, afsuski bunday emas. Uni ishonchli ishlatish uchun topgan yechimim [WJESOG DisplayPort + USB-A => USB-C kabelidan](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/) foydalanish. Keyin karnaylar va vebkamera joduday ishlaydi.

Apple Displays (Studio ham, XDR ham) uchun odatdagi klaviatura yorugʻlik tugmalaridan foydalangan holda Omarchy-da ichki yorqinlik boshqaruviga ega ekanligingizni unutmang.

### Ortiqcha dasturiy taʼminotni qanday yoʻqotaman?

Agar Obsidian yoki LibreOffice yoki oldindan oʻrnatilgan boshqa narsalar kabi dasturlarni istamasangiz, uni juda oson olib tashlashingiz mumkin.

Oʻrnatilgan har bir paketni koʻrish uchun _Olib tashlash > Paket_ ni ishga tushiring. Keyin siz tab bilan olib tashlamoqchi boʻlgan har qanday paketni tanlashingiz va return bilan tanlagan hamma narsangizni olib tashlashni boshlashingiz mumkin.

Va oldindan oʻrnatilgan veb-ilovalardan istamaydiganlarini olib tashlash uchun Omarchy menyusidan _Olib tashlash > Veb-ilova_ dan foydalanishingiz mumkin.

Yoki bir urinishda barcha oldindan oʻrnatilgan qoʻshimchalarni — veb-ilovalar, TUI lar va ixtiyoriy ilovalarni tozalash uchun _Olib tashlash > Oldindan oʻrnatilganlar_ ni ishga tushiring. Ularga boshlagan hotkeylar ular bilan yoʻqoladi, shuning uchun siz `~/.config/hypr/bindings.lua` da oʻzingizniki bilan toʻldirish uchun toza bindings lavhasi bilan qolasiz.

---

Xatolar va buzilgan bitlar uchun [Muammolarni hal qilish boʻlimini](45-troubleshooting.md) koʻring.
