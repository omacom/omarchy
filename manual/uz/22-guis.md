# GUIlar

## Fayllar

Files (Nautilus) — grafik fayl menejeri. `Super + Shift + F` uni ochadi, `Super + Shift + Alt + F` esa uni terminalingiz hozir turgan katalogda ochadi, bu juda ko'p bosishlardan qutqaradi. `Ctrl + L` yo'lni yozish imkonini beradi, istalgan fayl ustida `Space` bosilsa, hech narsa ochmasdan tezkor oldindan ko'rish chiqadi.

USB fleshka yoki SD kartani ulang va u avtomatik ulanadi, shuning uchun u yon panelda shunchaki paydo bo'ladi. Murakkabroq ishlar — diskni formatlash, SMART holatini tekshirish, bo'limlar yaratish — uchun ilovalar ishga tushirgichidan (`Super + Space`) _Disks_ ni ishga tushiring.

Ikki marta bosish oqilona standartlarga amal qiladi: rasmlar, videolar va musiqa Omaview da, PDFlar Document Viewer da, Markdown Omawrite da, oddiy matn esa _Setup > Default > Editor_ ostida tanlangan muharrirda ochiladi.

## Disktree

Disk to'lib qolsa va uni nima yeb tugatayotganini bilmasangiz, ilovalar ishga tushirgichidan (`Super + Space`) [Disktree](https://github.com/tobi/disktree) ni ishga tushiring. U uy katalogingizning grafik treemap ko'rinishini ko'rsatadi. Kattaroq bloklar ko'proq joy egallaydi; kataloglar ichiga klaviatura yoki sichqoncha bilan kiring, ketishi kerak bo'lgan narsalarni belgilang va biror narsani olib tashlashdan oldin tanlaganlaringizni ko'rib chiqing. Butun diskni skanerlash uchun `disktree --disk` ni ishga tushiring.

## Obsidian

