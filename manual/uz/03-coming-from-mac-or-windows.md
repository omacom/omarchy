# Mac yoki Windowsdan oʻtish

Agar yillar davomida macOS yoki Windowsda oʻtkazgan boʻlsangiz, barmoqlaringiz miyangiz qachon oʻrganganini unutib yuborgan yuzlab narsalarni biladi. Bu bob — tarjima qatlami: Omarchyda oʻsha instinktlar qayerga ketadi. Xususiyatlarning oʻzi boshqa joylarda chuqur yoritilgan — bu shunchaki xarita.

### Super — hammasining markazi

Cmd yoki Windows tugmasi atrofida shakllantirgan barcha mushak xotirangiz bitta tugmaga koʻchadi: Super. Bu kompyuter klaviaturasidagi Windows tugmasi va Omarchydagi deyarli har bir hotkey uchun tayanch nuqtadir.

Spotlight, Raycast yoki Start menyusi refleksingiz `Super + Space` ga aylanadi. Bu Omarchy menyusini ochadi, u ilovalarni ishga tushiradi, sozlamalarni oʻzgartiradi, dasturlarni oʻrnatadi, ekranni oladi — deyarli hamma narsa. Filtrlash uchun yozishni boshlang. `Super + Alt + Space` barcha ilovalarni Launchpad qilganidek bitta panjarada koʻrsatadi. [Navigatsiya](04-navigation.md) ga qarang.

### Dock ham, ish stoli ikonkalar ham yoʻq

Narsalarni ishga tushirish uchun bosiladigan narsa yoʻq, ish stolida tartibga solinadigan ikonkalar yoʻq. Ilovalar hotkeydan (terminal uchun `Super + Return`, brauzer uchun `Super + Shift + Return`, va xaritaga kiritilgan hamma narsaning roʻyxati uchun `Super + K`) yoki menyudan ishga tushadi. Yagona doimiy UI qismi — [yuqori panel](05-the-top-bar.md), u avval siz uchun menyu paneli, tizim laganda va Notification Center bajargan ishni bajaradi — va undagi deyarli har bir vidjet chap, oʻng va oʻrta bosishda nimadir qiladi.

### Oynalar oʻzlarini joylashtiradi

Eng katta tafakkur oʻzgarishi: siz oynalarni sudrab yurmaysiz yoki ularni ekran yarimlariga yopishtirmaysiz. Oyna ochasiz va u butun ekranni egallaydi. Ikkinchisini ochasiz va ular uni boʻlishadi. Siz hech qachon oynani boshqasining ostidan chiqarib olmaysiz, chunki oynalar ustma-ust tushmaydi.

Haqiqatan suzuvchi oyna kerak boʻlganda, `Super + T` faol oynani mozaikadan chiqaradi (va qaytaradi). Lekin avval mozaikaga haqiqiy imkoniyat bering — u butun narsaning yuragi. [Navigatsiya](04-navigation.md) sizni undan oʻtkazadi.

Ish maydonlari tanish tuyuladi: ular macOS Spaces yoki Windows virtual ish stollariga oʻxshaydi, faqat siz ularni haqiqatan ishlatasiz, chunki `Super + 1/2/3/4` toʻgʻridan-toʻgʻri bittasiga sakraydi va `Super + Shift + 1/2/3/4` faol oynani u yerga yuboradi. Animatsiya kechikishi yoʻq, faqat bir zumda sakrashlar. Bu shuni anglatadiki, agar avval unga oʻrganib qolgan boʻlsangiz, bir nechta monitor ham kerak boʻlmasligi mumkin.

### Nusxalash va qoʻyish shunchaki ishlaydi

Macda hamma joyda Cmd + C bor edi. Windowsda hamma joyda Ctrl + C bor edi — terminaldan tashqari, u yerda u dasturingizni oʻldiradi. Omarchy sizga `Super + C`, `Super + X` va `Super + V` beradi va ular hamma joyda, jumladan terminalda ham ishlaydi. Shell uchun alohida refleks oʻrganishga hojat yoʻq.

Windowsliklar: Win + V bufer tarixingiz `Super + Ctrl + V` da yashaydi va u matn bilan birga rasmlarni ham saqlaydi. [Yagona bufer va tarix](08-unified-clipboard-history.md) ga qarang.

### Tarjima jadvali

| Yetib borgan narsangiz | Omarchyda |
| ------------- | ---------- |
| Spotlight / Raycast / Start menyusi | `Super + Space` — Omarchy menyusi |
| AirDrop | LocalSend, `Super + Ctrl + S` orqali — [GUIlar](22-guis.md) ga qarang |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — [skrinshotlar va yozuv](12-screenshots-recording.md) ga qarang |
| Notification Center | Bildirishnoma tarixi `Super + Shift + Alt + ,` da |
| Time Machine (tizim uchun) | Har yangilanishda avtomatik [tizim snatshotlari](47-system-snapshots.md) |
| App Store / oʻrnatuvchi yuklab olish | Menyudagi _Oʻrnatish_ yoki `omarchy pkg add` — [boshqa paketlar](29-other-packages.md) ga qarang |
| System Settings / Control Panel | Menyudagi _Sozlash_, u oddiy konfiguratsiya fayllarini tahrirlaydi — [dotfiles](31-dotfiles.md) ga qarang |

### Baʼzi narsalar haqiqatan ham boshqacha

Koʻplab sozlamalar siz bosib oʻtadigan panellarda emas, siz tahrirlaydigan matn fayllarida yashaydi. Bu ibtidoiy eshitiladi, toki bu har bir oʻzgartirishni koʻrish, keyingi mashinangizga nusxalash va versiya nazoratiga qoʻyish mumkinligini anglamaguningizcha. _Sozlash_ menyusi sizni toʻgʻridan-toʻgʻri kerakli faylga tashlaydi va tugatganingizda qayta ishga tushirish kerak boʻlgan narsani qayta ishga tushiradi.

Yangilanishlar bitta buyruq orqali keladi — _Yangilash > Omarchy_ — u Omarchyning oʻzini va tizimdagi har bir paketni yangilaydi, avval snatshot oladi. Tasodifan bezovta qiladigan ilova yangilovchilari yoʻq. [Yangilanishlar](30-updates.md) ga qarang.

Dasturiy taʼminot yuklab olingan oʻrnatuvchilar emas, paket boshqaruvchisidan keladi.

Va oyna yopganingizda, ilova haqiqatan ham chiqib ketadi. Dastur oynalarsiz ishlashda davom etadigan macOS limba yoʻq. `Super + W` — yoki agar shu barmoq xotirasi bilan kelgan boʻlsangiz `Super + Q` — ketdi degani.

### Mac apparaturasida

Omarchy Intel Maclarda yaxshi ishlaydi — [Mac qoʻllab-quvvatlash](44-mac-support.md) ga qarang. Klaviatura ham sizga mehribon: Omarchy hech narsani qayta xaritaga kiritmaydi va Linux Command tugmasini Super deb hisoblaydi, shuning uchun Super Cmd har doim boʻlgan joyda oʻtiradi. Bosh barmogʻingiz koʻchishni sezmaydi.

### Ikki hafta bering

Instinktlar oʻylaganingizdan tezroq oʻtadi. [Hotkeylar](07-hotkeys.md) bobini bir marta koʻzdan kechiring va bogʻlanishni unutganingizda `Super + K` ni bosing — u ularning hammasini koʻrsatadi. Bu haqiqatan yodlab olishingiz kerak boʻlgan yagona hotkey.
