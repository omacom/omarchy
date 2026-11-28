# Brending

Omarchy yuklanish qulfini ochish ekrani, ekran saqlovchi va haqida ekrani uchun kompaniyangiz logotipini yoki shaxsiy tasviringizni oʻrnatish imkonini beradi.

### Yuklanish qulfini ochish

Maxsus logotipingiz va ranglaringiz qanday koʻrinishini koʻrish uchun `omarchy plymouth preview` dan foydalanishingiz mumkin. U fon rangini, matn rangini, logotip png sini va oldindan koʻrish tasviri uchun yoʻlni qabul qiladi:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Keyin sozlamani `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png` bilan qoʻllang, bu SDDM kirish ekraniga ham xuddi shu ranglar va logotipni beradi. Agar qaytarmoqchi boʻlsangiz, `omarchy plymouth reset` dan foydalanishingiz mumkin.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Ekran saqlovchi

Ekran saqlovchi uchun ishlatiladigan logotipni _Tashqi koʻrinish > Brending > Ekran saqlovchi_ ostida oʻzgartirishingiz mumkin. Bu ASCII logotip, shuning uchun matnni toʻgʻridan-toʻgʻri tahrirlashingiz mumkin, lekin unga png yoki svg tasvir ham berishingiz mumkin va biz uni ASCII ga aylantirib beramiz. Ancha zoʻr koʻrinadi.

 ![branding-screensaver](images/branding-screensaver.webp)

Oʻsha menyuda uchta band bor:

- **Matnni tahrirlash** `~/.config/omarchy/branding/screensaver.txt` ni muharriringizda ochadi. Xohlagan narsangizni yozing yoki joylashtiring — ASCII tasvir, ismingiz, biror qoʻpol soʻz. Saqlang va chiqing, ekran saqlovchi uni koʻrishingiz uchun darhol ishga tushadi.
- **Rasmdan oʻrnatish** png yoki svg uchun fayl tanlagichni ochadi, uni ASCII ga aylantiradi va natijani koʻrsatadi. Aniq siluetga ega logotiplar fotosuratlarga qaraganda ancha yaxshi ishlaydi.
- **Standartni tiklash** Omarchy logotipini qaytaradi.

### Haqida ekrani

Xuddi shu uchta variant Omarchy menyusidan oladigan _Haqida_ ekraningiz uchun _Tashqi koʻrinish > Brending > Haqida_ ostida joylashgan va ular xuddi shunday ishlaydi — fayl `~/.config/omarchy/branding/about.txt` boʻlib, har bir oʻzgarishdan keyin Haqida oynasi ochiladi. Haqida tasviri ekran saqlovchinikiga qaraganda kichikroq oʻlchamga aylantiriladi, chunki u displeyingizni toʻldirish oʻrniga oynaga sigʻishi kerak.

Oyna ochiq turganida, har bir necha soniyada yorqin oq yorugʻlik tasmasi tasvir ustidan qiya oʻtib ketadi va keyin uni yana tinch qoldiradi. Undagi har bir belgi bir ustun kengligida boʻlsa, sizning oʻz tasviringiz ham shuni oladi — _Rasmdan oʻrnatish_ ishlab chiqaradigan har qanday narsa shunday. Emoji yoki ikki kenglikdagi belgilardan tuzilgan tasvir esa harakatsiz qoladi, oʻzingizning fastfetch konfiguratsiyangiz boʻlsa, ekran ham shunday qoladi: bunday hollarda harakatsiz logotip animatsiya ishlamay qolganini emas, uning yoʻldan chekinayotganini bildiradi, chunki yaltirashni ular ustidan surish satrning qolgan qismini notoʻgʻri joyga tushirib qoʻyardi.

 ![branding-about](images/branding-about.webp)

### Tasvirlarni oʻzingiz konvertatsiya qilish

_Rasmdan oʻrnatish_ variantlarining ikkalasi ham shunchaki `omarchy transcode ascii` ni chaqiradi, agar konvertatsiya ustidan nazoratni xohlasangiz, uni toʻgʻridan-toʻgʻri ishlatishingiz mumkin:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

U terminal ustunlari va satrlarida `--width` va `--height` ni, `braille` (standart va ancha nozikroq) yoki `block` dan biri boʻlgan `--mode` ni, qaysi piksellar logotipning bir qismi deb hisoblanishini hal qilish uchun `--threshold` foizini va logotipingiz qorongʻu fonda och rangda boʻlganda `--invert` ni qabul qiladi. Agar konvertatsiya xira dogʻ boʻlib chiqsa, odatda burash kerak boʻlgan tugma threshold hisoblanadi.

### Logotip oʻrniga soʻzlar

`omarchy ascii` matnni Delta Corps Priest 1 da chizadi — bu Omarchy soʻz belgisi ham chizilgan FIGlet shrifti — shuning uchun ekran saqlovchi rasm koʻrsatish oʻrniga biror gap aytishi mumkin:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

U matnni argumentlar sifatida qabul qiladi yoki hech narsa berilmasa, uni quvurdan oʻqiydi. Shrift faqat harflar va boʻsh joylarni oʻz ichiga oladi — u raqamlar va tinish belgilarisiz chizilgan — shuning uchun boshqa har qanday narsa indamay yutib yuborilmasdan, tashlab yuboriladi va stderr da nomi aytiladi.
