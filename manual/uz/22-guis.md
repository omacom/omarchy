# GUIs

## Files

Files (Nautilus) — grafik fayl menejeri. `Super + Shift + F` uni ochadi, `Super + Shift + Alt + F` esa uni terminalingiz turgan katalogda ochadi, bu juda ko'p bosishlardan qutqaradi. `Ctrl + L` yo'l yozish imkonini beradi, istalgan faylda `Space` tugmasini bosish esa hech narsa ochmasdan tez ko'rib chiqish imkonini beradi.

USB fleshkani yoki SD kartani ulasangiz, u avtomatik ulanadi, shuning uchun u shunchaki yon panelda paydo bo'ladi. Murakkabroq ishlar — diskni formatlash, SMART holatini tekshirish, bo'limlar yaratish — uchun ilovalarni ishga tushirgichdan (`Super + Space`) _Disks_ ni ishga tushiring.

Ikki marta bosish oqilona standartlarga amal qiladi: rasmlar, videolar va musiqa Omaview da, PDFlar Document Viewer da, Markdown Omawrite da, oddiy matn esa _Setup > Default > Editor_ ostida tanlangan muharrirda ochiladi.

## Disktree

Disk to'lib qolsa va uni nima yeb tugatayotganini bilmasangiz, ilovalarni ishga tushirgichdan (`Super + Space`) [Disktree](https://github.com/tobi/disktree) ni ishga tushiring. U uy katalogingizning grafik treemap ko'rinishini ko'rsatadi. Kattaroq bloklar ko'proq joy egallaydi; kataloglar ichiga klaviatura yoki sichqoncha bilan kiring, ketishi kerak bo'lgan narsalarni belgilang va biror narsani olib tashlashdan oldin tanlaganlaringizni ko'rib chiqing. Butun diskni skanerlash uchun `disktree --disk` ni ishga tushiring.

## Obsidian

