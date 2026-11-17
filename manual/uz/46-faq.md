# Tez-tez so'raladigan savollar

### Klaviatura tartiblari o'rtasida qanday almashaman?

`~/.config/hypr/input.lua` faylingizni tahrirlang va `Left Alt + Right Alt` bilan tartiblar o'rtasida almashish uchun buni qo'shing:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Bir nechta tartibni sozlaganingizdan so'ng, panel joriy klaviatura tartibingizni avtomatik ko'rsatadi (almashish uchun uni bosishingiz ham mumkin).

### Soat formatini 12 soatlikka qanday o'zgartiraman?

Umumiy formatlar, jumladan 12 soatlik formatlar orasida aylanib o'tish uchun paneldagi soatni o'ng tugma bilan bosing. Formatni to'g'ridan-to'g'ri ham o'rnatishingiz mumkin:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Bu yakshanba 10:55 AM ko'rinishida ko'rsatadi.

### Vaqt mintaqamni qanday o'zgartiraman?

Omarchy menyusida _Update > Timezone_ ni ishga tushiring va ro'yxatdan tanlang. Agar vaqt mintaqasi to'g'ri bo'lsa-yu, lekin soatning o'zi adashib ketgan bo'lsa, _Update > Time_ vaqt sinxronizatsiyasini siz uchun qayta ishga tushiradi.

### DNS imni qanday o'zgartiraman, Wi-Fi imni qanday tarqataman yoki ulanish tezligimni qanday tekshiraman?

Ularning barchasi [tarmoq](35-networking.md) bo'limida joylashgan.

### Diskim qanchalik tez ekanini qanday tekshiraman?

_Trigger > Speed Test > Disk Speed Test_ diskingizdagi jonli o'qish va yozish tezligini o'lchaydi, yoki terminaldan `omarchy disk speedtest` ni ishga tushiring.

### Printer qanday qo'shaman?

Chop etish qutidan chiqqan holda sozlangan va ishlaydi, har bir printerni esa ilovalarni ishga tushirgichdagi (`Super + Space`) _Print Settings_ dan o'zingiz qo'shasiz.

_Add_ ni tanlang va qidirishi uchun unga biroz vaqt bering: USB orqali ulangan printer va ko'pchilik tarmoq printerlari siz uchun topiladi. Agar sizniki ro'yxatda bo'lmasa, _Network Printer > Internet Printing Protocol (ipp)_ ni tanlang va uning manzilini kiriting — printerning o'z displeyi yoki uning veb-sahifasi bu nima ekanini aytib beradi, odatda `ipp/print` navbati bilan `192.168.1.50` kabi narsa. So'ng _Forward_ drayver taklif qiladi, bunda zamonaviy printer drayversiz _IPP Everywhere_ profilida eng yaxshi ishlaydi, eskisi esa modelning o'z drayverini talab qiladi.

Ilovalaringiz birinchi bo'lib qaysi biriga murojaat qilishini tanlash uchun printerni o'ng tugma bilan bosing va _Set as Default_ ni tanlang, qog'oz o'lchami, duplex va sifatni o'rnatish uchun esa _Properties_ ni tanlang.

Tarmoqdagi printerlar qo'shmasdan turib paydo bo'ladigan avtomatik aniqlash, u qayta ishlanayotgani sababli vaqtincha o'chirilgan, aynan shuning uchun yuqoridagi birinchi qadamni avtomatik tizim emas, siz bajarasiz. PDF faylga chop etish umuman hech qanday printersiz ham ishlaydi.

### Skrinshotlar yoki ekran yozuvlari saqlanadigan joyni qanday o'zgartiraman?

Saqlangan skrinshotlar sukut bo'yicha `~/Pictures/Screenshots` ga boradi. Boshqa katalogdan foydalanish uchun buni `~/.config/uwsm/env.d/` ostidagi faylga (masalan, `~/.config/uwsm/env.d/capture`) qo'shing:

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Ekran yozuvlari uchun ham `OMARCHY_SCREENRECORD_DIR` yordamida xuddi shunday qilishingiz mumkin.

Omasnap o'zining skrinshot katalogini avtomatik yaratadi. Ekran yozuvi katalogini o'zingiz yarating, so'ng muhitdagi har ikkala o'zgarish ham kuchga kirishi uchun Omarchy ni qayta ishga tushiring.

### Apple Studio Display imda karnaylar + veb-kamerani qanday ishlataman?

USB C ni ulash bilan hammasi ishlaydi deb o'ylashingiz mumkin, ammo afsuski unday emas. Uni ishonchli ishlatish uchun men topgan yechim — [WJESOG DisplayPort + USB-A => USB-C kabeli](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/) dan foydalanish. Shunda karnaylar va veb-kamera ajoyib ishlaydi.

Omarchy da Apple displeylari (Studio ham, XDR ham) uchun oddiy klaviatura yorqinlik tugmalari yordamida o'rnatilgan yorqinlik boshqaruvi borligini unutmang.

### Barcha ortiqcha dasturiy ta'minotdan qanday qutulsam bo'ladi?

Agar Obsidian yoki LibreOffice kabi dasturlarni yoki oldindan o'rnatilgan boshqa narsalardan birortasini xohlamasangiz, uni juda oson olib tashlashingiz mumkin.

O'rnatilgan har bir paketni ko'rish uchun _Remove > Package_ ni ishga tushiring. Keyin olib tashlamoqchi bo'lgan har qanday paketni tab bilan tanlashingiz va tanlagan hamma narsangizni olib tashlashni return bilan boshlashingiz mumkin.

Kerak bo'lmagan oldindan o'rnatilgan veb-ilovalardan istalganini olib tashlash uchun Omarchy menyusidan _Remove > Web App_ dan ham foydalanishingiz mumkin.

Yoki barcha oldindan o'rnatilgan qo'shimchalar — veb-ilovalar, TUI lar va ixtiyoriy ilovalar — ni bir yo'la supurib tashlash uchun _Remove > Preinstalls_ ni ishga tushiring. Ularni ishga tushirgan tezkor tugmalar ham ular bilan birga yo'qoladi, shuning uchun sizga `~/.config/hypr/bindings.lua` da o'zingiznikilar bilan to'ldirish uchun toza bog'lamalar varag'i qoladi.

---

Xatolar va buzilgan joylar uchun [Muammolarni bartaraf etish bo'limi](45-troubleshooting.md) ga qarang.
