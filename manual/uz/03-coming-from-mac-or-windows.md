# Mac yoki Windows’dan o‘tayotganlar uchun

Agar yillar davomida macOS yoki Windows’da o‘tirgan bo‘lsangiz, barmoqlaringiz miyangiz qachonlardir o‘rganganini unutib yuborgan yuzlab narsalarni biladi. Bu bob — tarjima qatlami: o‘sha instinktlar Omarchy’da qayerga ko‘chadi. Xususiyatlarning o‘zi boshqa joylarda chuqur yoritilgan — bu shunchaki xarita.

### Super — hamma narsaning markazi

Cmd yoki Windows tugmasi atrofida shakllangan barcha mushak xotirasi bitta tugmaga o‘tadi: Super. Bu PC klaviaturasidagi Windows tugmasi va Omarchy’dagi deyarli har bir tezkor tugma uchun tayanch nuqta.

Spotlight, Raycast yoki Start menyusiga intilish refleksingiz `Super + Space` bo‘ladi. Bu Omarchy menyusini ochadi: ilovalarni ishga tushiradi, sozlamalarni o‘zgartiradi, dasturlarni o‘rnatadi, ekranni suratga oladi — deyarli hamma narsani qiladi. Filtrlash uchun yozishni boshlang. `Super + Alt + Space` barcha ilovalarni Launchpad kabi bitta panjarada ko‘rsatadi. [navigatsiya](04-navigation.md) ga qarang.

### Ish stolida piktogrammalar yo‘q, dock esa yo‘ldan chetda turadi

Ish stolida tartibga solinadigan piktogrammalar yo‘q, dock esa ish maydonida oyna paydo bo‘lishi bilan yashirinadi — ko‘rsatkichni ekranning chetiga, ko‘chirmasangiz o‘ng chetiga itarmaguningizcha (qarang: [navigatsiya](04-navigation.md)). Ilovalar tezkor tugma (`Super + Return` — terminal, `Super + Shift + Return` — brauzer va `Super + K` — belgilangan barcha tugmalar ro‘yxati) yoki menyu orqali ishga tushadi. Doimiy qoladigan yagona UI elementi — [yuqori panel](05-the-top-bar.md): u ilgari menyu satri, tizim treyi va Notification Center qilgan ishlarni bajaradi — undagi deyarli har bir vidjet chap, o‘ng va o‘rta bosishda nimadir qiladi.

### Oynalar o‘zi joylashadi

Eng katta dunyoqarash o‘zgarishi: oynalarni sudrab yurmaysiz, ekranning yarmiga yopishtirmaysiz. Oyna ochsangiz, butun ekranni egallaydi. Ikkinchisini ochsangiz, ekranni bo‘lishadi. Hech qachon oynani boshqasining ostidan chiqarib olmaysiz, chunki oynalar bir-birining ustiga chiqmaydi.

Suzuvchi oyna chindan ham kerak bo‘lsa, `Super + T` faol oynani plitka tartibidan chiqaradi (va qaytaradi). Lekin avval plitka tartibiga chindan ham imkon bering — butun ishning yuragi shu. [Navigatsiya](04-navigation.md) buni bosqichma-bosqich ko‘rsatib beradi.

Ish maydonlari tanish tuyuladi: ular macOS Spaces yoki Windows virtual ish stollari, faqat endi ularni chindan ham ishlatasiz, chunki `Super + 1/2/3/4` to‘g‘ridan-to‘g‘ri bittasiga o‘tadi, `Super + Shift + 1/2/3/4` esa faol oynani o‘sha yerga yuboradi. Animatsiya kechikishi yo‘q, faqat bir zumda o‘tish. Demak, ilgari bunga o‘rganib qolgan bo‘lsangiz ham, endi bir nechta monitor sizga kerak bo‘lmasligi ham mumkin.

### Nusxalash va qo‘yish shunchaki ishlaydi

Mac’da hamma joyda Cmd + C bor edi. Windows’da hamma joyda Ctrl + C bor edi — terminaldan tashqari, u yerda u dasturingizni o‘ldiradi. Omarchy sizga `Super + C`, `Super + X` va `Super + V` ni beradi va ular hamma joyda, jumladan terminalda ham ishlaydi. Qobiq uchun alohida refleks o‘rganish shart emas.

