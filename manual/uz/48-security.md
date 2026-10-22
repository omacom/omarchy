# Xavfsizlik

Omarchy xavfsizlikka juda jiddiy yondashadi. Bu _Haqiqiy Dunyoda_ _Haqiqiy Ish_ qilish uchun ishlatishingiz mumkin boʻlgan operatsion tizim boʻlishi moʻljallangan. Noutbukni yoʻqotish xavfsizlik favquloddaga olib kela olmaydi. Shunday qilib biz nima qilamiz:

1. *Toʻliq disk shifrlash majburiy*: Bu maʼlumotlaringiz fizik himoyasini taʼminlashdagi eng muhim qadam. Agar kompyuteringiz yoʻqotsa yoki oʻgʻirlansa, maʼlumotlar standart LUKS (Linux Unified Key Setup) yordamida toʻliq shifrlangan.
2. *Firewall standart holatda yoqilgan*: Barcha kiruvchi trafik [LocalSend](https://localsend.org/) uchun 53317 portidan tashqari standart holatda bloklangan. Hatto ssh siz uni _Sozlash > Xavfsizlik > SSHD_ orqali yoqquningizga qadar oʻchirilgan, bu sozlash qismi sifatida 22 portini ochadi (brute force ga qarshi tezlik cheklanadi). Biz hatto konteynerlaringiz tasodifan dunyoga ochilmasligi oldini olish uchun [ufw-docker](https://github.com/chaifeng/ufw-docker) sozlashidan foydalanib Docker kirishini yopamiz.
3. *Arch har doim eng soʻnggi yangilanishlarga ega*: Omarchy qurilgan asosiy distro boʻlgan Arch rolling distributsiya. Bu har qanday paketda topilgan va yamoqlangan har qanday xavfsizlik zaifligi `omarchy-update` yordamida oʻrnatish uchun tezda tayyor ekanidi bildiradi. Siz shunday qilib har doim hammaning eng soʻnggi, eng xavfsiz versiyalarini ishlatasiz.
4. *Omarchy oʻz paketlari va mirrorini saqlaydi*: Omarchy standart holatda faqat Archning oʻz core/extra/multilib omborlaridan va oʻzning Omarchy Package Repositorydan paketlarga tayanadi. Dasturiy taʼminotni AUR dan toʻgʻridan-toʻgʻri oʻrnatishingiz mumkin, lekin bazaviy oʻrnatish buni qilmaydi — faqat bir nechta ixtiyoriy oʻrnatishlar, uchinchi tomon brauzerlari kabi, AUR dan tortadi.
5. *Cloudflare bizni DDoS dan himoyaydi*: Barcha Omarchy tarqatish infratuzilmasi — ISO lar, Omarchy paketlari, Arch mirrori — Cloudflare ning ulugʻvor DDoS qalqoni orqasida himoyalangan va ularning CDN ida joylashtirilgan. Bu ajoyib mavjudlikni taʼminlaydi.

## Parollaringizni oʻzgartirish

Shifrlangan oʻrnatishda sizda ikki parol mavjud: yuklashda drayvni ochadigan va kirganingizda va `sudo` bilan ishlatadigan. Sozlash ularni bir xil qiladi. Ikkalasini ham Omarchy menyusida _Yangilash > Parol_ ostida oʻzgartirishingiz mumkin — birinchisi uchun _Drive Encryption_, ikkinchisi uchun _User_. Drayv parolini oʻzgartirish avval joriysini soʻraydi, shuning uchun uni tayyor tur ing. Agar oʻzgarish uzilsa, _Drive Encryption_ ni yana ishga tushiring: u hozir drayvni ochadigan parolni soʻraydi va oʻzgarishni tugatadi.

## Siz allaqachon ishlatgan mashinani topshirish

Agar mashinangizni boshqa birovga topshirayotgan boʻlsangiz, uni qayta oʻrnatishingiz shart emas. Omarchy menyusida _Sozlash > Kompyuterni qayta oʻrnatish_ ni ishga tushiring, tasdiqlash uchun `reset` deb yozing va qayta yuklang. Bu har bir foydalanuvchi hisobi va `/home` dagi hamma narsani tozalaydi, oʻrnatishdan beri qilgan barcha paketlar va tizim oʻzgarishlarini tashlaydi va mashina identifikatsiyasini tozalaydi — tarmoq ulanishlari, host kalitlari va barchasi. Qaytib kelgan narsa birinchi yuklashdagi sozlash ustasi boʻlib, uning yangi egasi oʻzining ismi, paroli va shifrlash parolini kiritishi uchun tayyor.

Bu oʻrnatuvchi oladigan bazaviy lavhani tiklash orqali ishlaydi, shuning uchun u faqat Omarchy ISO dan oʻrnatilgan mashinalarda mavjud. Va shifrlashsiz drayvda qayta oʻrnatish xavfsiz tozalash emas, oʻchirishdir, shuning uchun maʼlumotlar maxfiy boʻlsa, oʻrniga yangi oʻrnatish qiling.

## Parolsiz sudo

Baʼzan siz `sudo` soʻrashni toʻxtatishini istasangiz, ayniqsa AI agent siz uchun uzoq tizim ishlari qatorini bajarganda. _Sozlash > Xavfsizlik > Parolsiz Sudo_ kirishga qancha vaqt ruxsat berishni soʻraydi: **15 minutes**, **1 Hour**, **1 Day** yoki **Permanently**. Kirish faol boʻlsa, qizil ogohlantirish belgisi boshqa menyu paneli koʻrsatkichlari yonida paydo boʻladi. Kirishni oʻchirish uchun uni bosing yoki buyruqni yana ishga tushiring. `omarchy-sudo-passwordless 30` bilan oʻzingizning daqiqalar soningizni (1 dan 1440 gacha) ham berishingiz yoki `omarchy-sudo-passwordless permanent` dan foydalanishingiz mumkin.

Vaqtli kirish avtomatik tugaydi, shu jumladan muddati oʻtgan kutishdan darhol keyin uygʻongandan soʻng. Kompyuterni qayta ishga tushirish uni erta tugatadi. Doimiy kirish qayta yuklanishlardan omon qoladi va siz uni oʻchirguningizga qadar yoqilganda qoladi.

Omarchy-ning settings paketini yangilash yoki olib tashlash har qanday vaqtinchalik grantni uning tugash qoʻllab-quvvatlashi oʻzgarishidan oldin tugatadi. Agar buyruq avtorizatsiya yoki tozalash xatosini xabar qilsa, boshqa grantni yoqishga urinishdan oldin uni hal qiling; xato parolsiz kirish harakatsiz degani emas.

Bunga ochiq koʻz bilan qarang: u yoqilgan boʻlsa, sizning foydalanuvchingiz sifatida ishlaydigan har narsa soʻralmasdan root sifatida har qanday ishni qila oladi. Bu butun gap va shu ham butun xavf.

## Imzo kalitlari

Barcha ISO imzolari va Omarchy repo paketi uchun ochiq kalit `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([openpgp.org da tekshiring](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). `omarchy/omarchy-keyring` paketi buni ham oʻz ichiga oladi va har qanday mumkin boʻlgan yangilanishlarni muammosiz joriy etish uchun ishlatiladi.

Har qanday ISO versiyasi uchun imzoni URL ga .sig qoʻshish orqali topishingiz mumkin. kabi: https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
