# Brauzerlar

Omarchy standart brauzer sifatida [Google Chrome](https://www.google.com/chrome/) bilan birga keladi. U tizimingizning qolgan qismiga mos qilib mavzulashtirilgan, va aynan uni `Super + Shift + Return` ochadi hamda har bir [veb-ilova](25-web-apps.md) uning ichida ishlaydi. U to'g'ridan-to'g'ri brauzer oynasiga ochiladi: hech qanday xush kelibsiz ekrani yoki kirish so'rovi yo'q, foydalanish statistikasi va nosozlik hisobotlari Google ga yuborilmaydi, reklama maxfiyligi so'rovlari esa o'chirilgan. Sinxronlashni xohlaganingizda, profil tugmasi orqali Google hisobingizga baribir kira olasiz.

Agar Chrome sizning didingizga mos kelmasa, unga bog'lanib qolganingiz yo'q. Omarchy menyusidagi _Install > Browser_ ostida [Chromium](https://www.chromium.org/) (Chrome yasalgan oddiy ochiq manbali build), Edge, Brave, Brave Origin, Firefox va [Zen](https://zen-browser.app/) ni topasiz. Birini tanlang, Omarchy uni o'rnatadi, uning policy katalogini sozlaydi va unga joriy mavzuingizni qo'llaydi.

## Birini standart qilish

Brauzerni o'rnatish uni standartga aylantirmaydi. U mashinada paydo bo'lgach, _Setup > Defaults > Browser_ ga o'ting va uni tanlang — menyu faqat siz haqiqatan o'rnatgan brauzerlarni ro'yxatga oladi va joriy standartni belgi bilan ko'rsatadi.

Terminaldan bu shunday:

```bash
omarchy default browser firefox
```

Uni hech qanday argumentsiz ishga tushiring, u sizga joriy standartni aytadi. Bu XDG handler ni o'rnatadi, shuning uchun faqat Omarchy tezkor tugmalari unga ergashmaydi — havolani ochadigan har qanday narsa, chat ilovasidan tortib terminal buyrug'igacha, siz tanlagan brauzerga boradi.

## Copy URL va Download Video

Chromium oilasidagi brauzerlar (Chromium ning o'zi, Chrome, Edge va Brave) brauzerdan tashqariga chiqib, tizimingizning qolgan qismiga yetadigan ikkita Omarchy kengaytmasi bilan birga keladi.

**Copy URL** joriy varaq manzilini `Alt + Shift + L` bilan almashish buferingizga joylaydi. Bu manzil satriga bosib, nusxa olishdan tezroq, va u brauzernikidan emas, tizim almashish buferi orqali o'tgani uchun, siz uni tasdiqlovchi Omarchy bildirishnomasini olasiz va URL darhol [almashish buferi tarixi](08-unified-clipboard-history.md) da va boshqa har bir ilovada mavjud bo'ladi. Agar bosishni afzal ko'rsangiz, asboblar panelida tugmasi ham bor.

**Download Video** siz ko'rayotgan sahifada o'ynayotgan videoni `Alt + Shift + D` bilan oladi. U URL ni [yt-dlp](https://github.com/yt-dlp/yt-dlp) ga topshiradi, shuning uchun u YouTube dan ancha ko'proq joyda ishlaydi, va yuklab olingan fayl `~/Videos` ga tushadi. Jarayon ovoz balandligi va yorqinlik ishlatadigan o'sha ekrandagi displeyda ko'rinadi, bildirishnomalarni uyib tashlamasdan, joyida yangilanadi. Agar fayllar boshqa joyga borishini xohlasangiz, `OMARCHY_YTDLP_DIR` ni o'rnating — muhit o'zgaruvchilarini qayerga qo'yish kerakligini [FAQ](46-faq.md) da ko'ring.

Ikkala kengaytma ham Omarchy bilan kichik native messaging host orqali gaplashadi, u siz uchun brauzer bilan birga o'rnatiladi. Aynan shu qism veb-sahifadagi videoning uy katalogingizga tushishiga va URL ning almashish buferi menejeringizga tushishiga imkon beradi, oddiy kengaytma buni o'zi qila olmaydi.

Bular faqat Chromium oilasi uchun. Firefox va Zen ularni olmaydi.

## Firefox va Zen

Firefox va Zen boshqa oila, shuning uchun ularga boshqacha munosabatda bo'linadi: Omarchy oqilona standartlar uchun policies faylini o'rnatadi va ularni native Wayland rejimiga o'tkazadi, bu sizga kasrli masshtablash va trackpad da silliq aylantirish uchun kerak.

Ular yuqoridagi Chromium kengaytmalarini olmaydi va Omarchy tomonidan mavzulashtirilmaydi, shuning uchun tajribaning o'sha qismlarini sozlash sizning zimmangizda.

## Birini yana olib tashlash

Bu brauzerlarning har biri, Chrome ham shu jumladan, _Remove > Browser_ ostida yana olib tashlanishi mumkin. Keyin, agar ikkinchisi hali o'rnatilgan bo'lsa, havolalar Chrome yoki Chromium ga boradi.
