# Mac yoki Windows dan kelayotganlar

Agar siz macOS yoki Windows da yillar o'tkazgan bo'lsangiz, barmoqlaringiz miyangiz o'rganib, keyin unutib yuborganini ham bilmaydigan yuzlab narsalarni biladi. Bu bob — o'sha tarjima qatlami: Omarchy da bu instinktlar qayerga ko'chadi. Xususiyatlarning o'zi boshqa joylarda chuqur yoritilgan — bu shunchaki xarita.

### Super — hamma narsaning markazi

Cmd yoki Windows tugmasi atrofida shakllangan barcha mushak xotirangiz bitta tugmaga ko'chadi: Super. Bu — PC klaviaturasidagi Windows tugmasi, va u Omarchy dagi deyarli barcha tezkor tugmalarning tayanchi.

Spotlight yoki Raycast yoki Start menyusiga bo'lgan refleksingiz `Super + Space` ga aylanadi. Bu Omarchy menyusini ochadi, u esa ilovalarni ishga tushiradi, sozlamalarni o'zgartiradi, dasturiy ta'minot o'rnatadi, ekranni suratga oladi — xullas, deyarli hamma narsani qiladi. Filtrlash uchun yozishni boshlang. `Super + Alt + Space` barcha ilovalarni Launchpad qilgani kabi bitta katakchada ko'rsatadi. [navigatsiya](04-navigation.md) ga qarang.

### Ish stolida belgilar yo'q, dok esa faqat suzuvchi rejimda chiqadi

Ish stolida tartibga soladigan belgilar ham yo'q, plitkali ish maydonida dok ham yo'q — dok faqat suzuvchi ish maydonida paydo bo'ladi ([navigatsiya](04-navigation.md) ga qarang). Ilovalar tezkor tugma orqali (terminal uchun `Super + Return`, brauzer uchun `Super + Shift + Return`, va belgilangan hamma narsaning ro'yxati uchun `Super + K`) yoki menyudan ishga tushadi. Doimiy qoladigan yagona UI bo'lagi — [yuqori panel](05-the-top-bar.md), u ilgari menyu paneli, tizim treyi va Notification Center siz uchun qilgan ishlarni bajaradi — va undagi deyarli har bir vidjet chap, o'ng va o'rta bosishda biror narsa qiladi.

### Oynalar o'zlari joylashadi

Eng katta tafakkur o'zgarishi: siz oynalarni sudrab yurmaydi va ularni ekran yarmiga yopishtirmaysiz. Oyna ochsangiz, u butun ekranni egallaydi. Ikkinchisini ochsangiz, ular ekranni bo'lishadi. Siz hech qachon oynani boshqasining ostidan qidirib topmaysiz, chunki oynalar bir-birining ustiga chiqmaydi.

Suzuvchi oyna haqiqatan ham kerak bo'lganda, `Super + T` faol oynani plitkalashdan chiqaradi (va qaytaradi). Lekin avval plitkalashga haqiqiy imkoniyat bering — butun ishning yuragi shu. [Navigatsiya](04-navigation.md) sizni bu orqali olib o'tadi.

Ish maydonlari tanish tuyuladi: ular macOS Spaces yoki Windows virtual ish stollari, faqat siz ulardan haqiqatan ham foydalanasiz, chunki `Super + 1/2/3/4` to'g'ridan-to'g'ri bittasiga sakraydi va `Super + Shift + 1/2/3/4` faol oynani o'sha yerga yuboradi. Animatsiya kechikishi yo'q, faqat bir zumda sakrashlar. Bu shuni anglatadiki, agar oldin bunga o'rganib qolgan bo'lsangiz, sizga hatto bir nechta monitor ham kerak bo'lmasligi mumkin.

### Nusxa olish va qo'yish shunchaki ishlaydi

Mac da sizda hamma joyda Cmd + C bor edi. Windows da sizda hamma joyda Ctrl + C bor edi — terminaldan tashqari, u yerda u dasturingizni o'ldiradi. Omarchy sizga `Super + C`, `Super + X` va `Super + V` ni beradi, va ular hamma joyda, jumladan terminalda ham ishlaydi. Qobiq uchun alohida refleks o'rganish shart emas.

