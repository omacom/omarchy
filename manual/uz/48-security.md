# Xavfsizlik

Omarchy xavfsizlikka nihoyatda jiddiy yondashadi. Bu _Haqiqiy Dunyoda_ _Haqiqiy Ish_ qilish uchun ishlata oladigan operatsion tizim bo‘lishi uchun mo‘ljallangan. Noutbukni yo‘qotib qo‘yish xavfsizlik favqulodda holatiga olib kelmaydigan tizim. Shuning uchun biz quyidagilarni qilamiz:

1. *To‘liq diskni shifrlash majburiy*: Bu ma’lumotlaringizni jismoniy himoya qilishdagi eng muhim qadamdir. Agar kompyuteringiz yo‘qolsa yoki o‘g‘irlansa, ma’lumotlar standart LUKS (Linux Unified Key Setup) yordamida to‘liq shifrlangan bo‘ladi.
2. *Firewall sukut bo‘yicha yoqilgan*: Kiruvchi barcha trafik sukut bo‘yicha bloklanadi, [LocalSend](https://localsend.org/) uchun 53317-port bundan mustasno. Hatto ssh ham uni _Setup > Security > SSHD_ orqali yoqmaguningizcha o‘chiq bo‘ladi, bu esa sozlashning bir qismi sifatida 22-portni ochadi (brute force hujumlariga qarshi tezlik cheklangan). Biz hatto konteynerlaringiz tasodifan dunyoga ochilib qolmasligi uchun [ufw-docker](https://github.com/chaifeng/ufw-docker) sozlamasidan foydalanib Docker kirishini ham cheklaymiz.
3. *Arch doimo eng so‘nggi yangilanishlarga ega*: Arch, Omarchy asosiga qurilgan distributiv, uzluksiz yangilanadigan distributivdir. Bu shuni anglatadiki, biror paketda aniqlangan va tuzatilgan har qanday xavfsizlik zaifligi `omarchy-update` yordamida o‘rnatish uchun tezda mavjud bo‘ladi. Shu yo‘l bilan siz doimo hamma narsaning eng so‘nggi, eng xavfsiz versiyalarini ishlatasiz.
4. *Omarchy o‘z paketlari va mirror’ini yurituvchi*: Omarchy sukut bo‘yicha faqat Arch’ning o‘z core/extra/multilib repozitoriylaridagi paketlarga va o‘zining Omarchy Package Repository’siga tayanadi. Dasturiy ta’minotni to‘g‘ridan to‘g‘ri AUR’dan o‘rnatishingiz mumkin, lekin tayanch o‘rnatish bunday qilmaydi — faqat bir nechta ixtiyoriy o‘rnatishlar, masalan, uchinchi tomon brauzerlari, AUR’dan oladi.
5. *Cloudflare bizni DDoS’dan himoya qiladi*: Omarchy tarqatish infratuzilmasi — ISO’lar, Omarchy paketlari, Arch mirror’i — Cloudflare’ning qudratli DDoS qalqoni ortida himoyalangan va ularning CDN’ida joylashtirilgan. Bu a’lo darajadagi foydalanish imkoniyatini ta’minlaydi.

## Parollaringizni o‘zgartirish

Shifrlangan o‘rnatishda sizda ikkita parol bo‘ladi: biri yuklanishda disk qulfini ochadigan, ikkinchisi tizimga kirish va `sudo` uchun ishlatiladigan parol. Sozlash ularni bir xil qiladi. Ikkalasini ham Omarchy menyusida _Update > Password_ ostida o‘zgartirish mumkin — birinchisi uchun _Drive Encryption_, ikkinchisi uchun _User_. Disk parolini o‘zgartirish avval joriy parolni so‘raydi, shuning uchun uni tayyor tuting. Agar o‘zgartirish uzilib qolsa, _Drive Encryption_’ni yana ishga tushiring: u hozir disk qulfini ochadigan parolni so‘raydi va o‘zgartirishni yakunlaydi.

## Ishlatib bo‘lgan mashinangizni boshqaga topshirish

Agar mashinangizni boshqa birovga topshirayotgan bo‘lsangiz, uni qayta o‘rnatishingiz shart emas. Omarchy menyusida _Setup > Reset Computer_’ni ishga tushiring, tasdiqlash uchun `reset` deb yozing va qayta yuklang. Bu har bir foydalanuvchi akkauntini va `/home` ichidagi hamma narsani o‘chiradi, o‘rnatishdan beri kiritgan barcha paketlaringiz va tizim o‘zgarishlaringizni tashlab yuboradi hamda mashinaning identifikatorini — tarmoq ulanishlari, host kalitlari va hammasini tozalaydi. Qayta yuklanganda birinchi yuklashdagi sozlash ustasi chiqadi, yangi egasi o‘z ismini, parolini va shifrlash parolini kiritishga tayyor holda.

U o‘rnatuvchi olgan tayanch snapshot’ni tiklash orqali ishlaydi, shuning uchun u faqat Omarchy ISO’sidan o‘rnatilgan mashinalarda mavjud. Shifrlashsiz diskda esa qayta tiklash xavfsiz o‘chirish emas, shunchaki o‘chirishdir, shuning uchun ma’lumotlar nozik bo‘lgan bo‘lsa, buning o‘rniga toza o‘rnatish qiling.

## Parolsiz sudo

Ba’zida siz `sudo` so‘rashdan to‘xtashini xohlaysiz, ko‘pincha AI agent siz uchun uzoq davom etadigan tizim ishlarini bajarayotganda. _Setup > Security > Passwordless Sudo_ kirishga qancha vaqt ruxsat berishni so‘raydi: **15 daqiqa**, **1 Soat**, **1 Kun** yoki **Doimiy**. Kirish faol bo‘lgan vaqtda boshqa menyu paneli ko‘rsatkichlari yonida qizil ogohlantirish belgisi paydo bo‘ladi. Kirishni o‘chirish uchun uni bosing yoki buyruqni yana ishga tushiring. Shuningdek, `omarchy-sudo-passwordless 30` bilan o‘zingizning daqiqalar soningizni (1 dan 1440 gacha) berishingiz yoki `omarchy-sudo-passwordless permanent`’dan foydalanishingiz mumkin.

Vaqti cheklangan kirish avtomatik ravishda tugaydi, shu jumladan muddat o‘tib ketgan uyqu holatidan uyg‘ongandan keyin darhol. Kompyuterni qayta yuklash uni erta tugatadi. Doimiy kirish qayta yuklashlardan keyin ham saqlanib qoladi va siz o‘chirmaguningizcha yoqilgan holda qoladi.

Omarchy’ning settings paketini yangilash yoki olib tashlash uning amal qilish muddatini qo‘llab-quvvatlashi o‘zgarishidan oldin har qanday vaqtinchalik ruxsatni tugatadi. Agar buyruq avtorizatsiya yoki tozalash xatosi haqida xabar bersa, boshqa ruxsatni yoqishga urinishdan oldin uni hal qiling; xato parolsiz kirish faol emas degani emas.

Bu borada ko‘zingiz ochiq bo‘lsin: u yoqiq ekan, foydalanuvchingiz sifatida ishlayotgan har qanday narsa so‘ralmasdan root sifatida har qanday ishni qila oladi. Maqsad ham aynan shu, xavf ham aynan shu.

## Imzolash kalitlari

Barcha ISO imzolari va Omarchy repo paketlari uchun ochiq kalit `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([openpgp.org’da tekshiring](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). `omarchy/omarchy-keyring` paketi ham buni o‘z ichiga oladi va har qanday ehtimoliy yangilanishlarni muammosiz tarqatish uchun ishlatiladi.

Har qanday ISO relizining imzosini URL’ga .sig qo‘shish orqali topishingiz mumkin. Masalan https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
