# Skrinshotlar va yozib olish

Ekrandan olib bo‘ladigan hamma narsa Print Screen tugmasi atrofida aylanadi. Tugmaning o‘zi rasm oladi, modifikatorlar esa yozuv, rang yoki hudud ichidagi matnni oladi. Agar klaviaturangizda Print Screen tugmasi umuman bo‘lmasa, `Super + Ctrl + Alt + C` xuddi shu skrinshotni oladi, `Super + Ctrl + C` esa butun to‘plamni menyu sifatida ochadi.

| Hotkey | Function |
| ------ | -------- |
| `Print Screen` | Skrinshot |
| `Super + Ctrl + Alt + C` | Skrinshot |
| `Alt + Print Screen` | Ekran yozuvi (yoki ishlayotganini to‘xtatish) |
| `Super + Print Screen` | Rang tanlagich |
| `Super + Ctrl + Print Screen` | Hududdan matn ajratib olish |
| `Super + Ctrl + C` | Capture menyusi |
| `Super + Ctrl + .` | Rasm yoki videoni qayta kodlash |

## Skrinshotlar

`Print Screen` (yoki `Super + Ctrl + Alt + C`) tugmasini bosing va Omasnap uning qoplamasi paydo bo‘lishidan oldin fokusdagi monitorni oladi, shuning uchun nishon olayotganingizda hech narsa ostingizda siljimaydi. Erkin shakldagi hududni tortib tanlang, oynani bosib uni oling yoki bo‘sh joyni bosib butun monitorni oling. Aylanadigan hududni olish uchun chizishdan oldin `S` tugmasini bosing. Fikringizdan qaytdingizmi? Omasnap-ni yopish uchun xuddi shu tugmani yana bosing.

Hududni tanlaganingizdan keyin Omasnap olingan tasvirni saqlaydi, uni buferga nusxalaydi va 10 soniya davomida oldindan ko‘rinishni ko‘rsatadi. Uni ekranda qoldirish uchun oldindan ko‘rinishdagi mahkamlash tugmasini yoki `Ctrl + P` tugmasini ishlating, izoh qo‘shish uchun esa Edit-ni tanlang.

Izoh muharriri strelkalar, chiziqlar, shakllar, ajratib ko‘rsatishlar, raqamlangan belgilar, matn va xavfsiz yashirishlar chizishi; tasvirning bir qismini kesib olishi yoki qirqishi; uning matnini OCR qilishi; va orqa fon qo‘shishi mumkin. Muharrirda tayyor PNG-ni nusxalash va saqlash uchun `Enter` tugmasini, saqlamasdan nusxalash uchun `Ctrl + C` tugmasini yoki nusxalamasdan saqlash uchun `Ctrl + S` tugmasini bosing.

Saqlangan skrinshotlar sukut bo‘yicha `~/Pictures/Screenshots` ichiga tushadi, masalan `screenshot-2026-08-13_14-22-05-firefox.png` kabi nom bilan. Boshqa katalog ishlatish uchun `OMASNAP_SCREENSHOT_DIR` ni o‘rnating — sessiya muhit o‘zgaruvchilarini qayerga qo‘yishni [tez-tez beriladigan savollar](46-faq.md) dan ko‘ring. Omasnap birinchi tasvirni saqlaganda katalogni yaratadi. Avtomatik saqlashni o‘chirish uchun `~/.config/omasnap/omasnap.conf` ichida `[output] autosave = false` ni o‘rnating.

Terminaldan `omarchy screenshot` xuddi shu qoplamani ochadi va siz uning boshlang‘ich rejimini tanlashingiz mumkin: `omarchy capture screenshot region`, `windows`, `fullscreen` yoki `scroll`. `copy` yoki `save` dan iborat ikkinchi argument oldindan ko‘rinishni o‘tkazib yuboradi va tasvirni to‘g‘ridan-to‘g‘ri o‘sha manzilga yuboradi. Chiqarishdan oldin tahrirlash uchun to‘liq ekran muharriri uchun `omarchy screenshot --editor=overlay` ni yoki alohida oyna uchun `omarchy screenshot --editor=window` ni ishlating.

### Tanlagichni klaviaturadan boshqarish

Tanlash ochiq turganda sichqonchani umuman ishlatishingiz shart emas:

| Key | Function |
| --- | -------- |
| `S` | Aylanadigan hudud rejimini yoqish/o‘chirish |
| `Super + Arrow keys` | Window rejimida oynalar orasida harakatlanish |
| `Return` | Ajratib ko‘rsatilgan oynani olish |
| `Ctrl + A` | To‘liq fokusdagi monitorni olish |
| `R` | Ushbu sessiyada chizilgan oxirgi hududni tiklash |
| `Esc` | Omasnap-ni yopish |

Bu bog‘lanishlar faqat Omasnap ochiq bo‘lgandagina mavjud, shuning uchun ular o‘z konfiguratsiyangizdagi hech narsa bilan to‘qnashmaydi.

## Ekran yozuvi

`Alt + Print Screen` _Trigger > Capture > Screenrecord_ ni ochadi, u sizdan saundtrekda nima bo‘lishini so‘raydi: audio yo‘q, ish stoli audiosi, ish stoli va mikrofon, yoki ish stoli va mikrofon va veb-kamera. Oxirgisi faqat kamerangiz haqiqatan ham ulangan bo‘lsagina ko‘rinadi. Bittasini tanlang va Omarchy yozuv tanlagichi sizga hududni tortib tanlash yoki oyna yoki monitorni bosish imkonini beradi.

