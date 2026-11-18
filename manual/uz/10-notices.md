# Bildirishnomalar

Bildirishnomalar fokusdagi displeyning yuqori o‘ng burchagida paydo bo‘ladi. Shuningdek, tezkor tugmalar bildirishnomalari yordamida sana va vaqt, batareya holati va joriy ob-havoga tezda kirishingiz mumkin.

## Bildirishnomalar

Bir xil ilova yoki saytdan kelgan bildirishnomalar bitta to‘plamga yig‘iladi, shuning uchun sergap Slack kanali build xatosi haqidagi bildirishnomangizni ekrandan surib yubormaydi. To‘plamni yoyish uchun kursorni uning ustiga olib boring; siz o‘qiyotganingizda ko‘rsatkichingiz ostiga hech narsa yangidan sirg‘alib kirmaydi. Kelgan joyiga o‘tish uchun kartani bosing, uni yopish uchun o‘ng tugmani bosing, o‘rta tugmani bosing yoki ✕ belgisini bosing.

Kartalar o‘zida bor narsani taklif qiladi: tasdiqlash kodlari uchun _Copy code_ ([bufer tarixi](08-unified-clipboard-history.md)da saqlanmaydi va bir daqiqadan keyin tozalanadi), shuningdek ilova taqdim etadigan istalgan tugmalar. Bildirishnoma matnidagi havolalar bosilganda ochiladi.

Ularga sichqonchasiz kirish uchun `Super + Ctrl + ,` tugmalarini bosing. Eng yangi bildirishnoma tanlanadi va uning tugmalari raqamlanadi: biridan foydalanish uchun raqamni bosing, bildirishnomani bosish uchun `Enter`ni bosing, bildirishnomalar orasida harakatlanish uchun `↑` va `↓` tugmalarini bosing, birini yopish uchun `Delete`ni bosing va klaviaturani qaytarish uchun `Esc`ni bosing. U bir necha soniya harakatsizlikdan keyin o‘zi ham qo‘yib yuboradi.

Bildirishnomalarni ovozini o‘chirish ularni ushlab qoladi, bundan Omarchy’ning o‘z tasdiqlari, favqulodda ogohlantirishlari va siz hozirgina so‘ragan tasdiqlash kodlari mustasno. Ushlab qolinganmi yoki yo‘qmi, oxirgi bir nechtasini `Super + Shift + Alt + ,` bilan ekranga qaytaring. Tarix bir kun saqlanadi.

## Tezkor tugmalar bildirishnomalari

### Sana va vaqt

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Ob-havo

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Joylashuv IP manzilingizdan aniqlanadi, bu odatda yetarlicha yaqin, lekin har doim ham emas. Uni `omarchy weather location --set Malibu` bilan aniq belgilashingiz yoki koordinatalarni qo‘shib aniq ko‘rsatishingiz mumkin: `omarchy weather location --set Malibu 34.0259,-118.7798`. Qayerda deb hisoblayotganini ko‘rish uchun `omarchy weather location`ni alohida ishga tushiring va avtomatik aniqlashga qaytish uchun `--clear`dan foydalaning.

### Batareya

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
