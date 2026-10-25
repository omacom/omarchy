# Skrinshotlar va yozib olish

Ekrandan olish mumkin bo‘lgan hamma narsa Print Screen tugmasiga bog‘langan. Tugmaning o‘zi rasm oladi, modifikatorlar esa yozuv, rang yoki hudud ichidagi matnni oladi. Agar klaviaturangizda umuman Print Screen tugmasi bo‘lmasa, `Super + Ctrl + Alt + C` xuddi shu skrinshotni oladi, `Super + Ctrl + C` esa butun to‘plamni menyu sifatida ochadi.

| Tugmalar birikmasi | Vazifasi |
| ------ | -------- |
| `Print Screen` | Skrinshot |
| `Super + Ctrl + Alt + C` | Skrinshot |
| `Alt + Print Screen` | Ekranni yozib olish (yoki ishlayotganini to‘xtatish) |
| `Super + Print Screen` | Rang tanlagich |
| `Super + Ctrl + Print Screen` | Hududdan matn ajratib olish |
| `Super + Ctrl + C` | Tasvirga olish menyusi |
| `Super + Ctrl + .` | Rasm yoki videoni transkodlash |

## Skrinshotlar

`Print Screen` (yoki `Super + Ctrl + Alt + C`) ni bosing va Omasnap uning qoplamasi paydo bo‘lishidan oldin fokusdagi monitorni tasvirga oladi, shuning uchun nishan olayotganingizda hech narsa ostingizda siljib ketmaydi. Erkin shakldagi hududni tortib belgilang, oynani tasvirga olish uchun uni bosing yoki butun monitorni tasvirga olish uchun bo‘sh joyni bosing. Aylantiriladigan hududni tasvirga olish uchun chizishdan oldin `S` ni bosing. Fikringiz o‘zgardimi? Omasnap ni yopish uchun xuddi shu tugmani yana bosing.

Hududni tanlaganingizdan keyin Omasnap tasvirni saqlaydi, uni buferga nusxalaydi va uning eskizi bilan bildirishnoma ko‘rsatadi, xuddi saqlangan ekran yozuvida bo‘lgani kabi. Saqlangan tasvirni rasm ko‘ruvchingizda ko‘rish uchun Open ni, unga izoh qo‘shish uchun Edit ni tanlang.

Izoh muharriri o‘qlar, chiziqlar, shakllar, ajratib ko‘rsatishlar, raqamlangan belgilar, matn va xavfsiz tahrirlarni chizishi; tasvirning bir qismini kesib olishi yoki qirqishi; uning matnini OCR qilishi; va orqa fon qo‘shishi mumkin. Muharrirda tayyor PNG ni nusxalash va saqlash uchun `Enter` ni, saqlamasdan nusxalash uchun `Ctrl + C` ni yoki nusxalamasdan saqlash uchun `Ctrl + S` ni bosing.

Saqlangan skrinshotlar sukut bo‘yicha `~/Pictures/Screenshots` ga tushadi va `screenshot-2026-08-13_14-22-05-firefox.png` kabi nomga ega bo‘ladi. Boshqa katalog ishlatish uchun `OMASNAP_SCREENSHOT_DIR` ni o‘rnating — sessiya muhit o‘zgaruvchilarini qayerga qo‘yishni bilish uchun [tez-tez beriladigan savollar](46-faq.md) ga qarang. Omasnap birinchi tasvirni saqlaganda katalogni yaratadi. Avtomatik saqlashni o‘chirish uchun `~/.config/omasnap/omasnap.conf` da `[output] autosave = false` ni o‘rnating; tasvirlar u holda faqat nusxalanadi va 10 soniya davomida oldindan ko‘rishda ko‘rsatiladi, uni pin tugmasi yoki `Ctrl + P` bilan ekranda ushlab qolishingiz mumkin.

