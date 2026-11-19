# GUIlar

## Files

Files (Folio) — grafik fayl menejeri. `Super + Shift + F` uni ochadi, `Super + Shift + Alt + F` esa uni terminalingiz turgan katalogda ochadi, bu esa ko'p bosishlardan qutqaradi. `Ctrl + L` yo'lni yozish imkonini beradi, istalgan faylda `Space` ni bosish esa uni ochmasdan to'liq o'lchamda oldindan ko'rsatadi.

USB fleshka yoki SD kartani ulang va u avtomatik ulanadi, shuning uchun u shunchaki yon panelda paydo bo'ladi. Murakkabroq ishlar — diskni formatlash, SMART holatini tekshirish, bo'limlar yaratish — uchun ilovalarni ishga tushirgichdan (`Super + Space`) _Disks_ ni ishga tushiring.

Ikki marta bosish oqilona standartlarga amal qiladi: rasmlar, videolar va musiqa Omaview da, PDFlar Document Viewer da, Markdown Omawrite da, oddiy matn esa _Setup > Default > Editor_ ostida tanlangan muharrirda ochiladi.

## Disktree

Disk to'lib ketganda va uni nima yeb qo'yayotganini bilmasangiz, ilovalarni ishga tushirgichdan (`Super + Space`) [Disktree](https://github.com/tobi/disktree) ni ishga tushiring. U uy katalogingizning grafik treemap xaritasini ko'rsatadi. Kattaroq bloklar ko'proq joy egallaydi; klaviatura yoki sichqoncha bilan kataloglar ichiga kiring, ketishi kerak bo'lgan narsalarni belgilang va biror narsani o'chirishdan oldin tanlovingizni ko'rib chiqing. Butun diskni skanerlash uchun `disktree --disk` ni ishga tushiring.

## Obsidian

[Obsidian](https://obsidian.md/) — saqlash uchun oddiy Markdown fayllaridan foydalanadigan bepul va juda kengaytiriladigan qaydlar olish ilovasi.

Obsidian barcha maqsadlar uchun bepul, jumladan shaxsiy, tijorat va notijorat foydalanish uchun.

Obsidian shuningdek iOS va Android dagi mobil ilovalar bilan [sinxronlash uchun tijorat qo'shimchasini](https://obsidian.md/sync) taklif qiladi. (https://obsidian.md/pricing).

Obsidian ni `Super + Shift + O` bilan ishga tushirasiz. Mavzularni sinxronlashdan foydalanish uchun sozlamalarda `Omarchy` mavzusini tanlashingiz kerak.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) — Omarchy ning o'zining o'ta sodda Markdown yozish ilovasi. Vaultlar yo'q, plaginlar yo'q, faqat siz va so'zlar.

Omawrite ni `Super + Shift + W` bilan ishga tushirasiz.

## Pinta

[Pinta](https://www.pinta-project.com/) — kesish, o'lchamini o'zgartirish va boshqa oddiy manipulyatsiyalar uchun ajoyib bo'lgan oddiy rasm tahrirlash vositasi. Faqat Photoshop ga muqobil bo'lishini kutmang. Lekin unda baribir Magic Wand va qatlamlar bor!

Pinta ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) — fon rasmdan ranglarni ajratib olib, ularni to'liq, yaxlit mavzuga aylantira oladigan mavzulashtirish ilovasi. Bu [o'zingizning mavzungizni yaratishning](43-making-your-own-theme.md) eng oson yo'li.

Aether ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) sizga ilova ishlayotgan, xuddi shu tarmoqdagi boshqa qurilmalarga fayllar yuborish imkonini beradi, xuddi Apple ning AirDrop i kabi. Biroq u kross-platforma, shuning uchun fayllarni Windows, macOS, Android, iOS va albatta Linux bilan o'zaro yuborishingiz mumkin.

Share menyusini `Super + Ctrl + S` da yoki Omarchy menyusida _Trigger > Share_ ostida ochishingiz mumkin. U sizga to'rtta variantni beradi:

