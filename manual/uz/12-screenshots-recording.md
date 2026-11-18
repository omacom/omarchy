# Skrinshotlar va yozib olish

Ekrandan olinadigan hamma narsa Print Screen tugmasiga bog‘langan. Bitta tugmaning o‘zi rasm oladi, qo‘shimcha tugmalar esa yozuv, rang yoki hudud ichidagi matnni oladi. Agar klaviaturangizda Print Screen tugmasi umuman bo‘lmasa, `Super + Ctrl + Alt + C` xuddi shu skrinshotni oladi, `Super + Ctrl + C` esa butun to‘plamni menyu sifatida ochadi.

| Tugmalar birikmasi | Funksiya |
| ------ | -------- |
| `Print Screen` | Skrinshot |
| `Super + Ctrl + Alt + C` | Skrinshot |
| `Alt + Print Screen` | Ekranni yozib olish (yoki ishlayotgan yozuvni to‘xtatish) |
| `Super + Print Screen` | Rang tanlagich |
| `Super + Ctrl + Print Screen` | Hududdan matn ajratib olish |
| `Super + Ctrl + C` | Suratga olish menyusi |
| `Super + Ctrl + .` | Rasm yoki videoni qayta kodlash |

## Skrinshotlar

`Print Screen` (yoki `Super + Ctrl + Alt + C`) tugmasini bosing va Omasnap uning qatlami paydo bo‘lishidan oldin fokusdagi monitorni suratga oladi, shu sababli nishonga olayotganingizda hech narsa ostingizda siljimaydi. Erkin shakldagi hududni tortib tanlang, suratga olish uchun oynani bosing yoki butun monitorni suratga olish uchun bo‘sh joyni bosing. Aylanadigan hududni suratga olish uchun chizishdan oldin `S` tugmasini bosing. Fikringizdan qaytdingizmi? Omasnap ni yopish uchun xuddi shu tugmani yana bosing.

Hududni tanlaganingizdan keyin Omasnap suratni saqlaydi, uni almashuv buferiga nusxalaydi va saqlangan ekran yozuvidagi kabi uning eskizi bilan bildirishnoma ko‘rsatadi. Saqlangan suratni rasm ko‘ruvchingizda ko‘rish uchun Open ni, unga izoh qo‘shish uchun Edit ni tanlang.

Izoh muharriri strelkalar, chiziqlar, shakllar, ajratib ko‘rsatishlar, raqamlangan belgilar, matn va xavfsiz tahrirlarni chizishi; tasvirning bir qismini kesib olishi yoki qirqishi; uning matnini OCR qilishi; va orqa fon qo‘shishi mumkin. Muharrirda tugallangan PNG ni nusxalash va saqlash uchun `Enter` ni, saqlamasdan nusxalash uchun `Ctrl + C` ni yoki nusxalamasdan saqlash uchun `Ctrl + S` ni bosing.

Saqlangan skrinshotlar odatiy holatda `~/Pictures/Screenshots` ga tushadi va `screenshot-2026-08-13_14-22-05-firefox.png` kabi nomga ega bo‘ladi. Boshqa katalogdan foydalanish uchun `OMASNAP_SCREENSHOT_DIR` ni o‘rnating — seans muhit o‘zgaruvchilarini qayerga yozishni [tez-tez beriladigan savollar](46-faq.md) bo‘limidan ko‘ring. Omasnap birinchi suratni saqlaganida katalogni yaratadi. Avtomatik saqlashni o‘chirish uchun `~/.config/omasnap/omasnap.conf` da `[output] autosave = false` ni o‘rnating; suratlar u holda faqat nusxalanadi va 10 soniya davomida oldindan ko‘rishda ko‘rsatiladi, uni pin tugmasi yoki `Ctrl + P` bilan ekranda qoldirishingiz mumkin.