Terminaldan `omarchy screenshot` xuddi shu qoplamani ochadi va siz uning boshlang‘ich rejimini tanlashingiz mumkin: `omarchy capture screenshot region`, `windows`, `fullscreen` yoki `scroll`. `copy` yoki `save` dan iborat ikkinchi argument tasvirni to‘g‘ridan-to‘g‘ri o‘sha manzilga yuboradi. Chiqarishdan oldin tahrirlash uchun to‘liq ekran muharriri uchun `omarchy screenshot --editor=overlay` dan yoki alohida oyna uchun `omarchy screenshot --editor=window` dan foydalaning.

### Tanlagichni klaviaturadan boshqarish

Tanlash ochiq bo‘lganda sichqonchani umuman ishlatishingiz shart emas:

| Tugma | Vazifasi |
| --- | -------- |
| `S` | Aylantiriladigan hudud rejimini yoqish/o‘chirish |
| `Super + Arrow keys` | Window rejimida oynalar orasida harakatlanish |
| `Return` | Ajratilgan oynani tasvirga olish |
| `Ctrl + A` | To‘liq fokusdagi monitorni tasvirga olish |
| `R` | Ushbu sessiyada chizilgan oxirgi hududni tiklash |
| `Esc` | Omasnap ni yopish |

Bu bog‘lamlar faqat Omasnap ochiq bo‘lganda mavjud, shuning uchun ular o‘z konfiguratsiyangizdagi hech narsa bilan to‘qnasha olmaydi.

## Ekranni yozib olish

`Alt + Print Screen` _Trigger > Capture > Screenrecord_ ni ochadi, u ovoz yo‘liga nimani xohlashingizni so‘raydi: audiosiz, ish stoli audiosi, ish stoli plyus mikrofon yoki ish stoli plyus mikrofon plyus veb-kamera. Oxirgisi faqat kamerangiz haqiqatan ulangan bo‘lsa paydo bo‘ladi. Bittasini tanlang va Omarchy ning yozib olish tanlagichi hududni tortib belgilashga yoki oyna yoxud monitorni bosishga imkon beradi.

Yozib olish gpu-screen-recorder da ishlaydi, u GPU da 60fps da kodlaydi va zarur bo‘lsa CPU ga qaytadi. Natija `~/Videos` dagi MP4 bo‘ladi va `screenrecording-2026-08-13_14-22-05.mp4` deb nomlanadi. Buni o‘zgartirish uchun `OMARCHY_SCREENRECORD_DIR` ni o‘rnating — lekin shuni yodda tutingki, skrinshot katalogidan farqli o‘laroq, bu katalog allaqachon mavjud bo‘lishi kerak, aks holda yozib olish boshlanishdan bosh tortadi.

Yozib olayotganingizda panelda kichkina indikator paydo bo‘ladi. To‘xtatish uchun uni bosing. Shuningdek, `Alt + Print Screen` ni yana bosib to‘xtatishingiz mumkin yoki _Trigger > Capture > Screenrecord_ ostidagi _Stop Screenrecording_ yozuvi bilan to‘xtatishingiz mumkin, u faqat biror narsa haqiqatan yozib olinayotganda paydo bo‘ladi.

To‘xtatish faylni sizga berishdan oldin biroz tartibga soladi: birinchi kadr kesib tashlanadi va agar audio bo‘lsa, u -14 LUFS ga normallashtiriladi, eng boshidagi PipeWire tasvirga olish shovqini ovozsiz qilinadi. Keyin yozuvdan olingan eskiz bilan bildirishnoma paydo bo‘ladi. Faylni mpv da ijro etish uchun uni bosing.

### Veb-kamera qoplamasi

Veb-kamera bilan yozib olganingizda kamera yozib olayotgan narsangizning pastki o‘ng burchagida mahkamlangan, qirqilgan portret oynasi sifatida paydo bo‘ladi. Agar u kerakli narsaning ustida turgan bo‘lsa, uni shu zahoti o‘lchamini o‘zgartiring:

| Tugmalar birikmasi | Vazifasi |
| ------ | -------- |
| `Super + Alt + [` | Veb-kamera qoplamasini kichraytirish |
| `Super + Alt + ]` | Veb-kamera qoplamasini kattalashtirish |

