# Mac yoki Windows dan kelayotganlar uchun

Agar yillar davomida macOS yoki Windows ishlatgan bo'lsangiz, barmoqlaringiz miyangiz allaqachon unutib yuborgan yuzlab narsalarni biladi. Bu bob — tarjima qatlami: o'sha odatlar Omarchy da qayerga ko'chadi. Imkoniyatlarning o'zi boshqa joylarda chuqur yoritilgan — bu shunchaki xarita.

### Super — hamma narsaning markazi

Cmd yoki Windows tugmasi atrofida shakllangan barcha mushak xotirangiz bitta tugmaga o'tadi: Super. Bu — PC klaviaturasidagi Windows tugmasi, va u Omarchy dagi deyarli barcha tezkor tugmalarning tayanchi.

Spotlight yoki Raycast yoki Start menyusiga qo'l boradigan refleksingiz `Super + Space` ga aylanadi. Bu Omarchy menyusini ochadi — u dasturlarni ishga tushiradi, sozlamalarni o'zgartiradi, dasturiy ta'minot o'rnatadi, ekranni suratga oladi — deyarli hammasini qiladi. Filtrlash uchun yozishni boshlang. `Super + Alt + Space` barcha dasturlarni Launchpad qilganidek bitta katakchada ko'rsatadi. [navigatsiya](04-navigation.md) ga qarang.

### Ish stolida belgilar yo'q, dock esa faqat suzuvchi rejimda chiqadi

Ish stolida tartibga soladigan belgilar yo'q, plitka rejimidagi ish maydonida dock ham yo'q — dock faqat suzuvchi ish maydonida paydo bo'ladi ([navigatsiya](04-navigation.md) ga qarang). Dasturlar tezkor tugma orqali (terminal uchun `Super + Return`, brauzer uchun `Super + Shift + Return`, va belgilangan hamma narsaning ro'yxati uchun `Super + K`) yoki menyudan ishga tushadi. Yagona doimiy UI elementi — [yuqori panel](05-the-top-bar.md), u ilgari menyu qatori, tizim treyi va Notification Center siz uchun qilgan ishlarni qamrab oladi — va undagi deyarli har bir vidjet chap, o'ng va o'rta bosishda nimadir qiladi.

### Derazalar o'zlari joylashadi

Eng katta tafakkur o'zgarishi: siz derazalarni sudrab yurmaysiz yoki ekranning yarimlariga yopishtirmaysiz. Deraza ochasiz — u butun ekranni egallaydi. Ikkinchisini ochasiz — ular ekranni bo'lishadi. Siz hech qachon derazani boshqasining ostidan qidirib olmaysiz, chunki derazalar bir-birini bosmaydi.

Suzuvchi deraza haqiqatan ham kerak bo'lganda, `Super + T` faol derazani plitka rejimidan chiqaradi (va qaytaradi). Lekin avval plitka rejimiga haqiqiy imkon bering — butun ishning yuragi shu. [Navigatsiya](04-navigation.md) sizni bu bo'ylab olib o'tadi.

Ish maydonlari tanish tuyuladi: ular macOS Spaces yoki Windows virtual ish stollari, faqat siz ularni haqiqatan ham ishlatasiz, chunki `Super + 1/2/3/4` to'g'ridan-to'g'ri bittasiga sakraydi va `Super + Shift + 1/2/3/4` faol derazani o'sha yerga yuboradi. Animatsiya kechikishi yo'q, shunchaki bir zumda sakrash. Bu degani, agar ilgari shunga o'rganib qolgan bo'lsangiz, sizga hatto bir nechta monitor ham kerak bo'lmasligi mumkin.

### Nusxalash va joylashtirish shunchaki ishlaydi

Mac da sizda hamma joyda Cmd + C bor edi. Windows da sizda hamma joyda Ctrl + C bor edi — terminaldan tashqari, u yerda u dasturingizni o'ldiradi. Omarchy sizga `Super + C`, `Super + X` va `Super + V` ni beradi, va ular hamma joyda, jumladan terminalda ham ishlaydi. Shell uchun alohida refleks o'rganish kerak emas.

