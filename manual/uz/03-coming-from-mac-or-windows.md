# Mac yoki Windows'dan o'tsangiz

Agar siz yillar davomida macOS yoki Windows'da ishlagan bo'lsangiz, barmoqlaringiz miyangiz qachonlardir o'rganganini unutib yuborgan yuzlab narsalarni biladi. Bu bob — tarjima qatlami: Omarchy'da o'sha instinktlar qayerga mos tushadi. Imkoniyatlarning o'zi boshqa joylarda chuqur yoritilgan — bu shunchaki xarita.

### Super — hammasining markazi

Cmd yoki Windows tugmasi atrofida shakllangan barcha mushak xotirangiz bitta tugmaga o'tadi: Super. Bu — PC klaviaturasidagi Windows tugmasi va u Omarchy'dagi deyarli barcha tezkor tugmalar uchun tayanch nuqtadir.

Sizning Spotlight yoki Raycast yoki Start menyusiga qo'l cho'zish odatingiz `Super + Space` ga aylanadi. Bu Omarchy menyusini ochadi, u ilovalarni ishga tushiradi, sozlamalarni o'zgartiradi, dasturiy ta'minot o'rnatadi, ekranni suratga oladi — deyarli hamma narsani qiladi. Filtrlash uchun yozishni boshlang. `Super + Alt + Space` barcha ilovalarni Launchpad kabi bitta panjarada ko'rsatadi. Qarang: [navigatsiya](04-navigation.md).

### Ish stolida belgilar yo'q, dock esa xalaqit bermaydi

Ish stolida tartibga soladigan belgilar yo'q, dock esa ish maydonida oyna paydo bo'lishi bilan yashirinadi, siz ko'rsatkichni ekranning uning chetiga — agar ko'chirmagan bo'lsangiz, pastki chetiga — itarmaguningizcha (qarang: [navigatsiya](04-navigation.md)). Ilovalar tezkor tugma orqali (`Super + Return` terminal uchun, `Super + Shift + Return` brauzer uchun va `Super + K` bog'langan barcha narsalar ro'yxati uchun) yoki menyudan ishga tushadi. Yagona doimiy UI qismi — [yuqori panel](05-the-top-bar.md), u avval menyu satri, tizim treyi va Notification Center siz uchun qilgan ishlarni bajaradi — va undagi deyarli har bir vidjet chap, o'ng va o'rta bosishda nimadir qiladi.

### Oynalar o'zlari joylashadi

Eng katta tafakkur o'zgarishi: siz oynalarni sudrab yurmaysiz yoki ekran yarmiga yopishtirmaysiz. Oyna oching — u butun ekranni egallaydi. Ikkinchisini oching — ular ekranni bo'lishadi. Siz hech qachon oynani boshqasining ostidan qidirib olmaysiz, chunki oynalar bir-birining ustiga chiqmaydi.

Haqiqatan ham suzuvchi oyna kerak bo'lganda, `Super + T` faol oynani plitka rejimidan chiqaradi (va qaytaradi). Lekin avval plitka rejimiga haqiqiy imkon bering — butun tizimning yuragi shunda. [Navigatsiya](04-navigation.md) sizni bu orqali olib o'tadi.

Ish maydonlari tanish tuyuladi: ular macOS Spaces yoki Windows virtual ish stollari, faqat siz ulardan haqiqatan ham foydalanasiz, chunki `Super + 1/2/3/4` to'g'ridan-to'g'ri bittasiga o'tadi va `Super + Shift + 1/2/3/4` faol oynani o'sha yerga yuboradi. Animatsiya kechikishi yo'q, shunchaki bir zumda o'tish. Bu shuni anglatadiki, agar avval shunga o'rganib qolgan bo'lsangiz, sizga hatto bir nechta monitor ham kerak bo'lmasligi mumkin.

### Nusxalash va joylashtirish shunchaki ishlaydi

Mac'da sizda hamma joyda Cmd + C bor edi. Windows'da sizda hamma joyda Ctrl + C bor edi — terminaldan tashqari, u yerda u dasturingizni o'ldiradi. Omarchy sizga `Super + C`, `Super + X` va `Super + V` ni beradi va ular hamma joyda, jumladan terminalda ham ishlaydi. Shell uchun alohida odat o'rganish shart emas.

