# GUI ilovalar

## Files

Files (Nautilus) — grafik fayl menejeri. `Super + Shift + F` uni ochadi, `Super + Shift + Alt + F` esa uni terminalingiz turgan katalogda ochadi, bu juda ko‘p bosishlarni tejaydi. `Ctrl + L` yo‘lni yozish imkonini beradi, istalgan fayl ustida `Space` bosilsa, hech narsa ochmasdan tezkor ko‘rib chiqish chiqadi.

USB fleshka yoki SD kartani ulasang, u avtomatik ulanadi, shuning uchun shunchaki yon panelda chiqadi. Bundan murakkabroq ishlar — diskni formatlash, SMART holatini tekshirish, bo‘limlar yaratish — uchun ilovalarni ishga tushirish menyusidan (`Super + Space`) _Disks_ ni ishga tushiring.

Ikki marta bosishda oqilona standartlar ishlaydi: rasmlar, videolar va musiqa Omaview da, PDF lar Document Viewer da, Markdown Omawrite da, oddiy matn esa _Setup > Default > Editor_ ostida tanlangan muharrirda ochiladi.

## Disktree

Disk to‘lib qolsa va uni nima yeyayotganini bilmasangiz, ilovalarni ishga tushirish menyusidan (`Super + Space`) [Disktree](https://github.com/tobi/disktree) ni ishga tushiring. U uy katalogingizning grafik treemap xaritasini ko‘rsatadi. Kattaroq bloklar ko‘proq joy egallaydi; kataloglar ichiga klaviatura yoki sichqoncha bilan kiring, ketishi kerak bo‘lganlarni belgilang va biror narsani o‘chirishdan oldin tanlovingizni ko‘rib chiqing. Butun diskni skanerlash uchun `disktree --disk` ni ishga tushiring.

## Obsidian

[Obsidian](https://obsidian.md/) — saqlash uchun oddiy Markdown fayllardan foydalanadigan bepul va juda kengaytiriladigan qaydlar ilovasi.

Obsidian barcha maqsadlar uchun bepul, jumladan shaxsiy, tijorat va notijorat foydalanish uchun.

Obsidian shuningdek iOS va Android dagi mobil ilovalar bilan sinxronlash uchun [tijorat qo‘shimchasini](https://obsidian.md/sync) ham taklif qiladi. (https://obsidian.md/pricing).

Obsidian ni `Super + Shift + O` bilan ishga tushirasiz. Mavzularni sinxronlashdan foydalanish uchun sozlamalarda `Omarchy` mavzusini tanlashingiz kerak.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) — Omarchy ning o‘zining o‘ta sodda Markdown yozish ilovasi. Hech qanday vault lar ham, plaginlar ham yo‘q, faqat siz va so‘zlar.

Omawrite ni `Super + Shift + W` bilan ishga tushirasiz.

## Pinta

[Pinta](https://www.pinta-project.com/) — kesish, o‘lchamini o‘zgartirish va boshqa oddiy amallar uchun ajoyib bo‘lgan sodda rasm tahrirlash vositasi. Faqat Photoshop o‘rnini bosadi deb kutmang. Lekin unda baribir Magic Wand va qatlamlar bor!

Pinta ni ilovalarni ishga tushirish menyusi orqali ishga tushirasiz (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) — fon rasmdan ranglarni ajratib olib, ularni to‘liq, uyg‘un mavzuga aylantira oladigan mavzulashtirish ilovasi. Bu [o‘z mavzuingizni yaratishning](43-making-your-own-theme.md) eng oson yo‘li.

Aether ni ilovalarni ishga tushirish menyusi orqali ishga tushirasiz (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) xuddi Apple ning AirDrop i kabi, shu ilova ishlayotgan bir xil tarmoqdagi boshqa qurilmalarga fayl yuborish imkonini beradi. Lekin u kross-platforma, shuning uchun Windows, macOS, Android, iOS va albatta Linux ga va ulardan fayllar yuborishingiz mumkin.

Share menyusini `Super + Ctrl + S` bilan yoki Omarchy menyusida _Trigger > Share_ ostida ochishingiz mumkin. U sizga to‘rtta variant beradi:

- **Clipboard** nusxa olgan narsangizni matn fayli sifatida yuboradi. Havola yoki parchani o‘zingizga elektron pochta yubormasdan telefoningizga o‘tkazish uchun ajoyib.
- **File** bir vaqtning o‘zida bir nechtasini tanlashingiz mumkin bo‘lgan fayl tanlagichni ochadi.
- **Folder** butun katalogni yuboradi.
- **Receive** LocalSend ning o‘zini ochadi, shunda boshqa qurilma sizga biror narsa yuborishi mumkin.

Xuddi shu ish terminaldan `omarchy share clipboard`, `omarchy share file [path]` va `omarchy share folder [path]` bilan ham ishlaydi. Yo‘lni yozmasangiz, tanlagich chiqadi.

To‘g‘ridan-to‘g‘ri fayl menejeridan ham yuborishingiz mumkin: Nautilus da istalgan tanlovni sichqonchaning o‘ng tugmasi bilan bosing va _Send via LocalSend_ ni tanlang.

Omarchy ning firewall i standart holatda LocalSend portidan tashqari yopiq, shuning uchun bu yangi o‘rnatishda hech qanday sozlashsiz ishlaydi. Qarang: [xavfsizlik](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) — matn protsessori, elektron jadval, taqdimotlar, chizish ilovasi va boshqalarni o‘z ichiga olgan to‘liq ofis paketi. U Microsoft Office fayllari bilan mos keladi, shuning uchun bu o‘sha Word hujjatlarini ochishning ajoyib usuli.

LibreOffice ni ilovalarni ishga tushirish menyusi orqali ishga tushirasiz (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) — Omarchy ning o‘zining o‘ta sodda taqdimot ilovasi. Taqdimotingiz — rasmlari va videolari yonida turgan bitta Markdown fayl: har bir slaydni jonli ko‘rib chiqish ostida yozing, slaydlarni kerakli tartibga sudrab joylashtiring, keyin to‘liq ekranda taqdim eting yoki PDF va PowerPoint ga eksport qiling. U hatto Omarchy mavzuingizni ham oladi.

Hype ni ilovalarni ishga tushirish menyusi orqali ishga tushirasiz (`Super + Space`). Barcha yorliqlarni ko‘rish uchun uning ichida `?` ni bosing.

## Signed

[Signed](https://github.com/omacom/signed) — Omarchy ning PDF larni imzolash va to‘ldirishning o‘zining o‘ta sodda usuli. Saqlangan imzoyingizni, matnni va bugungi sanani sahifaning istalgan joyiga qo‘ying, keyin imzolangan nusxani asl nusxa yoniga saqlang. Qanday qilishni [PDF larni to‘ldirish](27-filling-out-pdfs.md) bo‘limida ko‘ring.

Signed ni ilovalarni ishga tushirish menyusi orqali ishga tushirasiz (`Super + Space`) yoki fayl menejeridan PDF ni u bilan ochasiz.

## Game Vibes

Game Vibes, ilovalarni ishga tushirish menyusida (`Super + Space`), Omarchy ning kichkina o‘yinlari yashaydigan joy: Checkmate — do‘stingizga yoki o‘rnatilgan raqibga qarshi 3D shaxmat o‘yini; Cards — Klondike pasyansi; va Neon Swarm — arkada otishma o‘yini. Har biri mavzuingizga moslashadigan bitta veb-sahifa. Birini strelkalar va `Enter` bilan tanlang, o‘yinning sarlavha ekranidan `Esc` bilan yoki u pauzada turganda `Q` bilan ro‘yxatga qayting. U to‘liq ekranda ochiladi: `Super + F` uni oynaga aylantiradi, `Super + W` esa yopadi.

Agent bilan yaratgan o‘yinlaringiz ham shu yerda chiqadi: agentlar panelida _Make something cool → Game_ ni tanlang va birini tasvirlab bering, yoki ustida ishlashni davom ettirish uchun Game Vibes da allaqachon bor o‘yinning nomini ayting. Agent uni `~/Games/vibes` ga nusxalaydi, u yerda uni o‘zgartirish sizniki bo‘ladi, va tayyor bo‘lganda uni ochadi. O‘sha nusxani o‘zingiz `omarchy games vibes copy <game>` bilan yaratishingiz mumkin. Boshqa birov ulashgan o‘yin mavzu kabi o‘rnatiladi: _Install > Gaming > Game Vibes_ ni tanlang va uning git manzilini joylashtiring, yoki `omarchy games vibes install <git-repo-url>` ni ishga tushiring. _Remove > Gaming_ birini yana olib tashlaydi, _Update > Game Vibes Games_ esa yangi versiyalarni olib keladi. O‘yinlar three.js ni internetdan yuklaydi, shuning uchun ishga tushish uchun ulanish kerak.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) — Omarchy ning o‘zining o‘ta sodda kalkulyatori, u suzuvchi oynada ochiladi.

Omacalc ni `Super + Shift + Q` bilan ishga tushirasiz (yoki klaviaturangizda bo‘lsa, kalkulyator tugmasi bilan).

## Signal

[Signal](https://signal.org/) — E2E shifrlangan xabar almashinuvining kashshofi va yirik texnologiya konglomeratlaridan biri orqali o‘tmaslikni afzal ko‘radigan har bir kishi uchun ajoyib aloqa varianti.

Signal ni `Super + Shift + G` bilan ishga tushirasiz. U asosiy o‘rnatishga kirmaydi, shuning uchun buni birinchi marta bossangiz, Omarchy uni siz uchun o‘rnatishni taklif qiladi (u Omarchy menyusida _Install > Service_ ostida ham bor).

## Omaview

[Omaview](https://github.com/omacom/omaview) — Omarchy ning o‘zining o‘ta sodda rasm ko‘ruvchisi va media pleyeri: fotosuratlaringiz, videolaringiz va musiqangiz uchun bitta oyna. Rasmni oching va strelka tugmalari uning katalogidagi qolganlari bo‘ylab yuradi, `N` va `P` buni istalgan narsa uchun qiladi, `Ctrl + M` esa butun katalogni to‘r sifatida ko‘rsatadi. U HEIC, AVIF va JPEG XL rasmlarni ham ko‘rsatadi va uzun narsalarda to‘xtagan joyingizdan davom etadi.

To‘liq ekran uchun `F` ni, rasmni Omasnap da tahrirlash yoki videoni Omacut da kesish uchun `E` ni, rasmni chop etish uchun `Ctrl + P` ni va faylni Trash ga ko‘chirish uchun `Delete` ni bosing (`Ctrl + Z` uni qaytaradi). Barcha yorliqlarni ko‘rish uchun uning ichida `?` ni bosing.

Omaview ni ilovalarni ishga tushirish menyusi orqali _Media Viewer_ sifatida ishga tushirasiz (`Super + Space`) yoki shunchaki fayl menejerida rasm, video yoki qo‘shiqni ikki marta bosasiz.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) — Omarchy ning o‘zining o‘ta sodda video kesuvchisi. Sizga kerak bo‘lgani faqat klipning boshi va oxirini kesish bo‘lsa, u to‘liq video muharrirni ishga tushirishdan ancha yaxshi.

Omacut ni ilovalarni ishga tushirish menyusi orqali ishga tushirasiz (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) — Omarchy ning o‘zining o‘ta sodda veb-kamera yozuvchisi. Kamera va mikrofoningizni bir marta tanlang, keyin yozish uchun `Space` ni bosing, o‘sha yozuvni pauza qilish va davom ettirish uchun yana bosing. U har doim kamerangizning eng yuqori o‘lchamida yozadi, boshlashdan oldin darajangizni tekshirishingiz uchun jonli mikrofon o‘lchagichi bilan.

Yozishni to‘xtating va u darhol o‘rnatilgan muharrirda ochiladi. Klipni bo‘lish uchun uni ikki marta bosing, har bir bo‘lakni kesish uchun tutqichlarni sudrang va kerak bo‘lmagan qismlarni olib tashlang. Keyin uni MP4 sifatida saqlang. Asl yozuvingiz uni tashlab yubormaguningizcha saqlanadi, shuning uchun har doim qaytib, uni boshqacha kesishingiz mumkin.

Monologue ni ilovalarni ishga tushirish menyusi orqali ishga tushirasiz (`Super + Space`).
