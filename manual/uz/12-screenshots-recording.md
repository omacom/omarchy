# Skrinshotlar va yozuv

Ekrandan olishingiz mumkin boʻlgan hamma narsa Print Screen tugmasiga osilgan. Oʻzicha bitta tugma rasm oladi va modifikatorlar yozuv, rang yoki hudud ichidagi matnni oladi. Agar klaviaturangizda umuman Print Screen tugmasi boʻlmasa, `Super + Ctrl + C` xuddi shu toʻplamni menyu sifatida ochadi.

| Hotkey | Funksiya |
| ------ | -------- |
| `Print Screen` | Skrinshot |
| `Alt + Print Screen` | Ekran yozuvi (yoki ishlayotganini toʻxtatish) |
| `Super + Print Screen` | Rang tanlagich |
| `Super + Ctrl + Print Screen` | Hududdan matn ajratish |
| `Super + Ctrl + C` | Yozib olish menyusi |
| `Super + Ctrl + .` | Rasm yoki videoni qayta kodlash |

## Skrinshotlar

`Print Screen` ni bosing va Omasnap uning qoplamasi paydo boʻlishidan oldin fokuslangan monitorni oladi, shuning uchun nishan olayotganingizda hech narsa ostingizda siljimaydi. Erkin shakldagi hududni sudrab boring, uni olish uchun oynani bosing yoki butun monitorni olish uchun ochiq joyni bosing. Siljituvchi hududni olish uchun chizishdan oldin `S` ni bosing. Fikringiz oʻzgardimi? Omasnapni yopish uchun yana `Print Screen` ni bosing.

Hudud tanlaganingizdan keyin Omasnap olinganini saqlaydi, buferga nusxalaydi va 10 soniya davomida oldindan koʻrishni koʻrsatadi. Uni ekranda saqlash uchun oldindan koʻrishning mahkamlash tugmasi yoki `Ctrl + P` ni ishlating yoki unga izoh qoʻshish uchun Tahrirlashni tanlang.

Izoh editori oʻqlar, chiziqlar, shakllar, ajratib koʻrsatishlar, raqamlangan belgilar, matn va xavfsiz tahrirlarni chizishi; rasmning bir qismini qirqishi yoki kesib olishi; uning matnini OCR qilishi; va fon qoʻshishi mumkin. Editorda tayyor PNG ni nusxalash va saqlash uchun `Enter`, saqlamasdan nusxalash uchun `Ctrl + C` yoki nusxalamasdan saqlash uchun `Ctrl + S` ni bosing.

Saqlangan skrinshotlar standartda `~/Pictures/Screenshots` ga tushadi, `screenshot-2026-08-13_14-22-05-firefox.png` kabi nom bilan. Boshqa katalog ishlatish uchun `OMASNAP_SCREENSHOT_DIR` ni oʻrnating — sessiya muhiti oʻzgaruvchilarini qayerga qoʻyish haqida [FAQ](46-faq.md) ga qarang. Omasnap birinchi suratni saqlaganda katalogni yaratadi. Avtomatik saqlashni oʻchirish uchun `~/.config/omasnap/omasnap.conf` da `[output] autosave = false` ni oʻrnating.

Terminaldan `omarchy screenshot` xuddi shu qoplamani ochadi va siz uning boshlangʻich rejimini tanlashingiz mumkin: `omarchy capture screenshot region`, `windows`, `fullscreen` yoki `scroll`. `copy` yoki `save` ikkinchi argumenti oldindan koʻrishni oʻtkazib yuboradi va suratni toʻgʻridan-toʻgʻri oʻsha manzilga yuboradi. Chiqarishdan oldin tahrirlash uchun toʻliq ekran editori uchun `omarchy screenshot --editor=overlay` yoki alohida oyna uchun `omarchy screenshot --editor=window` ishlating.

### Tanlovchini klaviaturadan boshqarish

Tanlov ochiq boʻlganda, sichqonchani umuman ishlatishingiz shart emas:

| Tugma | Funksiya |
| --- | -------- |
| `S` | Siljituvchi hudud rejimini almashtirish |
| `Super + Arrow keys` | Oyna rejimida oynalar orasida harakatlanish |
| `Return` | Ajratilgan oynani olish |
| `Ctrl + A` | Toʻliq fokuslangan monitorni olish |
| `R` | Ushbu sessiyada chizilgan oxirgi hududni tiklash |
| `Esc` | Omasnapni yopish |

Bu bogʻlanishlar faqat Omasnap ochiq boʻlganda mavjud, shuning uchun ular oʻz konfiguratsiyangizdagi hech narsa bilan toʻqnasha olmaydi.

## Ekran yozuvi

`Alt + Print Screen` _Ishga tushirish > Yozib olish > Ekran yozuvi_ ni ochadi, u ovoz yozuvida nimani xohlashingizni soʻraydi: ovoz yoʻq, ish stoli ovozi, ish stoli plyus mikrofon yoki ish stoli plyus mikrofon plyus veb-kamera. Oxirgisi faqat haqiqatan kamera ulagan boʻlsangiz paydo boʻladi. Bittasini tanlang va Omarchyning yozuv tanlovchisi sizga hudud sudrab borish yoki oyna yoki monitorni bosish imkonini beradi.

