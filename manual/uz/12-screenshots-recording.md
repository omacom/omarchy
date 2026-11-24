# Skrinshotlar va yozib olish

Ekrandan olishingiz mumkin bo'lgan hamma narsa Print Screen tugmasiga bog'langan. Tugmaning o'zi rasm oladi, modifikatorlar esa yozuv, rang yoki hudud ichidagi matnni oladi. Agar klaviaturangizda umuman Print Screen tugmasi bo'lmasa, `Super + Ctrl + Alt + C` xuddi shu skrinshotni oladi, `Super + Ctrl + C` esa butun to'plamni menyu sifatida ochadi.

| Tezkor tugma | Vazifasi |
| ------ | -------- |
| `Print Screen` | Skrinshot |
| `Super + Ctrl + Alt + C` | Skrinshot |
| `Alt + Print Screen` | Ekran yozuvi (yoki ishlayotganini to'xtatish) |
| `Super + Print Screen` | Rang tanlagich |
| `Super + Ctrl + Print Screen` | Hududdan matn ajratib olish |
| `Super + Ctrl + C` | Tasvirga olish menyusi |
| `Super + Ctrl + .` | Rasm yoki videoni transkodlash |

## Skrinshotlar

`Print Screen` (yoki `Super + Ctrl + Alt + C`) tugmasini bosing — Omasnap o'zining ustki qatlami paydo bo'lishidan oldin fokusdagi monitorni tasvirga oladi, shunda mo'ljal olayotganingizda hech narsa tagida siljimaydi. Erkin shakldagi hududni sudrab belgilang, oynani tasvirga olish uchun uni bosing yoki butun monitorni tasvirga olish uchun ochiq joyni bosing. Aylanadigan hududni tasvirga olish uchun chizishdan oldin `S` tugmasini bosing. Fikringiz o'zgardimi? Omasnap ni yopish uchun xuddi shu tugmani yana bosing.

Hududni tanlaganingizdan so'ng, Omasnap tasvirni saqlaydi, uni almashuv buferiga nusxalaydi va saqlangan ekran yozuvidagi kabi uning eskizi bilan bildirishnoma ko'rsatadi. Saqlangan tasvirni rasm ko'ruvchingizda ko'rish uchun Open ni, unga izoh qo'shish uchun Edit ni tanlang.

Izoh muharriri strelkalar, chiziqlar, shakllar, ajratib ko'rsatishlar, raqamlangan belgilar, matn va xavfsiz tahrirlarni chizishi; rasmning bir qismini qirqishi yoki kesib olishi; uning matnini OCR qilishi; va fon qo'shishi mumkin. Muharrirda tayyor PNG ni nusxalash va saqlash uchun `Enter` tugmasini, uni saqlamasdan nusxalash uchun `Ctrl + C` tugmasini yoki nusxalamasdan saqlash uchun `Ctrl + S` tugmasini bosing.

Saqlangan skrinshotlar sukut bo'yicha `~/Pictures/Screenshots` ga tushadi, nomi masalan `screenshot-2026-08-13_14-22-05-firefox.png` bo'ladi. Boshqa katalogdan foydalanish uchun `OMASNAP_SCREENSHOT_DIR` ni o'rnating — sessiya muhit o'zgaruvchilarini qayerga qo'yish haqida [FAQ](46-faq.md) ga qarang. Omasnap birinchi tasvirni saqlaganda katalogni yaratadi. Avtomatik saqlashni o'chirish uchun `~/.config/omasnap/omasnap.conf` da `[output] autosave = false` ni o'rnating; tasvirlar u holda faqat nusxalanadi va 7 soniya davomida oldindan ko'rishda ko'rsatiladi, uni mahkamlash tugmasi yoki `Ctrl + P` bilan ekranda qoldirishingiz mumkin.

Terminaldan `omarchy screenshot` xuddi shu ustki qatlamni ochadi va siz uning boshlang'ich rejimini tanlashingiz mumkin: `omarchy capture screenshot region`, `windows`, `fullscreen` yoki `scroll`. `copy` yoki `save` ikkinchi argumenti tasvirni to'g'ridan-to'g'ri o'sha manzilga yuboradi. Chiqarishdan oldin tahrirlash uchun to'liq ekranli muharrir uchun `omarchy screenshot --editor=overlay` dan yoki alohida oyna uchun `omarchy screenshot --editor=window` dan foydalaning.

### Tanlagichni klaviaturadan boshqarish

Tanlov ochiq turganda, sichqonchadan umuman foydalanishingiz shart emas:

| Tugma | Vazifasi |
| --- | -------- |
| `S` | Aylanadigan hudud rejimini yoqish/o'chirish |
| `Super + Arrow keys` | Window rejimida oynalar orasida harakatlanish |
| `Return` | Ajratilgan oynani tasvirga olish |
| `Ctrl + A` | Fokusdagi butun monitorni tasvirga olish |
| `R` | Ushbu sessiyada chizilgan oxirgi hududni tiklash |
| `Esc` | Omasnap ni yopish |

Bu bog'lamlar faqat Omasnap ochiq bo'lgandagina mavjud, shuning uchun ular o'zingizning konfiguratsiyangizdagi hech narsa bilan to'qnash kela olmaydi.

## Ekran yozuvi

`Alt + Print Screen` _Trigger > Capture > Screenrecord_ ni ochadi, u saundtrekda nima bo'lishini xohlashingizni so'raydi: audiosiz, ish stoli audiosi, ish stoli plyus mikrofon yoki ish stoli plyus mikrofon plyus veb-kamera. Oxirgisi faqat kamerangiz haqiqatan ulangan bo'lsa paydo bo'ladi. Birini tanlang — Omarchy ning yozib olish tanlagichi hududni sudrab belgilash yoki oyna yoxud monitorni bosish imkonini beradi.

Yozib olish gpu-screen-recorder da ishlaydi, u GPU da 60fps tezlikda kodlaydi va zarur bo'lsa CPU ga qaytadi; u qo'llab-quvvatlamaydigan GPU larda, masalan Apple Silicon dagilarda, Omarchy o'rniga wf-recorder bilan yozib oladi. Natija `~/Videos` dagi MP4 bo'ladi, nomi `screenrecording-2026-08-13_14-22-05.mp4`. Buni o'zgartirish uchun `OMARCHY_SCREENRECORD_DIR` ni o'rnating — lekin e'tibor bering, skrinshot katalogidan farqli o'laroq, bu katalog allaqachon mavjud bo'lishi kerak, aks holda yozib olish boshlanishdan bosh tortadi.

Yozib olayotganingizda barda kichkina indikator paydo bo'ladi. To'xtatish uchun uni bosing. Shuningdek `Alt + Print Screen` ni yana bosib yoki _Trigger > Capture > Screenrecord_ ostidagi _Stop Screenrecording_ bandi bilan to'xtatishingiz mumkin, u faqat biror narsa haqiqatan yozib olinayotganda paydo bo'ladi.

To'xtatish faylni sizga berishdan oldin biroz tartibga soladi: birinchi kadr qirqiladi, va agar audio bo'lsa, u -14 LUFS gacha normallashtiriladi, eng boshidagi PipeWire tasvirga olish shovqini o'chiriladi. So'ng yozuvdan eskiz bilan bildirishnoma paydo bo'ladi. Faylni Omaview da ijro etish uchun _Open_ ni, uni Omacut da qirqish uchun _Cut_ ni tanlang.

### Veb-kamera ustki qatlami

Veb-kamera bilan yozib olganingizda, kamera siz yozib olayotgan narsaning pastki o'ng burchagida mahkamlangan, qirqilgan portret oyna sifatida paydo bo'ladi. Agar u sizga kerakli narsaning ustida turgan bo'lsa, uni shu zahoti o'lchamini o'zgartiring:

| Tezkor tugma | Vazifasi |
| ------ | -------- |
| `Super + Alt + [` | Veb-kamera ustki qatlamini kichraytirish |
| `Super + Alt + ]` | Veb-kamera ustki qatlamini kattalashtirish |

Uchta o'lcham bor — kichik, o'rtacha va katta — va tezkor tugmalar ular orasida qadamlaydi. O'rtachasi sukut bo'yicha. Ular yozuvga mutanosib, shuning uchun kamera 1080p monitorni yoki 6K monitorni yozib olishingizdan qat'i nazar, kadrning bir xil ulushini egallaydi. Va agar siz butun displey o'rniga hududni yozib olgan bo'lsangiz, ustki qatlam monitor burchagiga emas, o'sha hudud burchagiga mahkamlanadi, shunda u tasvir ichida qoladi.

Uni to'g'ridan-to'g'ri `omarchy-capture-webcam-resize small` bilan ham chaqirishingiz mumkin, yoki o'rtachaga qaytish uchun `reset` dan foydalaning.

## Matn, QR kodlar va ranglar

`Super + Ctrl + Print Screen` hududni tanlaydi va uni OCR qilib almashuv buferiga joylaydi. Bu [Matn ajratib olish va diktant](11-text-extraction-dictation.md) da to'g'ri yoritilgan.

_Trigger > Capture > QR Code_ QR kodlar uchun xuddi shu nayrangni qiladi. Kod bor hududni tanlang, va dekodlangan qiymat almashuv buferiga tushadi. U faqat QR kodlarni qidiradi — aks holda zich ekran mazmuni shtrix-kod sifatida noto'g'ri aniqlanish odatiga ega. Bilish arziydi: dekodlangan qiymat almashuv buferiga tushadi va boshqa hech qayerga emas. U chop etilmaydi, u bildirishnomada yo'q, va u [almashuv buferi tarixi](08-unified-clipboard-history.md) da saqlanib qolmasligi uchun maxfiy deb belgilangan. QR kodlar odatda sirlarni tashiydi — masalan, 2FA o'rnatish kodi ortidagi `otpauth://` URI — va siz buni logda bo'lishini xohlamaysiz. Joylashtirish baribir yaxshi ishlaydi.

`Super + Print Screen` (yoki _Trigger > Capture > Color_) kursorni tomizg'ichga aylantiradi. Ekrandagi istalgan narsani bosing va rang almashuv buferiga tushadi. Tanlamasdan chiqish uchun tezkor tugmani yana bosing.

## Ulashishdan oldin transkodlash

4K ekran yozuvi yoki telefoningizdagi xom HEIC ko'pincha shunchaki yuborish uchun juda katta bo'ladi. `Super + Ctrl + .` (yoki _Trigger > Transcode_) buni tuzatadi. U sizga `~/Pictures` va `~/Videos` bo'yicha noaniq fayl tanlagichni taklif qiladi, so'ng format va o'lcham so'raydi.

Rasmlar yuqori, o'rtacha yoki past darajada jpg yoki png ga o'tadi, ular kenglikni 3160, 2160 va 1080 pikselda cheklaydi. Videolar 4k, 1080p yoki 720p da mp4 yoki jonlantirilgan gif ga o'tadi. O'zgartirilgan fayl asl fayl yoniga o'lchami nomi bilan yoziladi — `demo-1080p.mp4` — va yo'l fayl URI si sifatida almashuv buferiga nusxalanadi, shunda siz uni fayl tashlashni qabul qiladigan ilovaga to'g'ridan-to'g'ri joylashtirishingiz mumkin.

Agar nima xohlashingizni allaqachon bilsangiz, u terminaldan ham ishlaydi: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Shuningdek `omarchy transcode ascii` ham bor, u rasmni ASCII art ga aylantiradi — u asosan [brending](41-branding.md) uchun.

## Uni biror joyga yuborish

Faylni olganingizdan so'ng, `Super + Ctrl + S` Share menyusini ochadi va uni LocalSend orqali tarmog'ingizdagi boshqa qurilmaga yuboradi. Bu haqda [GUIs](22-guis.md) ga qarang.