Uchta o‘lcham bor — kichik, o‘rta va katta — va tugmalar birikmalari ular orasida qadam tashlaydi. O‘rta sukut bo‘yicha hisoblanadi. Ular yozuvga mutanosib, shuning uchun 1080p monitorni yoki 6K monitorni yozib olishingizdan qat’i nazar, kamera kadrning bir xil ulushini egallaydi. Va agar siz butun displey o‘rniga hududni yozib olgan bo‘lsangiz, qoplama monitor burchagiga emas, o‘sha hududning burchagiga tayanadi, shuning uchun u tasvir ichida qoladi.

Uni `omarchy-capture-webcam-resize small` bilan ham to‘g‘ridan-to‘g‘ri chaqirishingiz mumkin, yoki o‘rta holatga qaytish uchun `reset` bilan.

## Matn, QR kodlar va ranglar

`Super + Ctrl + Print Screen` hududni tanlaydi va uni buferga OCR qiladi. Bu [Matn ajratib olish va diktovka](11-text-extraction-dictation.md) da to‘g‘ri yoritilgan.

_Trigger > Capture > QR Code_ QR kodlar uchun xuddi shu hiylani qiladi. Ichida kod bor hududni tanlang va dekodlangan qiymat buferga o‘tadi. U faqat QR kodlarni qidiradi — aks holda zich ekran mazmuni shtrix-kod sifatida noto‘g‘ri aniqlanish odatiga ega. Bilish arziydi: dekodlangan qiymat buferga o‘tadi va boshqa hech qayerga o‘tmaydi. U chop etilmaydi, bildirishnomada yo‘q va [bufer tarixi](08-unified-clipboard-history.md) da qolib ketmasligi uchun maxfiy deb belgilangan. QR kodlar odatda sirlarni tashiydi — masalan, 2FA o‘rnatish kodi ortidagi `otpauth://` URI — va siz buni jurnalda qolishini xohlamaysiz. Joylashtirish baribir yaxshi ishlaydi.

`Super + Print Screen` (yoki _Trigger > Capture > Color_) kursorni tomizg‘ichga aylantiradi. Ekrandagi istalgan narsani bosing va rang buferga tushadi. Tanlamasdan chiqish uchun tugmalar birikmasini yana bosing.

## Ulashishdan oldin transkodlash

4K ekran yozuvi yoki telefoningizdan olingan xom HEIC ko‘pincha shunchaki yuborish uchun juda katta bo‘ladi. `Super + Ctrl + .` (yoki _Trigger > Transcode_) buni tuzatadi. U sizga `~/Pictures` va `~/Videos` ustidan noaniq fayl tanlagichni taklif qiladi, keyin format va o‘lcham so‘raydi.

Rasmlar yuqori, o‘rta yoki past darajada jpg yoki png ga o‘tadi, ular kenglikni 3160, 2160 va 1080 pikselda cheklaydi. Videolar 4k, 1080p yoki 720p da mp4 yoki animatsiyalangan gif ga o‘tadi. O‘zgartirilgan fayl asl fayl yoniga nomi ichida o‘lchami bilan yoziladi — `demo-1080p.mp4` — va yo‘l fayl URI si sifatida buferga nusxalanadi, shuning uchun uni fayllarni tashlashni qabul qiladigan ilovaga to‘g‘ridan-to‘g‘ri joylashtirishingiz mumkin.

Bu terminaldan ham ishlaydi, agar nimani xohlashingizni allaqachon bilsangiz: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Shuningdek, `omarchy transcode ascii` ham bor, u tasvirni ASCII art ga aylantiradi — u asosan [brending](41-branding.md) uchun.

## Uni biror joyga yuborish

Faylni olganingizdan keyin `Super + Ctrl + S` Share menyusini ochadi va uni LocalSend orqali tarmog‘ingizdagi boshqa qurilmaga yuboradi. Buning uchun [GUIs](22-guis.md) ga qarang.