[Obsidian](https://obsidian.md/) — saqlash uchun oddiy Markdown fayllaridan foydalanadigan, bepul va kengaytirish imkoniyati juda yuqori bo'lgan qaydlar ilovasi.

Obsidian barcha maqsadlar uchun bepul, jumladan shaxsiy, tijorat va notijorat foydalanish uchun.

Obsidian, shuningdek, iOS va Android dagi mobil ilovalar bilan sinxronlash uchun [tijorat qo'shimchasini](https://obsidian.md/sync) ham taklif qiladi. (https://obsidian.md/pricing).

Obsidian ni `Super + Shift + O` bilan ishga tushirasiz. Mavzu sinxronlashidan foydalanish uchun sozlamalarda `Omarchy` mavzusini tanlashingiz kerak.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) — Omarchy ning o'zining o'ta oddiy Markdown yozuv ilovasi. Vaultlar yo'q, plaginlar yo'q, faqat siz va so'zlar.

Omawrite ni `Super + Shift + W` bilan ishga tushirasiz.

## Pinta

[Pinta](https://www.pinta-project.com/) — kesish, o'lchamini o'zgartirish va boshqa oddiy amallar uchun ajoyib bo'lgan oddiy rasm tahrirlash vositasi. Faqat undan Photoshop ga muqobil bo'lishini kutmang. Lekin unda baribir Magic Wand va qatlamlar bor!

Pinta ni ilovalar ishga tushirgichi orqali (`Super + Space`) ishga tushirasiz.

## Aether

[Aether](https://github.com/bjarneo/aether) — fon rasmdan ranglarni ajratib olub, ularni to'liq, uyg'un mavzuga aylantira oladigan mavzulashtirish ilovasi. Bu [o'z mavzuingizni yaratishning](43-making-your-own-theme.md) eng oson yo'li.

Aether ni ilovalar ishga tushirgichi orqali (`Super + Space`) ishga tushirasiz.

## LocalSend

[LocalSend](https://localsend.org/) sizga ilova ishlayotgan, bitta tarmoqdagi boshqa qurilmalarga fayllar yuborish imkonini beradi, xuddi Apple ning AirDrop i kabi. Lekin u ko'p platformali, shuning uchun Windows, macOS, Android, iOS va, albatta, Linux ga va ulardan fayllar yuborishingiz mumkin.

Share menyusini `Super + Ctrl + S` bilan yoki Omarchy menyusida _Trigger > Share_ ostida ochishingiz mumkin. U sizga to'rtta variantni beradi:

- **Clipboard** nusxa olgan narsangizni matn fayli sifatida yuboradi. Havola yoki parcha kodni o'zingizga elektron pochta orqali yubormasdan telefoningizga o'tkazish uchun ajoyib.
- **File** bir vaqtning o'zida bir nechtasini tanlashingiz mumkin bo'lgan fayl tanlagichni ochadi.
- **Folder** butun katalogni yuboradi.
- **Receive** LocalSend ning o'zini ochadi, shunda boshqa qurilma sizga biror narsa yubora oladi.

Xuddi shu narsa terminaldan `omarchy share clipboard`, `omarchy share file [path]` va `omarchy share folder [path]` bilan ham ishlaydi. Yo'lni yozmasdan qoldirsangiz, tanlagich chiqadi.

To'g'ridan-to'g'ri fayl menejeridan ham yuborishingiz mumkin: Nautilus da istalgan tanlovni o'ng tugma bilan bosing va _Send via LocalSend_ ni tanlang.

Omarchy ning firewall i standart holatda LocalSend portidan tashqari yopiq, shuning uchun bu yangi o'rnatishda ham darhol ishlaydi. Qarang: [xavfsizlik](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) — matn protsessori, elektron jadval, taqdimotlar, chizma ilovasi va boshqalarni o'z ichiga olgan to'liq ofis paketi. U Microsoft Office fayllari bilan mos keladi, shuning uchun bu o'sha Word hujjatlarini ochish imkoniga ega bo'lishning ajoyib usuli.

LibreOffice ni ilovalar ishga tushirgichi orqali (`Super + Space`) ishga tushirasiz.

## Hype

[Hype](https://github.com/omacom/hype) — Omarchy ning o'zining o'ta oddiy taqdimot ilovasi. To'plamingiz — yonida rasmlari va videolari turgan bitta Markdown fayli: har bir slaydni jonli oldindan ko'rish ostida yozing, slaydlarni kerakli tartibga sudrab joylashtiring, keyin to'liq ekranda taqdim qiling yoki PDF va PowerPoint ga eksport qiling. U hatto Omarchy mavzuingizni ham oladi.

Hype ni ilovalar ishga tushirgichi orqali (`Super + Space`) ishga tushirasiz. Har bir tezkor tugmani ko'rish uchun uning ichida `?` ni bosing.

## Signed

[Signed](https://github.com/omacom/signed) — PDF larga imzo qo'yish va ularni to'ldirishning Omarchy dagi o'zining o'ta oddiy usuli. Saqlangan imzoyingiz, matn va bugungi sanani sahifaning istalgan joyiga qo'ying, keyin asl nusxaning yoniga imzolangan nusxani saqlang. Buni qanday qilishni [PDF larni to'ldirish](27-filling-out-pdfs.md) bo'limidan ko'ring.

Signed ni ilovalar ishga tushirgichi orqali (`Super + Space`) ishga tushirasiz yoki u bilan fayl menejeridan PDF ni ochasiz.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) — suzuvchi oynada ochiladigan, Omarchy ning o'zining o'ta oddiy kalkulyatori.

Omacalc ni `Super + Shift + Q` bilan ishga tushirasiz (yoki klaviaturangizda bo'lsa, kalkulyator tugmasi bilan).

## Signal

[Signal](https://signal.org/) — E2E shifrlangan xabar almashinuvning kashshofi va yirik texnologiya konglomeratlaridan biri orqali o'tishni istamaydigan har qanday kishi uchun ajoyib aloqa varianti.

Signal ni `Super + Shift + G` bilan ishga tushirasiz. U asosiy o'rnatish tarkibiga kirmaydi, shuning uchun buni birinchi marta bossangiz, Omarchy uni siz uchun o'rnatishni taklif qiladi (u Omarchy menyusida _Install > Service_ ostida ham bor).

## Omaview

[Omaview](https://github.com/omacom/omaview) — Omarchy ning o'zining o'ta oddiy rasm ko'ruvchisi va media pleeri: suratlaringiz, videolaringiz va musiqangiz uchun bitta oyna. Suratni oching va strelka tugmalari uning papkasidagi qolganlari bo'ylab o'tadi, `N` va `P` buni istalgan narsa uchun qiladi, `Ctrl + M` esa butun papkani panjara ko'rinishida ko'rsatadi. U HEIC, AVIF va JPEG XL suratlarni ham ko'rsatadi va uzun narsalarda to'xtagan joyingizdan davom etadi.

To'liq ekran uchun `F` ni, suratni Omasnap da tahrirlash yoki videoni Omacut da kesish uchun `E` ni, suratni chop etish uchun `Ctrl + P` ni va faylni Trash ga ko'chirish uchun `Delete` ni bosing (`Ctrl + Z` uni qaytarib olib keladi). Har bir tezkor tugmani ko'rish uchun uning ichida `?` ni bosing.

Omaview ni ilovalar ishga tushirgichi orqali (`Super + Space`) _Media Viewer_ sifatida ishga tushirasiz yoki fayl menejerida surat, video yoki qo'shiqni shunchaki ikki marta bosasiz.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) — Omarchy ning o'zining o'ta oddiy video kesish vositasi. Sizga kerak bo'lgani faqat klipning boshlanishi va oxirini kesib tashlash bo'lsa, u to'liq video muharririni ishga tushirishdan ancha yaxshi.

Omacut ni ilovalar ishga tushirgichi orqali (`Super + Space`) ishga tushirasiz.

## Monologue

[Monologue](https://github.com/omacom/monologue) — Omarchy ning o'zining o'ta oddiy veb-kamera yozib oluvchisi. Kamera va mikrofoningizni bir marta tanlang, keyin yozib olish uchun `Space` ni bosing, xuddi shu yozuvni pauza qilish va davom ettirish uchun yana bosing. U har doim kamerangizning eng yuqori aniqligida yozib oladi, boshlashdan oldin darajangizni tekshirishingiz uchun jonli mikrofon o'lchagichi ham bor.

Yozuvni to'xtating va u darhol o'rnatilgan muharrirda ochiladi. Klipni bo'lish uchun uni ikki marta bosing, har bir qismni kesish uchun tutqichlarni sudrab torting va kerak bo'lmagan qismlarni olib tashlang. Keyin uni MP4 sifatida saqlang. Asl yozuvingiz uni tashlab yubormaguningizcha saqlanib qoladi, shuning uchun har doim qaytib kelib, uni boshqacha kesishingiz mumkin.

Monologue ni ilovalar ishga tushirgichi orqali (`Super + Space`) ishga tushirasiz.