Yozuv gpu-screen-recorder da ishlaydi, u GPU da 60fps da kodlaydi va zarur bo‘lsa CPU ga qaytadi. Natija `~/Videos` ichidagi MP4 bo‘ladi, `screenrecording-2026-08-13_14-22-05.mp4` deb nomlanadi. Buni o‘zgartirish uchun `OMARCHY_SCREENRECORD_DIR` ni o‘rnating — lekin shuni yodda tutingki, skrinshot katalogidan farqli o‘laroq, bu katalog allaqachon mavjud bo‘lishi kerak, aks holda yozuv boshlanishdan bosh tortadi.

Yozayotganingizda panelda kichkina ko‘rsatkich paydo bo‘ladi. To‘xtatish uchun uni bosing. Yana `Alt + Print Screen` bilan ham to‘xtatishingiz mumkin, yoki _Trigger > Capture > Screenrecord_ ostidagi _Stop Screenrecording_ yozuvi bilan, u faqat nimadir haqiqatan ham yozilayotgandagina paydo bo‘ladi.

To‘xtatish faylni sizga berishdan oldin ozgina tartibga soladi: birinchi kadr qirqib tashlanadi va agar audio bo‘lsa, u -14 LUFS ga normallashtiriladi, eng boshidagi PipeWire olish shovqini o‘chirib qo‘yiladi. Keyin yozuvdan eskiz bilan bildirishnoma paydo bo‘ladi. Faylni mpv da ijro etish uchun uni bosing.

### Veb-kamera qoplamasi

Veb-kamera bilan yozganingizda kamera yozayotgan narsangizning pastki o‘ng burchagida mahkamlangan, qirqilgan portret oyna sifatida paydo bo‘ladi. Agar u sizga kerakli narsaning ustida turgan bo‘lsa, uni joyida o‘lchamini o‘zgartiring:

| Hotkey | Function |
| ------ | -------- |
| `Super + Alt + [` | Veb-kamera qoplamasini kichraytirish |
| `Super + Alt + ]` | Veb-kamera qoplamasini kattalashtirish |

Uchta o‘lcham bor — kichik, o‘rta va katta — va tezkor tugmalar ular orasida qadam tashlaydi. O‘rta sukut bo‘yicha ishlatiladi. Ular yozuvga mutanosib, shuning uchun kamera 1080p monitorni yoki 6K monitorni yozishingizdan qat’i nazar, kadrning bir xil ulushini egallaydi. Va agar siz butun displey o‘rniga hududni yozgan bo‘lsangiz, qoplama monitor burchagiga emas, o‘sha hudud burchagiga mahkamlanadi, shuning uchun u tasvir ichida qoladi.

Uni to‘g‘ridan-to‘g‘ri `omarchy-capture-webcam-resize small` bilan ham chaqirishingiz mumkin, yoki o‘rtaga qaytish uchun `reset` bilan.

## Matn, QR kodlar va ranglar

`Super + Ctrl + Print Screen` hududni tanlaydi va uni OCR qilib buferga oladi. Bu [Matn ajratib olish va diktovka](11-text-extraction-dictation.md) da to‘g‘ri yoritilgan.

_Trigger > Capture > QR Code_ QR kodlar uchun xuddi shu hiylani qiladi. Ichida kod bor hududni tanlang va dekodlangan qiymat buferga o‘tadi. U faqat QR kodlarni qidiradi — aks holda zich ekran mazmuni shtrix-kod sifatida noto‘g‘ri tanilish odatiga ega. Bilish arziydi: dekodlangan qiymat buferga boradi va boshqa hech qayerga bormaydi. U chop etilmaydi, bildirishnomada yo‘q va [bufer tarixi](08-unified-clipboard-history.md) da qolib ketmasligi uchun sezgir deb belgilangan. QR kodlar muntazam ravishda sirlarni tashiydi — masalan, 2FA sozlash kodi ortidagi `otpauth://` URI — va siz buni jurnalda bo‘lishini xohlamaysiz. Qo‘yish baribir yaxshi ishlaydi.

`Super + Print Screen` (yoki _Trigger > Capture > Color_) kursorni tomizg‘ichga aylantiradi. Ekrandagi istalgan narsani bosing va rang buferga tushadi. Tanlamasdan chiqish uchun tezkor tugmani yana bosing.

## Ulashishdan oldin qayta kodlash

4K ekran yozuvi yoki telefoningizdan olingan xom HEIC ko‘pincha shunchaki yuborish uchun juda katta bo‘ladi. `Super + Ctrl + .` (yoki _Trigger > Transcode_) buni tuzatadi. U sizga `~/Pictures` va `~/Videos` ustida loyqa fayl tanlagichni taklif qiladi, keyin format va o‘lchamni so‘raydi.

Rasmlar kengligi 3160, 2160 va 1080 piksel bilan cheklanadigan high, medium yoki low da jpg yoki png ga o‘tadi. Videolar 4k, 1080p yoki 720p da mp4 yoki animatsiyalangan gif ga o‘tadi. O‘zgartirilgan fayl asl nusxaning yoniga nomida o‘lchami bilan yoziladi — `demo-1080p.mp4` — va yo‘l fayl URI si sifatida buferga nusxalanadi, shuning uchun uni fayl tashlashni qabul qiladigan ilovaga to‘g‘ridan-to‘g‘ri qo‘yishingiz mumkin.

Bu terminaldan ham ishlaydi, agar nima xohlayotganingizni allaqachon bilsangiz: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Yana `omarchy transcode ascii` ham bor, u tasvirni ASCII art ga aylantiradi — bu asosan [brending](41-branding.md) uchun.

## Uni biror joyga yuborish

Faylni olganingizdan keyin `Super + Ctrl + S` Share menyusini ochadi va uni LocalSend orqali tarmog‘ingizdagi boshqa qurilmaga yuboradi. Buning uchun [GUIlar](22-guis.md) ga qarang.
