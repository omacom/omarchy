# Brauzerlar

Omarchy standart brauzer sifatida [Google Chrome](https://www.google.com/chrome/) bilan birga keladi. U tizimingizning qolgan qismiga moslab mavzulashtirilgan va aynan uni `Super + Shift + Return` (yoki `Super + Shift + B`) ochadi, `Super + Shift + Alt + B` esa shaxsiy oyna uchun, shuningdek har bir [veb-ilova](25-web-apps.md) uning ichida ishlaydi. U toʻgʻridan-toʻgʻri brauzer oynasida ochiladi: hech qanday xush kelibsiz ekrani yoki hisobga kirish soʻrovi yoʻq, foydalanish statistikasi va nosozlik hisobotlari Googleʼga yuborilmaydi, reklama maxfiyligi soʻrovlari esa oʻchirilgan. Sinxronlashni xohlaganingizda profil tugmasi orqali Google hisobingizga baribir kirishingiz mumkin.

Agar Chrome sizning didingizga mos kelmasa, unga bogʻlanib qolgansiz yoʻq. Omarchy menyusidagi _Oʻrnatish > Brauzer_ boʻlimida [Chromium](https://www.chromium.org/) (Chrome yaratilgan oddiy ochiq manbali talqin), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/) va [Ladybird](https://ladybird.org/) ni topasiz (Edge faqat x86 mashinalarida). Birini tanlang, Omarchy uni oʻrnatadi, uning siyosat katalogini sozlaydi va unga joriy mavzuingizni qoʻllaydi.

## Birini standart qilish

Brauzerni oʻrnatish uni standartga aylantirmaydi. Almashtirish uchun _Sozlash > Standartlar > Brauzer_ boʻlimiga oʻting va birini tanlang. Joriy standart katakcha bilan belgilangan, hali sizda yoʻq brauzerni tanlasangiz, u avval oʻrnatiladi.

Terminaldan bu shunday:

```bash
omarchy default browser firefox
```

Uni argumentsiz ishga tushiring, u sizga joriy standartni aytadi. Bu XDG ishlovchisini oʻrnatadi, shuning uchun faqat Omarchy tezkor tugmalari unga moslashmaydi — havolani ochadigan har qanday narsa, chat ilovasidan terminal buyrugʻigacha, siz tanlagan brauzerga oʻtadi.

## Copy URL va Download Video

Chromium oilasidagi brauzerlar (Chromiumʼning oʻzi, Chrome, Edge, Brave va Brave Origin) uchta Omarchy kengaytmasi bilan birga keladi: ikkitasi brauzerdan tashqariga chiqib, tizimingizning qolgan qismiga ulanadi, bittasi esa WhatsAppʼni tartibga soladi.

**Copy URL** joriy varaq manzilini `Alt + Shift + L` bilan buferingizga joylaydi. Bu manzil satrini bosib nusxalashdan tezroq, va u brauzer buferi orqali emas, tizim buferi orqali oʻtgani uchun, siz uni tasdiqlovchi Omarchy bildirishnomasini olasiz va URL darhol [bufer tarixi](08-unified-clipboard-history.md) da va har bir boshqa ilovada mavjud boʻladi. Agar bosishni afzal koʻrsangiz, asboblar paneli tugmasi ham bor.

**Download Video** siz koʻrayotgan sahifada ijro etilayotgan videoni `Alt + Shift + D` bilan oladi. U URLʼni [yt-dlp](https://github.com/yt-dlp/yt-dlp) ga topshiradi, shuning uchun u YouTubeʼdan ancha koʻp joyda ishlaydi, va yuklab olish `~/Videos` ga tushadi. Jarayon ovoz balandligi va yorqinligi ishlatadigan oʻsha ekrandagi displeyda koʻrinadi, bildirishnomalarni uyib tashlamasdan, joyida yangilanadi. Agar fayllar boshqa joyga tushishini xohlasangiz, `OMARCHY_YTDLP_DIR` ni oʻrnating — muhit oʻzgaruvchilarini qayerga qoʻyishni [FAQ](46-faq.md) da koʻring.

Ikkala kengaytma ham Omarchy bilan kichik mahalliy xabarlar xosti orqali gaplashadi, u siz uchun brauzer bilan birga oʻrnatiladi. Aynan shu qism veb-sahifadagi videoning uy katalogingizga tushishiga va URLʼning bufer boshqaruvchingizga tushishiga imkon beradi, oddiy kengaytma buni oʻzi qila olmaydi.

**WhatsApp Slim** WhatsApp Webʼni tizim mavzuingizga ergashishga majbur qiladi va oyna tor boʻlganda uning chatlar roʻyxatini yigʻadi.

Bular faqat Chromium oilasi uchun. Firefox va Zen ularni olmaydi.

## Firefox va Zen

Firefox va Zen boshqa oila, shuning uchun ularga boshqacha munosabat qilinadi: Omarchy oqilona standartlar uchun siyosatlar faylini oʻrnatadi va ularni mahalliy Wayland rejimiga oʻtkazadi, bu sizga kasrli masshtablash va trekpedda silliq aylantirish uchun kerak.

Ularda yuqoridagi Chromium kengaytmalari berilmaydi, va ular Omarchy tomonidan mavzulashtirilmaydi, shuning uchun tajribaning oʻsha qismlarini oʻzingiz sozlashingiz kerak.

## Ladybird

Ladybird — noldan yozilgan brauzer, Chromium yoki Firefox dvijoki oʻrniga oʻz dvijokiga ega. U hali alfa bosqichida, shuning uchun hali ishlamaydigan saytlarni kuting, va Omarchy uni boricha oʻrnatadi: kengaytmalarsiz, mavzusiz, siyosatlarsiz. Unda shaxsiy oyna ham yoʻq, shuning uchun `Super + Shift + Alt + B` uni yopganingizda oʻchiriladigan vaqtinchalik profil bilan ochadi. [Veb-ilovalar](25-web-apps.md) Chrome yoki Chromiumʼda ishlashda davom etadi.

## Birini yana olib tashlash

Bu brauzerlarning har biri, Chrome ham shu jumladan, _Olib tashlash > Brauzer_ boʻlimida yana olib tashlanishi mumkin. Agar ikkinchisi hali oʻrnatilgan boʻlsa, havolalar keyin Chrome yoki Chromiumʼga oʻtadi.
