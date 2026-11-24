# Boshlash

Omarchy ISO yordamida o'rnatiladi. Siz butun diskni egallaydigan to'liq diskli o'rnatishni yoki Omarchy ni diskdagi ajratilmagan bo'sh joyga joylashtiradigan bo'sh joyli o'rnatishni tanlashingiz mumkin — Windows yoki boshqa OT bilan yonma-yon ikki tizimni birga yuklash shunday amalga oshiriladi (qarang: [ikki tizimni birga o'rnatish](50-dual-boot-install.md) — e'tibor bering, avval Windows da BitLocker ni o'chirib qo'yishingiz kerak bo'ladi). Har ikkala holatda ham o'rnatish sukut bo'yicha to'liq shifrlash bilan amalga oshiriladi, to'liq diskli variant esa tanlangan diskni butunlay tozalab tashlaydi, shuning uchun mavjud diskdan foydalanishdan oldin albatta zaxira nusxasini olib qo'ying!

Apple Silicon li Mac da siz buning o'rniga macOS dan o'rnatasiz, ISO ham, USB fleshka ham kerak emas. Qarang: [Apple Silicon uchun Omarchy](44-mac-support.md#omarchy-for-apple-silicon).

Avval [Omarchy ISO faylini yuklab oling](https://omarchy.org/), uni USB fleshkaga yozing (Windows da [Rufus](https://rufus.ie/) dan, Mac da [balenaEtcher](https://etcher.balena.io/) dan yoki Linux da [caligula](https://github.com/ifd3f/caligula) dan foydalaning) va fleshkadan yuklaning.

_Siz BIOS da Secure Boot va/yoki TPM ni o'chirib qo'yishingiz shart. Omarchy ni o'rnata olish uchun bularni o'chirishingiz kerak. Bular Windows va Microsoft ga aloqador Linux distributivlari uchun mo'ljallangan Microsoft xavfsizlik sxemalaridir._

Keyin konfiguratsiya savollariga javob bering va ularni mana bunday tasdiqlang:

 ![install-config](images/install-config.webp)

Keyin o'rnatish uchun diskni tanlang, orqaga suyanib o'tirib, o'rnatish tomoshasini kuzating. Eng tezkor zamonaviy mashinalarda buni bir daqiqadan kam vaqt ichida bajarish mumkin, lekin eskiroq kompyuterda ham bu 5 daqiqadan ko'proq vaqt olmasligi kerak.

 ![install-done](images/install-done.webp)

Endi siz Omarchy ga tayyorsiz!

### Simli yoki 2.4ghz klaviaturadan foydalaning!

To'liq disk shifrlashi ishga tushishda parolni Bluetooth klaviaturadan kiritishingizga ruxsat bermaydi. Xuddi PC da BIOS ga kirish uchun Bluetooth klaviaturadan foydalana olmaganingizdek. Sizga 2.4ghz dongle ishlatadigan yoki kabelli klaviatura kerak bo'ladi (bu kechikish jihatidan ham ancha yoqimli!). Men shaxsan [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard) ni juda yaxshi ko'raman!

### Boshqa egasi uchun o'rnatish

Agar siz mashinani boshqa birov — oila a'zosi, yangi xodim, xaridor — uchun sozlayotgan bo'lsangiz, shaxsiy savollarga ularning nomidan javob bermasligingiz kerak. O'rnatuvchining eng birinchi ekranida (klaviaturani tanlash) `Ctrl + C` tugmalarini bosing, shunda Omarchy buning o'rniga mashinani boshqa egasi uchun tayyorlashni taklif qiladi. Tizim darhol o'rnatiladi, lekin barcha shaxsiy sozlashlar — klaviatura tartibi, foydalanuvchi nomi, parol — mashina birinchi marta yuklangunga qadar qoldiriladi. Disk hamon sukut bo'yicha shifrlangan bo'ladi, yangi egasi o'sha birinchi yuklanishda tanlagan parol esa shifrlash paroliga ham aylanadi. (Siz allaqachon foydalanib kelayotgan mashinani qayta o'rnatmasdan ham topshirish mumkin — qarang: [kompyuterni tiklash](48-security.md).)

### Qarovsiz o'rnatishlar

ISO, konfiguratsiyasi ikkinchi diskda berilgan bo'lsa, butunlay o'z-o'zidan — klaviaturasiz, o'rnatish ustasisiz — ham o'rnatilishi mumkin. Omarchy ga VM lar va mashinalar parki uchun bazaviy obraz sifatida munosabatda bo'lish usuli shudir. Qarang: [qarovsiz o'rnatishlar](51-unattended-installs.md).

### Shifrlashsiz o'rnatishlar

Omarchy sukut bo'yicha shifrlash bilan o'rnatiladi. Bu yo'qolishi yoki o'g'irlanishi mumkin bo'lgan har qanday kompyuter uchun xavfsiz, mas'uliyatli tanlovdir. Uskunangizga kira oladigan kimdir ma'lumotlaringizga ham kira olishini xohlamaysiz!

Lekin maxsus holatlarda, masalan, himoyalangan kompyuterlarga masofaviy Omarchy o'rnatishlarda yoki maxfiy ma'lumotlari bo'lmagan bir martalik o'rnatishlar uchun, siz shifrlashsiz o'rnatishni xohlashingiz mumkin. Shifrlashsiz o'rnatishga o'tish uchun diskni formatlash tasdig'ida `Ctrl + C` tugmalarini bosishingiz mumkin.

### Til

Omarchy 50 tilda gaplashadi — omarchy.org dagi xuddi shu to'plam — va English sukut bo'yicha tildir. Almashtirish uchun Omarchy menyusini oching va _Sozlash > Mintaqa > Til_ bo'limiga o'ting yoki terminalda `omarchy language <code>` buyrug'ini ishga tushiring (`omarchy language list` kodlarni ko'rsatadi). Menyu, ish stoli va Omarchy ning o'z bildirishnomalari tilni darhol o'zgartiradi, undan keyin ochadigan har bir ilovangiz ham shunga ergashadi. Allaqachon ochiq bo'lgan ilovalar ularni qayta ishga tushirganingizda almashadi.

Tilni saqlab qolib, lekin sanalar, vaqtlar, raqamlar, pul, birliklar va qog'oz o'lchamlarini boshqa mintaqa usulida yozish uchun (aytaylik, English, lekin Yevropa sanalari va 24 soatlik soat bilan), _Sozlash > Mintaqa > Formatlar_ ostidan mintaqani tanlang, bu yerda har bir tanlov namuna ko'rsatadi, yoki `omarchy region formats <code>` buyrug'ini ishga tushiring (`omarchy region formats list` kodlarni ko'rsatadi). _Til bilan bir xil_ varianti tilning o'z formatlariga qaytaradi. Tilni almashtirish kabi, bu ham undan keyin ochadigan ilovalaringizga yetib boradi.

### Tiqilib qolsangiz yordam

Agar tiqilib qolsangiz, odatda [hamjamiyat Discord](https://omarchy.org/discord) idagi _#omarchy-help_ kanalida yordam berishga tayyor kimnidir topishingiz mumkin.
