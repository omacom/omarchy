# Brauzerlar

Omarchy standart brauzer sifatida [Chromium](https://www.chromium.org/) bilan keladi. Bu tizimingizning qolgan qismiga mos mavzulashtirilgan oddiy ochiq manbali yigʻma va u `Super + Shift + Return` ochadigan narsa hamda har bir [veb-ilova](25-web-apps.md) ichida ishlaydigan narsadir.

Agar Chromium didingizga toʻgʻri kelmasa, unga bogʻlanib qolmaysiz. Omarchy menyusidagi _Oʻrnatish > Browser_ ostida Chrome, Edge, Brave, Brave Origin, Firefox va [Zen](https://zen-browser.app/) ni topasiz. Bittasini tanlang va Omarchy uni oʻrnatadi, uning siyosat katalogini sozlaydi va joriy mavzungizni unga qoʻllaydi.

## Bittasini standart qilish

Brauzerni oʻrnatish uni koʻtarmaydi. U mashinaga tushgach, _Sozlash > Defaults > Browser_ ga oʻting va uni tanlang — menyu faqat sizda haqiqatan oʻrnatilgan brauzerlarni roʻyxat qiladi va joriy standartni belgi bilan belgilaydi.

Terminaldan u shunday:

```bash
omarchy default browser firefox
```

Uni argumentsiz ishga tushiring va u joriy standartni aytadi. Bu XDG ishlovchisini belgilaydi, shuning uchun faqat Omarchy ning tezkor tugmalari ergashmaydi — chat ilovasidan terminal buyrugʻigacha havolani ochadigan har qanday narsa siz tanlagan brauzerga boradi.

## URL dan nusxa olish va videoni yuklab olish

Chromium oilasidagi brauzerlar (Chromium ning oʻzi, Chrome, Edge va Brave) brauzerdan tashqariga va tizimingizning qolgan qismiga chiqadigan ikkita Omarchy kengaytmasi bilan keladi.

**Copy URL** joriy varaqning manzilini `Alt + Shift + L` bilan almashish buferingizga qoʻyadi. Bu manzil qatoriga bosib nusxa olishdan tezroqdir va u brauzerniki oʻrniga tizim almashish buferi orqali oʻtganligi sababli, siz uni tasdiqlovchi Omarchy bildirishnomasini olasiz va URL darhol [bufer tarixi](08-unified-clipboard-history.md) va har bir boshqa ilovada mavjud boʻladi. Agar bosishni afzal koʻrsangiz, asboblar paneli tugmasi ham bor.

**Download Video** `Alt + Shift + D` bilan siz qarab turgan sahifada ijro etilayotgan videoni olib keladi. U URL ni [yt-dlp](https://github.com/yt-dlp/yt-dlp) ga topshiradi, shuning uchun u YouTube dan ancha koʻp narsada ishlaydi va yuklab olish `~/Videos` ga tushadi. Jarayon ovoz va yorqinlik ishlatadigan oʻsha ekrandagi displeyda paydo boʻladi, bildirishnomalarni toʻplab yubormasdan joyida yangilanadi. Agar fayllar boshqa joyga borishini istasangiz, `OMARCHY_YTDLP_DIR` ni belgilang — muhit oʻzgaruvchilarini qayerga qoʻyish uchun [FAQ](46-faq.md) ga qarang.

Ikkala kengaytma ham brauzer bilan birga siz uchun oʻrnatiladigan kichik native xabar almashish hosti orqali Omarchy bilan gaplashadi. Bu veb-sahifaning videosini uy kataloggingizga va URL ni almashish buferi boshqaruvchingizga tushirish imkonini beruvchi qism boʻlib, oddiy kengaytma oʻz-oʻzidan buni qila olmaydi.

Bular faqat Chromium oilasi uchun. Firefox va Zen ularni olmaydi.

## Firefox va Zen

Firefox va Zen boshqa oila, shuning uchun ular boshqa munosabat oladi: Omarchy oqilona standartlar uchun siyosatlar faylini oʻrnatadi va ularni native Wayland rejimiga oʻtkazadi, buni siz kasr miqyoslash va sensor panelning silliq aylantirishi uchun xohlaysiz.

Ular yuqoridagi Chromium kengaytmalarini olmaydi va ular Omarchy tomonidan mavzulashtirilmaydi, shuning uchun tajribaning oʻsha qismlari siz sozlaysiz.

## Bittasini yana olib tashlash

Bu yerda oʻrnatgan har qanday narsa _Olib tashlash > Browser_ ostida qaytarib olinishi mumkin. Chromium oʻsha roʻyxatda emas — u asosiy tizimning bir qismidir.