Windows'dan kelganlar: sizning Win + V bufer tarixingiz `Super + Ctrl + V` da yashaydi va u matn bilan birga tasvirlarni ham saqlaydi. Qarang: [yagona bufer va tarix](08-unified-clipboard-history.md).

### Tarjima jadvali

| Siz qo'l cho'zadigan narsa | Omarchy'da |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy menyusi |
| AirDrop | LocalSend, `Super + Ctrl + S` orqali — qarang: [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` yoki `Print Screen` — qarang: [skrinshotlar va yozib olish](12-screenshots-recording.md) |
| Notification Center | Bildirishnomalar tarixi `Super + Shift + Alt + ,` da |
| Time Machine (tizim uchun) | Har bir yangilanishda avtomatik [tizim snapshotlari](47-system-snapshots.md) |
| App Store / o'rnatgichni yuklab olish | Menyudagi _Install_ yoki `omarchy pkg add` — qarang: [boshqa paketlar](29-other-packages.md) |
| System Settings / Control Panel | Menyudagi _Setup_, u oddiy config fayllarini tahrirlaydi — qarang: [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, `Super + Shift + F` da — qarang: [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome `Super + Shift + Return` da; boshqasini _Setup > Defaults > Browser_ ostida tanlang — qarang: [brauzerlar](23-browsers.md) |
| Preview / Photos | Rasmlar, video va musiqa uchun Omaview, PDF'lar uchun Document Viewer — qarang: [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, `Super + Shift + N` da; boshqasini _Setup > Defaults > Editor_ ostida tanlang |

### Ba'zi narsalar haqiqatan ham boshqacha

Ko'plab sozlamalar bosib o'tadigan panellarda emas, siz tahrirlaydigan matn fayllarida yashaydi. Bu ibtidoiy tuyuladi, toki siz har bir o'zgartirishni ko'rish, keyingi mashinangizga ko'chirish va version control'ga qo'yish mumkinligini tushunmaguningizcha. _Setup_ menyusi sizni to'g'ridan-to'g'ri kerakli faylga tashlaydi va tugatganingizda qayta ishga tushishi kerak bo'lgan narsani qayta ishga tushiradi.

Yangilanishlar bitta buyruq orqali keladi — _Update > Omarchy_ — u Omarchy'ning o'zini va tizimdagi har bir paketni yangilaydi, avval snapshot oladi. Tasodifiy paytlarda bezovta qiladigan ilova bo'yicha yangilagichlar yo'q. Qarang: [yangilanishlar](30-updates.md).

Dasturiy ta'minot yuklab olingan o'rnatgichlardan emas, paket menejeridan keladi.

Va siz oynani yopganingizda, ilova haqiqatan ham chiqadi. Dastur oynasiz ishlab turadigan macOS'dagi oraliq holat yo'q. `Super + W` — yoki agar siz shu barmoq xotirasi bilan kelgan bo'lsangiz, `Super + Q` — ketdi degani.

### Mac uskunalarida

Omarchy Intel Mac'larda va Omarchy for Apple Silicon bilan M1, M2 va M3 Mac'larda yaxshi ishlaydi. Qarang: [Mac qo'llab-quvvatlashi](44-mac-support.md). Klaviatura ham sizga mehribon: Omarchy hech narsani qayta bog'lamaydi va Linux Command tugmasini Super sifatida qabul qiladi, shuning uchun Super doim Cmd bo'lgan joyda o'tiradi. Bosh barmog'ingiz ko'chishni sezmaydi.

### Unga ikki hafta bering

Instinktlar siz o'ylagandan tezroq o'tadi. [tezkor tugmalar](07-hotkeys.md) bobini bir marta ko'zdan kechiring va bog'lanishni esdan chiqarganingizda, `Super + K` ni bosing — u hammasini ko'rsatadi. Bu — siz haqiqatan ham yodlab olishingiz kerak bo'lgan yagona tezkor tugma.
