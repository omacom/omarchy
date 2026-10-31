# Xavfsizlik

Omarchy xavfsizlikka nihoyatda jiddiy yondashadi. Bu _Haqiqiy Dunyo_da _Haqiqiy Ish_ qilish uchun ishlata oladigan operatsion tizim bo'lishi kerak. Noutbukni yo'qotib qo'yish xavfsizlik bo'yicha favqulodda holatga aylanib ketmasligi kerak. Mana, biz nima qilamiz:

1. *To'liq disk shifrlashi majburiy*: Bu ma'lumotlaringizning jismoniy himoyasini ta'minlashdagi eng muhim qadamdir. Agar kompyuteringiz yo'qolsa yoki o'g'irlansa, ma'lumotlar standart LUKS (Linux Unified Key Setup) yordamida to'liq shifrlangan bo'ladi.
2. *Firewall sukut bo'yicha yoqilgan*: Kiruvchi barcha trafik sukut bo'yicha bloklanadi, [LocalSend](https://localsend.org/) uchun 53317-port bundan mustasno. Hatto ssh ham uni _Sozlash > Xavfsizlik > SSHD_ orqali yoqmaguningizcha o'chiq bo'ladi, bu esa sozlashning bir qismi sifatida 22-portni ochadi (brute force hujumlariga qarshi tezligi cheklangan). Konteynerlaringiz tasodifan butun dunyoga ochilib qolmasligi uchun [ufw-docker](https://github.com/chaifeng/ufw-docker) sozlamasidan foydalanib, Docker kirishini ham qattiq cheklab qo'yamiz.
3. *Arch doim eng so'nggi yangilanishlarga ega*: Omarchy asos qilib olingan asosiy distributiv Arch — uzluksiz yangilanib boradigan distributivdir. Bu shuni anglatadiki, biron-bir paketda xavfsizlik zaifligi aniqlanib, tuzatilsa, uni `omarchy-update` yordamida tezda o'rnatish mumkin bo'ladi. Shu tariqa siz doim hamma narsaning eng so'nggi, eng xavfsiz versiyalarini ishlatib yurasiz.
4. *Omarchy o'z paketlari va mirrorini o'zi yuritadi*: Omarchy sukut bo'yicha faqat Arch'ning o'z core/extra/multilib repozitoriylaridagi paketlarga va o'zining Omarchy Package Repository'ga tayanadi. Dasturlarni to'g'ridan-to'g'ri AUR'dan o'rnatishingiz mumkin, lekin asosiy o'rnatish unday qilmaydi — faqat uchinchi tomon brauzerlari kabi bir nechta ixtiyoriy o'rnatishlar AUR'dan olinadi.
5. *Cloudflare bizni DDoS'dan himoya qiladi*: Omarchy tarqatish infratuzilmasi — ISO'lar, Omarchy paketlari, Arch mirrori — Cloudflare'ning mahobatli DDoS qalqoni ortida himoyalangan va ularning CDN'ida joylashtirilgan. Bu ajoyib darajada yuqori mavjudlikni ta'minlaydi.

## Parollaringizni o'zgartirish

Shifrlangan o'rnatishda sizda ikkita parol bo'ladi: biri yuklanish paytida disk qulfini ochadi, ikkinchisi bilan tizimga kirasiz va `sudo` ishlatasiz. Sozlash ularni bir xil qilib qo'yadi. Ikkalasini ham Omarchy menyusidagi _Yangilash > Parol_ bo'limida o'zgartirish mumkin — birinchisi uchun _Disk shifrlashi_, ikkinchisi uchun _Foydalanuvchi_. Disk parolini o'zgartirish avval joriy parolni so'raydi, shuning uchun uni yodingizda tayyor tuting. Agar o'zgartirish uzilib qolsa, _Disk shifrlashi_ ni yana ishga tushiring: u hozir disk qulfini ochadigan parolni so'raydi va o'zgartirishni yakunlaydi.

## Allaqachon ishlatgan mashinangizni birovga topshirish

Agar mashinangizni boshqa birovga topshirayotgan bo'lsangiz, uni qayta o'rnatishingiz shart emas. Omarchy menyusida _Sozlash > Kompyuterni tiklash_ ni ishga tushiring, tasdiqlash uchun `reset` deb yozing va qayta yuklang. Bu barcha foydalanuvchi hisoblarini va `/home` dagi hamma narsani o'chirib tashlaydi, o'rnatishdan beri qo'shgan barcha paketlaringiz va tizim o'zgarishlaringizni tashlab yuboradi hamda mashinaning identifikatorini tozalaydi — tarmoq ulanishlari, host kalitlari va hammasini. Qayta yuklanganda birinchi yuklanishdagi sozlash ustasi chiqadi, yangi egasi o'z ismi, paroli va shifrlash parolini kiritishga tayyor holda.

Bu o'rnatuvchi olgan bazaviy snapshot'ni tiklash orqali ishlaydi, shuning uchun u faqat Omarchy ISO'dan o'rnatilgan mashinalarda mavjud. Shifrlashsiz diskda esa tiklash xavfsiz o'chirish emas, shunchaki o'chirish bo'ladi, shuning uchun ma'lumotlar maxfiy bo'lgan bo'lsa, buning o'rniga yangidan toza o'rnatish qiling.

## Parolsiz sudo

Ba'zan `sudo` ning so'rayverishini to'xtatgingiz keladi, ko'pincha AI agent siz uchun uzoq cho'zilgan tizim ishini bajarayotganda. _Sozlash > Xavfsizlik > Parolsiz Sudo_ kirishga qancha vaqt ruxsat berishni so'raydi: **15 daqiqa**, **1 Soat**, **1 Kun** yoki **Doimiy**. Kirish faol bo'lganda boshqa menyu paneli ko'rsatkichlari yonida qizil ogohlantirish belgisi paydo bo'ladi. Kirishni o'chirish uchun uni bosing yoki buyruqni yana ishga tushiring. Shuningdek, `omarchy-sudo-passwordless 30` yordamida o'zingizning daqiqalar soningizni (1 dan 1440 gacha) berishingiz yoki `omarchy-sudo-passwordless permanent` dan foydalanishingiz mumkin.

Muddatli kirish avtomatik tugaydi, jumladan muddat chegarasidan o'tib ketgan uyqudan uyg'ongandan keyin darhol. Kompyuterni qayta yuklash uni ertaroq tugatadi. Doimiy kirish qayta yuklashlardan keyin ham saqlanib qoladi va uni o'chirmaguningizcha yoqilgan holda qoladi.

Omarchy'ning settings paketini yangilash yoki olib tashlash har qanday vaqtinchalik ruxsatni, uning amal qilish muddatini qo'llab-quvvatlash o'zgarishidan oldin tugatadi. Agar buyruq avtorizatsiya yoki tozalash xatosi haqida xabar bersa, boshqa ruxsatni yoqishga urinishdan oldin uni hal qiling; xato parolsiz kirish faol emas degani emas.

Bunga ochiq ko'z bilan qarang: u yoqilgan paytda, foydalanuvchingiz sifatida ishlayotgan har qanday narsa so'ralmasdan root sifatida xohlagan ishini qila oladi. Maqsad ham aynan shu, xavf ham aynan shu.

## Imzolash kalitlari

Barcha ISO imzolari va Omarchy repo paketlari uchun ochiq kalit — `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([openpgp.org'da tekshirish](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). `omarchy/omarchy-keyring` paketi ham shuni o'z ichiga oladi va har qanday ehtimoliy yangilanishlarni muammosiz tarqatishda ishlatiladi.

Har qanday ISO relizining imzosini uning URL manziliga `.sig` qo'shish orqali topishingiz mumkin, masalan `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
