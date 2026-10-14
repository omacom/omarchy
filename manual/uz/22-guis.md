# GUIlar

## Files

Files (Nautilus) grafik fayl boshqaruvchisidir. `Super + Shift + F` uni ochadi va `Super + Shift + Alt + F` uni terminalingiz turgan katalogda ochadi, bu koʻp bosishdan qutqaradi. `Ctrl + L` yoʻl yozish imkonini beradi va istalgan faylda `Space` ni bosish hech narsa ochmasdan tezkor koʻrinish beradi.

USB fleshka yoki SD kartani ulang va u avtomatik ulanadi, shuning uchun u shunchaki yon panelda paydo boʻladi. Murakkabroq har qanday narsa uchun — diskni formatlash, SMART sogʻligʻini tekshirish, boʻlimlar yaratish — ilova ishga tushirgichidan (`Super + Space`) _Disks_ ni ishga tushiring.

Ikki marta bosish oqilona standartlarga amal qiladi: rasmlar imv da, video mpv da, PDFlar Document Viewer da va oddiy matn Neovim da ochiladi.

## Disktree

Disk toʻlib qolganda va nima uni yeyotganini bilmasangiz, ilova ishga tushirgichidan (`Super + Space`) [Disktree](https://github.com/tobi/disktree) ni ishga tushiring. U uy kataloggingizning grafik treemapini koʻrsatadi. Kattaroq bloklar koʻproq joy egallaydi; kataloglar ichiga klaviatura yoki sichqoncha bilan kiring, ketishi kerak boʻlganini belgilang va biror narsani olib tashlashdan oldin tanlovlaringizni koʻrib chiqing. Butun diskni skanerlash uchun `disktree --disk` ni ishga tushiring.

## Obsidian

[Obsidian](https://obsidian.md/) saqlash uchun oddiy Markdown fayllaridan foydalanuvchi bepul va juda kengaytiriladigan qaydlar ilovasidir.

Obsidian barcha maqsadlar, jumladan shaxsiy, tijorat va notijorat foydalanish uchun bepuldir.

Obsidian iOS va Android dagi mobil ilovalar bilan [sinxronlash uchun tijorat qoʻshimchasini](https://obsidian.md/sync) ham taklif etadi. (https://obsidian.md/pricing).

Obsidian ni `Super + Shift + O` bilan boshlaysiz. Mavzu sinxronlashdan foydalanish uchun sozlamalar ostida `Omarchy` mavzusini tanlashingiz kerak.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) Omarchy ning oʻzining juda oddiy Markdown yozish ilovasidir. Vaultlar yoʻq, plaginlar yoʻq, faqat siz va soʻzlar.

Omawrite ni `Super + Shift + W` bilan boshlaysiz.

## Pinta

[Pinta](https://www.pinta-project.com/) kesish, oʻlchamini oʻzgartirish va boshqa asosiy manipulyatsiyalar uchun ajoyib boʻlgan asosiy rasm tahrirlash vositasidir. Shunchaki Photoshop muqobilini kutmang. Lekin unda Magic Wand va qatlamlar ham bor!

Pinta ni ilova ishga tushirgichi (`Super + Space`) orqali boshlaysiz.

## Aether

[Aether](https://github.com/bjarneo/aether) fon rasmidan ranglarni chiqarib, ularni toʻliq, yaxlit mavzuga aylantira oladigan mavzulashtirish ilovasidir. Bu [oʻz mavzungizni yaratish](43-making-your-own-theme.md) ning eng oson yoʻlidir.

Aether ni ilova ishga tushirgichi (`Super + Space`) orqali boshlaysiz.

## LocalSend

[LocalSend](https://localsend.org/) sizga Apple ning AirDrop kabi ilovani ishlatuvchi bir xil tarmoqdagi boshqa qurilmalarga fayllar yuborish imkonini beradi. Biroq u kross-platforma, shuning uchun Windows, macOS, Android, iOS va albatta Linux ga va ulardan fayllar yuborishingiz mumkin.

Ulashish menyusini `Super + Ctrl + S` da yoki Omarchy menyusidagi _Ishga tushirish > Share_ ostida ochishingiz mumkin. U sizga toʻrtta variant beradi:

- **Clipboard** nusxa olgan narsangizni matn fayli sifatida yuboradi. Oʻzingizga elektron pochta yubormasdan havola yoki parchani telefoningizga olish uchun ajoyib.
- **File** bir vaqtning oʻzida bir nechtasini tanlashingiz mumkin boʻlgan fayl tanlagichni ochadi.
- **Folder** butun katalogni yuboradi.
- **Receive** boshqa qurilma sizga biror narsa yuborishi uchun LocalSend ning oʻzini ochadi.

Xuddi shu narsa terminaldan `omarchy share clipboard`, `omarchy share file [path]` va `omarchy share folder [path]` bilan ham ishlaydi. Yoʻlni qoldirib keting va tanlagichni olasiz.

Fayl boshqaruvchisidan toʻgʻridan-toʻgʻri ham yuborishingiz mumkin: Nautilus da istalgan tanlovni oʻng tugma bilan bosing va _Send via LocalSend_ ni tanlang.

Omarchy ning xavfsizlik devori LocalSend portidan tashqari standart tarzda yopiq, shuning uchun bu yangi oʻrnatishda qutidan chiqqanidayoq ishlaydi. [security](48-security.md) ga qarang.

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) soʻz protsessori, jadval, taqdimotlar, chizish ilovasi va boshqalar bilan toʻliq ofis paketidir. U Microsoft Office fayllari bilan mos keladi, shuning uchun bu oʻsha Word hujjatlarini ocha olishning ajoyib yoʻlidir.

LibreOffice ni ilova ishga tushirgichi (`Super + Space`) orqali boshlaysiz.

## Hype

[Hype](https://github.com/omacom/hype) Omarchy ning oʻzining juda oddiy taqdimot ilovasidir. Sizning toʻplamingiz rasmlari va videolari yonida boʻlgan bitta Markdown faylidir: har bir slaydni jonli koʻrinish ostida yozing, slaydlarni tartibga sudrab oʻtkazing, keyin toʻliq ekran taqdim eting yoki PDF va PowerPoint ga eksport qiling. U hatto Omarchy mavzungizni ham oladi.

Hype ni ilova ishga tushirgichi (`Super + Space`) orqali boshlaysiz. Har bir yorliqni koʻrish uchun uning ichida `?` ni bosing.

## Signed

[Signed](https://github.com/omacom/signed) Omarchy ning PDFlarni imzolash va toʻldirishning oʻzining juda oddiy usulidir. Saqlangan imzongizni, matnni va bugungi sanani sahifaning istalgan joyiga qoʻying, keyin asl nusxa yonida imzolangan nusxani saqlang. Qanday qilish uchun [Filling out PDFs](27-filling-out-pdfs.md) ga qarang.

Signed ni ilova ishga tushirgichi (`Super + Space`) orqali boshlaysiz yoki fayl boshqaruvchisidan u bilan PDF ochasiz.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) suzuvchi oynada ochiladigan Omarchy ning oʻzining juda oddiy kalkulyatoridir.

Omacalc ni `Super + Ctrl + Q` bilan boshlaysiz (yoki klaviaturangizda boʻlsa, kalkulyator tugmasi bilan).

## Signal

[Signal](https://signal.org/) E2E shifrlangan xabar almashishning kashshofidir va yirik texnologik konglomeratlardan biri orqali oʻtishni istamaydigan har bir kishi uchun ajoyib aloqa variantidir.

Signal ni `Super + Shift + G` bilan boshlaysiz. U asosiy oʻrnatishning bir qismi emas, shuning uchun birinchi marta uni bossangiz, Omarchy uni siz uchun oʻrnatishni taklif qiladi (u Omarchy menyusidagi _Oʻrnatish > Service_ ostida ham bor).

## mpv

[mpv](https://mpv.io/) deyarli istalgan manbadan deyarli istalgan narsani ijro etuvchi oddiy, tez media pleyerdir. Videolarni koʻrish uchun ajoyib.

mpv ni ilova ishga tushirgichi (`Super + Space`) orqali boshlaysiz yoki fayl boshqaruvchisida videoga shunchaki ikki marta bosasiz.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) Omarchy ning oʻzining juda oddiy video qirqish vositasidir. Sizga kerak boʻlgan narsa faqat klipning boshi va oxirini kesish boʻlsa, u toʻliq video muharririni ishga tushirishdan yaxshiroqdir.

Omacut ni ilova ishga tushirgichi (`Super + Space`) orqali boshlaysiz.

## Monologue

[Monologue](https://github.com/omacom/monologue) Omarchy ning oʻzining juda oddiy veb-kamera yozuvchisidir. Kamera va mikrofoningizni bir marta tanlang, keyin yozish uchun `Space` ni bosing va xuddi shu kadrni pauza qilish va davom ettirish uchun yana bosing. U har doim kamerangizning eng yuqori aniqligida yozadi, boshlashdan oldin darajangizni tekshirishingiz uchun jonli mikrofon oʻlchagichi bilan.

Kadrni toʻxtating va u darhol oʻrnatilgan muharrirda ochiladi. Klipni boʻlish uchun ikki marta bosing, har bir qismni qirqish uchun tutqichlarni sudrab oʻtkazing va istamagan qismlarni olib tashlang. Keyin uni MP4 sifatida saqlang. Asl yozuvingiz uni tashlab yuborishingizgacha saqlanadi, shuning uchun har doim qaytib kelib uni boshqacha kesishingiz mumkin.

Monologue ni ilova ishga tushirgichi (`Super + Space`) orqali boshlaysiz.