Windows chilar: Win + V almashinuv buferi tarixingiz `Super + Ctrl + V` da yashaydi, va u matn bilan birga rasmlarni ham saqlaydi. [yagona almashinuv buferi va tarixi](08-unified-clipboard-history.md) ga qarang.

### Tarjima jadvali

| Qo'lingiz boradigan narsa | Omarchy da |
| ------------- | ---------- |
| Spotlight / Raycast / Start menyusi | `Super + Space` — Omarchy menyusi |
| AirDrop | LocalSend, `Super + Ctrl + S` orqali — [GUIs](22-guis.md) ga qarang |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` yoki `Print Screen` — [skrinshotlar va yozib olish](12-screenshots-recording.md) ga qarang |
| Notification Center | Bildirishnomalar tarixi `Super + Shift + Alt + ,` da |
| Time Machine (tizim uchun) | Har bir yangilanishda avtomatik [tizim snapshotlari](47-system-snapshots.md) |
| App Store / o'rnatuvchini yuklab olish | Menyudagi _Install_, yoki `omarchy pkg add` — [boshqa paketlar](29-other-packages.md) ga qarang |
| System Settings / Control Panel | Menyudagi _Setup_, u oddiy konfiguratsiya fayllarini tahrirlaydi — [dotfiles](31-dotfiles.md) ga qarang |
| Finder / File Explorer | Files, `Super + Shift + F` da — [GUIs](22-guis.md) ga qarang |
| Safari / Edge | Google Chrome `Super + Shift + Return` da; boshqasini _Setup > Defaults > Browser_ ostidan tanlang — [brauzerlar](23-browsers.md) ga qarang |
| Preview / Photos | Rasmlar, video va musiqa uchun Omaview, PDF lar uchun Document Viewer — [GUIs](22-guis.md) ga qarang |
| TextEdit / Notepad | Plain, `Super + Shift + N` da; boshqasini _Setup > Defaults > Editor_ ostidan tanlang |

### Ba'zi narsalar haqiqatan ham boshqacha

Ko'plab sozlamalar siz bosib o'tadigan panellarda emas, siz tahrirlaydigan matn fayllarida yashaydi. Bu har bir o'zgartirishni ko'rish, keyingi mashinangizga ko'chirish va versiyalar nazoratiga qo'yish mumkinligini anglatmaguncha ibtidoiy tuyuladi. _Setup_ menyusi sizni to'g'ridan-to'g'ri kerakli faylga tashlaydi va tugatganingizda qayta ishga tushirish kerak bo'lgan narsani qayta ishga tushiradi.

Yangilanishlar bitta buyruq orqali keladi — _Update > Omarchy_ — u Omarchy ning o'zini va tizimdagi har bir paketni yangilaydi, avval snapshot oladi. Tasodifiy paytlarda bezovta qiladigan har bir dastur uchun alohida yangilovchilar yo'q. [yangilanishlar](30-updates.md) ga qarang.

Dasturiy ta'minot yuklab olingan o'rnatuvchilardan emas, paket menejeridan keladi.

Va derazani yopganingizda, dastur haqiqatan ham chiqib ketadi. Dastur derazasiz ishlashda qoladigan macOS dagi limb holati yo'q. `Super + W` — yoki agar siz shu barmoq xotirasi bilan kelgan bo'lsangiz, `Super + Q` — ketdi degani.

### Mac uskunasida

Omarchy Intel Mac larda yaxshi ishlaydi, va Apple Silicon uchun Omarchy bilan M1, M2 va M3 Mac larda ham. [Mac qo'llab-quvvatlashi](44-mac-support.md) ga qarang. Va klaviatura sizga mehribon: Omarchy hech narsani qayta belgilamaydi, va Linux Command tugmasini Super deb hisoblaydi, shuning uchun Super aynan Cmd har doim turgan joyda turadi. Bosh barmog'ingiz ko'chishni sezmaydi ham.

### Unga ikki hafta bering

Odatlar siz o'ylagandan tezroq ko'chadi. [tezkor tugmalar](07-hotkeys.md) bobini bir marta ko'zdan kechiring, va qachonki biror bog'lanishni esdan chiqarsangiz, `Super + K` ni bosing — u sizga hammasini ko'rsatadi. Bu — siz haqiqatan ham yodlashingiz kerak bo'lgan yagona tezkor tugma.
