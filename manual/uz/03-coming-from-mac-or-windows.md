# Mac yoki Windows'dan kelayotganlar uchun

Agar yillar davomida macOS yoki Windows'da ishlagan bo'lsangiz, barmoqlaringiz miyangiz qachonlardir o'rganganini unutib yuborgan yuzlab narsani biladi. Bu bob — tarjima qatlami: o'sha instinktlar Omarchy'da qayerga tushadi. Xususiyatlarning o'zlari boshqa joylarda chuqur yoritilgan — bu shunchaki xarita.

### Super — hamma narsaning markazi

Cmd yoki Windows tugmasi atrofida shakllantirgan barcha mushak xotirangiz bitta tugmaga o'tadi: Super. Bu PC klaviaturasidagi Windows tugmasi va u Omarchy'dagi deyarli har bir tezkor tugma uchun tayanchdir.

Spotlight yoki Raycast yoki Start menyusiga intilish refleksingiz `Super + Space` ga aylanadi. Bu ilovalarni ishga tushiradigan, sozlamalarni o'zgartiradigan, dasturlarni o'rnatadigan, ekranni suratga oladigan — deyarli hamma narsani qiladigan Omarchy menyusini ochadi. Filtrlash uchun yozishni boshlang. `Super + Alt + Space` barcha ilovalarni Launchpad qilganidek bitta panjarada ko'rsatadi. [navigatsiya](04-navigation.md) ga qarang.

### Dock ham, ish stoli piktogrammalari ham yo'q

Biror narsani ishga tushirish uchun bosadigan hech narsa yo'q, ish stolida tartibga soladigan piktogrammalar ham yo'q. Ilovalar tezkor tugma (`Super + Return` — terminal uchun, `Super + Shift + Return` — brauzer uchun va `Super + K` — bog'langan hamma narsaning ro'yxati uchun) yoki menyu orqali ishga tushadi. Doimiy UI elementi yagona — [yuqori panel](05-the-top-bar.md), u ilgari menyu paneli, tizim treyi va Notification Center siz uchun qilgan ishlarni bajaradi — va undagi deyarli har bir vidjet chap, o'ng va o'rta bosishda nimadir qiladi.

### Derazalar o'zlari joylashadi

Eng katta tafakkur o'zgarishi: siz derazalarni sudrab yurmaysiz yoki ekran yarmiga yopishtirmaysiz. Deraza oching va u butun ekranni egallaydi. Ikkinchisini oching va ular ekranni bo'lishadi. Hech qachon derazani boshqasining ostidan qidirib topmaysiz, chunki derazalar bir-birining ustiga chiqmaydi.

Chindan ham suzuvchi deraza kerak bo'lganda, `Super + T` faol derazani plitkalashdan chiqaradi (va qaytaradi). Lekin avval plitkalashga chin imkon bering — u butun narsaning yuragi. [Navigation](04-navigation.md) sizni u orqali olib o'tadi.

Ish maydonlari tanish tuyuladi: ular macOS Spaces yoki Windows virtual ish stollari, faqat siz ulardan chindan ham foydalanasiz, chunki `Super + 1/2/3/4` to'g'ridan-to'g'ri bittasiga sakraydi va `Super + Shift + 1/2/3/4` faol derazani o'sha yerga yuboradi. Animatsiya kechikishi yo'q, faqat bir zumda sakrashlar. Bu shuni anglatadiki, agar ilgari bunga o'rganib qolgan bo'lsangiz, hatto bir nechta monitor ham kerak bo'lmasligi mumkin.

### Nusxalash va qo'yish shunchaki ishlaydi

Mac'da sizda hamma joyda Cmd + C bor edi. Windows'da sizda hamma joyda Ctrl + C bor edi — terminaldan tashqari, u yerda u dasturingizni o'ldiradi. Omarchy sizga `Super + C`, `Super + X` va `Super + V` ni beradi va ular hamma joyda, jumladan terminalda ham ishlaydi. Shell uchun alohida refleks o'rganish shart emas.

Windows'dan kelganlar: Win + V bufer tarixingiz `Super + Ctrl + V` da yashaydi va u matn bilan birga tasvirlarni ham saqlaydi. [yagona bufer va tarix](08-unified-clipboard-history.md) ga qarang.

### Tarjima jadvali

| Siz intiladigan narsa | Omarchy'da |
| ------------- | ---------- |
| Spotlight / Raycast / Start menyusi | `Super + Space` — Omarchy menyusi |
| AirDrop | LocalSend, `Super + Ctrl + S` orqali — [GUI'lar](22-guis.md) ga qarang |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` yoki `Print Screen` — [skrinshotlar va yozib olish](12-screenshots-recording.md) ga qarang |
| Notification Center | `Super + Shift + Alt + ,` dagi bildirishnomalar tarixi |
| Time Machine (tizim uchun) | Har bir yangilanishda avtomatik [tizim suratlari](47-system-snapshots.md) |
| App Store / o'rnatuvchini yuklab olish | Menyudagi _Install_ yoki `omarchy pkg add` — [boshqa paketlar](29-other-packages.md) ga qarang |
| System Settings / Control Panel | Oddiy konfiguratsiya fayllarini tahrirlaydigan menyudagi _Setup_ — [dotfiles](31-dotfiles.md) ga qarang |

### Ba'zi narsalar chindan ham boshqacha

Ko'p sozlamalar siz bosib o'tadigan panellarda emas, tahrir qiladigan matn fayllarida yashaydi. Bu ibtidoiy tuyuladi, toki har bir o'zgarishni ko'rish, keyingi mashinangizga nusxalash va versiya nazoratiga qo'yish mumkinligini anglamaguningizcha. _Setup_ menyusi sizni to'g'ridan-to'g'ri kerakli faylga tushiradi va tugatganingizda qayta ishga tushirish kerak bo'lgan narsani qayta ishga tushiradi.

Yangilanishlar bitta buyruq — _Update > Omarchy_ — orqali keladi, u Omarchy'ning o'zini va tizimdagi har bir paketni yangilaydi, avval surat oladi. Tasodifiy paytlarda bezovta qiladigan ilova bo'yicha yangilovchilar yo'q. [yangilanishlar](30-updates.md) ga qarang.

Dasturlar yuklab olingan o'rnatuvchilardan emas, paket menejeridan keladi.

Va derazani yopganingizda, ilova chindan ham chiqib ketadi. Dastur derazasiz ishlashda davom etadigan macOS limbi yo'q. `Super + W` — yoki agar shu barmoq xotirasi bilan kelgan bo'lsangiz, `Super + Q` — ketdi degani.

### Mac qurilmalarida

Omarchy Intel Mac'larda yaxshi ishlaydi — [Mac qo'llab-quvvatlovi](44-mac-support.md) ga qarang. Va klaviatura sizga mehribon: Omarchy hech narsani qayta bog'lamaydi va Linux Command tugmasini Super sifatida qabul qiladi, shuning uchun Super aynan Cmd doim bo'lgan joyda o'tiradi. Bosh barmog'ingiz ko'chishni sezmaydi ham.

### Unga ikki hafta bering

Instinktlar o'ylaganingizdan tezroq o'tadi. [tezkor tugmalar](07-hotkeys.md) bobini bir marta ko'rib chiqing va bog'lanishni esdan chiqarganingizda, `Super + K` ni bosing — u sizga ularning hammasini ko'rsatadi. Bu chindan ham yodlashingiz kerak bo'lgan yagona tezkor tugma.
