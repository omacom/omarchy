# Ko'p so'raladigan savollar

### Klaviatura tartiblari orasida qanday almashaman?

`~/.config/hypr/input.lua` faylingizni tahrirlang va `Left Alt + Right Alt` bilan tartiblar orasida almashish uchun quyidagini qo'shing:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Bir nechta tartib sozlanganidan keyin panel joriy klaviatura tartibingizni avtomatik ravishda ko'rsatadi (va almashish uchun uni bosishingiz ham mumkin).

### Soat formatini 12 soatlikka qanday o'zgartiraman?

Keng tarqalgan formatlar, jumladan 12 soatliklari orasida almashish uchun paneldagi soatni o'ng tugma bilan bosing. Formatni bevosita ham belgilashingiz mumkin:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Bu Yakshanba 10:55 AM ko'rinishida aks etadi.

### Vaqt mintaqamni qanday o'zgartiraman?

Omarchy menyusida _Sozlash > Hudud > Vaqt mintaqasi_ ni ishga tushiring va ro'yxatdan tanlang. Vaqt mintaqasi to'g'ri bo'lsayu, lekin soatning o'zi adashgan bo'lsa, _Yangilash > Vaqt_ siz uchun vaqt sinxronizatsiyasini qayta ishga tushiradi.

### DNS imni qanday o'zgartiraman, Wi-Fi imni qanday ulashaman yoki ulanish tezligini qanday tekshiraman?

Bularning barchasi [tarmoq](35-networking.md) da joylashgan.

### Diskim qanchalik tez ekanini qanday tekshiraman?

_Trigger > Speed Test > Disk Speed Test_ diskingizdagi jonli o'qish va yozish tezligini o'lchaydi, yoki terminaldan `omarchy disk speedtest` buyrug'ini ishlating.

### Printer qanday qo'shaman?

Chop etish tayyor sozlangan va qutidan chiqqan holda ishlaydi, har bir printerni esa ilovalarni ishga tushirish vositasi (`Super + Alt + Space`) dagi _Chop etish sozlamalari_ dan o'zingiz qo'shasiz.

_Qo'shish_ ni tanlang va izlashiga bir oz vaqt bering: USB orqali ulangan printer va aksariyat tarmoq printerlari siz uchun topiladi. Agar sizniki ro'yxatda bo'lmasa, _Network Printer > Internet Printing Protocol (ipp)_ ni tanlang va uning manzilini kiriting — printer manzili nima ekanini printer displeyining o'zi yoki uning veb-sahifasi aytadi, odatda `ipp/print` navbati bilan `192.168.1.50` kabi biror narsa. Keyin _Forward_ drayver taklif qiladi, bunda zamonaviy printer drayversiz _IPP Everywhere_ profilida eng yaxshi ishlaydi, eskisi esa modelning o'z drayverini xohlaydi.

Ilovalaringiz birinchi bo'lib qaysi biriga murojaat qilishini tanlash uchun printerni o'ng tugma bilan bosib _Set as Default_ ni, qog'oz o'lchami, ikki tomonlama chop etish va sifatni sozlash uchun _Properties_ ni tanlang.

Avtomatik aniqlash, ya'ni tarmoqdagi printerlar qo'shilmasdan turib paydo bo'lishi, qayta ishlanayotgani sababli vaqtincha o'chirilgan, shuning uchun yuqoridagi birinchi qadam avtomatik emas, sizniki. Hech qanday printer bo'lmasa ham PDF faylga chop etish ishlaydi.

### Skrinshotlar yoki ekran yozuvlari saqlanadigan joyni qanday o'zgartiraman?

Saqlangan skrinshotlar standart bo'yicha `~/Pictures/Screenshots` ga boradi. Boshqa katalogdan foydalanish uchun `~/.config/uwsm/env.d/` ostidagi faylga (masalan, `~/.config/uwsm/env.d/capture`) quyidagini qo'shing:

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Ekran yozuvlari uchun ham `OMARCHY_SCREENRECORD_DIR` yordamida xuddi shunday qilishingiz mumkin.

Omasnap skrinshot katalogini avtomatik ravishda yaratadi. Ekran yozuvi katalogini o'zingiz yarating, keyin atrof-muhitdagi har ikkala o'zgarish ham kuchga kirishi uchun Omarchy ni qayta ishga tushiring.

### Apple Studio Display imda karnaylar + veb-kamerani qanday ishlataman?

USB C ulashning o'zi bilan hammasi ishlashi kerak deb o'ylaysiz, lekin afsuski unday emas. Uni ishonchli ishlatish uchun men topgan yechim — [WJESOG DisplayPort + USB-A => USB-C kabeli](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/) dan foydalanish. Shunda karnaylar va veb-kamera ajoyib ishlaydi.

Esda tuting, Omarchy da Apple displeylari (Studio ham, XDR ham) uchun oddiy klaviatura yorqinlik tugmalari bilan ishlaydigan o'rnatilgan yorqinlik boshqaruvi bor.

### Barcha ortiqcha dasturiy ta'minotdan qanday qutulaman?

Obsidian yoki LibreOffice kabi dasturlarni yoki boshqa oldindan o'rnatilgan narsalarni xohlamasangiz, ularni juda oson olib tashlashingiz mumkin.

O'rnatilgan har bir paketni ko'rish uchun _Olib tashlash > Paket_ ni ishga tushiring. Keyin tab bilan olib tashlamoqchi bo'lgan har qanday paketni tanlashingiz va return bilan tanlanganlarning hammasini olib tashlashni boshlashingiz mumkin.

Xohlamagan oldindan o'rnatilgan veb-ilovalarning istalganini olib tashlash uchun esa Omarchy menyusidan _Olib tashlash > Veb-ilova_ dan foydalanishingiz mumkin.

Yoki oldindan o'rnatilgan barcha qo'shimchalar — veb-ilovalar, TUIs va ixtiyoriy ilovalar — ni bir yo'la supurib tashlash uchun _Olib tashlash > Oldindan o'rnatilganlar_ ni ishga tushiring. Ularni ishga tushirgan tezkor tugmalar ham ular bilan birga yo'qoladi, shuning uchun `~/.config/hypr/bindings.lua` da o'zingiznikilar bilan to'ldirish uchun toza bog'lanishlar ro'yxati qoladi.

---

Xatolar va buzilgan qismlar uchun [Muammolarni bartaraf etish bo'limi](45-troubleshooting.md) ga qarang.
