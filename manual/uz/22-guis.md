# GUIlar

## Fayllar

Files (Nautilus) — grafik fayl menejeri. `Super + Shift + F` uni ochadi, `Super + Shift + Alt + F` esa uni terminalingiz turgan katalogda ochadi, bu juda ko'p bosishlardan qutqaradi. `Ctrl + L` yo'lni yozish imkonini beradi, biron fayl ustida `Space` ni bosish esa hech narsa ochmasdan tezkor ko'rib chiqish imkonini beradi.

USB fleshka yoki SD kartani ulang va u avtomatik tarzda ulanadi, shuning uchun u yon panelda shunchaki chiqib keladi. Murakkabroq ishlar — diskni formatlash, SMART holatini tekshirish, bo'limlar yaratish — uchun ilovalarni ishga tushirgichdan (`Super + Space`) _Disks_ ni ishga tushiring.

Ikki marta bosishda oqilona standartlar ishlaydi: rasmlar, videolar va musiqa Omaview da, PDFlar Document Viewer da, oddiy matn esa Neovim da ochiladi.

## Disktree

Disk to'lib qolganda va uni nima yeb qo'yayotganini bilmaganingizda, ilovalarni ishga tushirgichdan (`Super + Space`) [Disktree](https://github.com/tobi/disktree) ni ishga tushiring. U uy katalogingizning grafik treemap ko'rinishini ko'rsatadi. Kattaroq bloklar ko'proq joy egallaydi; kataloglar ichiga klaviatura yoki sichqoncha bilan kiring, ketishi kerak bo'lganlarni belgilang va biron narsani o'chirishdan oldin tanlaganlaringizni ko'rib chiqing. Butun diskni skanerlash uchun `disktree --disk` ni ishga tushiring.

## Obsidian

[Obsidian](https://obsidian.md/) — saqlash uchun oddiy Markdown fayllaridan foydalanadigan bepul va juda kengaytiriladigan qaydlar olish ilovasi.

Obsidian barcha maqsadlar uchun bepul, jumladan shaxsiy, tijorat va notijorat foydalanish uchun.

Obsidian shuningdek iOS va Android dagi mobil ilovalar bilan [sinxronlash uchun tijorat qo'shimchasini](https://obsidian.md/sync) taklif qiladi. (https://obsidian.md/pricing).

Obsidian ni `Super + Shift + O` bilan ishga tushirasiz. Mavzularni sinxronlashdan foydalanish uchun sozlamalarda `Omarchy` mavzusini tanlashingiz kerak.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) — Omarchy ning o'zining o'ta oddiy Markdown yozish ilovasi. Vaultlar yo'q, plaginlar yo'q, faqat siz va so'zlar.

Omawrite ni `Super + Shift + W` bilan ishga tushirasiz.

## Pinta

[Pinta](https://www.pinta-project.com/) — kesish, o'lchamini o'zgartirish va boshqa asosiy amallar uchun ajoyib bo'lgan asosiy rasm tahrirlash vositasi. Faqat Photoshop muqobilini kutmang. Lekin unda baribir Magic Wand va qatlamlar bor!

Pinta ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) — fon rasmdan ranglarni ajratib olib, ularni to'liq, uyg'un mavzuga aylantira oladigan mavzulashtirish ilovasi. Bu [o'z mavzuingizni yaratishning](43-making-your-own-theme.md) eng oson yo'li.

Aether ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) Apple ning AirDrop i kabi, ilova ishlayotgan shu tarmoqdagi boshqa qurilmalarga fayllar yuborish imkonini beradi. Biroq u platformalararo, shuning uchun Windows, macOS, Android, iOS va albatta Linux ga va ulardan fayllar yuborishingiz mumkin.

Ulashish menyusini `Super + Ctrl + S` bilan yoki Omarchy menyusida _Trigger > Share_ ostida ochishingiz mumkin. U sizga to'rtta variant beradi:

- **Clipboard** nusxa olgan narsangizni matn fayli sifatida yuboradi. Havola yoki parchani o'zingizga email yubormasdan telefoningizga o'tkazish uchun ajoyib.
- **File** bir vaqtning o'zida bir nechtasini tanlashingiz mumkin bo'lgan fayl tanlagichni ochadi.
- **Folder** butun katalogni yuboradi.
- **Receive** LocalSend ning o'zini ochadi, shunda boshqa qurilma sizga biron narsa yubora oladi.

Xuddi shu narsa terminaldan `omarchy share clipboard`, `omarchy share file [path]` va `omarchy share folder [path]` bilan ishlaydi. Yo'lni qoldirib ketsangiz, tanlagichni olasiz.

Shuningdek, to'g'ridan-to'g'ri fayl menejeridan yuborishingiz mumkin: Nautilus da istalgan tanlovni o'ng tugma bilan bosing va _Send via LocalSend_ ni tanlang.

Omarchy ning firewall i standart bo'yicha LocalSend portidan tashqari yopiq, shuning uchun bu yangi o'rnatishda qutidan chiqqan holda ishlaydi. Qarang: [xavfsizlik](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) — so'z protsessori, elektron jadval, taqdimotlar, chizish ilovasi va boshqalarni o'z ichiga olgan to'liq ofis paketi. U Microsoft Office fayllari bilan mos, shuning uchun bu o'sha Word hujjatlarini ochishning ajoyib usuli.

LibreOffice ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) — Omarchy ning o'zining o'ta oddiy taqdimot ilovasi. Sizning taqdimotingiz — rasmlari va videolari yonida turgan bitta Markdown fayli: har bir slaydni jonli ko'rib chiqish ostida yozing, slaydlarni tartibga tortib olib boring, keyin to'liq ekranda taqdim eting yoki PDF va PowerPoint ga eksport qiling. U hatto Omarchy mavzuingizni ham oladi.

Hype ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`). Har bir yorliqni ko'rish uchun uning ichida `?` ni bosing.

## Signed

[Signed](https://github.com/omacom/signed) — Omarchy ning PDFlarni imzolash va to'ldirishning o'ta oddiy o'z usuli. Saqlangan imzoyingizni, matnni va bugungi sanani sahifaning istalgan joyiga qo'ying, keyin asl nusxa yonida imzolangan nusxani saqlang. Qanday qilishni [PDFlarni to'ldirish](27-filling-out-pdfs.md) bo'limida ko'ring.

Signed ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`), yoki fayl menejeridan u bilan PDF oching.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) — suzuvchi oynada ochiladigan Omarchy ning o'zining o'ta oddiy kalkulyatori.