Yozuv gpu-screen-recorderda ishlaydi, u GPUda 60fpsda kodlaydi va kerak boʻlsa CPUga qaytadi. Natija `~/Videos` dagi `screenrecording-2026-08-13_14-22-05.mp4` nomli MP4 dir. Uni oʻzgartirish uchun `OMARCHY_SCREENRECORD_DIR` ni oʻrnating — lekin esda tuting, skrinshot katalogidan farqli oʻlaroq, bu katalog allaqachon mavjud boʻlishi kerak, aks holda yozuv boshlanishni rad etadi.

Yozib olayotganingizda panelda kichik koʻrsatkich paydo boʻladi. Toʻxtatish uchun uni bosing. Yana `Alt + Print Screen` yoki _Ishga tushirish > Yozib olish > Ekran yozuvi_ ostidagi _Yozuvni toʻxtatish_ yozuvi bilan ham toʻxtatishingiz mumkin, u faqat nimadir haqiqatan yozib olinayotgan paytda paydo boʻladi.

Toʻxtatish sizga faylni berishdan oldin biroz tozalash qiladi: birinchi kadr kesiladi va agar ovoz boʻlsa u PipeWire olishi boshida oʻchirilgan holda -14 LUFS ga normallashtiriladi. Keyin yozuvdan eskizi bor bildirishnoma paydo boʻladi. Faylni mpvda oʻynatish uchun uni bosing.

### Veb-kamera qoplamasi

Veb-kamera bilan yozib olganingizda, kamera yozib olayotgan narsangizning pastki oʻng burchagida mahkamlangan, qirqilgan portret oyna sifatida paydo boʻladi. Agar u sizga kerak boʻlgan narsaning ustida oʻtirgan boʻlsa, parvozda uning oʻlchamini oʻzgartiring:

| Hotkey | Funksiya |
| ------ | -------- |
| `Super + Alt + [` | Veb-kamera qoplamasini kichraytirish |
| `Super + Alt + ]` | Veb-kamera qoplamasini kattalashtirish |

Uchta oʻlcham bor — kichik, oʻrta va katta — va hotkeylar ular orasida qadam tashlaydi. Oʻrta standart hisoblanadi. Ular yozuvga mutanosib, shuning uchun kamera 1080p monitor yoki 6K monitor yozib olayotganingizdan qatʼi nazar kadrning bir xil ulushini egallaydi. Va agar butun displey emas, hudud yozib olgan boʻlsangiz, qoplama monitorning emas, oʻsha hudud burchagiga mahkamlanadi, shuning uchun u surat ichida qoladi.

Uni bevosita `omarchy-capture-webcam-resize small` bilan yoki oʻrtaga qaytish uchun `reset` bilan ham chaqirishingiz mumkin.

## Matn, QR kodlar va ranglar

`Super + Ctrl + Print Screen` hudud tanlaydi va uni buferga OCR qiladi. Bu [Matn ajratish va diktovka](11-text-extraction-dictation.md) da toʻgʻri yoritilgan.

_Ishga tushirish > Yozib olish > QR kod_ QR kodlar uchun xuddi shu hiylani qiladi. Kod bor hududni tanlang va dekodlangan qiymat buferga ketadi. U faqat QR kodlarni qidiradi — zich ekran kontenti aks holda shtrix-kod sifatida notoʻgʻri ijobiy boʻlish odatiga ega. Bilish muhim: dekodlangan qiymat buferga ketadi va boshqa hech qayerga. U chop etilmaydi, bildirishnomada yoʻq va u maxfiy deb belgilanadi, shuning uchun [bufer tarixida](08-unified-clipboard-history.md) qolib ketmaydi. QR kodlar muntazam ravishda sirlarni — masalan, 2FA sozlash kodi ortidagi `otpauth://` URI ni — tashiydi va siz buni jurnalda xohlamaysiz. Qoʻyish baribir yaxshi ishlaydi.

`Super + Print Screen` (yoki _Ishga tushirish > Yozib olish > Rang_) kursorni tomizgʻichga aylantiradi. Ekrandagi istalgan narsani bosing va rang buferga tushadi. Tanlamasdan chiqish uchun hotkeyni yana bosing.

## Ulashishdan oldin qayta kodlash

4K ekran yozuvi yoki telefoningizdan xom HEIC koʻpincha shunchaki yuborish uchun juda katta. `Super + Ctrl + .` (yoki _Ishga tushirish > Qayta kodlash_) buni tuzatadi. U sizga `~/Pictures` va `~/Videos` ustidan fuzzy fayl tanlovchi taklif qiladi, keyin format va oʻlcham soʻraydi.

Rasmlar kengligi 3160, 2160 va 1080 piksel bilan chegaralanadigan yuqori, oʻrta yoki past sifatda jpg yoki png ga ketadi. Videolar 4k, 1080p yoki 720p da mp4 yoki animatsiyali gif ga ketadi. Oʻzgartirilgan fayl nomda oʻlcham bilan asl fayl yoniga yoziladi — `demo-1080p.mp4` — va yoʻl fayl URI si sifatida buferga nusxalanadi, shuning uchun uni fayl tashlashlarni oladigan ilovaga toʻgʻridan-toʻgʻri qoʻyishingiz mumkin.

Agar nimani xohlashingizni allaqachon bilsangiz, u terminaldan ham ishlaydi: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Yana `omarchy transcode ascii` bor, u rasmni ASCII sanʼatiga aylantiradi — bunisi asosan [brending](41-branding.md) uchun.

## Uni biror joyga yuborish

Fayl sizda boʻlgandan keyin, `Super + Ctrl + S` Ulashish menyusini ochadi va uni LocalSend orqali tarmogʻingizdagi boshqa qurilmaga yuboradi. Bu haqida [GUIlar](22-guis.md) ga qarang.
