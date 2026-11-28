# Qurilma autentifikatsiyasi

### Barmoq izi autentifikatsiyasi

Ko‘plab noutbuklar autentifikatsiya qilish uchun barmoq izi sensori bilan keladi. Omarchy’da bundan Omarchy menyusida (`Super + Space`) _Setup > Security > Fingerprint_ ni ishga tushirib foydalanishingiz mumkin.

Bu sensorga tekkanda to‘lib boradigan to‘liq ekranli barmoq izini ochadi. Orqa fonda Omarchy barmoq izi paketini o‘rnatadi, izingizni oladi, uni tekshiradi va siz barmoq izingizdan foydalanib qulflangan ekrandan qulfni ochishga (`Super + Ctrl + L` bilan ishga tushirishingiz mumkin), sudo rejimiga kirishga va tizim so‘rovlarini tasdiqlashga tayyor bo‘lasiz.

Qulflangan ekran displeyni o‘chirganidan keyin sensor quvvatni tejash uchun dam oladi, shuning uchun unga tegishdan oldin istalgan tugma yoki touchpad yordamida ekranni uyg‘oting.

Noutbukingiz qopqog‘i yopiq bo‘lganda, barmoq izi so‘rovi avtomatik ravishda o‘tkazib yuboriladi, shuning uchun yetib bo‘lmaydigan sensorni kutmasdan to‘g‘ridan-to‘g‘ri parol so‘roviga o‘tasiz. Agar boshqa holatda sensori bo‘lmagan tashqi klaviaturada ishlashingiz kerak bo‘lsa, `sudo` paytida barmoq izingiz so‘ralganda shunchaki `CTRL + C` ni bosing.

Barmoq izi autentifikatsiyasini Omarchy menyusidagi _Remove > Security > Fingerprint_ ostida olib tashlashingiz mumkin.

### Fido2 autentifikatsiyasi

Agar Fido2 qurilmasidan foydalanayotgan bo‘lsangiz, uni Omarchy menyusida (`Super + Space`) _Setup > Security > Fido2_ yordamida `sudo` autentifikatsiyasi uchun sozlashingiz mumkin. Biroq bu `sudo` va tizim avtorizatsiyasi so‘rovlarini qamrab oladi, kompyuteringiz qulfini ochishni emas.

fido2 autentifikatsiyasini Omarchy menyusidagi _Remove > Security > Fido2_ ostida olib tashlashingiz mumkin.