- **Clipboard** nusxa olgan narsangizni matn fayli sifatida yuboradi. O'zingizga elektron pochta yubormasdan havola yoki parchani telefoningizga o'tkazish uchun ajoyib.
- **File** bir vaqtning o'zida bir nechtasini tanlashingiz mumkin bo'lgan fayl tanlagichni ochadi.
- **Folder** butun katalogni yuboradi.
- **Receive** boshqa qurilma sizga biror narsa yuborishi uchun LocalSend ning o'zini ochadi.

Xuddi shu narsa terminaldan `omarchy share clipboard`, `omarchy share file [path]` va `omarchy share folder [path]` bilan ishlaydi. Yo'lni yozmasangiz, tanlagich ochiladi.

Siz shuningdek to'g'ridan-to'g'ri fayl menejeridan yuborishingiz mumkin: Files da istalgan tanlovni sichqonchaning o'ng tugmasi bilan bosing va uni LocalSend bilan ulashing.

Omarchy ning firewall i standart holatda LocalSend portidan tashqari yopiq, shuning uchun bu yangi o'rnatishda qutidan chiqqan holda ishlaydi. Qarang: [xavfsizlik](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) — matn protsessori, elektron jadval, taqdimotlar, chizish ilovasi va boshqalarni o'z ichiga olgan to'liq ofis paketi. U Microsoft Office fayllari bilan mos keladi, shuning uchun bu o'sha Word hujjatlarini ochishning ajoyib usuli.

LibreOffice ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) — Omarchy ning o'zining o'ta sodda taqdimot ilovasi. Taqdimotingiz — rasmlari va videolari yonida joylashgan bitta Markdown fayli: har bir slaydni jonli oldindan ko'rish ostida yozing, slaydlarni tartib bo'yicha sudrab joylashtiring, so'ng to'liq ekranda taqdim eting yoki PDF va PowerPoint ga eksport qiling. U hatto Omarchy mavzungizni ham qabul qiladi.

Hype ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`). Har bir klaviatura yorlig'ini ko'rish uchun uning ichida `?` ni bosing.

## Signed

[Signed](https://github.com/omacom/signed) — Omarchy ning PDFlarni imzolash va ularni to'ldirishning o'zining o'ta sodda usuli. Saqlangan imzoingiz, matningiz va bugungi sanani sahifaning istalgan joyiga qo'ying, so'ng imzolangan nusxani asl nusxa yoniga saqlang. Qanday qilishni [PDFlarni to'ldirish](27-filling-out-pdfs.md) bo'limida ko'ring.

Signed ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`) yoki fayl menejeridan u bilan PDF ochasiz.

## Game Vibes

Game Vibes, ilovalarni ishga tushirgichda (`Super + Space`), — Omarchy ning kichik o'yinlari joylashgan joy: Checkmate, do'stingizga yoki o'rnatilgan raqibga qarshi 3D shaxmat o'yini; Cards, Klondike solitaire; va Neon Swarm, arkada otishma o'yini. Har biri sizning mavzungizga amal qiladigan bitta veb-sahifa. Strelkalar va `Enter` bilan birini tanlang, o'yinning sarlavha ekranidan `Esc` bilan yoki u pauza qilinganda `Q` bilan ro'yxatga qayting. U to'liq ekranda ochiladi: `Super + F` uni oynaga aylantiradi, `Super + W` esa uni yopadi.

