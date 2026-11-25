# Keng tarqalgan o'zgartirishlar

Bu Omarchy sozlamalariga kiritiladigan keng tarqalgan moslashuvlar to'plami. Shuni bilingki, tizim yangilanishlari vaqti-vaqti bilan ayrim konfiguratsiyalarni asl holatiga qaytarishi zarur bo'lib qolishi mumkin. Agar shunday bo'lsa, o'zgarishlaringiz yo'qolmaydi, balki asl fayl yonidagi `.bak.<timestamp>` fayliga joylashtiriladi.

Agar biror narsani buzib qo'ysangiz, alohida konfiguratsiyalarni Omarchy menyusidagi _Update > Config_ orqali asl sozlamalariga qaytarishingiz mumkin. Agar _haqiqatan ham_ hamma narsani buzib qo'ysangiz, `omarchy reinstall configs` orqali barcha konfiguratsiyalarni tiklashingiz yoki `omarchy reinstall` bilan har bir standart paket va konfiguratsiyani qayta o'rnatishingiz mumkin.

### Barcha tray piktogrammalarini har doim ko'rsatish

Odatiy bo'yicha, Dropbox, 1password yoki Steam kabi tray piktogrammalari tray kengaytiruvchi o'q orqasida yashiringan bo'ladi, sichqonchani uning ustiga olib borsangiz, ular paydo bo'ladi. Agar ularni har doim ochiq ko'rinishda saqlamoqchi bo'lsangiz, kengaytiruvchi o'qqa o'ng tugma bilan bosib tray piktogrammalari boshqaruvchisini oching, keyin ko'rinib turishini istagan piktogrammalaringizni mahkamlang (hech qachon ko'rishni istamaydiganlaringizni ham yashirishingiz mumkin).

### Dumaloq oyna burchaklari

Omarchy'ning standart dizayni to'rtburchak burchaklardan iborat, lekin buni biroz yumshatishni istasangiz, Omarchy menyusida _Appearance > Windows > Window Corners > Rounded Corners_ ni tanlang yoki `omarchy hyprland corners rounded` ni ishga tushiring. _Theme Corners_ mavzu ishlatadigan holatga qaytaradi. O'zingizning radiusingizni tanlash uchun _Theme Corners_ (`omarchy hyprland corners theme`) da qoling, chunki Rounded va Sharp sizning konfiguratsiyangizdan keyin yuklanadi va uni bekor qiladi, hamda `~/.config/hypr/looknfeel.lua` da rounding ni izohdan chiqaring:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Oyna oralig'larini olib tashlash

Noutbuk ekranlarida ba'zi odamlar oyna oralig'lariga (yoki hatto `Super + Shift + Space` bilan o'chirib-yoqish mumkin bo'lgan yuqori panelga ham) birorta piksel sarflamaslikni afzal ko'radi. Barcha oraliqlar va chekkalarni `Super + Shift + Backspace` bilan o'chirib-yoqishingiz yoki `~/.config/hypr/looknfeel.lua` ning ushbu bo'limidagi izohlarni olib tashlab, ularni butunlay olib tashlashingiz mumkin:

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
