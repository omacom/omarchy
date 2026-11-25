# Xavfsizlik

Omarchy xavfsizlikka nihoyatda jiddiy yondashadi. Bu _Haqiqiy ish_ni _Haqiqiy dunyo_da bajarish uchun ishlatishingiz mumkin bo'lgan operatsion tizim bo'lishi mo'ljallangan. Noutbukni yo'qotish xavfsizlik bo'yicha favqulodda holatga aylanib qolmasligi kerak bo'lgan dunyo. Mana biz nima qilamiz:

1. *To'liq disk shifrlash sukut bo'yicha yoqilgan*: Bu ma'lumotlaringizning jismoniy himoyasini ta'minlashdagi eng muhim qadam. Agar kompyuteringiz yo'qolsa yoki o'g'irlansa, ma'lumotlar standart LUKS (Linux Unified Key Setup) yordamida to'liq shifrlangan bo'ladi. O'rnatuvchi bir martalik mashinalar uchun bundan voz kechishga imkon beradi (qarang: [Ishni boshlash](02-getting-started.md)); shifrlashsiz o'rnatishda bunday himoya umuman bo'lmaydi va disk kimning qo'lida bo'lsa, o'sha uni o'qiy oladi.
2. *Firewall sukut bo'yicha yoqilgan*: Barcha kiruvchi trafik sukut bo'yicha bloklanadi, bir nechta istisnolar bilan: [LocalSend](https://localsend.org/) uchun 53317-port; kompyuterning o'z resolveriga Docker bridge manzili (172.17.0.1) orqali yuboriladigan DNS so'rovlari, Docker o'z konteynerlariga beradigan xususiy manzil diapazonlaridan qabul qilinadi; va multicast DNS (5353-port), bu tarmog'ingizdagi printerlar va boshqa qurilmalarga bir-birini topish imkonini beradi va u yerda kompyuteringiz nomini ham e'lon qiladi. Bulardan tashqari, firewall ping, routeringizdan manzil olish (DHCP) va UPnP discovery uchun UFW ning standart ruxsatlarini saqlab qoladi. Hatto ssh ham uni _Sozlash > Xavfsizlik > SSHD_ orqali yoqmaguningizcha o'chiq turadi, bu sizning SSH kalitingizni avtorizatsiya qiladi, parol bilan kirishni o'chiradi va shundan keyingina 22-portni ochadi (brute force hujumlaridan himoya qilish uchun tezligi cheklangan). Biz hatto konteynerlaringiz tasodifan dunyoga ochilib qolmasligi uchun [ufw-docker](https://github.com/chaifeng/ufw-docker) sozlamasidan foydalanib Docker ga kirishni ham cheklaymiz.
3. *Arch har doim eng so'nggi yangilanishlarga ega*: Arch, Omarchy qurilgan asosiy distro, rolling distribution hisoblanadi. Bu shuni anglatadiki, biron bir paketda aniqlangan va tuzatilgan har qanday xavfsizlik zaifligi `omarchy-update` yordamida o'rnatish uchun tezda mavjud bo'ladi. Shunday qilib, siz har doim hamma narsaning eng so'nggi, eng xavfsiz versiyalarini ishlatasiz.
4. *Omarchy o'z paketlari va mirrorini o'zi yuritadi*: Omarchy sukut bo'yicha faqat Arch ning o'z core/extra/multilib repositorylaridagi (ARM mashinalarida Arch Linux ARM, Apple Silicon da esa Asahi ALARM) paketlarga va o'zining Omarchy Package Repository siga tayanadi. Siz dasturiy ta'minotni to'g'ridan-to'g'ri AUR dan o'rnatishingiz mumkin, lekin bazaviy o'rnatish bunday qilmaydi — faqat uchinchi tomon brauzerlari kabi bir nechta ixtiyoriy o'rnatishlar AUR dan foydalanadi.
5. *Cloudflare bizni DDoS dan himoya qiladi*: Omarchy tarqatish infratuzilmasi — ISO lar, Omarchy paketlari, Arch mirrori — Cloudflare ning qudratli DDoS qalqoni orqasida himoyalangan va ularning CDN ida joylashtirilgan. Bu a'lo darajadagi mavjudlikni ta'minlaydi.

## Parollaringizni o'zgartirish

Shifrlangan o'rnatishda sizda ikkita parol bo'ladi: biri yuklashda diskni ochadigan parol, ikkinchisi esa tizimga kirish va `sudo` uchun ishlatadigan parolingiz. Dastlabki sozlash ularni bir xil qiladi. Omarchy menyusidagi _Yangilash > Parol_ ikkalasini birdaniga o'zgartiradi, shuning uchun ular bir xil bo'lib qoladi: u joriy disk parolini, keyin yangi parolni so'raydi, disk parolini o'zgartiradi va keyin kirish parolingizni ham shunga moslab qo'yadi. Disk shifrlashsiz u faqat kirish parolingizni o'zgartiradi. Agar o'zgartirish uzilib qolsa, _Yangilash > Parol_ ni yana ishga tushiring: u hozir diskni ochadigan parolni so'raydi, o'zgartirishni yakunlaydi va kirish parolingizni ham shunga o'rnatadi. Boshqa shifrlangan diskning parolini o'zgartirish uchun terminalda `omarchy-drive-password` ni ishga tushiring.

## Ishlatgan mashinangizni boshqaga topshirish

Agar mashinangizni boshqa birovga topshirayotgan bo'lsangiz, uni qayta o'rnatishingiz shart emas. Omarchy menyusida _Olib tashlash > Zavod sozlamalarini tiklash_ ni ishga tushiring, tasdiqlash uchun `reset` deb yozing, so'ralsa disk shifrlash parolingizni kiriting va qayta yuklang. Bu har bir foydalanuvchi hisobini va `/home` dagi hamma narsani o'chirib tashlaydi, o'rnatishdan beri o'rnatgan barcha paketlaringiz va qilgan tizim o'zgarishlaringizni tashlab yuboradi hamda mashinaning identifikatorini — tarmoq ulanishlari, host kalitlari va hammasini tozalaydi. Qayta ishga tushganda birinchi yuklashdagi sozlash ustasi chiqadi, yangi egasi o'z ismini, parolini va shifrlash parolini kiritishga tayyor bo'ladi.

Bu o'rnatuvchi olgan bazaviy snapshot ni tiklash orqali ishlaydi, shuning uchun u faqat Omarchy ISO sidan o'rnatilgan mashinalarda mavjud. Shifrlashsiz diskda esa qayta tiklash xavfsiz o'chirish emas, shunchaki o'chirish bo'ladi, shuning uchun ma'lumotlar nozik bo'lgan bo'lsa, buning o'rniga yangidan o'rnating.

## Parolsiz sudo

Ba'zan `sudo` so'rashdan to'xtashini xohlaysiz, ko'pincha AI agent siz uchun uzoq vaqt davomida tizim ishlarini bajarayotganda. _Sozlash > Xavfsizlik > Parolsiz Sudo_ qancha vaqtga ruxsat berishni so'raydi: **15 daqiqa**, **1 soat**, **1 kun** yoki **Doimiy**. Ruxsat faol bo'lganida menyu panelining boshqa ko'rsatkichlari yonida qizil ogohlantirish belgisi paydo bo'ladi. Ruxsatni o'chirish uchun uni bosing yoki buyruqni yana ishga tushiring. Shuningdek, `omarchy-sudo-passwordless 30` bilan o'zingizning daqiqalar soningizni (1 dan 1440 gacha) berishingiz yoki `omarchy-sudo-passwordless permanent` dan foydalanishingiz mumkin.

Vaqtli ruxsat avtomatik tugaydi, muddat tugash vaqtini kesib o'tgan suspend dan qaytgandan keyin darhol ham. Kompyuterni qayta yuklash uni erta tugatadi. Doimiy ruxsat qayta yuklashlardan keyin ham saqlanib qoladi va siz uni o'chirmaguningizcha yoqilgan bo'lib qoladi.

Omarchy sozlamalar paketini yangilash yoki olib tashlash, muddati tugashini qo'llab-quvvatlash tartibi o'zgarishidan oldin har qanday vaqtinchalik ruxsatni tugatadi. Agar buyruq avtorizatsiya yoki tozalash xatosi haqida xabar bersa, boshqa ruxsatni yoqishga urinishdan oldin uni hal qiling; xato parolsiz kirish faol emasligini anglatmaydi.

Bunga ochiq ko'z bilan qarang: u yoqilgan paytda, sizning foydalanuvchingiz sifatida ishlaydigan har qanday narsa so'ralmasdan root sifatida har qanday ishni qila oladi. Maqsad ham aynan shu, xavf ham aynan shu.

## Imzo kalitlari

Barcha ISO imzolari va Omarchy repo paketi uchun ommaviy kalit `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([openpgp.org da tekshiring](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). `omarchy/omarchy-keyring` paketi ham buni o'z ichiga oladi va har qanday ehtimoliy yangilanishlarni muammosiz tarqatish uchun ishlatiladi.

Har qanday ISO relizining imzosini uning URL iga `.sig` qo'shish orqali topishingiz mumkin, masalan, `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
