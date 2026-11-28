# Brending

Omarchy kompaniyangiz logotipi yoki shaxsiy tasviringizni ham ekran saqlovchisi, ham haqida ekrani uchun o‘rnatish imkonini beradi.

### Ekran saqlovchisi

Ekran saqlovchisi uchun ishlatiladigan logotipni _Tashqi ko‘rinish > Brending > Ekran saqlovchisi_ bo‘limida o‘zgartirishingiz mumkin. Bu ASCII logotip, shuning uchun matnni to‘g‘ridan-to‘g‘ri tahrirlashingiz mumkin, lekin unga png yoki svg tasvir ham berishingiz mumkin, biz esa uni ASCII ga aylantirib beramiz. Juda zo‘r ko‘rinadi.

 ![branding-screensaver](images/branding-screensaver.webp)

O‘sha menyuda uchta band bor:

- **Matnni tahrirlash** `~/.config/omarchy/branding/screensaver.txt` faylini muharriringizda ochadi. Xohlaganingizni yozing yoki joylashtiring — ASCII san’ati, ismingiz, qo‘pol so‘z. Saqlang va chiqing, ekran saqlovchisi darhol ishga tushadi, shunda uni ko‘rishingiz mumkin.
- **Tasvirdan o‘rnatish** png yoki svg uchun fayl tanlagichni ochadi, uni ASCII ga aylantiradi va natijani sizga ko‘rsatadi. Aniq siluetga ega logotiplar fotosuratlarga qaraganda ancha yaxshi chiqadi.
- **Standartni tiklash** Omarchy logotipini joyiga qaytaradi.

### Haqida ekrani

Xuddi shu uchta variant Omarchy menyusidan oladigan _Haqida_ ekraningiz uchun _Tashqi ko‘rinish > Brending > Haqida_ bo‘limida ham bor va ular xuddi shunday ishlaydi — fayl `~/.config/omarchy/branding/about.txt`, har bir o‘zgarishdan keyin esa Haqida oynasi ochiladi. Haqida san’ati ekran saqlovchisinikiga qaraganda kichikroq o‘lchamga aylantiriladi, chunki u displeyingizni to‘ldirish o‘rniga oynaga sig‘ishi kerak.

Oyna ochiq turganda yorqin oq yorug‘lik tasmasi har bir necha soniyada san’at ustidan egilib o‘tadi va keyin uni yana tinch qoldiradi. San’atingizdagi har bir belgi bir ustun kengligida bo‘lsa, sizning o‘z san’atingiz ham shuni oladi — _Tasvirdan o‘rnatish_ yaratadigan har qanday narsa shunday. Emoji yoki ikki kenglikdagi belgilardan tuzilgan san’at o‘rnida harakatsiz qoladi, o‘zingizning fastfetch konfiguratsiyangizni saqlab qolsangiz ekran ham shunday qoladi: bunday hollarda harakatsiz logotip animatsiya ishlamay qolgani uchun emas, balki yo‘l bo‘shatayotgani uchundir, chunki ular ustidan yaltirashni siljitish satrning qolgan qismini noto‘g‘ri joyga tushirib qo‘yardi.

 ![branding-about](images/branding-about.webp)

### Tasvirlarni o‘zingiz aylantirish

Ikkala _Tasvirdan o‘rnatish_ varianti ham shunchaki `omarchy transcode ascii` ni chaqiradi, agar aylantirish ustidan nazoratni xohlasangiz, uni to‘g‘ridan-to‘g‘ri ishga tushirishingiz mumkin:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

U terminal ustunlari va satrlarida `--width` va `--height` ni, `braille` (standart variant va ancha nozikroq) yoki `block` bo‘lishi mumkin bo‘lgan `--mode` ni, qaysi piksellar logotipning bir qismi deb hisoblanishini hal qilish uchun foiz ko‘rinishidagi `--threshold` ni va logotipingiz qorong‘i fonda och rangda bo‘lganda `--invert` ni qabul qiladi. Agar aylantirish bir uyum dog‘ bo‘lib chiqsa, odatda burash kerak bo‘lgan tugma threshold bo‘ladi.

### Logotip o‘rniga so‘zlar

`omarchy ascii` matnni Omarchy so‘z belgisi chizilgan FIGlet shrifti Delta Corps Priest 1 da chizadi, shuning uchun ekran saqlovchisi rasm ko‘rsatish o‘rniga biror narsa aytishi mumkin:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

U matnni argumentlar sifatida qabul qiladi yoki hech qanday argument berilmasa, uni quvurdan o‘qiydi. Shrift faqat harflar va bo‘sh joylarni o‘z ichiga oladi — u raqamlar va tinish belgilarisiz chizilgan — shuning uchun boshqa har qanday narsa tashlab yuboriladi va jim yutib yuborilmasdan stderr da nomi aytiladi.
