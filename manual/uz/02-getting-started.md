# Ishni boshlash

Omarchy ISO yordamida o'rnatiladi. Siz butun diskni egallab oladigan to'liq diskka o'rnatishni yoki Omarchy'ni diskdagi ajratilmagan bo'sh joyga joylashtiradigan bo'sh joyga o'rnatishni tanlashingiz mumkin — Windows yoki boshqa OT yonida ikkita tizimni yonma-yon yuklash shunday amalga oshiriladi (qarang [ikkita tizimni yonma-yon o'rnatish](50-dual-boot-install.md) — e'tibor bering, avval Windows'da BitLocker'ni o'chirib qo'yishingiz kerak bo'ladi). Har qanday holatda ham o'rnatish sukut bo'yicha to'liq shifrlash bilan amalga oshiriladi va to'liq disk varianti tanlangan diskni butunlay tozalab tashlaydi, shuning uchun mavjud diskdan foydalanishdan oldin albatta zaxira nusxa olib qo'ying!

Avval [Omarchy ISO'ni yuklab oling](https://omarchy.org/), uni USB xotira qurilmasiga yozing (Windows'da [Rufus](https://rufus.ie/), Mac'da [balenaEtcher](https://etcher.balena.io/), Linux'da [caligula](https://github.com/ifd3f/caligula) dan foydalaning) va shu qurilmadan yuklaning.

_BIOS'da Secure Boot va/yoki TPM'ni o'chirib qo'yishingiz shart. Omarchy'ni o'rnata olishingiz uchun bularni o'chirishingiz kerak. Bular Windows va Microsoft bilan bog'liq Linux distributivlari uchun mo'ljallangan Microsoft xavfsizlik sxemalaridir._

Keyin konfiguratsiya savollariga javob bering va ularni mana bunday tasdiqlang:

 ![install-config](images/install-config.webp)

Keyin o'rnatish uchun diskni tanlang va orqaga suyanib, o'rnatish shousini tomosha qiling. Bu eng tezkor zamonaviy mashinalarda bir daqiqadan kam vaqtda bajarilishi mumkin, lekin eski kompyuterda ham 5 daqiqadan ko'p vaqt olmasligi kerak.

 ![install-done](images/install-done.webp)

Endi siz Omarchy'dan foydalanishga tayyorsiz!

### Simli yoki 2.4ghz klaviaturadan foydalaning!

To'liq disk shifrlashi ishga tushish paytida parolni Bluetooth klaviaturadan kiritishingizga ruxsat bermaydi. Xuddi PC'da BIOS'ga kirish uchun Bluetooth klaviaturadan foydalana olmaganingiz kabi. Sizga 2.4ghz adapterdan foydalanadigan yoki kabelli klaviatura kerak bo'ladi (kechikish jihatidan ham bu ancha yoqimli!). Shaxsan menga [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard) juda yoqadi!

### Boshqa egasi uchun o'rnatish

Agar siz mashinani boshqa birov uchun — oila a'zosi, yangi xodim, xaridor uchun sozlayotgan bo'lsangiz, shaxsiy savollarga uning nomidan javob bermasligingiz kerak. O'rnatuvchining eng birinchi ekranida (klaviaturani tanlash) `Ctrl + C` ni bosing va Omarchy uning o'rniga mashinani boshqa egasi uchun tayyorlashni taklif qiladi. Tizim darhol o'rnatiladi, lekin barcha shaxsiy sozlamalar — klaviatura tartibi, foydalanuvchi nomi, parol — mashina birinchi marta yuklangunga qadar qoldiriladi. Disk hali ham sukut bo'yicha shifrlanadi va yangi egasi o'sha birinchi yuklanishda tanlagan parol shifrlash paroliga ham aylanadi. (Siz allaqachon foydalanib kelayotgan mashinani ham qayta o'rnatmasdan topshirish mumkin — qarang [kompyuterni tiklash](48-security.md).)

### Nazoratsiz o'rnatishlar

ISO'ga ikkinchi diskda uning konfiguratsiyasi berilsa, u butunlay o'zi ham o'rnatilishi mumkin — na klaviatura, na usta kerak. Omarchy'ga VMs va mashinalar parki uchun asosiy obraz sifatida qarashning yo'li shu. Qarang [nazoratsiz o'rnatishlar](51-unattended-installs.md).

### Shifrlashsiz o'rnatishlar

Omarchy sukut bo'yicha shifrlash bilan o'rnatiladi. Yo'qolishi yoki o'g'irlanishi mumkin bo'lgan har qanday kompyuter uchun bu xavfsiz, mas'uliyatli tanlovdir. Qurilmangizga ega bo'lgan har kim ma'lumotlaringizga kira olishini xohlamaysiz!

Lekin maxsus holatlarda, masalan, himoyalangan kompyuterlarga masofadan Omarchy o'rnatishda yoki maxfiy ma'lumotlari bo'lmagan bir martalik o'rnatishlarda, shifrlashsiz o'rnatishni xohlashingiz mumkin. Shifrlashsiz o'rnatishga o'tish uchun diskni formatlashni tasdiqlashda `Ctrl + C` ni bosishingiz mumkin.

### Til

Omarchy 50 tilda gapiradi — omarchy.org'dagi bilan bir xil to'plam — va English sukut bo'yicha tildir. O'zgartirish uchun Omarchy menyusini oching va _Sozlash > Mintaqa > Til_ ga o'ting yoki terminalda `omarchy language <code>` ni ishga tushiring (`omarchy language list` kodlarni ko'rsatadi). Menyu, ish stoli va Omarchy'ning o'z bildirishnomalari tilni darhol o'zgartiradi va undan keyin ochadigan har bir ilovangiz ham shunga ergashadi. Allaqachon ochiq bo'lgan ilovalar ularni qayta ishga tushirganingizdan keyin o'zgaradi.

Tilni saqlab qolib, lekin sanalar, vaqtlar, raqamlar, pul, birliklar va qog'oz o'lchamlarini boshqa mintaqadagi kabi yozish uchun (masalan, European sanalari va 24 soatlik soat bilan English), _Sozlash > Mintaqa > Formatlar_ ostida mintaqani tanlang, bu yerda har bir tanlov namunani ko'rsatadi, yoki `omarchy region <code>` ni ishga tushiring (`omarchy region list` kodlarni ko'rsatadi). _Til bilan bir xil_ tilning o'z formatlariga qaytaradi. Tilni o'zgartirish kabi, bu ham undan keyin ochadigan ilovalaringizga yetib boradi.

### Qotib qolsangiz yordam

Agar qotib qolsangiz, odatda [hamjamiyat Discord](https://omarchy.org/discord) idagi _#omarchy-help_ kanalida yordam berishga tayyor odamni topishingiz mumkin.
