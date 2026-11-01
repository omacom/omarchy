# Boshlash

Omarchy ISO yordamida o'rnatiladi. Siz butun diskni egallaydigan to'liq diskka o'rnatishni yoki Omarchyni diskdagi ajratilmagan bo'sh joyga joylashtiradigan bo'sh joyga o'rnatishni tanlashingiz mumkin — Windows yoki boshqa OT bilan birga dual boot qilish shunday amalga oshiriladi (qarang: [dual-boot o'rnatish](50-dual-boot-install.md) — e'tibor bering, avval Windows'da BitLocker'ni o'chirishingiz kerak bo'ladi). Har qanday holatda ham o'rnatishda standart bo'yicha to'liq shifrlash yoqiladi va to'liq disk varianti tanlangan diskdagi barcha narsani o'chirib yuboradi, shuning uchun mavjud diskdan foydalanishdan oldin albatta zaxira nusxasini oling!

Avval [Omarchy ISO'sini yuklab oling](https://omarchy.org/), uni USB flechkaga yozing (Windows'da [Rufus](https://rufus.ie/), Mac'da [balenaEtcher](https://etcher.balena.io/) yoki Linux'da [caligula](https://github.com/ifd3f/caligula) dan foydalaning) va flechkadan yuklang.

_BIOS'da Secure Boot va/yoki TPM'ni o'chirishingiz shart. Omarchy'ni o'rnata olish uchun bularni o'chirishingiz kerak. Bular Windows va Microsoft'ga aloqador Linux distributivlari uchun mo'ljallangan Microsoft xavfsizlik sxemalari._

Keyin konfiguratsiya savollariga javob bering va ularni mana bunday tasdiqlang:

 ![install-config](images/install-config.webp)

Keyin o'rnatish uchun diskni tanlang, bemalol o'tirib, o'rnatish shousini tomosha qiling. Bu eng tez zamonaviy mashinalarda bir daqiqadan kam vaqt ichida tugashi mumkin, lekin hatto eski kompyuterda ham 5 daqiqadan ko'p vaqt olmasligi kerak.

 ![install-done](images/install-done.webp)

Endi siz Omarchy'ga tayyorsiz!

### Simli yoki 2.4ghz klaviaturadan foydalaning!

To'liq disk shifrlashi ishga tushishda Bluetooth klaviaturadan parol kiritishga ruxsat bermaydi. Xuddi PC'da BIOS'ga kirish uchun Bluetooth klaviaturadan foydalana olmaganingizdek. Sizga 2.4ghz dongle ishlatadigan yoki kabelli klaviatura kerak bo'ladi (bu kechikish jihatidan ham ancha yaxshi!). Shaxsan menga [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard) juda yoqadi!

### Boshqa egasi uchun o'rnatish

Agar siz mashinani boshqa birov uchun — oila a'zosi, yangi xodim, xaridor uchun tayyorlayotgan bo'lsangiz — shaxsiy savollarga ular nomidan javob bermasligingiz kerak. O'rnatuvchining eng birinchi ekranida (klaviatura tanlash) `Ctrl + C` ni bosing, shunda Omarchy mashinani boshqa egasi uchun tayyorlashni taklif qiladi. Tizim darhol o'rnatiladi, lekin barcha shaxsiy sozlashlar — klaviatura tartibi, foydalanuvchi nomi, parol — mashina birinchi marta yuklangunicha qoldiriladi. Disk hali ham standart bo'yicha shifrlangan bo'ladi va yangi egasi o'sha birinchi yuklanishda tanlagan parol shifrlash paroliga ham aylanadi. (Siz allaqachon ishlatib kelayotgan mashinani ham qayta o'rnatmasdan topshirish mumkin — qarang: [kompyuterni tiklash](48-security.md).)

### Nazoratsiz o'rnatishlar

ISO ham butunlay o'zi o'rnatilishi mumkin — na klaviatura, na usta kerak — unga konfiguratsiyasi ikkinchi diskda berilsa. Omarchy'ga VM'lar va mashinalar parki uchun asosiy obraz sifatida qarashning yo'li shu. Qarang: [nazoratsiz o'rnatishlar](51-unattended-installs.md).

### Shifrlashsiz o'rnatishlar

Omarchy standart bo'yicha shifrlash bilan o'rnatiladi. Bu yo'qolishi yoki o'g'irlanishi mumkin bo'lgan har qanday kompyuter uchun xavfsiz, mas'uliyatli tanlov. Uskunangizga kira oladigan hech kim ma'lumotlaringizga ega bo'lishini xohlamaysiz!

Lekin maxsus holatlarda, masalan, himoyalangan kompyuterlarga masofaviy Omarchy o'rnatishlarda yoki maxfiy ma'lumotlari bo'lmagan bir martalik o'rnatishlarda, shifrlashsiz o'rnatishni xohlashingiz mumkin. Shifrlashsiz o'rnatishga o'tish uchun diskni formatlashni tasdiqlashda `Ctrl + C` ni bosishingiz mumkin.

### Til

Omarchy 50 ta tilda gapiradi — omarchy.org'dagi bilan bir xil to'plam — va standart til ingliz tili. Almashtirish uchun Omarchy menyusini oching va _Setup > Language_ ga o'ting yoki terminalda `omarchy language <code>` ni ishga tushiring (`omarchy language list` kodlarni ko'rsatadi). Menyu, ish stoli va Omarchy'ning o'z bildirishnomalari tilni darhol o'zgartiradi va undan keyin ochadigan har bir ilovangiz ham shunga ergashadi. Allaqachon ochiq bo'lgan ilovalar ularni qayta ishga tushirganingizda almashadi.

### Agar tiqilib qolsangiz, yordam

Agar tiqilib qolsangiz, odatda [jamiyat Discord](https://omarchy.org/discord)'idagi _#omarchy-help_ kanalida yordam berishga tayyor kishini topishingiz mumkin.
