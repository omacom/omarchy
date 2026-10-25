# Brending

Omarchy sizga kompaniyangiz logotipini yoki shaxsiy rasmingizni yuklanishda qulfni ochish ekrani, ekran saqlagichi va "Haqida" ekrani uchun o'rnatish imkonini beradi.

### Yuklanishda qulfni ochish

Maxsus logotipingiz va ranglaringiz qanday ko'rinishini ko'rish uchun `omarchy plymouth preview` dan foydalanishingiz mumkin. U fon rangini, matn rangini, logo png faylini va ko'rib chiqish rasmi uchun yo'lni qabul qiladi:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Keyin `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png` bilan sozlamani qo'llang; bu SDDM kirish ekraniga ham xuddi shu ranglar va logotipni beradi. Agar qaytarishni istasangiz, `omarchy plymouth reset` dan foydalanishingiz mumkin.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Ekran saqlagichi

Ekran saqlagichi uchun ishlatiladigan logotipni _Tashqi ko'rinish > Brending > Ekran saqlagichi_ bo'limida o'zgartirishingiz mumkin. Bu ASCII logotip, shuning uchun matnni to'g'ridan-to'g'ri tahrirlashingiz mumkin, lekin unga png yoki svg rasm ham berishingiz mumkin, biz esa uni ASCII ga aylantiramiz. Juda zo'r ko'rinadi.

 ![branding-screensaver](images/branding-screensaver.webp)

O'sha menyuda uchta band bor:

- **Matnni tahrirlash** muharriringizda `~/.config/omarchy/branding/screensaver.txt` ni ochadi. Xohlaganingizni yozing yoki joylashtiring — ASCII san'at, ismingiz, qo'pol bir so'z. Saqlang va chiqing, ekran saqlagichi uni ko'rishingiz uchun darhol ishga tushadi.
- **Rasmdan o'rnatish** png yoki svg uchun fayl tanlagichni ochadi, uni ASCII ga aylantiradi va natijani ko'rsatadi. Aniq siluetga ega logotiplar fotosuratlarga qaraganda ancha yaxshi ishlaydi.
- **Standartni tiklash** Omarchy logotipini qaytarib qo'yadi.

### "Haqida" ekrani

Xuddi shu uchta variant Omarchy menyusidan oladigan _Haqida_ ekraningiz uchun _Tashqi ko'rinish > Brending > Haqida_ bo'limida ham bor va ular xuddi shunday ishlaydi — fayl `~/.config/omarchy/branding/about.txt`, "Haqida" oynasi esa har bir o'zgarishdan keyin ochiladi. "Haqida" rasmi ekran saqlagichinikiga qaraganda kichikroq o'lchamga aylantiriladi, chunki u butun displeyni to'ldirmasdan, oynaga sig'ishi kerak.

Oyna ochiq ekan, har bir necha soniyada rasm ustidan yashil shu'la egilib o'tadi va keyin uni yana harakatsiz qoldiradi. Sizning o'z rasmingiz ham shuni oladi, basharti undagi har bir belgi bir ustun kengligida bo'lsa — _Rasmdan o'rnatish_ yaratgan har qanday narsa shunday. Emoji yoki qo'sh kenglikdagi belgilardan qurilgan rasm buning o'rniga harakatsiz qoladi, agar o'zingizning fastfetch konfiguratsiyangizni saqlasangiz, ekran ham shunday qoladi: bunday hollarda harakatsiz logotip animatsiya ishlamay qolgani emas, balki u yo'ldan chetga chiqayotgani, chunki shu'lani ular ustidan sirpantirish qatorning qolgan qismini noto'g'ri joyga tushirib qo'ygan bo'lardi.

 ![branding-about](images/branding-about.webp)

### Rasmlarni o'zingiz aylantirish

Ikkala _Rasmdan o'rnatish_ varianti ham shunchaki `omarchy transcode ascii` ni chaqiradi, aylantirishni nazorat qilishni istasangiz, uni to'g'ridan-to'g'ri ham ishga tushirishingiz mumkin:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

U terminal ustunlari va qatorlarida `--width` va `--height` ni, `braille` (standart va ancha nozikroq) yoki `block` dan biri bo'lgan `--mode` ni, qaysi piksellar logotipning bir qismi deb hisoblanishini hal qilish uchun foiz ko'rinishidagi `--threshold` ni va logotipingiz to'q fonda och rangda bo'lganda `--invert` ni qabul qiladi. Agar aylantirish dog' bo'lib chiqsa, odatda burash kerak bo'lgan tugma threshold hisoblanadi.

### Logotip o'rniga so'zlar

`omarchy ascii` matnni Delta Corps Priest 1 da, Omarchy so'z belgisi chizilgan FIGlet shriftida chizadi, shuning uchun ekran saqlagichi rasm ko'rsatish o'rniga biror narsa deyishi mumkin:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

U matnni argumentlar sifatida qabul qiladi yoki hech narsa berilmasa, uni pipe orqali o'qiydi. Shrift faqat harflar va bo'shliqlarni o'z ichiga oladi — u raqamlar va tinish belgilarisiz chizilgan — shuning uchun boshqa har qanday narsa jimgina yutib yuborilmasdan, tashlab yuboriladi va stderr da nomi aytiladi.