Omacalc ni `Super + Shift + Q` bilan ishga tushirasiz (yoki klaviaturangizda bo'lsa, kalkulyator tugmasi bilan).

## Signal

[Signal](https://signal.org/) — E2E shifrlangan xabar almashishning kashshofi va yirik texnologik konglomeratlardan biri orqali o'tishni istamaydigan har kim uchun ajoyib aloqa varianti.

Signal ni `Super + Shift + G` bilan ishga tushirasiz. U asosiy o'rnatishning bir qismi emas, shuning uchun uni birinchi marta bossangiz, Omarchy uni siz uchun o'rnatishni taklif qiladi (u Omarchy menyusida _Install > Service_ ostida ham bor).

## Omaview

[Omaview](https://github.com/omacom/omaview) — Omarchy ning o'zining o'ta oddiy rasm ko'ruvchisi va media pleyeri: fotosuratlaringiz, videolaringiz va musiqangiz uchun bitta oyna. Fotosuratni oching va strelka tugmalari uning papkasidagi qolganlarini ketma-ket ko'rsatadi, `N` va `P` buni har qanday narsa uchun qiladi, `Ctrl + M` esa butun papkani panjara sifatida ko'rsatadi. U HEIC, AVIF va JPEG XL fotosuratlarini ham ko'rsatadi va uzun narsalarda to'xtagan joyingizdan davom etadi.

To'liq ekran uchun `F` ni, rasmni Omasnap da tahrirlash yoki videoni Omacut da kesish uchun `E` ni, rasmni chop etish uchun `Ctrl + P` ni va faylni Trash ga ko'chirish uchun `Delete` ni bosing (`Ctrl + Z` uni qaytaradi). Har bir yorliqni ko'rish uchun uning ichida `?` ni bosing.

Omaview ni ilovalarni ishga tushirgich orqali _Media Viewer_ sifatida ishga tushirasiz (`Super + Space`), yoki fayl menejerida rasm, video yoki qo'shiqni shunchaki ikki marta bosing.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) — Omarchy ning o'zining o'ta oddiy video kesuvchisi. Sizga kerak bo'lgan narsa faqat klipning boshi va oxirini kesish bo'lsa, u to'liq video tahrirlovchini ishga tushirishdan ustun.

Omacut ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) — Omarchy ning o'zining o'ta oddiy veb-kamera yozuvchisi. Kamera va mikrofoningizni bir marta tanlang, keyin yozish uchun `Space` ni bosing, yana o'sha yozuvni pauza qilish va davom ettirish uchun yana bosing. U har doim kamerangizning eng yuqori aniqligida yozadi, boshlashdan oldin darajangizni tekshirishingiz uchun jonli mikrofon o'lchagichi bilan.

Yozuvni to'xtating va u darhol o'rnatilgan tahrirlovchida ochiladi. Klipni bo'lish uchun uni ikki marta bosing, har bir bo'lakni kesish uchun tutqichlarni torting va kerak bo'lmagan qismlarni olib tashlang. Keyin uni MP4 sifatida saqlang. Asl yozuvingiz uni tashlab yubormaguningizcha saqlanadi, shuning uchun har doim qaytib, uni boshqacha kesishingiz mumkin.

Monologue ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`).
