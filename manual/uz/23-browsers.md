# Brauzerlar

Omarchy standart brauzer sifatida [Google Chrome](https://www.google.com/chrome/) bilan birga keladi. U tizimingizning qolgan qismiga moslab mavzulangan va aynan uni `Super + Shift + Return` (yoki `Super + Shift + B`) ochadi, `Super + Shift + Alt + B` esa shaxsiy oyna uchun ishlatiladi, va har bir [veb-ilova](25-web-apps.md) uning ichida ishlaydi. U to'g'ridan-to'g'ri brauzer oynasida ochiladi: hech qanday xush kelibsiz ekrani yoki tizimga kirish so'rovi yo'q, foydalanish statistikasi va nosozlik hisobotlari Google ga yuborilmaydi, reklama maxfiyligi so'rovlari esa o'chirilgan. Sinxronlashni xohlaganingizda, profil tugmasi orqali Google hisobingizga istalgan vaqtda baribir kirishingiz mumkin.

Agar Chrome didingizga mos kelmasa, unga bog'lanib qolmagansiz. Omarchy menyusidagi _O'rnatish > Brauzer_ bo'limida siz [Chromium](https://www.chromium.org/) (Chrome yasalgan oddiy ochiq manbali build), Edge, Brave, Brave Origin, Firefox va [Zen](https://zen-browser.app/) ni topasiz (Edge faqat x86 mashinalarida). Bittasini tanlang va Omarchy uni o'rnatadi, uning policy katalogini sozlaydi hamda unga joriy mavzuingizni qo'llaydi.

## Bittasini standart qilish

Brauzerni o'rnatish uni standart brauzerga aylantirmaydi. Almashtirish uchun _Sozlash > Standartlar > Brauzer_ bo'limiga o'ting va bittasini tanlang. Joriy standart belgi bilan ajratib ko'rsatilgan, hali sizda yo'q brauzerni tanlasangiz, u avval o'rnatiladi.

Terminaldan bu shunday amalga oshiriladi:

```bash
omarchy default browser firefox
```

Uni hech qanday argumentsiz ishga tushiring va u sizga joriy standartni aytib beradi. Bu XDG handler ni o'rnatadi, shuning uchun bunga faqat Omarchy tezkor tugmalari ergashmaydi — havolani ochadigan har qanday narsa, chat ilovasidan tortib terminal buyrug'igacha, siz tanlagan brauzerga o'tadi.

## Copy URL va Download Video

Chromium oilasiga mansub brauzerlar (Chromium ning o'zi, Chrome, Edge, Brave va Brave Origin) uchta Omarchy kengaytmasi bilan birga keladi: ulardan ikkitasi brauzerdan tashqariga chiqib, tizimingizning qolgan qismiga yetib boradi, bittasi esa WhatsApp ni tartibga keltiradi.

**Copy URL** joriy tab manzilini `Alt + Shift + L` yordamida clipboard ingizga qo'yadi. Bu manzil satriga bosib nusxa olishdan tezroq va u brauzer clipboard i orqali emas, tizim clipboard i orqali o'tgani uchun siz Omarchy bildirishnomasini tasdiq sifatida olasiz hamda URL darhol [clipboard tarixi](08-unified-clipboard-history.md) va boshqa har bir ilovada mavjud bo'ladi. Agar bosishni afzal ko'rsangiz, asboblar panelida tugmasi ham bor.

**Download Video** siz ko'rib turgan sahifada ijro etilayotgan videoni `Alt + Shift + D` yordamida oladi. U URL ni [yt-dlp](https://github.com/yt-dlp/yt-dlp) ga topshiradi, shuning uchun u YouTube dagina emas, ancha ko'proq saytlarda ishlaydi va yuklab olingan fayl `~/Videos` ga tushadi. Jarayon ovoz balandligi va yorug'lik ishlatadigan xuddi shu ekran ko'rsatkichida aks etadi, bildirishnomalarni ustma-ust to'plamasdan joyida yangilanadi. Fayllar boshqa joyga borishini xohlasangiz, `OMARCHY_YTDLP_DIR` ni o'rnating — muhit o'zgaruvchilarini qayerga qo'yish kerakligini bilish uchun [FAQ](46-faq.md) ga qarang.

Ikkala kengaytma ham Omarchy bilan kichik native messaging host orqali muloqot qiladi, u brauzer bilan birga siz uchun o'rnatiladi. Aynan shu qism veb-sahifadagi videoning home katalogingizga, URL ning esa clipboard menejeringizga tushishiga imkon beradi; oddiy kengaytma buni o'zi qila olmaydi.

**WhatsApp Slim** WhatsApp Web ni tizim mavzuingizga ergashadigan qiladi va oyna tor bo'lganda uning chatlar ro'yxatini yig'ib qo'yadi.

Bular faqat Chromium oilasi uchungina mavjud. Firefox va Zen ularni olmaydi.

## Firefox va Zen

Firefox va Zen boshqa oilaga mansub, shuning uchun ularga boshqacha munosabatda bo'linadi: Omarchy maqbul standart sozlamalar uchun policies faylini o'rnatadi va ularni native Wayland rejimiga o'tkazadi; bu sizga kasrli masshtablash va trackpad bilan silliq aylantirish uchun kerak bo'ladi.

Ular yuqoridagi Chromium kengaytmalarini olmaydi va Omarchy tomonidan mavzulanmaydi, shuning uchun tajribaning o'sha qismlarini o'zingiz sozlashingizga to'g'ri keladi.

## Bittasini yana olib tashlash

Bu brauzerlarning har biri, Chrome ham shu jumladan, _O'chirish > Brauzer_ bo'limi orqali qayta olib tashlanishi mumkin. Keyin, agar boshqasi hali ham o'rnatilgan bo'lsa, havolalar Chrome yoki Chromium ga o'tadi.
