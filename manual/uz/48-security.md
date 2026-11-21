# Xavfsizlik

Omarchy xavfsizlikka nihoyatda jiddiy yondashadi. Bu — _Haqiqiy Dunyo_da _Haqiqiy Ish_ qilish uchun foydalanishingiz mumkin bo'lgan operatsion tizim bo'lishi ko'zlangan. Bunda noutbukni yo'qotish xavfsizlik bo'yicha favqulodda holatga olib kelmasligi kerak. Shunday qilib, biz quyidagilarni qilamiz:

1. *Diskni to'liq shifrlash sukut bo'yicha yoqilgan*: Bu ma'lumotlaringizning jismoniy himoyasini ta'minlashdagi eng muhim qadamdir. Agar kompyuteringiz yo'qolsa yoki o'g'irlansa, ma'lumotlar standart LUKS (Linux Unified Key Setup) yordamida to'liq shifrlangan bo'ladi. O'rnatuvchi bir martalik mashinalar uchun bundan voz kechishga imkon beradi (qarang [Ishni boshlash](02-getting-started.md)); shifrlashsiz o'rnatishda bunday himoya bo'lmaydi va disk kimning qo'lida bo'lsa, u uni o'qiy oladi.
2. *Firewall sukut bo'yicha yoqilgan*: Kiruvchi barcha trafik sukut bo'yicha bloklanadi, bir nechta istisnolar bilan: [LocalSend](https://localsend.org/) uchun 53317-port; kompyuterning Docker bridge manzilidagi (172.17.0.1) o'z resolveriga DNS so'rovlari, Docker o'z konteynerlariga beradigan xususiy manzil diapazonlaridan qabul qilinadi; va multicast DNS (5353-port), bu printerlar va tarmog'ingizdagi boshqa qurilmalarga bir-birini topish imkonini beradi va u yerda kompyuteringiz nomini ham e'lon qiladi. Bulardan tashqari, firewall UFWning ping, routeringizdan manzil olish (DHCP) va UPnP discovery uchun standart ruxsatlarini saqlab qoladi. Hatto ssh ham _Setup > Security > SSHD_ orqali yoqmaguningizcha o'chiq bo'ladi, u sizning SSH kalitingizga ruxsat beradi, parol bilan kirishni o'chiradi va shundan keyingina 22-portni ochadi (brute forcega qarshi tezlik cheklovi bilan). Biz hatto konteynerlaringiz tasodifan dunyoga ochilib qolmasligi uchun [ufw-docker](https://github.com/chaifeng/ufw-docker) sozlamasidan foydalanib Dockerga kirishni ham cheklaymiz.
3. *Archda doim eng so'nggi yangilanishlar bo'ladi*: Arch, Omarchy qurilgan bazaviy distro, rolling distribution hisoblanadi. Bu shuni anglatadiki, biron bir paketda xavfsizlik zaifligi topilib tuzatilsa, u `omarchy-update` yordamida o'rnatish uchun tezda mavjud bo'ladi. Shu tariqa siz doim hamma narsaning eng so'nggi, eng xavfsiz versiyalarini ishlatasiz.
4. *Omarchy o'z paketlari va mirrorini yuritadi*: Omarchy sukut bo'yicha faqat Archning o'z core/extra/multilib repozitoriylaridagi (ARM mashinalarida Arch Linux ARM, Apple Silicon'da esa unga qo'shimcha Asahi ALARM) va o'zining Omarchy Package Repository'dagi paketlarga tayanadi. Dasturiy ta'minotni to'g'ridan-to'g'ri AURdan o'rnatishingiz mumkin, lekin bazaviy o'rnatish bunday qilmaydi — faqat uchinchi tomon brauzerlari kabi bir nechta ixtiyoriy o'rnatishlar AURdan oladi.
5. *Cloudflare bizni DDoSdan himoya qiladi*: Omarchy tarqatish infratuzilmasi — ISOlar, Omarchy paketlari, Arch mirrori — Cloudflare'ning qudratli DDoS qalqoni orqasida himoyalangan va ularning CDNida joylashtirilgan. Bu a'lo darajadagi mavjudlikni ta'minlaydi.

## Parollaringizni o'zgartirish

Shifrlangan o'rnatishda sizda ikkita parol bo'ladi: biri yuklanishda disk qulfini ochadigan, ikkinchisi tizimga kirish va `sudo` uchun ishlatiladigani. Setup ularni bir xil qilib o'rnatadi. Ikkalasini ham Omarchy menyusidagi _Update > Password_ orqali o'zgartirish mumkin — birinchisi uchun _Drive Encryption_, ikkinchisi uchun _User_. Disk parolini o'zgartirish avval joriy parolni so'raydi, shuning uchun uni tayyor tuting. Agar o'zgartirish uzilib qolsa, _Drive Encryption_ni yana ishga tushiring: u hozir disk qulfini ochadigan parolni so'raydi va o'zgartirishni yakunlaydi.

## O'zingiz ishlatgan mashinani boshqaga berish

Agar mashinangizni boshqa birovga berayotgan bo'lsangiz, uni qayta o'rnatishingiz shart emas. Omarchy menyusida _Remove > Factory Reset_ni ishga tushiring, tasdiqlash uchun `reset` deb yozing, so'ralsa diskni shifrlash parolingizni kiriting va qayta yuklang. Bu har bir foydalanuvchi hisobini va `/home`dagi hamma narsani o'chirib tashlaydi, o'rnatishdan beri qilgan barcha paketlaringiz va tizim o'zgarishlaringizni tashlab yuboradi, mashinaning identifikatorini — tarmoq ulanishlari, host kalitlari va hammasini tozalaydi. Qayta yuklangandan keyin birinchi yuklashdagi sozlash ustasi chiqadi, yangi egasi o'z ismini, parolini va shifrlash parolini kiritishga tayyor.

U o'rnatuvchi olgan bazaviy snapshotni tiklash orqali ishlaydi, shuning uchun faqat Omarchy ISOdan o'rnatilgan mashinalarda mavjud. Shifrlanmagan diskda esa reset xavfsiz o'chirish emas, shunchaki o'chirish bo'ladi, shuning uchun ma'lumotlar nozik bo'lgan bo'lsa, buning o'rniga toza o'rnatish qiling.

## Parolsiz sudo

Ba'zan siz `sudo` so'rashdan to'xtashini xohlaysiz, ko'pincha AI agent siz uchun uzoq tizim ishini bajarayotganda. _Setup > Security > Passwordless Sudo_ kirishga qancha vaqt ruxsat berishni so'raydi: **15 daqiqa**, **1 soat**, **1 kun** yoki **Doimiy**. Kirish faol bo'lgan vaqtda menyu panelidagi boshqa indikatorlar yonida qizil ogohlantirish belgisi paydo bo'ladi. Kirishni o'chirish uchun uni bosing yoki buyruqni yana ishga tushiring. Shuningdek, `omarchy-sudo-passwordless 30` bilan o'zingizning daqiqalar soningizni (1 dan 1440 gacha) berishingiz yoki `omarchy-sudo-passwordless permanent`dan foydalanishingiz mumkin.

Vaqtli kirish muddati avtomatik tugaydi, jumladan muddat o'tib ketgan uyqudan uyg'ongandan so'ng darhol. Kompyuterni qayta yuklash uni erta tugatadi. Doimiy kirish qayta yuklashlardan keyin ham saqlanib qoladi va siz o'chirmaguningizcha yoqilgan bo'lib qoladi.

Omarchyning settings paketini yangilash yoki olib tashlash, uning amal qilish muddatini qo'llab-quvvatlashi o'zgarishidan oldin har qanday vaqtinchalik ruxsatni tugatadi. Agar buyruq avtorizatsiya yoki tozalash xatosi haqida xabar bersa, boshqa ruxsatni yoqishga urinishdan oldin uni hal qiling; xato parolsiz kirish faol emas degani emas.

Bunga ochiq ko'z bilan qarang: u yoqilgan vaqtda, sizning foydalanuvchingiz sifatida ishlayotgan har qanday narsa so'ralmasdan root sifatida har qanday ishni qila oladi. Maqsad ham shu, xavf ham aynan shu.

## Imzo kalitlari

Barcha ISO imzolari va Omarchy repo paketi uchun ochiq kalit `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([openpgp.orgda tekshirish](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). `omarchy/omarchy-keyring` paketi ham buni o'z ichiga oladi va undan har qanday ehtimoliy yangilanishlarni uzluksiz tarqatishda foydalaniladi.

Har qanday ISO relizining imzosini uning URLiga `.sig` qo'shib topishingiz mumkin, masalan `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
