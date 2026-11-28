# GUIlar

## Fayllar

Files (Folio) — grafik fayl menejeri. `Super + Shift + F` uni ochadi, `Super + Shift + Alt + F` esa uni terminalingiz hozir turgan katalogda ochadi, bu esa ko‘p bosishlardan qutqaradi. `Ctrl + L` yo‘lni yozish imkonini beradi, birorta faylda `Space` tugmasini bosish esa uni ochmasdan to‘liq o‘lchamda oldindan ko‘rsatadi.

USB fleshka yoki SD kartani ulang va u avtomatik ravishda ulanadi, shuning uchun u shunchaki yon panelda paydo bo‘ladi. Murakkabroq ishlar uchun — diskni formatlash, SMART holatini tekshirish, bo‘limlar yaratish — ilovalarni ishga tushirish menyusidan (`Super + Space`) _Disks_ ilovasini ishga tushiring.

Shifrlangan disk ulanganda parolini so‘raydi. Uning o‘zi avtomatik ochilishi uchun unga `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` buyrug‘i bilan kalit fayl qo‘shing va o‘sha kalit faylni `~/.config/omarchy/drive-keys/<UUID>` manziliga qo‘ying, bunda u `lsblk -dno UUID /dev/sdX1` shifrlangan bo‘lim uchun chiqaradigan UUID bo‘yicha nomlangan bo‘lsin va faqat siz o‘qiy oladigan bo‘lsin (`chmod 600`). Agar o‘sha kalit fayl bo‘lmasa yoki rad etilsa, sizdan odatdagidek parol so‘raladi.

Ikki marta bosish oqilona standartlarga amal qiladi: rasmlar, videolar va musiqa Omaview’da, PDF’lar Document Viewer’da, Markdown Omawrite’da, oddiy matn esa muharriringizda ochiladi, siz _Setup > Defaults > Editor_ ostida boshqasini tanlamasangiz, standart bo‘yicha Plain.

## Disktree

