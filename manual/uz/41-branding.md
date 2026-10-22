# Branding

Omarchy sizga ham yuklash ochilishi, ham ekran saqlagich, ham haqida ekrani uchun kompaniya logotipingizni yoki shaxsiy rasmingizni oʻrnatish imkonini beradi.

### Yuklash ochilishi

Maxsus logotipingiz va ranglaringiz qanday koʻrinishini koʻrish uchun `omarchy plymouth preview` dan foydalanishingiz mumkin. Bu orqa fon rangini, matn rangini, logotip png sini va oldindan koʻrish rasmi uchun yoʻlni oladi:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Keyin sozlashni `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png` bilan qoʻllang, bu SDDM kirish ekraniga ham bir xil ranglar va logotipni beradi. Agar qaytarishni istasangiz, `omarchy plymouth reset` dan foydalanishingiz mumkin.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Ekran saqlagich

Ekran saqlagich uchun ishlatiladigan logotipni _Uslub > Ekran saqlagich_ ostida oʻzgartirishingiz mumkin. Bu ASCII logotip, shuning uchun matnni toʻgʻridan-toʻgʻri tahrirlashingiz mumkin, lekin unga png yoki svg rasmini ham berishingiz mumkin va biz uni ASCII ga aylantiramiz. Bu juda salqin koʻrinadi.

 ![branding-screensaver](images/branding-screensaver.webp)

Bu menyuda uchta yozuv mavjud:

- **Matnni tahrirlash** muharriringizda `~/.config/omarchy/branding/screensaver.txt` ni ochadi. Istaganingizni yozing yoki joylashtiring — ASCII sanʼati, ismingiz, qoʻpol soʻz. Saqlang va chiqing va ekran saqlagich darhol ishga tushadi, shunda koʻrishingiz mumkin.
- **Rasmdan oʻrnatish** png yoki svg uchun fayl tanlagichni ochadi, uni ASCII ga aylantiradi va natijani koʻrsatadi. Aniq siluetga ega logotiplar fotosuratlarga qaraganda ancha yaxshiroq ishlaydi.
- **Standartni tiklash** Omarchy logotipini qayta qoʻyadi.

### Haqida ekrani

Xuddi shu uchta variant Omarchy menyusidan oladigan _Haqida_ ekrani uchun _Uslub > Haqida_ ostida joylashgan va ular bir xil ishlaydi — fayl `~/.config/omarchy/branding/about.txt` va Haqida oynasi har bir oʻzgarishdan keyin paydo boʻladi. Haqida sanʼati ekran saqlagichga qaraganda kichikroq oʻlchamga aylantiriladi, chunki u displeyingizni toʻldirish oʻrniga oynaga sigʻishi kerak.

Oyna ochiq boʻlganda har bir necha soniyalarda yashil nur sanʼat boʻylab qiyshayib oʻtadi va keyin uni yana harakatsiz qoldiradi. Oʻzingizning sanʼatingiz ham uni oladi, agar undagi har bir belgi bir ustun kengligida boʻlsa — _Rasmdan oʻrnatish_ chiqaradigan har narsa shunday. Emoji yoki ikki kenglik belgilaridan tuzilgan sanʼat uning oʻrniga harakatsiz qoladi va agar siz oʻzingizning fastfetch konfiguratsiyangizni saqlasangiz, ekran ham shunday boʻladi: bunday hollarda harakatsiz logotip animatsiyaning muvaffaqiyatsiz boʻlish oʻrniga yoʻldan chetlanganidir, chunki ular boʻylab nurni surish chiziqning qolgan qismini notoʻgʻri joyga tushirardi.

 ![branding-about](images/branding-about.webp)

### Rasmlarni oʻzingiz aylantirish

_Rasmdan oʻrnatish_ variantlari ikkalasi ham `omarchy transcode ascii` ni chaqirmoqda xolos, agar aylantirish ustidan nazorat istasangiz, uni toʻgʻridan-toʻgʻri ishlatishingiz mumkin:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Bu terminal ustunlari va qatorlarda `--width` va `--height` ni, `braille` (standart va ancha nozik) yoki `block` dan birining `--mode` ini, qaysi piksellar logotipning bir qismi sifatida hisoblanishini hal qiladigan `--threshold` foizni va logotipingiz qoramtir fonda och boʻlganda `--invert` ni oladi. Agar aylantirish parcha sifatida chiqsa, chegara odatda burilishi kerak boʻlgan tutqichdir.

### Logotip oʻrniga soʻzlar

`omarchy ascii` matnni Delta Corps Priest 1 da chizadi, Omarchy soʻz markasining oʻzi chizilgan FIGlet shrifti, shunday qilib ekran saqlagich rasm koʻrsatish oʻrniga biror narsa aytishi mumkin:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Bu matnni argumentlar sifatida oladi yoki hech narsa berilmaganda uni quvurdan oʻqiydi. Shrift faqat harflar va boʻshliqlarni oʻz ichiga oladi — u raqamlar yoki tinish belgilarisiz chizilgan — shuning uchun boshqa har narsa tushirib qoldiriladi va jimgina yutilish oʻrniga stderr da nomlanadi.
