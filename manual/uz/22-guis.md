# GUI ilovalari

## Fayllar

Files (Folio) — grafik fayl menejeri. `Super + Shift + F` uni ochadi, `Super + Shift + Alt + F` esa uni terminalingiz turgan katalogda ochadi, bu koʻp bosishlardan qutqaradi. `Ctrl + L` yoʻl yozish imkonini beradi, istalgan faylda `Space` bosilsa, uni ochmasdan toʻliq hajmda oldindan koʻrsatadi.

USB fleshka yoki SD kartani ulang va u avtomatik ulanadi, shunda u shunchaki yon panelda paydo boʻladi. Murakkabroq ishlar — diskni formatlash, SMART holatini tekshirish, boʻlimlar yaratish — uchun ilovalarni ishga tushirgichdan (`Super + Space`) _Disks_ ni ishga tushiring.

Ikki marta bosish oqilona standartlarga amal qiladi: rasmlar, videolar va musiqa Omaview da, PDFlar Document Viewer da, Markdown Omawrite da, oddiy matn esa muharriringizda ochiladi — _Setup > Defaults > Editor_ ostida boshqa birini tanlamasangiz, Plain da.

## Disktree

Disk toʻlib ketganda va uni nima yeyayotganini bilmasangiz, ilovalarni ishga tushirgichdan (`Super + Space`) [Disktree](https://github.com/tobi/disktree) ni ishga tushiring. U uy katalogingizning grafik treemapini koʻrsatadi. Kattaroq bloklar koʻproq joy egallaydi; kataloglar ichiga klaviatura yoki sichqoncha bilan kiring, ketishi kerak boʻlganlarni belgilang va biror narsani oʻchirishdan oldin tanlaganlaringizni koʻrib chiqing. Butun diskni skanerlash uchun `disktree --disk` ni ishga tushiring.

## Obsidian

[Obsidian](https://obsidian.md/) — saqlash uchun oddiy Markdown fayllaridan foydalanadigan bepul va juda kengaytiriladigan qayd olish ilovasi.

Obsidian barcha maqsadlar uchun, jumladan shaxsiy, tijorat va notijorat foydalanish uchun bepul.

Obsidian iOS va Android dagi mobil ilovalar bilan sinxronlash uchun [tijorat qoʻshimchasini](https://obsidian.md/sync) ham taklif qiladi. (https://obsidian.md/pricing).

Obsidian ni `Super + Shift + O` bilan ishga tushirasiz. Tema sinxronlashdan foydalanish uchun sozlamalar ostida `Omarchy` temasini tanlashingiz kerak.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) — Omarchy ning oʻzining oʻta oddiy Markdown yozish ilovasi. Vaultlar yoʻq, plaginlar yoʻq, faqat siz va soʻzlar.

Omawrite ni `Super + Shift + W` bilan ishga tushirasiz.

## Pinta

[Pinta](https://www.pinta-project.com/) — kesish, oʻlchamni oʻzgartirish va boshqa asosiy amallar uchun ajoyib asosiy rasm tahrirlash vositasi. Faqat Photoshop alternativi kutmang. Lekin baribir uning Magic Wand i va qatlamlari bor!

Pinta ni ilovalarni ishga tushirgich (`Super + Space`) orqali ishga tushirasiz.

## Aether

[Aether](https://github.com/bjarneo/aether) — fon rasmdan ranglarni ajratib olib, ularni toʻliq, uygʻun temaga aylantira oladigan temalar ilovasi. Bu [oʻz temangizni yaratishning](43-making-your-own-theme.md) eng oson yoʻli.

Aether ni ilovalarni ishga tushirgich (`Super + Space`) orqali ishga tushirasiz.

## LocalSend

[LocalSend](https://localsend.org/) Apple ning AirDrop iga oʻxshab, ilova ishlayotgan bir xil tarmoqdagi boshqa qurilmalarga fayllar yuborish imkonini beradi. Biroq u kross-platforma, shuning uchun Windows, macOS, Android, iOS va albatta Linux ga va ulardan fayllar yuborishingiz mumkin.

Share menyusini `Super + Ctrl + S` bilan yoki Omarchy menyusida _Trigger > Share_ ostida ochishingiz mumkin. U sizga toʻrtta variant beradi:

- **Clipboard** nusxa olgan narsangizni matn fayli sifatida yuboradi. Havola yoki parchani oʻzingizga email yubormasdan telefoningizga yetkazish uchun ajoyib.
- **File** bir vaqtning oʻzida bir nechtasini tanlashingiz mumkin boʻlgan fayl tanlagichni ochadi.
- **Folder** butun katalogni yuboradi.
- **Receive** boshqa qurilma sizga biror narsa yuborishi uchun LocalSend ning oʻzini ochadi.

Xuddi shu narsa terminaldan `omarchy share clipboard`, `omarchy share file [path]` va `omarchy share folder [path]` bilan ham ishlaydi. Yoʻlni qoldirib yuborsangiz, tanlagichni olasiz.

Fayl menejeridan ham toʻgʻridan-toʻgʻri yuborishingiz mumkin: Files da istalgan tanlovni oʻng tugma bilan bosing va uni LocalSend bilan ulashing.

Omarchy ning firewalli standart holatda LocalSend portidan tashqari yopiq, shuning uchun bu yangi oʻrnatishda darhol ishlaydi. [xavfsizlik](48-security.md) ga qarang.

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) — matn protsessori, elektron jadval, taqdimotlar, chizish ilovasi va boshqalarni oʻz ichiga olgan toʻliq ofis paketi. U Microsoft Office fayllari bilan mos keladi, shuning uchun bu oʻsha Word hujjatlarini ochishning ajoyib yoʻli.

LibreOffice ni ilovalarni ishga tushirgich (`Super + Space`) orqali ishga tushirasiz.

## Hype

[Hype](https://github.com/omacom/hype) — Omarchy ning oʻzining oʻta oddiy taqdimot ilovasi. Toʻplamingiz rasmlari va videolari yonida turgan bitta Markdown fayli: har bir slaydni jonli oldindan koʻrish ostida yozing, slaydlarni tartibga torting, keyin toʻliq ekranda taqdim eting yoki PDF va PowerPoint ga eksport qiling. U hatto Omarchy temangizni ham oladi.

Hype ni ilovalarni ishga tushirgich (`Super + Space`) orqali ishga tushirasiz. Har bir qisqa tugmani koʻrish uchun uning ichida `?` bosing.

## Signed

[Signed](https://github.com/omacom/signed) — Omarchy ning PDFlarni imzolash va ularni toʻldirishning oʻzining oʻta oddiy usuli. Saqlangan imzoingiz, matn va bugungi sanani sahifaning istalgan joyiga qoʻying, keyin asl nusxa yonida imzolangan nusxani saqlang. Qanday qilishni [PDFlarni toʻldirish](27-filling-out-pdfs.md) da koʻring.

Signed ni ilovalarni ishga tushirgich (`Super + Space`) orqali ishga tushirasiz yoki fayl menejeridan u bilan PDF ochasiz.

## Game Vibes

Game Vibes, ilovalarni ishga tushirgichda (`Super + Space`), Omarchy ning kichik oʻyinlari yashaydigan joy: Checkmate, doʻstga yoki oʻrnatilgan raqibga qarshi 3D shaxmat oʻyini; Cards, Klondike solitaire; Death Wish, tikanlar va arralar bilan toʻla oʻn xonadan iborat pikselligacha aniq platformer; va Neon Swarm, arkada shooter. Har biri temangizga moslashadigan bitta veb-sahifa. Strelkalar va `Enter` bilan birini tanlang, oʻyinning sarlavha ekranidan `Esc` bilan yoki u pauzada boʻlganda `Q` bilan roʻyxatga qayting. U toʻliq ekranda ochiladi: `Super + F` uni oyna qiladi va `Super + W` uni yopadi.

Agent bilan qilgan oʻyinlaringiz ham bu yerda paydo boʻladi: agentlar panelida _Make something cool → Game_ ni tanlang va bittasini tasvirlang, yoki ustida ishlashni davom ettirish uchun Game Vibes da allaqachon bor oʻyinni nomlang. Agent uni `~/Games/vibes` ga nusxalaydi, u yerda u sizniki boʻlib oʻzgartira olasiz va tugagach uni ochadi. Bu nusxani oʻzingiz `omarchy games vibes copy <game>` bilan qilishingiz mumkin. Boshqa birov ulashgan oʻyin tema kabi oʻrnatiladi: _Install > Gaming > Game Vibes_ ni tanlang va uning git manzilini joylashtiring, yoki `omarchy games vibes install <git-repo-url>` ni ishga tushiring. _Remove > Gaming_ bittasini yana olib tashlaydi va _Update > Game Vibes Games_ yangi versiyalarni oladi. Oʻyinlar three.js ni internetdan yuklaydi, shuning uchun boshlash uchun ulanish kerak.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) — suzuvchi oynada ochiladigan Omarchy ning oʻzining oʻta oddiy kalkulyatori.

Omacalc ni `Super + Shift + Q` bilan ishga tushirasiz (yoki klaviaturangizda boʻlsa, kalkulyator tugmasi bilan).

## Signal

[Signal](https://signal.org/) — E2E shifrlangan xabar almashinuvining kashshofi va yirik texnologiya konglomeratlaridan biri orqali oʻtishni istamaydigan har kim uchun ajoyib aloqa varianti.

Signal ni `Super + Shift + G` bilan ishga tushirasiz. U asosiy oʻrnatishga kirmaydi, shuning uchun uni birinchi marta bossangiz, Omarchy uni oʻrnatishni taklif qiladi (u Omarchy menyusida _Install > Service_ ostida ham bor).

## Omaview

[Omaview](https://github.com/omacom/omaview) — Omarchy ning oʻzining oʻta oddiy rasm koʻruvchisi va media pleeri: fotosuratlaringiz, videolaringiz va musiqangiz uchun bitta oyna. Rasmni oching va strelka tugmalari uning papkasidagi qolganlari boʻylab qadamlaydi, `N` va `P` istalgan narsa uchun shuni qiladi va `Ctrl + M` butun papkani panjara sifatida koʻrsatadi. U HEIC, AVIF va JPEG XL fotosuratlarini ham koʻrsatadi va uzun narsalarda toʻxtagan joyingizdan davom etadi.

Toʻliq ekran uchun `F` ni, rasmni Omasnap da tahrirlash yoki videoni Omacut da kesish uchun `E` ni, rasmni chop etish uchun `Ctrl + P` ni va faylni Trash ga koʻchirish uchun `Delete` ni bosing (`Ctrl + Z` uni qaytaradi). Har bir qisqa tugmani koʻrish uchun uning ichida `?` bosing.

Omaview ni ilovalarni ishga tushirgich (`Super + Space`) orqali _Media Viewer_ sifatida ishga tushirasiz, yoki shunchaki fayl menejerida rasm, video yoki qoʻshiqni ikki marta bosasiz.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) — Omarchy ning oʻzining oʻta oddiy video kesuvchisi. Sizga kerak boʻlgan narsa faqat klipning boshi va oxirini kesish boʻlsa, u toʻliq video muharririni ishga tushirishdan ustun turadi.

Omacut ni ilovalarni ishga tushirgich (`Super + Space`) orqali ishga tushirasiz.

## Monologue

[Monologue](https://github.com/omacom/monologue) — Omarchy ning oʻzining oʻta oddiy veb-kamera yozuvchisi. Kamerangiz va mikrofoningizni bir marta tanlang, keyin yozish uchun `Space` bosing, yana bossangiz oʻsha yozuvni pauza qilib davom ettirasiz. U doim kamerangizning eng yuqori aniqligida yozadi, boshlashdan oldin darajangizni tekshirishingiz uchun jonli mikrofon oʻlchagichi bilan.

Yozuvni toʻxtating va u darhol oʻrnatilgan muharrirda ochiladi. Klipni boʻlish uchun uni ikki marta bosing, har bir qismni kesish uchun tutqichlarni torting va kerak boʻlmagan qismlarni olib tashlang. Keyin uni MP4 sifatida saqlang. Asl yozuvingiz uni tashlab yuborguningizcha saqlanadi, shuning uchun doim qaytib uni boshqacha kesishingiz mumkin.

Monologue ni ilovalarni ishga tushirgich (`Super + Space`) orqali ishga tushirasiz.
