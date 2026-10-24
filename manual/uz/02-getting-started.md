# Ishni boshlash

Omarchy ISO yordamida o'rnatiladi. Siz butun diskni egallaydigan to'liq diskka o'rnatishni yoki Omarchy-ni diskdagi ajratilmagan joyga joylashtiradigan bo'sh joyga o'rnatishni tanlashingiz mumkin — Windows yoki boshqa OS yonida dual boot qilish shunday amalga oshiriladi (qarang: [dual-boot o'rnatish](50-dual-boot-install.md) — e'tibor bering, avvalo Windows-da BitLocker-ni o'chirish kerak bo'ladi). Har qanday holatda ham o'rnatish sukut bo'yicha to'liq shifrlash bilan amalga oshiriladi va to'liq disk varianti tanlangan diskni tozalab yuboradi, shuning uchun mavjud diskdan foydalanishdan oldin albatta zaxira nusxasini oling!

Avvalo [Omarchy ISO-ni yuklab oling](https://omarchy.org/), uni USB xotira qurilmasiga yozing (Mac/Windows-da [balenaEtcher](https://etcher.balena.io/), Linux-da esa [caligula](https://github.com/ifd3f/caligula) dan foydalaning) va shu qurilmadan yuklang.

_BIOS-da Secure Boot va/yoki TPM-ni o'chirishingiz shart. Omarchy-ni o'rnata olishingiz uchun bularni o'chirishingiz kerak. Bular Windows va Microsoft bilan bog'liq Linux distributivlari uchun mo'ljallangan Microsoft xavfsizlik sxemalaridir._

Keyin konfiguratsiya savollariga javob bering va ularni mana bunday tasdiqlang:

 ![install-config](images/install-config.webp)

Keyin o'rnatish uchun disk tanlang, orqaga suyaning va o'rnatish tomoshasining borishini kuzating. Eng tez zamonaviy mashinalarda bu bir daqiqadan kam vaqtda bajarilishi mumkin, lekin eskiroq kompyuterda ham 5 daqiqadan ko'p vaqt ketmasligi kerak.

 ![install-done](images/install-done.webp)

Endi Omarchy-lashga tayyorsiz!

### Simli yoki 2.4ghz klaviaturadan foydalaning!

Diskni to'liq shifrlash ishga tushishda Bluetooth klaviaturadan parolni kiritishga ruxsat bermaydi. Xuddi PC-da BIOS-ga kirish uchun Bluetooth klaviaturadan foydalana olmasligingiz kabi. Sizga 2.4ghz dongle ishlatadigan yoki kabelli klaviatura kerak bo'ladi (bu har holda kechikish jihatidan ancha yaxshiroq!). Menga shaxsan [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard) juda yoqadi!

### Boshqa egasi uchun o'rnatish

Agar siz mashinani boshqa birov — oila a'zosi, yangi xodim, xaridor — uchun sozlayotgan bo'lsangiz, shaxsiy savollarga ularning nomidan javob bermasligingiz kerak. O'rnatuvchining eng birinchi ekranida (klaviatura tanlashda) `Ctrl + C` ni bosing, shunda Omarchy buning o'rniga mashinani boshqa egasi uchun tayyorlashni taklif qiladi. Tizim darhol o'rnatiladi, lekin barcha shaxsiy sozlashlar — klaviatura joylashuvi, foydalanuvchi nomi, parol — mashina birinchi marta yuklanguncha qoldiriladi. Disk baribir sukut bo'yicha shifrlangan bo'ladi va yangi egasi birinchi yuklanishda tanlagan parol shifrlash paroliga ham aylanadi. (Allaqachon o'zingiz foydalanib kelgan mashinani ham qayta o'rnatmasdan topshirish mumkin — qarang: [kompyuterni boshlang'ich holatga qaytarish](48-security.md).)

### Nazoratsiz o'rnatishlar

ISO unga konfiguratsiyasi ikkinchi diskda topshirilganda butunlay o'z-o'zidan ham o'rnatilishi mumkin — klaviatura ham, o'rnatish yordamchisi ham kerak emas. Omarchy-ga VM-lar va mashinalar parki uchun asosiy tasvir sifatida munosabatda bo'lishning yo'li shudir. Qarang: [nazoratsiz o'rnatishlar](51-unattended-installs.md).

### Shifrlashsiz o'rnatishlar

Omarchy sukut bo'yicha shifrlash bilan o'rnatiladi. Yo'qolishi yoki o'g'irlanishi mumkin bo'lgan har qanday kompyuter uchun bu xavfsiz, mas'uliyatli tanlovdir. Qurilmangizga kira olgan har qanday odam ma'lumotlaringizga ega bo'lishini istamaysiz!

Lekin alohida holatlarda, masalan, himoyalangan kompyuterlarga masofadan Omarchy o'rnatishda yoki maxfiy ma'lumotlari bo'lmagan bir martalik o'rnatishlarda, shifrlashsiz o'rnatishni istashingiz mumkin. Shifrlashsiz o'rnatishga o'tish uchun diskni formatlashni tasdiqlashda `Ctrl + C` ni bosishingiz mumkin.

### Til

Omarchy 50 tilda gaplashadi — omarchy.org dagi ayni to'plam — va sukut bo'yicha ingliz tili ishlatiladi. Almashtirish uchun Omarchy menyusini oching va _Setup > Language_ ga o'ting, yoki terminalda `omarchy language <code>` buyrug'ini ishga tushiring (`omarchy language list` kodlarni ko'rsatadi). Menyu, ish stoli va Omarchy-ning o'z bildirishnomalari tilni darhol o'zgartiradi va shundan keyin ochadigan har bir dasturingiz ham shunga ergashadi. Allaqachon ochiq bo'lgan dasturlar ularni qayta ishga tushirganingizdan keyin o'tadi.

### Qiyin ahvolda qolsangiz yordam

Agar qiyin ahvolda qolsangiz, odatda [hamjamiyat Discord](https://omarchy.org/discord) dagi _#omarchy-help_ kanalida yordam berishga tayyor odamni topishingiz mumkin.