Windows’dan kelganlar: Win + V almashuv buferi tarixingiz `Super + Ctrl + V` da yashaydi va u matn bilan birga rasmlarni ham saqlaydi. [yagona almashuv buferi va tarix](08-unified-clipboard-history.md) ga qarang.

### Tarjima jadvali

| Siz nimaga intilasiz | Omarchy’da |
| ------------- | ---------- |
| Spotlight / Raycast / Start menyusi | `Super + Space` — Omarchy menyusi |
| AirDrop | LocalSend, `Super + Ctrl + S` orqali — [GUIs](22-guis.md) ga qarang |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` yoki `Print Screen` — [skrinshotlar va yozib olish](12-screenshots-recording.md) ga qarang |
| Notification Center | Bildirishnomalar tarixi, `Super + Shift + Alt + ,` da |
| Time Machine (tizim uchun) | Har bir yangilanishda avtomatik [tizim suratlari](47-system-snapshots.md) |
| App Store / o‘rnatuvchini yuklab olish | Menyudagi _O‘rnatish_ yoki `omarchy pkg add` — [boshqa paketlar](29-other-packages.md) ga qarang |
| System Settings / Control Panel | Menyudagi _Sozlash_: oddiy config fayllarini tahrirlaydi — [dotfiles](31-dotfiles.md) ga qarang |
| Finder / File Explorer | Files, `Super + Shift + F` da — [GUIs](22-guis.md) ga qarang |
| Safari / Edge | Google Chrome, `Super + Shift + Return` da; boshqasini _Sozlash > Standart ilovalar > Brauzer_ ostida tanlang — [brauzerlar](23-browsers.md) ga qarang |
| Preview / Photos | Rasmlar, video va musiqa uchun Omaview, PDFlar uchun Document Viewer — [GUIs](22-guis.md) ga qarang |
| TextEdit / Notepad | Plain, `Super + Shift + N` da; boshqasini _Sozlash > Standart ilovalar > Tahrirlovchi_ ostida tanlang |

### Ba’zi narsalar chindan ham boshqacha

Ko‘plab sozlamalar siz bosib chiqadigan panellarda emas, tahrir qiladigan matn fayllarida yashaydi. Bu ibtidoiy tuyuladi, toki har bir o‘zgartirishni ko‘rish, keyingi mashinangizga ko‘chirish va versiyalarni boshqarish tizimiga qo‘yish mumkinligini anglamaguningizcha. _Sozlash_ menyusi sizni to‘g‘ridan-to‘g‘ri kerakli faylga tashlaydi va ish tugagach, qayta ishga tushishi kerak bo‘lgan narsani qayta ishga tushiradi.

Yangilanishlar bitta buyruq — _Yangilash > Omarchy_ — orqali keladi: u Omarchy’ning o‘zini va tizimdagi har bir paketni yangilaydi, oldin tizim suratini oladi. Tasodifiy paytlarda bezovta qiladigan alohida ilova yangilovchilari yo‘q. [yangilanishlar](30-updates.md) ga qarang.

Dasturlar yuklab olingan o‘rnatuvchilardan emas, paket menejeridan keladi.

Va oynani yopsangiz, ilova chindan ham chiqib ketadi. Dastur oynasiz ishlashda davom etadigan macOS’dagi muallaq holat yo‘q. `Super + W` — yoki kelgan barmoq xotirangiz shunday bo‘lsa, `Super + Q` — yo‘q bo‘ldi degani.

### Mac uskunalarida

Omarchy Intel Mac’larda ham, Omarchy for Apple Silicon bilan M1, M2 va M3 Mac’larda ham yaxshi ishlaydi. [Mac’ni qo‘llab-quvvatlash](44-mac-support.md) ga qarang. Klaviatura esa sizga mehribon: Omarchy hech narsani qayta belgilamaydi va Linux Command tugmasini Super deb hisoblaydi, shuning uchun Super aynan Cmd doim turgan joyda turadi. Bosh barmog‘ingiz ko‘chishni sezmaydi ham.

### Unga ikki hafta bering

Instinktlar o‘ylaganingizdan tezroq o‘tadi. [tezkor tugmalar](07-hotkeys.md) bobini bir marta ko‘zdan kechiring va qachonki tugma bog‘lanishi esimga tushmay qolsa, `Super + K` ni bosing — u hammasini ko‘rsatadi. Aslida yodlashingiz kerak bo‘lgan yagona tezkor tugma shu.