Terminaldan `omarchy screenshot` xuddi shu qatlamni ochadi va siz uning boshlang‘ich rejimini tanlashingiz mumkin: `omarchy capture screenshot region`, `windows`, `fullscreen` yoki `scroll`. `copy` yoki `save` degan ikkinchi argument suratni to‘g‘ridan-to‘g‘ri o‘sha manzilga yuboradi. Chiqarishdan oldin tahrirlash uchun to‘liq ekranli muharrir uchun `omarchy screenshot --editor=overlay` dan yoki alohida oyna uchun `omarchy screenshot --editor=window` dan foydalaning.

### Tanlagichni klaviaturadan boshqarish

Tanlash ochiq turganida sichqonchani umuman ishlatishingiz shart emas:

| Tugma | Funksiya |
| --- | -------- |
| `S` | Aylanadigan hudud rejimini yoqish/o‘chirish |
| `Super + Arrow keys` | Oyna rejimida oynalar orasida harakatlanish |
| `Return` | Ajratilgan oynani suratga olish |
| `Ctrl + A` | To‘liq fokusdagi monitorni suratga olish |
| `R` | Ushbu seansda chizilgan oxirgi hududni tiklash |
| `Esc` | Omasnap ni yopish |

Bu birikmalar faqat Omasnap ochiq bo‘lgandagina mavjud, shu sababli ular o‘z konfiguratsiyangizdagi hech narsa bilan to‘qnashmaydi.

## Ekranni yozib olish

`Alt + Print Screen` _Trigger > Capture > Screenrecord_ ni ochadi, u saundtrekda nima bo‘lishini so‘raydi: audio yo‘q, ish stoli audiosi, ish stoli va mikrofon yoki ish stoli, mikrofon va veb-kamera. Oxirgisi faqat sizda haqiqatan ham kamera ulangan bo‘lsagina ko‘rinadi. Bittasini tanlang va Omarchy ning yozib olish tanlagichi hududni tortib tanlashingizga yoki oyna yoxud monitorni bosishingizga imkon beradi.

Yozib olish gpu-screen-recorder da ishlaydi, u GPU da 60fps da kodlaydi va zarur bo‘lsa CPU ga qaytadi. Natija `~/Videos` dagi MP4 bo‘ladi va `screenrecording-2026-08-13_14-22-05.mp4` deb nomlanadi. Buni o‘zgartirish uchun `OMARCHY_SCREENRECORD_DIR` ni o‘rnating — lekin shuni yodda tutingki, skrinshot katalogidan farqli o‘laroq, bu katalog allaqachon mavjud bo‘lishi kerak, aks holda yozib olish boshlanishdan bosh tortadi.

Yozib olayotganingizda barda kichik ko‘rsatkich paydo bo‘ladi. To‘xtatish uchun uni bosing. Yozuvni `Alt + Print Screen` ni yana bosib yoki _Trigger > Capture > Screenrecord_ ostidagi, faqat nimadir haqiqatan yozib olinayotgandagina paydo bo‘ladigan _Stop Screenrecording_ bandi bilan ham to‘xtatishingiz mumkin.

To‘xtatish faylni sizga berishdan oldin biroz tartibga soladi: birinchi kadr qirqiladi va agar audio bo‘lsa, u -14 LUFS ga normallashtiriladi, eng boshidagi PipeWire yozib olish shovqini ovozisiz qilinadi. Keyin yozuvdan olingan eskiz bilan bildirishnoma paydo bo‘ladi. Faylni Omaview da ijro etish uchun uni bosing.

### Veb-kamera qatlami

Veb-kamera bilan yozib olganingizda kamera yozib olinayotgan narsangizning pastki o‘ng burchagida qadab qo‘yilgan, qirqilgan portret oyna sifatida paydo bo‘ladi. Agar u sizga kerakli narsaning ustida turgan bo‘lsa, uni tezda o‘lchamini o‘zgartiring:

| Tugmalar birikmasi | Funksiya |
| ------ | -------- |
| `Super + Alt + [` | Veb-kamera qatlamini kichraytirish |
| `Super + Alt + ]` | Veb-kamera qatlamini kattalashtirish |

