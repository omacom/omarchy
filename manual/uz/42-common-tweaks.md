# Keng tarqalgan tuzatishlar

Bu Omarchy sozlashiga keng tarqalgan moslashtirishlar toʻplami. Shuni bilingki, baʼzan tizim yangilanishlarida muayyan konfiguratsiyalarni dastlabki holatiga qaytarish kerak boʻlishi mumkin. Agar bu sodir boʻlsa, sizning oʻzgarishlaringiz yoʻqolmaydi, lekin bir xil katalogdagi `.bak` fayliga qoʻyiladi.

Agar biror narsani buzib qoʻysangiz, Omarchy menyusidagi _Yangilash > Config_ orqali alohida konfiguratsiyalarni dastlabki sozlashga qaytarishingiz mumkin. Agar hamma narsani _haqiqatan_ buzib qoʻysangiz, `omarchy-reinstall` orqali barcha konfiguratsiyalarni qayta oʻrnatishingiz mumkin.

### Barcha laganda belgilarini har doim koʻrsatish

Standart holatda, Dropbox, 1password yoki Steam kabi laganda belgilari lagandani kengaytiruvchi strelka orqasida yashiringan, siz uni ustiga olib borganda ularni ochadi. Agar ularni har doim ochiq qilib qoʻymoqchi boʻlsangiz, laganda belgi menejerini ochish uchun kengaytiruvchi strelkani oʻng tugma bilan bosing, keyin koʻrinishini istagan belgilarni qotiring (hech qachon koʻrishni istamaydiganlarini ham yashirishingiz mumkin).

### Yumaloq oyna burchaklari

Omarchy ning standart dizayni kvadrat burchaklardan biri, ammo agar uni ozgina yumshoq qilishni yoqtirsangiz, `~/.config/hypr/looknfeel.lua` ni oʻzgartirishingiz mumkin, yumaloqlash izohlangan holatda qolmasin:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Oyna oraliqlarini olib tashlash

Noutbuk displeylarida baʼzi odamlar oyna oraliqlariga (yoki hatto yuqori panelga, uni `Super + Shift + Space` bilan oʻchirishingiz mumkin) hech qanday piksel sarflamaslikni afzal koʻrishadi. `Super + Shift + Backspace` bilan barcha oraliqlar va chegaralarni oʻchirishingiz yoki `~/.config/hypr/looknfeel.lua` ning ushbu qismidagi izohlarni olib tashlash bilan ularni butunlay olib tashlashingiz mumkin:

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