Disk to‘lib qolganda va uni nima yeb qo‘yayotganini bilmasangiz, ilovalarni ishga tushirish menyusidan (`Super + Space`) [Disktree](https://github.com/tobi/disktree) ilovasini ishga tushiring. U uy katalogingizning grafik daraxt xaritasini ko‘rsatadi. Kattaroq bloklar ko‘proq joy egallaydi; klaviatura yoki sichqoncha bilan kataloglar ichiga kiring, nimalar ketishi kerakligini belgilang va biror narsani o‘chirishdan oldin tanlaganlaringizni ko‘rib chiqing. Butun diskni skanerlash uchun `disktree --disk` buyrug‘ini ishga tushiring.

## Obsidian

[Obsidian](https://obsidian.md/) — saqlash uchun oddiy Markdown fayllardan foydalanadigan, bepul va yuqori darajada kengaytiriladigan qaydlar ilovasi.

Obsidian barcha maqsadlar uchun bepul, jumladan shaxsiy, tijorat va notijorat foydalanish uchun.

Obsidian shuningdek iOS va Android’dagi mobil ilovalar bilan sinxronlash uchun [tijorat qo‘shimchasini](https://obsidian.md/sync) taklif qiladi. (https://obsidian.md/pricing).

Obsidian’ni `Super + Shift + O` bilan ishga tushirasiz. Tema sinxronlashidan foydalanish uchun sozlamalar ostida `Omarchy` temasini tanlashingiz kerak.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) — Omarchy’ning o‘zining o‘ta sodda Markdown yozish ilovasi. Omborlar yo‘q, plaginlar yo‘q, faqat siz va so‘zlar.

Omawrite’ni `Super + Shift + W` bilan ishga tushirasiz.

## Pinta

[Pinta](https://www.pinta-project.com/) — kesish, o‘lchamini o‘zgartirish va boshqa asosiy amallar uchun ajoyib bo‘lgan oddiy rasm tahrirlash vositasi. Faqat Photoshop muqobilini kutmang. Lekin unda baribir Magic Wand va qatlamlar ham bor!

Pinta’ni ilovalarni ishga tushirish menyusi orqali ishga tushirasiz (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) — fon rasmdan ranglarni ajratib olib, ularni to‘liq, uyg‘un temaga aylantira oladigan temalar ilovasi. Bu [o‘z temangizni yaratish](43-making-your-own-theme.md)ning eng oson yo‘li.

Aether’ni ilovalarni ishga tushirish menyusi orqali ishga tushirasiz (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) sizga ilovani ishga tushirayotgan, xuddi shu tarmoqdagi boshqa qurilmalarga fayllar yuborish imkonini beradi, Apple AirDrop kabi. Lekin u platformalararo, shuning uchun siz Windows, macOS, Android, iOS va albatta Linux bilan ikki yo‘nalishda ham fayllar almashishingiz mumkin.

Siz Share menyusini `Super + Ctrl + S` da yoki Omarchy menyusida _Trigger > Share_ ostida ochishingiz mumkin. U sizga to‘rtta variant beradi:

- **Clipboard** nusxa olgan narsangizni matn fayli sifatida yuboradi. Havola yoki parchani o‘zingizga elektron pochta orqali yubormasdan telefoningizga olish uchun ajoyib.
- **File** bir vaqtning o‘zida bir nechtasini tanlashingiz mumkin bo‘lgan fayl tanlagichni ochadi.
- **Folder** butun katalogni yuboradi.
- **Receive** haqiqiy LocalSend’ni ochadi, shunda boshqa qurilma sizga biror narsa yubora oladi.

Xuddi shu narsa terminaldan `omarchy share clipboard`, `omarchy share file [path]` va `omarchy share folder [path]` bilan ishlaydi. Yo‘lni tashlab keting va sizga tanlagich chiqadi.

Siz shuningdek fayl menejeridan to‘g‘ridan-to‘g‘ri yuborishingiz mumkin: Files’dagi istalgan tanlovni o‘ng tugma bilan bosing va uni LocalSend bilan ulashing.

Omarchy’ning firewall’i standart bo‘yicha LocalSend portidan tashqari yopiq, shuning uchun bu yangi o‘rnatishda qutidan chiqqan holda ishlaydi. [xavfsizlik](48-security.md) ga qarang.

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) — matn protsessori, elektron jadval, taqdimotlar, chizish ilovasi va boshqalarni o‘z ichiga olgan to‘liq ofis to‘plami. U Microsoft Office fayllari bilan mos keladi, shuning uchun bu o‘sha Word hujjatlarini ochish imkoniga ega bo‘lishning ajoyib yo‘li.

LibreOffice’ni ilovalarni ishga tushirish menyusi orqali ishga tushirasiz (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) — Omarchy’ning o‘zining o‘ta sodda taqdimot ilovasi. Sizning kolodangiz — rasmlari va videolari yonida joylashgan bitta Markdown fayl: har bir slaydni jonli oldindan ko‘rish ostida yozing, slaydlarni tartibga torting, so‘ngra to‘liq ekranda taqdim eting yoki PDF va PowerPoint’ga eksport qiling. U hatto Omarchy temangizni ham oladi.

Hype’ni ilovalarni ishga tushirish menyusi orqali ishga tushirasiz (`Super + Space`). Har bir klaviatura yorlig‘ini ko‘rish uchun uning ichida `?` tugmasini bosing.

## Signed

[Signed](https://github.com/omacom/signed) — Omarchy’ning PDF’larni imzolash va ularni to‘ldirishning o‘zining o‘ta sodda usuli. Saqlangan imzoingizni, matnni va bugungi sanani sahifaning istalgan joyiga qo‘ying, so‘ngra imzolangan nusxani asl nusxa yonida saqlang. Qanday qilishni bilish uchun [PDFlarni to‘ldirish](27-filling-out-pdfs.md) ga qarang.

Signed’ni ilovalarni ishga tushirish menyusi orqali ishga tushirasiz (`Super + Space`), yoki u bilan fayl menejeridan PDF ochasiz.

## Game Vibes

Ilovalarni ishga tushirish menyusidagi (`Super + Space`) Game Vibes — Omarchy’ning kichik o‘yinlari yashaydigan joy: Checkmate, do‘stingizga yoki o‘rnatilgan raqibga qarshi 3D shaxmat o‘yini; Cards, Klondike solitaire; Death Wish, tikanlar va arralar bilan to‘la o‘nta xonadan iborat, pikselgacha aniq platformer; va Neon Swarm, arkada otishma o‘yini. Har biri sizning temangizga amal qiladigan bitta veb-sahifa. Strelkalar va `Enter` bilan bittasini tanlang va o‘yinning sarlavha ekranidan `Esc` bilan yoki u pauza qilinganda `Q` bilan ro‘yxatga qayting. U to‘liq ekranda ochiladi: `Super + F` uni oyna qiladi, `Super + W` esa uni yopadi.

Agent bilan qilgan o‘yinlaringiz ham bu yerda chiqadi: agentlar panelida _Make something cool → Game_ ni tanlang va bittasini tasvirlang, yoki ustida ishlashni davom ettirish uchun Game Vibes’da allaqachon bor o‘yinni nomlang. Agent uni `~/Games/vibes` ichiga nusxalaydi, u yerda uni o‘zgartirish sizniki bo‘ladi va tugagach uni ochadi. Siz o‘sha nusxani `omarchy games vibes copy <game>` bilan o‘zingiz qilishingiz mumkin. Boshqa kimdir ulashgan o‘yin tema kabi o‘rnatiladi: _Install > Gaming > Game Vibes_ ni tanlang va uning git manzilini joylashtiring, yoki `omarchy games vibes install <git-repo-url>` buyrug‘ini ishga tushiring. _Remove > Gaming_ bittasini yana olib tashlaydi, _Update > Game Vibes Games_ esa yangi versiyalarni oladi. O‘yinlar three.js’ni internetdan yuklaydi, shuning uchun ular boshlanishi uchun ulanishga muhtoj.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) — suzuvchi oynada ochiladigan, Omarchy’ning o‘zining o‘ta sodda kalkulyatori.

Omacalc’ni `Super + Shift + Q` bilan ishga tushirasiz (yoki klaviaturangizda bo‘lsa, kalkulyator tugmasi bilan).

## Signal

[Signal](https://signal.org/) — E2E shifrlangan xabar almashishning kashshofi va katta texnologiya konglomeratlaridan birining orqali o‘tishni istamaydigan har bir kishi uchun ajoyib aloqa varianti.

Signal’ni `Super + Shift + G` bilan ishga tushirasiz. U asosiy o‘rnatishning bir qismi emas, shuning uchun siz buni birinchi marta bosganingizda Omarchy uni siz uchun o‘rnatishni taklif qiladi (u shuningdek Omarchy menyusida _Install > Service_ ostida ham bor).

## Omaview

[Omaview](https://github.com/omacom/omaview) — Omarchy’ning o‘zining o‘ta sodda rasm ko‘ruvchisi va media pleeri: suratlaringiz, videolaringiz va musiqangiz uchun bitta oyna. Suratni oching va strelka tugmalari uning papkasidagi qolganlari bo‘ylab qadamlab o‘tadi, `N` va `P` buni har qanday narsa uchun qiladi, `Ctrl + M` esa butun papkani panjara sifatida ko‘rsatadi. U HEIC, AVIF va JPEG XL suratlarni ham ko‘rsatadi va uzun narsalarda to‘xtagan joyingizdan davom etadi.

To‘liq ekran uchun `F` ni, suratni Omasnap’da tahrirlash yoki videoni Omacut’da kesish uchun `E` ni, suratni chop etish uchun `Ctrl + P` ni va faylni Trash’ga ko‘chirish uchun `Delete` ni bosing (`Ctrl + Z` uni qaytarib olib keladi). Har bir klaviatura yorlig‘ini ko‘rish uchun uning ichida `?` tugmasini bosing.

Omaview’ni ilovalarni ishga tushirish menyusi orqali _Media Viewer_ sifatida ishga tushirasiz (`Super + Space`), yoki shunchaki fayl menejerida surat, video yoki qo‘shiqni ikki marta bosasiz.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) — Omarchy’ning o‘zining o‘ta sodda video kesuvchisi. Sizga kerak bo‘lgan narsa faqat klipning boshi va oxirini kesish bo‘lsa, u to‘liq video muharrirni ishga tushirishni yengadi.

Omacut’ni ilovalarni ishga tushirish menyusi orqali ishga tushirasiz (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) — Omarchy’ning o‘zining o‘ta sodda veb-kamera yozuvchisi. Kamera va mikrofoningizni bir marta tanlang, so‘ngra yozish uchun `Space` ni bosing va xuddi shu dubleni pauza qilish va davom ettirish uchun yana bosing. U har doim kamerangizning eng yuqori aniqligida yozadi, boshlashdan oldin darajangizni tekshirishingiz uchun jonli mikrofon o‘lchagich bilan.

Dubleni to‘xtating va u darhol o‘rnatilgan muharrirda ochiladi. Klipni bo‘lish uchun uni ikki marta bosing, har bir bo‘lakni kesish uchun tutqichlarni torting va kerak bo‘lmagan qismlarni olib tashlang. So‘ngra uni MP4 sifatida saqlang. Asl yozuvingiz uni tashlab yuborguningizcha saqlanadi, shuning uchun siz har doim qaytib kelib, uni boshqacha kesishingiz mumkin.

Monologue’ni ilovalarni ishga tushirish menyusi orqali ishga tushirasiz (`Super + Space`).
