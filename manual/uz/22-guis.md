# GUIlar

## Files

Files (Nautilus) — grafik fayl menejeri. `Super + Shift + F` uni ochadi, `Super + Shift + Alt + F` esa uni terminalingiz turgan katalogda ochadi, bu ko‘p bosishlardan qutqaradi. `Ctrl + L` yo‘l yozish imkonini beradi, istalgan faylda `Space` ni bosish esa hech narsa ochmasdan tezkor ko‘rib chiqishni beradi.

USB fleshka yoki SD karta ulang va u avtomatik ulanadi, shuning uchun u yon panelda shunchaki paydo bo‘ladi. Murakkabroq ishlar — diskni formatlash, SMART holatini tekshirish, bo‘limlar yaratish — uchun dastur ishga tushirgichidan (`Super + Space`) _Disks_ ni ishga tushiring.

Ikki marta bosish oqilona standartlarga amal qiladi: rasmlar, videolar va musiqa Omaview da, PDFlar Document Viewer da, Markdown Omawrite da, oddiy matn esa _Setup > Default > Editor_ ostida tanlangan muharrirda ochiladi.

## Disktree

Disk to‘lib qolsa va uni nima yeyayotganini bilmasangiz, dastur ishga tushirgichidan (`Super + Space`) [Disktree](https://github.com/tobi/disktree) ni ishga tushiring. U uy katalogingizning grafik treemap xaritasini ko‘rsatadi. Kattaroq bloklar ko‘proq joy egallaydi; klaviatura yoki sichqoncha bilan kataloglar ichiga kiring, ketishi kerak bo‘lganlarni belgilang va biror narsani o‘chirishdan oldin tanlaganlaringizni ko‘rib chiqing. Butun diskni skanerlash uchun `disktree --disk` ni ishga tushiring.

## Obsidian

[Obsidian](https://obsidian.md/) — saqlash uchun oddiy Markdown fayllaridan foydalanadigan bepul va juda kengaytiriladigan qayd olish dasturi.

Obsidian barcha maqsadlar uchun bepul, jumladan shaxsiy, tijorat va notijorat foydalanish uchun.

Obsidian shuningdek iOS va Android dagi mobil ilovalar bilan sinxronlash uchun [tijorat qo‘shimchasini](https://obsidian.md/sync) taklif qiladi. (https://obsidian.md/pricing).

Obsidian ni `Super + Shift + O` bilan ishga tushirasiz. Mavzularni sinxronlashdan foydalanish uchun sozlamalarda `Omarchy` mavzusini tanlashingiz kerak.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) — Omarchy ning o‘zining juda oddiy Markdown yozish dasturi. Vaultlar yo‘q, plaginlar yo‘q, faqat siz va so‘zlar.

Omawrite ni `Super + Shift + W` bilan ishga tushirasiz.

## Pinta

[Pinta](https://www.pinta-project.com/) — kesish, o‘lchamini o‘zgartirish va boshqa oddiy amallar uchun ajoyib bo‘lgan oddiy rasm tahrirlash vositasi. Faqat Photoshop o‘rnini bosadi deb kutmang. Lekin unda baribir Magic Wand va qatlamlar bor!

Pinta ni dastur ishga tushirgichi (`Super + Space`) orqali ishga tushirasiz.

## Aether

[Aether](https://github.com/bjarneo/aether) — fon rasmdan ranglarni ajratib olib, ularni to‘liq, uyg‘un mavzuga aylantira oladigan mavzulashtirish dasturi. Bu [o‘z mavzuingizni yaratishning](43-making-your-own-theme.md) eng oson yo‘li.

Aether ni dastur ishga tushirgichi (`Super + Space`) orqali ishga tushirasiz.

## LocalSend

[LocalSend](https://localsend.org/) bir xil tarmoqda shu dasturni ishlatayotgan boshqa qurilmalarga fayllar yuborish imkonini beradi, Apple ning AirDrop i kabi. Lekin u kross-platforma, shuning uchun Windows, macOS, Android, iOS va albatta Linux ga va ulardan fayllar yuborishingiz mumkin.

Share menyusini `Super + Ctrl + S` bilan yoki Omarchy menyusida _Trigger > Share_ ostida ochishingiz mumkin. U sizga to‘rtta variant beradi:

- **Clipboard** nusxa olgan narsangizni matn fayli sifatida yuboradi. Havola yoki parchani o‘zingizga elektron pochta yubormasdan telefoningizga o‘tkazish uchun ajoyib.
- **File** bir vaqtning o‘zida bir nechtasini tanlashingiz mumkin bo‘lgan fayl tanlagichni ochadi.
- **Folder** butun katalogni yuboradi.
- **Receive** LocalSend ning o‘zini ochadi, shunda boshqa qurilma sizga biror narsa yuborishi mumkin.

Xuddi shu narsa terminaldan `omarchy share clipboard`, `omarchy share file [path]` va `omarchy share folder [path]` bilan ishlaydi. Yo‘lni yozmasangiz, tanlagich chiqadi.

Fayl menejeridan ham to‘g‘ridan-to‘g‘ri yuborishingiz mumkin: Nautilus da istalgan tanlovni o‘ng tugma bilan bosing va _Send via LocalSend_ ni tanlang.

Omarchy firewalli standart holatda LocalSend portidan tashqari yopiq, shuning uchun bu yangi o‘rnatishda qutidan chiqqan holda ishlaydi. Qarang [xavfsizlik](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) — matn protsessori, elektron jadval, taqdimotlar, chizish dasturi va boshqalarni o‘z ichiga olgan to‘liq ofis paketi. U Microsoft Office fayllari bilan mos keladi, shuning uchun bu o‘sha Word hujjatlarini ocha olishning ajoyib yo‘li.

LibreOffice ni dastur ishga tushirgichi (`Super + Space`) orqali ishga tushirasiz.

## Hype

[Hype](https://github.com/omacom/hype) — Omarchy ning o‘zining juda oddiy taqdimot dasturi. Taqdimotingiz — rasmlari va videolari yonida turgan bitta Markdown fayli: har bir slaydni jonli ko‘rib chiqish ostida yozing, slaydlarni tartibga sudrab joylashtiring, keyin to‘liq ekranda taqdim eting yoki PDF va PowerPoint ga eksport qiling. U hatto Omarchy mavzuingizni ham oladi.

Hype ni dastur ishga tushirgichi (`Super + Space`) orqali ishga tushirasiz. Har bir yorliqni ko‘rish uchun uning ichida `?` ni bosing.

## Signed

[Signed](https://github.com/omacom/signed) — Omarchy ning PDFlarni imzolash va to‘ldirishning o‘zining juda oddiy usuli. Saqlangan imzoingizni, matnni va bugungi sanani sahifaning istalgan joyiga qo‘ying, keyin imzolangan nusxani asl nusxa yonida saqlang. Qanday qilishni [PDFlarni to‘ldirish](27-filling-out-pdfs.md) bo‘limida ko‘ring.

Signed ni dastur ishga tushirgichi (`Super + Space`) orqali ishga tushirasiz yoki fayl menejeridan PDF ni u bilan ochasiz.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) — Omarchy ning o‘zining 3D shaxmat o‘yini. Bitta kompyuterda do‘stingiz bilan yoki uchta darajada o‘rnatilgan raqibga qarshi o‘ynang, har biri o‘ziga xos tarzda harakatlanadigan to‘rtta haykalcha to‘plamida: orbital apparatlar, o‘yilgan yog‘och va fil suyagi, o‘rmon jonzotlari va konfet. O‘yinlarda soat yo‘q va har bir yurishdan keyin saqlanadi.

Checkmate ni dastur ishga tushirgichi (`Super + Space`) orqali ishga tushirasiz, u yerda u Chess sifatida ro‘yxatga olingan. Har bir yorliqni ko‘rish uchun uning ichida `?` ni bosing.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) — Omarchy ning o‘zining juda oddiy kalkulyatori, u suzuvchi oynada ochiladi.

Omacalc ni `Super + Shift + Q` bilan ishga tushirasiz (yoki klaviaturangizda bo‘lsa, kalkulyator tugmasi bilan).

## Signal

[Signal](https://signal.org/) — E2E shifrlangan xabar almashinuvining kashshofi va yirik texnologik konglomeratlardan biri orqali o‘tmaslikni afzal ko‘radigan har bir kishi uchun ajoyib aloqa varianti.

Signal ni `Super + Shift + G` bilan ishga tushirasiz. U asosiy o‘rnatish tarkibiga kirmaydi, shuning uchun buni birinchi marta bossangiz, Omarchy uni siz uchun o‘rnatishni taklif qiladi (u Omarchy menyusida _Install > Service_ ostida ham bor).

## Omaview

[Omaview](https://github.com/omacom/omaview) — Omarchy ning o‘zining juda oddiy rasm ko‘ruvchisi va media pleyeri: fotosuratlaringiz, videolaringiz va musiqangiz uchun bitta oyna. Fotosuratni oching va strelka tugmalari uning katalogidagi qolganlarini birma-bir ko‘rsatadi, `N` va `P` buni har qanday narsa uchun qiladi, `Ctrl + M` esa butun katalogni katakcha sifatida ko‘rsatadi. U HEIC, AVIF va JPEG XL fotosuratlarini ham ko‘rsatadi va uzun narsalarda to‘xtagan joyingizdan davom etadi.

To‘liq ekran uchun `F` ni, rasmni Omasnap da tahrirlash yoki videoni Omacut da kesish uchun `E` ni, rasmni chop etish uchun `Ctrl + P` ni va faylni Trash ga ko‘chirish uchun `Delete` ni bosing (`Ctrl + Z` uni qaytaradi). Har bir yorliqni ko‘rish uchun uning ichida `?` ni bosing.

Omaview ni dastur ishga tushirgichi (`Super + Space`) orqali _Media Viewer_ sifatida ishga tushirasiz yoki fayl menejerida rasm, video yoki qo‘shiqni shunchaki ikki marta bosasiz.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) — Omarchy ning o‘zining juda oddiy video kesuvchisi. Sizga faqat klipning boshi va oxirini kesish kerak bo‘lganda, u to‘liq video muharririni ishga tushirishdan yaxshiroq.

Omacut ni dastur ishga tushirgichi (`Super + Space`) orqali ishga tushirasiz.

## Monologue

[Monologue](https://github.com/omacom/monologue) — Omarchy ning o‘zining juda oddiy veb-kamera yozuvchisi. Kamera va mikrofoningizni bir marta tanlang, keyin yozish uchun `Space` ni bosing, o‘sha olishni pauza qilish va davom ettirish uchun yana bosing. U har doim kamerangizning eng yuqori aniqligida yozadi, boshlashdan oldin darajangizni tekshirishingiz uchun jonli mikrofon o‘lchagichi bilan.

Olishni to‘xtating va u darhol o‘rnatilgan muharrirda ochiladi. Klipni bo‘lish uchun uni ikki marta bosing, har bir bo‘lakni kesish uchun tutqichlarni sudrab torting va kerak bo‘lmagan qismlarni olib tashlang. Keyin uni MP4 sifatida saqlang. Asl yozuvingiz uni tashlab yuborguningizcha saqlanadi, shuning uchun har doim qaytib, uni boshqacha kesishingiz mumkin.

Monologue ni dastur ishga tushirgichi (`Super + Space`) orqali ishga tushirasiz.
