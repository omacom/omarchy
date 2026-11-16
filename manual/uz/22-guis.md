# GUIlar

## Fayllar

Files (Nautilus) — grafik fayl menejeri. `Super + Shift + F` uni ochadi, `Super + Shift + Alt + F` esa uni terminalingiz turgan katalogda ochadi, bu juda ko'p bosishlardan qutqaradi. `Ctrl + L` yo'l yozish imkonini beradi, biror faylda `Space`ni bosish esa hech narsa ochmasdan tezkor ko'rib chiqish beradi.

USB fleshkani yoki SD kartani ulang va u avtomatik ulanadi, shuning uchun u shunchaki yon panelda paydo bo'ladi. Murakkabroq ishlar — diskni formatlash, SMART holatini tekshirish, bo'limlar yaratish — uchun ilovalarni ishga tushirgichdan (`Super + Space`) _Disks_ni ishga tushiring.

Ikki marta bosish oqilona standartlarga amal qiladi: rasmlar, videolar va musiqalar Omaviewda, PDFlar Document Viewerda, Markdown Omawrite'da, oddiy matn esa _Setup > Default > Editor_ ostida tanlangan muharrirda ochiladi.

## Disktree

Disk to'lib qolganda va uni nima yeb qo'yayotganini bilmasangiz, ilovalarni ishga tushirgichdan (`Super + Space`) [Disktree](https://github.com/tobi/disktree)ni ishga tushiring. U uy katalogingizning grafik treemap ko'rinishini ko'rsatadi. Kattaroq bloklar ko'proq joy egallaydi; klaviatura yoki sichqoncha bilan kataloglar ichiga kiring, ketishi kerak bo'lgan narsalarni belgilang va biror narsani o'chirishdan oldin tanlaganlaringizni ko'rib chiqing. Butun diskni skanerlash uchun `disktree --disk`ni ishga tushiring.

## Obsidian

[Obsidian](https://obsidian.md/) — saqlash uchun oddiy Markdown fayllardan foydalanadigan bepul va juda kengaytiriladigan qaydlar olish ilovasi.

Obsidian barcha maqsadlar uchun bepul, jumladan shaxsiy, tijorat va notijorat foydalanish uchun.

Obsidian iOS va Androiddagi mobil ilovalar bilan sinxronlash uchun [tijorat qo'shimchasini](https://obsidian.md/sync) ham taklif qiladi. (https://obsidian.md/pricing).

Obsidian'ni `Super + Shift + O` bilan ishga tushirasiz. Mavzularni sinxronlashdan foydalanish uchun sozlamalarda `Omarchy` mavzusini tanlashingiz kerak.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) — Omarchy'ning o'zining o'ta sodda Markdown yozish ilovasi. Hech qanday vaultlar, hech qanday plaginlar yo'q, faqat siz va so'zlar.

Omawrite'ni `Super + Shift + W` bilan ishga tushirasiz.

## Pinta

[Pinta](https://www.pinta-project.com/) — kesish, o'lchamini o'zgartirish va boshqa asosiy amallar uchun ajoyib bo'lgan asosiy rasm tahrirlash vositasi. Faqat Photoshop muqobilini kutmang. Lekin unda baribir Magic Wand va qatlamlar bor!

Pinta'ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) — fon rasmdan ranglarni chiqarib olib, ularni to'liq, uyg'un mavzuga aylantira oladigan mavzulashtirish ilovasi. Bu [o'zingizning mavzungizni yaratish](43-making-your-own-theme.md)ning eng oson yo'li.

Aether'ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) sizga Apple'ning AirDrop'i kabi ilovani ishlatayotgan bir xil tarmoqdagi boshqa qurilmalarga fayl yuborish imkonini beradi. Biroq u kross-platformadir, shuning uchun Windows, macOS, Android, iOS va albatta Linuxga va ulardan fayl yuborishingiz mumkin.

Share menyusini `Super + Ctrl + S`da yoki Omarchy menyusida _Trigger > Share_ ostida ochishingiz mumkin. U sizga to'rtta variant beradi:

- **Clipboard** nusxa olgan narsangizni matn fayli sifatida yuboradi. Havola yoki parchaning o'zingizga elektron pochta yubormasdan telefoningizga o'tkazish uchun ajoyib.
- **File** bir vaqtning o'zida bir nechtasini tanlashingiz mumkin bo'lgan fayl tanlagichni ochadi.
- **Folder** butun katalogni yuboradi.
- **Receive** boshqa qurilma sizga biror narsa yuborishi uchun LocalSend'ning o'zini ochadi.

Xuddi shu narsa terminaldan `omarchy share clipboard`, `omarchy share file [path]` va `omarchy share folder [path]` bilan ishlaydi. Yo'lni qoldirib yuboring va sizga tanlagich chiqadi.

Fayl menejeridan ham to'g'ridan-to'g'ri yuborishingiz mumkin: Nautilus'da biror tanlovni o'ng tugma bilan bosing va _Send via LocalSend_ni tanlang.

Omarchy'ning firewall'i standart bo'yicha LocalSend portidan tashqari yopiq, shuning uchun bu yangi o'rnatishda qutidan chiqqan holda ishlaydi. Qarang [xavfsizlik](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) — matn protsessori, elektron jadval, taqdimotlar, chizish ilovasi va boshqalarni o'z ichiga olgan to'liq ofis paketi. U Microsoft Office fayllari bilan mos keladi, shuning uchun bu o'sha Word hujjatlarini ochishning ajoyib yo'li.

LibreOffice'ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) — Omarchy'ning o'zining o'ta sodda taqdimot ilovasi. Taqdimotingiz rasmlari va videolari yonida turgan bitta Markdown fayldir: har bir slaydni jonli ko'rib chiqish ostida yozing, slaydlarni tartibga tortib o'tkazing, keyin to'liq ekranda taqdim qiling yoki PDF va PowerPointga eksport qiling. U hatto Omarchy mavzungizni ham oladi.

Hype'ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`). Undagi har bir yorliqni ko'rish uchun ichida `?`ni bosing.

## Signed

[Signed](https://github.com/omacom/signed) — Omarchy'ning PDFlarni imzolash va to'ldirishning o'zining o'ta sodda usuli. Saqlangan imzoingizni, matnni va bugungi sanani sahifaning istalgan joyiga qo'ying, keyin imzolangan nusxani asl nusxa yoniga saqlang. Qanday qilishni [PDFlarni to'ldirish](27-filling-out-pdfs.md)da ko'ring.

Signed'ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`) yoki fayl menejeridan u bilan PDF ochasiz.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) — Omarchy'ning o'zining 3D shaxmat o'yini. Bir xil kompyuterda do'stingiz bilan yoki uch darajada o'rnatilgan raqib bilan o'ynang, har biri o'ziga xos tarzda harakatlanadigan to'rtta haykalcha to'plamida: orbital kemalar, o'yilgan yog'och va fil suyagi, o'rmon jonzotlari va konfet. O'yinlarda soat yo'q va har bir yurishdan keyin saqlanadi.

Checkmate'ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`), u yerda u Chess sifatida ko'rsatilgan. Undagi har bir yorliqni ko'rish uchun ichida `?`ni bosing.

## Cards

[Cards](https://github.com/omacom/cards) — Omarchy'ning o'zining Klondike solitaire'i. Uchtadan torting, o'tishlar sonida cheklov yo'q, to'rtta karta seriyasida: biri mavzungiz ranglarida chizilgan, uchtasi esa o'z ko'rinishiga ega. Kartani bosing va keyin u boradigan joyni bosing, uni torting yoki uni eng yaxshi joyga yuborish uchun ikki marta bosing. O'yinlar har bir yurishdan keyin saqlanadi.

Cards'ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`). Har bir yorliqni ko'rish uchun uning nomini bosing yoki `?`ni bosing.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) — suzuvchi oynada ochiladigan Omarchy'ning o'zining o'ta sodda kalkulyatori.

Omacalc'ni `Super + Shift + Q` bilan ishga tushirasiz (yoki klaviaturangizda bo'lsa, kalkulyator tugmasi bilan).

## Signal

[Signal](https://signal.org/) — E2E shifrlangan xabar almashishning kashshofi va yirik texnologiya konglomeratlaridan biri orqali o'tishni istamaydigan har kim uchun ajoyib aloqa varianti.

Signal'ni `Super + Shift + G` bilan ishga tushirasiz. U asosiy o'rnatishning bir qismi emas, shuning uchun uni birinchi marta bossangiz, Omarchy uni siz uchun o'rnatishni taklif qiladi (u Omarchy menyusida _Install > Service_ ostida ham bor).

## Omaview

[Omaview](https://github.com/omacom/omaview) — Omarchy'ning o'zining o'ta sodda rasm ko'ruvchisi va media pleyeri: fotosuratlaringiz, videolaringiz va musiqangiz uchun bitta oyna. Rasmni oching va strelka tugmalari uning papkasidagi qolganlari bo'ylab qadamlaydi, `N` va `P` buni har qanday narsa uchun qiladi, `Ctrl + M` esa butun papkani panjara sifatida ko'rsatadi. U HEIC, AVIF va JPEG XL fotosuratlarni ham ko'rsatadi va uzun narsalarda to'xtagan joyingizdan davom etadi.

To'liq ekran uchun `F`ni, rasmni Omasnap'da tahrirlash yoki videoni Omacut'da kesish uchun `E`ni, rasmni chop qilish uchun `Ctrl + P`ni va faylni Trash'ga ko'chirish uchun `Delete`ni bosing (`Ctrl + Z` uni qaytarib olib keladi). Undagi har bir yorliqni ko'rish uchun ichida `?`ni bosing.

Omaview'ni ilovalarni ishga tushirgich orqali _Media Viewer_ sifatida ishga tushirasiz (`Super + Space`) yoki fayl menejerida rasm, video yoki qo'shiqni shunchaki ikki marta bosasiz.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) — Omarchy'ning o'zining o'ta sodda video kesuvchisi. Sizga kerak bo'lgan narsa klipning boshi va oxirini kesish bo'lganda, u to'liq video muharrirni ishga tushirishdan ustun turadi.

Omacut'ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) — Omarchy'ning o'zining o'ta sodda veb-kamera yozuvchisi. Kamera va mikrofoningizni bir marta tanlang, keyin yozish uchun `Space`ni bosing, yana o'sha dublyajni to'xtatib turish va davom ettirish uchun yana bosing. U har doim kamerangizning eng yuqori aniqligida yozadi, boshlashdan oldin darajangizni tekshirishingiz uchun jonli mikrofon o'lchagichi bilan.

Dublyajni to'xtating va u darhol o'rnatilgan muharrirda ochiladi. Klipni bo'lish uchun uni ikki marta bosing, har bir qismni kesish uchun tutqichlarni torting va kerak bo'lmagan qismlarni olib tashlang. Keyin uni MP4 sifatida saqlang. Asl yozuvingiz uni tashlab yubormaguningizcha saqlanadi, shuning uchun har doim qaytib kelib uni boshqacha kesishingiz mumkin.

Monologue'ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`).