Uchta o‘lcham bor — kichik, o‘rta va katta — va tugmalar birikmalari ular orasida qadam tashlaydi. O‘rta odatiy hisoblanadi. Ular yozuvga mutanosib, shu sababli siz 1080p monitorni yoki 6K monitorni yozib olishingizdan qat’i nazar, kamera kadrning bir xil ulushini egallaydi. Va agar siz butun displey o‘rniga hududni yozib olgan bo‘lsangiz, qatlam monitor burchagiga emas, o‘sha hudud burchagiga bog‘lanadi, shu sababli u surat ichida qoladi.

Uni `omarchy-capture-webcam-resize small` bilan to‘g‘ridan-to‘g‘ri ham chaqirishingiz yoki o‘rtaga qaytish uchun `reset` dan foydalanishingiz mumkin.

## Matn, QR kodlar va ranglar

`Super + Ctrl + Print Screen` hududni tanlaydi va uni OCR qilib almashuv buferiga oladi. Bu [Matn ajratib olish va diktovka](11-text-extraction-dictation.md) bo‘limida to‘g‘ri yoritilgan.

_Trigger > Capture > QR Code_ QR kodlar uchun xuddi shu ayyorlikni qiladi. Ichida kod bor hududni tanlang va ochilgan qiymat almashuv buferiga o‘tadi. U faqat QR kodlarni qidiradi — zich ekran tarkibi aks holda shtrix-kod sifatida noto‘g‘ri aniqlanish odatiga ega. Bilishga arziydi: ochilgan qiymat almashuv buferiga boradi va boshqa hech qayerga bormaydi. U chop etilmaydi, bildirishnomada yo‘q va sezgir deb belgilanadi, shu sababli u [almashuv buferi tarixi](08-unified-clipboard-history.md) da qolib ketmaydi. QR kodlar muntazam ravishda sirlarni tashiydi — masalan, 2FA o‘rnatish kodi ortidagi `otpauth://` URI — va siz buning jurnalda bo‘lishini istamaysiz. Joylashtirish baribir yaxshi ishlaydi.

`Super + Print Screen` (yoki _Trigger > Capture > Color_) kursorni tomizg‘ichga aylantiradi. Ekrandagi istalgan narsani bosing va rang almashuv buferiga tushadi. Tanlamasdan qaytish uchun tugmalar birikmasini yana bosing.

## Ulashishdan oldin qayta kodlash

4K ekran yozuvi yoki telefoningizdan olingan xom HEIC ko‘pincha shunchaki yuborish uchun juda katta bo‘ladi. `Super + Ctrl + .` (yoki _Trigger > Transcode_) buni tuzatadi. U sizga `~/Pictures` va `~/Videos` bo‘ylab noaniq fayl tanlagichni taklif qiladi, keyin format va o‘lchamni so‘raydi.

Rasmlar yuqori, o‘rta yoki past sifatda jpg yoki png ga o‘tadi, ular kenglikni 3160, 2160 va 1080 pikselda cheklaydi. Videolar 4k, 1080p yoki 720p da mp4 yoki jonlantirilgan gif ga o‘tadi. O‘zgartirilgan fayl asl fayl yoniga nomi bilan yoziladi — `demo-1080p.mp4` — va yo‘l almashuv buferiga fayl URI si sifatida nusxalanadi, shu sababli uni fayl tashlashlarni qabul qiladigan ilovaga to‘g‘ridan-to‘g‘ri joylashtirishingiz mumkin.

U terminaldan ham ishlaydi, agar nimani xohlayotganingizni allaqachon bilsangiz: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Shuningdek, tasvirni ASCII san’atiga aylantiradigan `omarchy transcode ascii` ham bor — u asosan [brendlash](41-branding.md) uchun.

## Uni biror joyga yuborish

Faylni olganingizdan keyin `Super + Ctrl + S` Share menyusini ochadi va uni LocalSend orqali tarmog‘ingizdagi boshqa qurilmaga yuboradi. Buning uchun [GUIlar](22-guis.md) bo‘limiga qarang.
