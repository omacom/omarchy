# Ishni boshlash

Omarchy ISO yordamida o‘rnatiladi. Siz butun diskni egallaydigan to‘liq diskka o‘rnatishni yoki Omarchy’ni diskdagi ajratilmagan joyga qo‘yadigan bo‘sh joyga o‘rnatishni tanlashingiz mumkin — Windows yoki boshqa OS yonida dual boot qilish shunday amalga oshiriladi (qarang: [dual-boot o‘rnatish](50-dual-boot-install.md) — e’tibor bering, avval Windows’da BitLocker’ni o‘chirishingiz kerak bo‘ladi). Har qanday holatda ham o‘rnatish sukut bo‘yicha to‘liq shifrlash bilan amalga oshiriladi va to‘liq disk varianti tanlangan diskni butunlay tozalab yuboradi, shuning uchun mavjud diskdan foydalansangiz, oldindan zaxira nusxasini olishni unutmang!

Avval [Omarchy ISO’sini yuklab oling](https://omarchy.org/), uni USB fleshkaga yozing (Windows’da [Rufus](https://rufus.ie/), Mac’da [balenaEtcher](https://etcher.balena.io/) yoki Linux’da [caligula](https://github.com/ifd3f/caligula) dan foydalaning) va fleshka orqali yuklang.

_BIOS’da Secure Boot va/yoki TPM’ni o‘chirishingiz shart. Omarchy’ni o‘rnata olishingiz uchun bularni o‘chirishingiz kerak. Bular Windows va Microsoft’ga aloqador Linux distributivlari uchun mo‘ljallangan Microsoft xavfsizlik sxemalaridir._

Keyin konfiguratsiya savollariga javob bering va ularni mana bunday tasdiqlang:

 ![install-config](images/install-config.webp)

Keyin o‘rnatish uchun diskni tanlang, orqaga suyanib o‘tiring va o‘rnatish tomoshasini kuzating. Bu eng tezkor zamonaviy mashinalarda bir daqiqadan kam vaqt ichida tugashi mumkin, lekin hatto eski kompyuterda ham 5 daqiqadan ko‘p vaqt olmasligi kerak.

 ![install-done](images/install-done.webp)

Endi siz Omarchy’ga tayyorsiz!

### Simli yoki 2.4ghz klaviaturadan foydalaning!

To‘liq disk shifrlashi ishga tushishda Bluetooth klaviaturadan parolni kiritishingizga yo‘l qo‘ymaydi. Xuddi PC’da BIOS’ga kirish uchun Bluetooth klaviaturadan foydalana olmaganingizdek. Sizga 2.4ghz dongle yoki kabeldan foydalanadigan klaviatura kerak bo‘ladi (kabel kechikish jihatidan ham ancha yoqimli!). Men shaxsan [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard) ni juda yaxshi ko‘raman!

### Boshqa egasi uchun o‘rnatish

Agar siz mashinani boshqa birov — oila a’zosi, yangi xodim, xaridor — uchun sozlayotgan bo‘lsangiz, shaxsiy savollarga ular nomidan javob bermasligingiz kerak. O‘rnatuvchining eng birinchi ekranida (klaviatura tanlash) `Ctrl + C` ni bosing, shunda Omarchy uning o‘rniga mashinani boshqa egasi uchun tayyorlashni taklif qiladi. Tizim darhol o‘rnatiladi, lekin barcha shaxsiy sozlamalar — klaviatura tartibi, foydalanuvchi nomi, parol — mashina birinchi marta yuklangunicha qoldiriladi. Disk baribir sukut bo‘yicha shifrlanadi va yangi egasi o‘sha birinchi yuklanishda tanlagan parol shifrlash paroliga ham aylanadi. (Siz allaqachon foydalanib kelgan mashinani ham qayta o‘rnatmasdan topshirish mumkin — qarang: [kompyuterni tiklash](48-security.md).)

### Nazoratsiz o‘rnatishlar

ISO ikkinchi diskda unga konfiguratsiyasi berilsa, hammasini butunlay o‘zi o‘rnatishi ham mumkin — na klaviatura, na usta kerak. Omarchy’ni VM’lar va mashinalar parki uchun asosiy obraz sifatida ishlatish usuli shudir. Qarang: [nazoratsiz o‘rnatishlar](51-unattended-installs.md).

### Shifrlashsiz o‘rnatishlar

Omarchy sukut bo‘yicha shifrlash bilan o‘rnatiladi. Bu yo‘qolishi yoki o‘g‘irlanishi mumkin bo‘lgan har qanday kompyuter uchun xavfsiz, mas’uliyatli tanlovdir. Qurilmangizga kira oladigan kimdir ma’lumotlaringizni qo‘lga kiritishini xohlamaysiz-ku!

Lekin alohida holatlarda, masalan, himoyalangan kompyuterlarga Omarchy’ni masofadan o‘rnatishda yoki maxfiy ma’lumotlarsiz bir martalik o‘rnatishlarda, shifrlashsiz o‘rnatishni xohlashingiz mumkin. Shifrlashsiz o‘rnatishga o‘tish uchun diskni formatlashni tasdiqlashda `Ctrl + C` ni bosishingiz mumkin.

### Til

Omarchy 50 tilda gapiradi — omarchy.org’dagi xuddi shu to‘plam — va ingliz tili sukut bo‘yicha tanlangan. Almashtirish uchun Omarchy menyusini oching va _Setup > Region > Language_ ga o‘ting yoki terminalda `omarchy language <code>` ni ishga tushiring (`omarchy language list` kodlarni ko‘rsatadi). Menyu, ish stoli va Omarchy’ning o‘z bildirishnomalari tilini darhol o‘zgartiradi va undan keyin ochadigan har bir ilovangiz ham shunga ergashadi. Allaqachon ochiq bo‘lgan ilovalar ularni qayta ishga tushirganingizda almashadi.

Tilni saqlab qolish, lekin sanalar, vaqtlar, raqamlar, pullar, birliklar va qog‘oz o‘lchamlarini boshqa mintaqa uslubida yozish uchun (masalan, ingliz tili, lekin Yevropa sanalari va 24 soatlik soat bilan), _Setup > Region > Formats_ ostida mintaqani tanlang, bu yerda har bir tanlov namuna ko‘rsatadi, yoki `omarchy region formats <code>` ni ishga tushiring (`omarchy region formats list` kodlarni ko‘rsatadi). _Same as language_ tilning o‘z formatlariga qaytaradi. Tilni almashtirish kabi, bu ham undan keyin ochadigan ilovalaringizga yetib boradi.

### Tiqilib qolsangiz yordam

Agar tiqilib qolsangiz, odatda [hamjamiyat Discord](https://omarchy.org/discord) dagi _#omarchy-help_ kanalida yordam berishga tayyor kimnidir topishingiz mumkin.