[Obsidian](https://obsidian.md/) — saqlash uchun oddiy Markdown fayllaridan foydalanadigan bepul va juda kengaytiriladigan qaydlar ilovasi.

Obsidian barcha maqsadlarda, jumladan shaxsiy, tijorat va notijorat foydalanish uchun bepul.

Obsidian shuningdek iOS va Android dagi mobil ilovalar bilan sinxronlash uchun [pullik qo'shimcha](https://obsidian.md/sync) ham taklif qiladi. (https://obsidian.md/pricing).

Obsidian ni `Super + Shift + O` bilan ishga tushirasiz. Mavzularni sinxronlashdan foydalanish uchun sozlamalarda `Omarchy` mavzusini tanlashingiz kerak.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) — Omarchy ning o'zining o'lik darajada oddiy Markdown yozish ilovasi. Vaultlar yo'q, plaginlar yo'q, faqat siz va so'zlar.

Omawrite ni `Super + Shift + W` bilan ishga tushirasiz.

## Pinta

[Pinta](https://www.pinta-project.com/) — kesish, o'lchamini o'zgartirish va boshqa asosiy amallar uchun ajoyib bo'lgan oddiy rasm tahrirlash vositasi. Faqat undan Photoshop ga muqobil bo'lishini kutmang. Lekin unda baribir Magic Wand va qatlamlar bor!

Pinta ni ilovalarni ishga tushirgich orqali (`Super + Space`) ishga tushirasiz.

## Aether

[Aether](https://github.com/bjarneo/aether) — fon rasmdan ranglarni ajratib olib, ularni to'liq, uyg'un mavzuga aylantira oladigan mavzulashtirish ilovasi. Bu [o'z mavzuingizni yaratish](43-making-your-own-theme.md) ning eng oson yo'li.

Aether ni ilovalarni ishga tushirgich orqali (`Super + Space`) ishga tushirasiz.

## LocalSend

[LocalSend](https://localsend.org/) ushbu ilova ishlayotgan, bir xil tarmoqdagi boshqa qurilmalarga fayllar yuborish imkonini beradi, xuddi Apple ning AirDrop i kabi. Lekin u kross-platforma, shuning uchun siz Windows, macOS, Android, iOS va albatta Linux ga va ulardan fayllar yuborishingiz mumkin.

Share menyusini `Super + Ctrl + S` bilan yoki Omarchy menyusida _Trigger > Share_ ostida ochishingiz mumkin. U sizga to'rtta variantni beradi:

- **Clipboard** nusxa olgan narsangizni matn fayli sifatida yuboradi. O'zingizga email yubormasdan havolani yoki parcha kodni telefoningizga o'tkazish uchun ajoyib.
- **File** bir vaqtning o'zida bir nechtasini tanlashingiz mumkin bo'lgan fayl tanlagichni ochadi.
- **Folder** butun katalogni yuboradi.
- **Receive** LocalSend ning o'zini ochadi, shunda boshqa qurilma sizga biror narsa yubora oladi.

Xuddi shu narsa terminaldan `omarchy share clipboard`, `omarchy share file [path]` va `omarchy share folder [path]` bilan ham ishlaydi. Yo'lni yozmasdan qoldiring va tanlagich chiqadi.

To'g'ridan-to'g'ri fayl menejeridan ham yuborishingiz mumkin: Nautilus da istalgan tanlovni sichqonchaning o'ng tugmasi bilan bosing va _Send via LocalSend_ ni tanlang.

Omarchy ning firewall i standart holatda LocalSend portidan tashqari yopiq, shuning uchun bu yangi o'rnatishda qutidan chiqqan holda ishlaydi. [xavfsizlik](48-security.md) ga qarang.

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) — matn protsessori, elektron jadval, taqdimotlar, chizish ilovasi va boshqalarni o'z ichiga olgan to'liq ofis paketi. U Microsoft Office fayllari bilan mos keladi, shuning uchun bu o'sha Word hujjatlarini ochishning ajoyib yo'li.

LibreOffice ni ilovalarni ishga tushirgich orqali (`Super + Space`) ishga tushirasiz.

## Hype

[Hype](https://github.com/omacom/hype) — Omarchy ning o'zining o'lik darajada oddiy taqdimot ilovasi. Taqdimotingiz — rasmlari va videolari yonida turgan bitta Markdown fayli: har bir slaydni jonli ko'rib chiqish ostida yozing, slaydlarni tartibga tortib o'tkazing, keyin to'liq ekranda taqdim eting yoki PDF va PowerPoint ga eksport qiling. U hatto Omarchy mavzuingizni ham oladi.

Hype ni ilovalarni ishga tushirgich orqali (`Super + Space`) ishga tushirasiz. Har bir tezkor tugmani ko'rish uchun uning ichida `?` ni bosing.

## Signed

[Signed](https://github.com/omacom/signed) — Omarchy ning PDFlarni imzolash va to'ldirishning o'zining o'lik darajada oddiy usuli. Saqlangan imzoingizni, matnni va bugungi sanani sahifaning istalgan joyiga qo'ying, keyin imzolangan nusxani asl nusxa yoniga saqlang. Buni qanday qilishni [PDFlarni to'ldirish](27-filling-out-pdfs.md) dan ko'ring.

Signed ni ilovalarni ishga tushirgich orqali (`Super + Space`) ishga tushirasiz yoki fayl menejeridan PDF ni u bilan ochasiz.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) — Omarchy ning o'zining 3D shaxmat o'yini. Bitta kompyuterda do'stingiz bilan yoki uch darajada o'rnatilgan raqibga qarshi, har biri o'z uslubida harakatlanadigan to'rtta haykaldek to'plamda o'ynang: orbital kemalar, o'yilgan yog'och va fil suyagi, o'rmon jonzotlari va konfetlar. O'yinlarda soat yo'q va har bir yurishdan keyin saqlanadi.

Checkmate ni ilovalarni ishga tushirgich orqali (`Super + Space`) ishga tushirasiz. Har bir tezkor tugmani ko'rish uchun uning ichida `?` ni bosing.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) — Omarchy ning suzuvchi oynada ochiladigan o'zining o'lik darajada oddiy kalkulyatori.

Omacalc ni `Super + Shift + Q` bilan ishga tushirasiz (yoki klaviaturangizda bo'lsa, kalkulyator tugmasi bilan).

## Signal

[Signal](https://signal.org/) — E2E shifrlangan xabar almashishning kashshofi va yirik texnologiya konglomeratlaridan biri orqali o'tishni istamaydigan har bir kishi uchun ajoyib aloqa varianti.

Signal ni `Super + Shift + G` bilan ishga tushirasiz. U asosiy o'rnatish tarkibiga kirmaydi, shuning uchun buni birinchi marta bossangiz, Omarchy uni siz uchun o'rnatishni taklif qiladi (u Omarchy menyusida _Install > Service_ ostida ham bor).

## Omaview

[Omaview](https://github.com/omacom/omaview) — Omarchy ning o'zining o'lik darajada oddiy rasm ko'rgichi va media pleeri: suratlaringiz, videolaringiz va musiqangiz uchun bitta oyna. Suratni oching va strelka tugmalari uning papkasidagi qolganlari bo'ylab o'tadi, `N` va `P` buni har qanday narsa uchun qiladi, `Ctrl + M` esa butun papkani to'r ko'rinishida ko'rsatadi. U HEIC, AVIF va JPEG XL suratlarni ham ko'rsatadi va uzun narsalarda to'xtagan joyingizdan davom etadi.

To'liq ekran uchun `F` ni, rasmni Omasnap da tahrirlash yoki videoni Omacut da kesish uchun `E` ni, rasmni chop etish uchun `Ctrl + P` ni va faylni Trash ga ko'chirish uchun `Delete` ni bosing (`Ctrl + Z` uni qaytarib olib keladi). Har bir tezkor tugmani ko'rish uchun uning ichida `?` ni bosing.

Omaview ni ilovalarni ishga tushirgich orqali _Media Viewer_ sifatida (`Super + Space`) ishga tushirasiz yoki fayl menejerida rasm, video yoki qo'shiqni shunchaki ikki marta bosasiz.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) — Omarchy ning o'zining o'lik darajada oddiy video kesuvchisi. Sizga faqat klipning boshi va oxirini kesish kerak bo'lganda, u to'liq video muharrirni ishga tushirishdan yaxshiroq.

Omacut ni ilovalarni ishga tushirgich orqali (`Super + Space`) ishga tushirasiz.

## Monologue

[Monologue](https://github.com/omacom/monologue) — Omarchy ning o'zining o'lik darajada oddiy veb-kamera yozuvchisi. Kamera va mikrofoningizni bir marta tanlang, keyin yozish uchun `Space` ni bosing, xuddi shu dubleni pauza qilish va davom ettirish uchun yana bosing. U har doim kamerangizning eng yuqori aniqligida yozadi, boshlashdan oldin darajangizni tekshirishingiz uchun jonli mikrofon o'lchagichi bilan.

Dubleni to'xtating va u darhol o'rnatilgan muharrirda ochiladi. Klipni bo'lish uchun uni ikki marta bosing, har bir bo'lakni kesish uchun tutqichlarni torting va kerak bo'lmagan qismlarni olib tashlang. Keyin uni MP4 sifatida saqlang. Asl yozuvingiz uni tashlab yubormaguningizcha saqlanadi, shuning uchun har doim qaytib kelib, uni boshqacha kesishingiz mumkin.

Monologue ni ilovalarni ishga tushirgich orqali (`Super + Space`) ishga tushirasiz.
