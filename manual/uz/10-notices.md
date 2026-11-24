# Xabarnomalar

Bildirishnomalar fokusdagi displeyning yuqori o'ng burchagida paydo bo'ladi. Tezkor tugmalar xabarnomalaridan foydalanib, sana va vaqt, batareya holati va joriy ob-havoni ham tezda ko'rishingiz mumkin.

## Bildirishnomalar

Bir xil ilova yoki saytdan kelgan bildirishnomalar bitta to'plamga yig'iladi, shuning uchun gapdon Slack kanali build xatosi haqidagi xabaringizni ekrandan surib yubora olmaydi. To'plamni yoyish uchun kursorni uning ustiga olib boring; o'qib turganingizda kursoringiz ostiga hech narsa yangidan sirg'alib kirmaydi. Kartochkani bossangiz, u kelgan joyga o'tasiz, uni yopish uchun esa o'ng tugmani bosing, o'rta tugmani bosing yoki ✕ belgisini bosing.

Kartochkalar o'zi olib kelganini taklif qiladi: tasdiqlash kodlari uchun _Kodni nusxalash_ ([bufer tarixi](08-unified-clipboard-history.md)dan tashqarida saqlanadi va bir daqiqadan keyin tozalanadi), shuningdek ilova taqdim etgan har qanday tugmalar. Bildirishnoma matnidagi havolalar bosilganda ochiladi.

`Super + ,` eng yangi bildirishnomani yopadi yoki u shunday imkoniyatni taklif qilsa, u ko'rsatgan narsani ochadi, `Super + Alt + ,` faqat oxirgisini yopadi, `Super + Shift + ,` hammasini yopadi va `Super + Shift + Alt + ,` tarixni ochadi. Ulardan sichqonchasiz foydalanish uchun `Super + Ctrl + ,` ni bosing. Eng yangi bildirishnoma tanlanadi va uning tugmalari raqamlanadi: birini ishlatish uchun raqamni bosing, bildirishnomani bosish uchun `Enter` ni, bildirishnomalar orasida harakatlanish uchun `↑` va `↓` ni, bittasini yopish uchun `Delete` ni va klaviaturani qaytarib berish uchun `Esc` ni bosing. U bir necha soniya harakatsizlikdan keyin o'zi ham qo'yib yuboradi.

Bildirishnomalarni ovozsiz qilish ularni ushlab turadi, bundan Omarchy'ning o'z tasdiqlari, favqulodda ogohlantirishlar va siz bir zum oldin so'ragan tasdiqlash kodlari mustasno. Oxirgi bir nechtasini, ushlab turilgan bo'ladimi yoki yo'qmi, `Super + Shift + Alt + ,` bilan ekranga qaytaring. Tarix bir kun saqlanadi.

## Tezkor tugmalar xabarnomalari

### Sana va vaqt

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Ob-havo

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Joylashuv IP manzilingiz bo'yicha aniqlanadi, bu odatda yetarlicha yaqin chiqadi, lekin har doim ham emas. Uni `omarchy weather location --set Malibu` bilan aniq belgilab qo'yishingiz yoki koordinatalarni qo'shib, mutlaqo aniq qilishingiz mumkin: `omarchy weather location --set Malibu 34.0259,-118.7798`. Qayerda deb o'ylayotganini ko'rish uchun `omarchy weather location` ni alohida ishga tushiring, avtomatik aniqlashga qaytish uchun esa `--clear` dan foydalaning.

### Batareya

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