Windows chilar: sizning Win + V nusxa buferi tarixingiz `Super + Ctrl + V` da yashaydi, va u matn bilan birga tasvirlarni ham saqlaydi. [yagona nusxa buferi va tarix](08-unified-clipboard-history.md) ga qarang.

### Tarjima jadvali

| Siz qo'l cho'zadigan narsa | Omarchy da |
| ------------- | ---------- |
| Spotlight / Raycast / Start menyusi | `Super + Space` — Omarchy menyusi |
| AirDrop | LocalSend, `Super + Ctrl + S` orqali — [GUI dasturlar](22-guis.md) ga qarang |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` yoki `Print Screen` — [skrinshotlar va yozib olish](12-screenshots-recording.md) ga qarang |
| Notification Center | `Super + Shift + Alt + ,` dagi bildirishnomalar tarixi |
| Time Machine (tizim uchun) | Har bir yangilanishda avtomatik [tizim suratlari](47-system-snapshots.md) |
| App Store / o'rnatuvchini yuklab olish | Menyudagi _O'rnatish_, yoki `omarchy pkg add` — [boshqa paketlar](29-other-packages.md) ga qarang |
| System Settings / Control Panel | Menyudagi _Sozlash_, u oddiy konfiguratsiya fayllarini tahrirlaydi — [dotfiles](31-dotfiles.md) ga qarang |
| Finder / File Explorer | Files, `Super + Shift + F` da — [GUI dasturlar](22-guis.md) ga qarang |
| Safari / Edge | `Super + Shift + Return` dagi Google Chrome; _Sozlash > Standartlar > Brauzer_ ostida boshqasini tanlang — [brauzerlar](23-browsers.md) ga qarang |
| Preview / Photos | Rasmlar, video va musiqa uchun Omaview, PDF lar uchun Document Viewer — [GUI dasturlar](22-guis.md) ga qarang |
| TextEdit / Notepad | Plain, `Super + Shift + N` da; _Sozlash > Standartlar > Muharrir_ ostida boshqasini tanlang |

### Ba'zi narsalar haqiqatan ham boshqacha

Ko'plab sozlamalar siz bosib o'tadigan panellarda emas, siz tahrirlaydigan matn fayllarida yashaydi. Bu ibtidoiy tuyuladi, toki har bir o'zgartirishni ko'rish, keyingi mashinangizga nusxalash va versiya nazoratiga qo'yish mumkinligini tushunib yetmaguningizcha. _Sozlash_ menyusi sizni to'g'ridan-to'g'ri to'g'ri faylga tashlaydi va tugatganingizda qayta ishga tushishi kerak bo'lgan narsani qayta ishga tushiradi.

Yangilanishlar bitta buyruq orqali keladi — _Yangilash > Omarchy_ — u Omarchy ning o'zini va tizimdagi har bir paketni yangilaydi, avval suratni olib qo'yadi. Tasodifiy vaqtlarda bezovta qiladigan alohida ilova yangilovchilari yo'q. [yangilanishlar](30-updates.md) ga qarang.

Dasturiy ta'minot yuklab olingan o'rnatuvchilardan emas, paket menejeridan keladi.

Va siz oynani yopganingizda, ilova haqiqatan ham chiqib ketadi. Dastur oynalarsiz ishlashda davom etadigan macOS dagi oraliq holat yo'q. `Super + W` — yoki agar siz shu barmoq xotirasi bilan kelgan bo'lsangiz, `Super + Q` — ketdi degani.

### Mac jihozida

Omarchy Intel Mac larda yaxshi ishlaydi — [Mac qo'llab-quvvatlovi](44-mac-support.md) ga qarang. Va klaviatura sizga mehribon: Omarchy hech narsani qayta belgilamaydi, Linux esa Command tugmasini Super deb hisoblaydi, shuning uchun Super doim Cmd turgan joyda turadi. Bosh barmog'ingiz ko'chib o'tganini sezmaydi ham.

### Unga ikki hafta vaqt bering

Instinktlar o'ylaganingizdan tezroq ko'chadi. [tezkor tugmalar](07-hotkeys.md) bobini bir marta ko'zdan kechirib chiqing, va biror bog'lanish esingizdan chiqsa, `Super + K` ni bosing — u hammasini ko'rsatadi. Aslida yodlab olishingiz kerak bo'lgan yagona tezkor tugma shu.
