# Xavfsizlik

Omarchy xavfsizlikka nihoyatda jiddiy yondashadi. Bu _Haqiqiy dunyoda_ _Haqiqiy ish_ qilish uchun ishlatishingiz mumkin bo'lgan operatsion tizim bo'lishi mo'ljallangan. Bunda noutbukni yo'qotish xavfsizlik favqulodda holatiga olib kelmasligi kerak. Shunday qilib, biz quyidagilarni qilamiz:

1. *To'liq disk shifrlash sukut bo'yicha yoqilgan*: Bu ma'lumotlaringizning jismoniy himoyasini ta'minlashdagi eng muhim qadamdir. Agar kompyuteringiz yo'qolsa yoki o'g'irlansa, ma'lumotlar standart LUKS (Linux Unified Key Setup) yordamida to'liq shifrlangan bo'ladi. O'rnatuvchi bir martalik mashinalar uchun bundan voz kechishga imkon beradi (qarang: [Ishni boshlash](02-getting-started.md)); shifrlashsiz o'rnatishda bu himoyaning hech biri bo'lmaydi va disk qo'lida bo'lgan har kim uni o'qiy oladi.
2. *Firewall sukut bo'yicha yoqilgan*: Barcha kiruvchi trafik sukut bo'yicha bloklanadi, bir nechta istisnolardan tashqari: [LocalSend](https://localsend.org/) uchun 53317-port; Docker ko'prigi manzilidagi (172.17.0.1) kompyuterning o'z resolveriga DNS so'rovlari, Docker o'z konteynerlariga beradigan xususiy manzil diapazonlaridan qabul qilinadi; va multicast DNS (5353-port), bu tarmog'ingizdagi printerlar va boshqa qurilmalarga bir-birini topishga imkon beradi va u yerda kompyuteringiz nomini ham e'lon qiladi. Bularga qo'shimcha ravishda, firewall ping, routeringizdan manzil olish (DHCP) va UPnP aniqlash uchun UFW ning standart ruxsatlarini saqlab qoladi. Hatto ssh ham _Sozlash > Xavfsizlik > SSHD_ orqali yoqmaguningizcha o'chiq bo'ladi, bu sozlashning bir qismi sifatida 22-portni ochadi (qo'pol kuch hujumiga qarshi tezlik cheklangan). Biz hatto konteynerlaringiz tasodifan dunyoga ochilib qolmasligi uchun [ufw-docker](https://github.com/chaifeng/ufw-docker) sozlamasidan foydalanib Docker kirishini ham cheklaymiz.
3. *Arch da doim eng so'nggi yangilanishlar bor*: Omarchy qurilgan asosiy distributiv bo'lgan Arch uzluksiz yangilanib boruvchi distributiv hisoblanadi. Bu shuni anglatadiki, istalgan paketda xavfsizlik zaifligi aniqlanib tuzatilsa, u `omarchy-update` yordamida o'rnatish uchun tezda mavjud bo'ladi. Shu tariqa siz doim hamma narsaning eng so'nggi, eng xavfsiz versiyalarini ishlatasiz.
4. *Omarchy o'z paketlari va mirrorini yuritadi*: Omarchy sukut bo'yicha faqat Arch ning o'z core/extra/multilib repozitoriylaridagi va o'zining Omarchy Package Repository sidagi paketlarga tayanadi. Siz dasturlarni to'g'ridan-to'g'ri AUR dan o'rnatishingiz mumkin, lekin asosiy o'rnatish bunday qilmaydi — faqat uchinchi tomon brauzerlari kabi bir nechta ixtiyoriy o'rnatishlar AUR dan oladi.
5. *Cloudflare bizni DDoS dan himoya qiladi*: Omarchy tarqatish infratuzilmasi — ISO lar, Omarchy paketlari, Arch mirrori — Cloudflare ning qudratli DDoS qalqoni ortida himoyalangan va ularning CDN ida joylashtirilgan. Bu ajoyib mavjudlikni ta'minlaydi.

## Parollaringizni o'zgartirish

Shifrlangan o'rnatishda sizda ikkita parol bor: biri yuklanishda diskni ochadi, ikkinchisi bilan tizimga kirasiz va `sudo` dan foydalanasiz. Sozlash ularni bir xil qiladi. Ikkalasini ham Omarchy menyusidagi _Yangilash > Parol_ ostida o'zgartirish mumkin — birinchisi uchun _Disk shifrlash_, ikkinchisi uchun _Foydalanuvchi_. Disk parolini o'zgartirish avval joriy parolni so'raydi, shuning uchun uni tayyor tuting. Agar o'zgartirish uzilib qolsa, _Disk shifrlash_ ni yana ishga tushiring: u hozir diskni ochadigan parolni so'raydi va o'zgartirishni yakunlaydi.

## Ishlatib bo'lingan kompyuterni birovga berish

Agar kompyuteringizni boshqa birovga topshirayotgan bo'lsangiz, uni qayta o'rnatishingiz shart emas. Omarchy menyusida _Sozlash > Kompyuterni tiklash_ ni ishga tushiring, tasdiqlash uchun `reset` deb yozing va qayta yuklang. Bu har bir foydalanuvchi akkauntini va `/home` dagi hamma narsani o'chiradi, o'rnatishdan beri qilgan barcha paketlaringiz va tizim o'zgarishlaringizni tashlab yuboradi hamda kompyuterning identifikatorini tozalaydi — tarmoq ulanishlari, host kalitlari va hammasini. Qayta yuklanganda birinchi yuklashdagi sozlash ustasi chiqadi, yangi egasi o'z ismi, paroli va shifrlash parolini kiritishga tayyor bo'ladi.

Bu o'rnatuvchi olgan bazaviy snapshot ni tiklash orqali ishlaydi, shuning uchun u faqat Omarchy ISO sidan o'rnatilgan kompyuterlarda mavjud. Shifrlash bo'lmagan diskda esa tiklash xavfsiz o'chirish emas, balki oddiy o'chirishdir, shuning uchun ma'lumotlar maxfiy bo'lgan bo'lsa, o'rniga toza o'rnatish qiling.

## Parolsiz sudo

Ba'zida `sudo` so'rashni to'xtatishini xohlaysiz, ko'pincha AI agent siz uchun uzoq davom etadigan tizim ishlarini bajarayotganda. _Sozlash > Xavfsizlik > Parolsiz Sudo_ kirishga qancha vaqt ruxsat berishni so'raydi: **15 daqiqa**, **1 soat**, **1 kun** yoki **Doimiy**. Kirish faol bo'lganda boshqa menyu paneli indikatorlari yonida qizil ogohlantirish belgisi paydo bo'ladi. Kirishni o'chirish uchun uni bosing yoki buyruqni yana ishga tushiring. Shuningdek, `omarchy-sudo-passwordless 30` bilan o'zingizning daqiqalar sonini (1 dan 1440 gacha) berishingiz yoki `omarchy-sudo-passwordless permanent` dan foydalanishingiz mumkin.

Vaqtli kirish avtomatik ravishda tugaydi, jumladan muddat o'tib ketgan uyqu holatidan uyg'ongandan so'ng darhol. Kompyuterni qayta ishga tushirish uni erta tugatadi. Doimiy kirish qayta yuklashlardan keyin ham saqlanadi va siz o'chirmaguningizcha yoqilgan holatda qoladi.

Omarchy ning sozlamalar paketini yangilash yoki olib tashlash har qanday vaqtinchalik ruxsatni uning amal qilish muddati qo'llab-quvvatlashi o'zgarishidan oldin tugatadi. Agar buyruq avtorizatsiya yoki tozalash xatosi haqida xabar bersa, boshqa ruxsatni yoqishga urinishdan oldin uni hal qiling; xato parolsiz kirish faol emasligini anglatmaydi.

Bu masalaga hushyor bo'ling: u yoqilgan paytda, foydalanuvchingiz sifatida ishlayotgan har qanday narsa so'ralmasdan root sifatida har qanday ishni qila oladi. Aynan maqsad ham shu, xavf ham aynan shu.

## Imzo kalitlari

Barcha ISO imzolari va Omarchy repo paketi uchun ochiq kalit `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([openpgp.org da tekshiring](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). `omarchy/omarchy-keyring` paketi ham buni o'z ichiga oladi va har qanday bo'lajak yangilanishlarni muammosiz tarqatish uchun ishlatiladi.

Har qanday ISO relizining imzosini uning URL manziliga `.sig` qo'shish orqali topishingiz mumkin, masalan, `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