Agent bilan qilgan o'yinlaringiz ham shu yerda chiqadi: agentlar panelida _Make something cool → Game_ ni tanlang va birini tasvirlab bering, yoki ustida ishlashni davom ettirish uchun Game Vibes da allaqachon bor bo'lgan o'yinni nomlang. Agent uni `~/Games/vibes` ga nusxalaydi, u yerda u o'zgartirishingiz uchun sizniki bo'ladi va tayyor bo'lganda uni ochadi. O'sha nusxani o'zingiz `omarchy games vibes copy <game>` bilan qilishingiz mumkin. Boshqa birov ulashgan o'yin xuddi mavzu kabi o'rnatiladi: _Install > Gaming > Game Vibes_ ni tanlang va uning git manzilini qo'ying, yoki `omarchy games vibes install <git-repo-url>` ni ishga tushiring. _Remove > Gaming_ birini yana olib tashlaydi, _Update > Game Vibes Games_ esa yangi versiyalarni olib keladi. O'yinlar three.js ni internetdan yuklaydi, shuning uchun boshlash uchun ularga ulanish kerak.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) — suzuvchi oynada ochiladigan Omarchy ning o'zining o'ta sodda kalkulyatori.

Omacalc ni `Super + Shift + Q` bilan (yoki klaviaturangizda bo'lsa, kalkulyator tugmasi bilan) ishga tushirasiz.

## Signal

[Signal](https://signal.org/) — E2E shifrlangan xabar almashinuvining kashshofi va katta texnologiya konglomeratlaridan biri orqali o'tishni istamaydigan har bir kishi uchun ajoyib aloqa varianti.

Signal ni `Super + Shift + G` bilan ishga tushirasiz. U asosiy o'rnatishga kirmaydi, shuning uchun buni birinchi marta bosganingizda, Omarchy uni siz uchun o'rnatishni taklif qiladi (u shuningdek Omarchy menyusida _Install > Service_ ostida ham bor).

## Omaview

[Omaview](https://github.com/omacom/omaview) — Omarchy ning o'zining o'ta sodda rasm ko'ruvchisi va media pleyeri: fotosuratlaringiz, videolaringiz va musiqangiz uchun bitta oyna. Fotosuratni oching va strelka tugmalari uning papkasidagi qolgani bo'ylab harakatlanadi, `N` va `P` buni hamma narsa uchun qiladi, `Ctrl + M` esa butun papkani panjara sifatida ko'rsatadi. U HEIC, AVIF va JPEG XL fotosuratlarini ham ko'rsatadi va uzun narsalarda to'xtagan joyingizdan davom etadi.

`F` ni to'liq ekran uchun, `E` ni rasmni Omasnap da tahrirlash yoki videoni Omacut da kesish uchun, `Ctrl + P` ni rasmni chop etish uchun va `Delete` ni faylni Trash ga ko'chirish uchun bosing (`Ctrl + Z` uni qaytaradi). Har bir klaviatura yorlig'ini ko'rish uchun uning ichida `?` ni bosing.

Omaview ni ilovalarni ishga tushirgich orqali _Media Viewer_ sifatida ishga tushirasiz (`Super + Space`) yoki fayl menejerida rasm, video yoki qo'shiqni shunchaki ikki marta bosasiz.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) — Omarchy ning o'zining o'ta sodda video kesuvchisi. Sizga kerak bo'lgan narsa faqat klipning boshi va oxirini kesish bo'lsa, u to'liq video muharririni ishga tushirishdan ustun turadi.

Omacut ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) — Omarchy ning o'zining o'ta sodda veb-kamera yozuvchisi. Kamera va mikrofoningizni bir marta tanlang, so'ng yozish uchun `Space` ni bosing, xuddi shu yozuvni pauza qilish va davom ettirish uchun yana bosing. U har doim kamerangizning eng yuqori aniqligida yozadi, boshlashdan oldin darajangizni tekshirishingiz uchun jonli mikrofon o'lchagichi bilan.

Yozuvni to'xtating va u darhol o'rnatilgan muharrirda ochiladi. Klipni bo'lish uchun uni ikki marta bosing, har bir bo'lakni kesish uchun tutqichlarni sudrang va xohlamagan qismlaringizni olib tashlang. So'ng uni MP4 sifatida saqlang. Asl yozuvingiz uni tashlab yubormaguningizcha saqlanadi, shuning uchun har doim qaytib kelib uni boshqacha kesishingiz mumkin.

Monologue ni ilovalarni ishga tushirgich orqali ishga tushirasiz (`Super + Space`).
