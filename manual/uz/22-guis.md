# GUIlar

## Fayllar

Files (Nautilus) — grafik fayl menejeri. `Super + Shift + F` uni ochadi, `Super + Shift + Alt + F` esa uni terminalingiz turgan katalogda ochadi, bu juda ko'p bosishlardan qutqaradi. `Ctrl + L` sizga yo'lni yozish imkonini beradi, istalgan fayl ustida `Space` tugmasini bosish esa hech narsa ochmasdan tezkor oldindan ko'rishni beradi.

USB fleshka yoki SD karta ulang va u avtomatik tarzda ulanadi, shuning uchun u shunchaki yon panelda paydo bo'ladi. Murakkabroq ishlar — diskni formatlash, SMART holatini tekshirish, bo'limlar yaratish — uchun dastur ishga tushirgichidan (`Super + Space`) _Disks_ ni ishga tushiring.

Ikki marta bosish oqilona standartlarga amal qiladi: rasmlar imv da, video mpv da, PDFlar Document Viewer da, oddiy matn esa Neovim da ochiladi.

## Disktree

Disk to'lib qolganda va uni nima yeb qo'yayotganini bilmaganingizda, dastur ishga tushirgichidan (`Super + Space`) [Disktree](https://github.com/tobi/disktree) ni ishga tushiring. U uy katalogingizning grafik treemap ko'rinishini ko'rsatadi. Kattaroq bloklar ko'proq joy egallaydi; kataloglar ichiga klaviatura yoki sichqoncha bilan kiring, ketishi kerak bo'lgan narsalarni belgilang va biror narsani olib tashlashdan oldin tanlaganlaringizni ko'rib chiqing. Butun diskni skanerlash uchun `disktree --disk` ni ishga tushiring.

## Obsidian

[Obsidian](https://obsidian.md/) — saqlash uchun oddiy Markdown fayllardan foydalanadigan bepul va yuqori darajada kengaytiriladigan eslatma olish dasturi.

Obsidian barcha maqsadlar uchun, jumladan shaxsiy, tijorat va notijorat foydalanish uchun bepul.

Obsidian shuningdek iOS va Android dagi mobil ilovalar bilan sinxronlash uchun [tijorat qo'shimchasini](https://obsidian.md/sync) taklif qiladi. (https://obsidian.md/pricing).

Obsidian ni `Super + Shift + O` bilan ishga tushirasiz. Mavzuni sinxronlashdan foydalanish uchun sozlamalarda `Omarchy` mavzusini tanlashingiz kerak.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) — Omarchy ning o'zining o'lik darajada oddiy Markdown yozish dasturi. Vaultlar yo'q, plaginlar yo'q, faqat siz va so'zlar.

Omawrite ni `Super + Shift + W` bilan ishga tushirasiz.

## Pinta

[Pinta](https://www.pinta-project.com/) — kesish, o'lchamini o'zgartirish va boshqa asosiy amallar uchun ajoyib bo'lgan asosiy rasm tahrirlash vositasi. Faqat Photoshop muqobilini kutmang. Lekin unda baribir Magic Wand va qatlamlar bor!

Pinta ni dastur ishga tushirgichi (`Super + Space`) orqali ishga tushirasiz.

## Aether

[Aether](https://github.com/bjarneo/aether) — fon rasmdan ranglarni ajratib olib, ularni to'liq, yaxlit mavzuga aylantira oladigan mavzulashtirish dasturi. Bu [o'zingizning mavzungizni yaratishning](43-making-your-own-theme.md) eng oson yo'li.

Aether ni dastur ishga tushirgichi (`Super + Space`) orqali ishga tushirasiz.

## LocalSend

[LocalSend](https://localsend.org/) sizga Apple ning AirDrop i kabi, ilovani ishlatayotgan bir xil tarmoqdagi boshqa qurilmalarga fayllar yuborish imkonini beradi. Lekin u ko'p platformali, shuning uchun siz Windows, macOS, Android, iOS va albatta Linux ga va ulardan fayllar yuborishingiz mumkin.

Ulashish menyusini `Super + Ctrl + S` da yoki Omarchy menyusida _Trigger > Share_ ostida ochishingiz mumkin. U sizga to'rtta variantni beradi:

- **Clipboard** nusxa olgan narsangizni matn fayli sifatida yuboradi. Havola yoki parcha kodi o'zingizga elektron pochta yubormasdan telefoningizga o'tkazish uchun ajoyib.
- **File** bir vaqtning o'zida bir nechtasini tanlashingiz mumkin bo'lgan fayl tanlagichni ochadi.
- **Folder** butun katalogni yuboradi.
- **Receive** LocalSend ning o'zini ochadi, shunda boshqa qurilma sizga biror narsa yuborishi mumkin.

Xuddi shu narsa terminaldan `omarchy share clipboard`, `omarchy share file [path]` va `omarchy share folder [path]` bilan ham ishlaydi. Yo'lni qoldirib yuboring va sizga tanlagich chiqadi.

Shuningdek, to'g'ridan-to'g'ri fayl menejeridan yuborishingiz mumkin: Nautilus da istalgan tanlovni o'ng tugma bilan bosing va _Send via LocalSend_ ni tanlang.

Omarchy ning firewall i LocalSend portidan tashqari standart bo'yicha yopiq, shuning uchun bu yangi o'rnatishda qutidan chiqqan holda ishlaydi. Qarang [xavfsizlik](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) — matn protsessori, elektron jadval, taqdimotlar, chizma dasturi va boshqalarni o'z ichiga olgan to'liq ofis paketi. U Microsoft Office fayllari bilan mos keladi, shuning uchun bu o'sha Word hujjatlarini ochishning ajoyib usuli.

LibreOffice ni dastur ishga tushirgichi (`Super + Space`) orqali ishga tushirasiz.

## Hype

[Hype](https://github.com/omacom/hype) — Omarchy ning o'zining o'lik darajada oddiy taqdimot dasturi. Sizning taqdimotingiz — rasmlari va videolari yonida yotgan bitta Markdown fayl: har bir slaydni jonli oldindan ko'rish ostida yozing, slaydlarni tartibga tortib o'tkazing, keyin to'liq ekranda taqdim eting yoki PDF va PowerPoint ga eksport qiling. U hatto Omarchy mavzungizni ham oladi.

Hype ni dastur ishga tushirgichi (`Super + Space`) orqali ishga tushirasiz. Har bir tezkor tugmani ko'rish uchun uning ichida `?` ni bosing.

## Signed

[Signed](https://github.com/omacom/signed) — Omarchy ning PDFlarni imzolash va ularni to'ldirishning o'zining o'lik darajada oddiy usuli. Saqlangan imzoingizni, matnni va bugungi sanani sahifaning istalgan joyiga qo'ying, keyin imzolangan nusxani asl nusxa yoniga saqlang. Qanday qilishni bilish uchun [PDFlarni to'ldirish](27-filling-out-pdfs.md) ga qarang.

Signed ni dastur ishga tushirgichi (`Super + Space`) orqali ishga tushirasiz yoki u bilan fayl menejeridan PDF ochasiz.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) — suzuvchi oynada ochiladigan Omarchy ning o'zining o'lik darajada oddiy kalkulyatori.

Omacalc ni `Super + Shift + Q` bilan ishga tushirasiz (yoki klaviaturangizda bo'lsa, kalkulyator tugmasi bilan).

## Signal

[Signal](https://signal.org/) — E2E shifrlangan xabar almashinuvining kashshofi va yirik texnologik konglomeratlardan biri orqali o'tishni istamaydigan har kim uchun ajoyib aloqa varianti.

Signal ni `Super + Shift + G` bilan ishga tushirasiz. U asosiy o'rnatishning bir qismi emas, shuning uchun birinchi marta buni bossangiz, Omarchy uni siz uchun o'rnatishni taklif qiladi (u shuningdek Omarchy menyusida _Install > Service_ ostida ham bor).

## mpv

[mpv](https://mpv.io/) — deyarli har qanday manbadan deyarli har qanday narsani o'ynaydigan oddiy, tezkor media pleyer. Videolarni tomosha qilish uchun ajoyib.

mpv ni dastur ishga tushirgichi (`Super + Space`) orqali yoki shunchaki fayl menejerida videoni ikki marta bosish orqali ishga tushirasiz.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) — Omarchy ning o'zining o'lik darajada oddiy video kesuvchisi. Sizga faqat klipning boshi va oxirini kesish kerak bo'lganda, u to'liq video tahrirlagichni ishga tushirishdan ustun keladi.

Omacut ni dastur ishga tushirgichi (`Super + Space`) orqali ishga tushirasiz.

## Monologue

[Monologue](https://github.com/omacom/monologue) — Omarchy ning o'zining o'lik darajada oddiy veb-kamera yozib oluvchisi. Kamera va mikrofoningizni bir marta tanlang, keyin yozib olish uchun `Space` ni bosing, xuddi shu dubleni pauza qilish va davom ettirish uchun yana bosing. U har doim kamerangizning eng yuqori aniqligida yozib oladi, boshlashdan oldin darajangizni tekshirishingiz uchun jonli mikrofon o'lchagichi bilan.

Dubleni to'xtating va u darhol o'rnatilgan tahrirlagichda ochiladi. Klipni bo'lish uchun uni ikki marta bosing, har bir qismni kesish uchun tutqichlarni torting va kerak bo'lmagan qismlarni olib tashlang. Keyin uni MP4 sifatida saqlang. Asl yozuvingiz uni tashlab yuborguningizcha saqlanadi, shuning uchun siz har doim qaytib kelib, uni boshqacha kesishingiz mumkin.

Monologue ni dastur ishga tushirgichi (`Super + Space`) orqali ishga tushirasiz.
