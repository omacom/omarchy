# Mac qo'llab-quvvatlovi

Omarchy'da **Intel Macs** uchun ichki qo'llab-quvvatlov mavjud. Hozircha bir nechta ma'lum cheklovlar bor, lekin ularni bilsangiz va ular sizga ma'qul bo'lsa; eski Maclaringizga Omarchy yuklab, ularga yangi hayot bag'ishlashingiz mumkin.

E'tibor bering, M-seriyali Mac'ga o'rnatish hozirda bevosita qo'llab-quvvatlanmaydi. Bu boradagi holat haqida ko'proq ma'lumotni [Discord](https://discord.gg/tXFUdasqhY) serverimizdagi #omarchy-on-other kanalida topishingiz mumkin.

Oddiy testda biz 2019-yilgi MacBook Pro'ga shunchaki Omarchy o'rnatish orqali 36% unumdorlik o'sishiga erisha oldik.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy'ni Mac'ga o'rnatish

Omarchy hozirda **yagona** o'rnatilgan OS bo'lishni qo'llab-quvvatlaydi. O'rnatish davomida disk to'liq o'chiriladi va MacOS endi yuklanmaydi.

Keyinroq xohlasangiz, uni Internet Recovery orqali tiklashingiz mumkin.

Bu qism uchun siz allaqachon [Boshlash](02-getting-started.md) bo'limini ko'rib chiqqansiz va USB diskingiz tayyor, deb hisoblaymiz. Agar unday bo'lmasa, hozir shuni qiling.

#### Secure Boot'ni o'chirish

Yuklanadigan USB'ni, shuningdek OS'ni ham yuklash uchun Apple'ning Secure Boot funksiyasini o'chirish zarur. Uni o'chirish uchun quyidagilarni bajaring:

1. Mac'ingizni o'chiring
2. Uni yoqing va yuklanish ekrani paydo bo'lguncha _darhol_ Command-R tugmasini bosib turing
3. Foydalanuvchingizni tanlang va so'ralsa, parolingizni kiriting
4. Tiklash ekraniga kirgach, menyu panelidan **Yordamchi dasturlar > Ishga tushirish xavfsizligi yordam dasturi** ni tanlang
5. Autentifikatsiya uchun so'ralganda parolingizni kiriting
6. Secure Boot parametrlaridan "Xavfsizlik yo'q" variantini tanlang
7. External Boot parametrlaridan "Tashqi yoki olinadigan mediadan yuklashga ruxsat berish" variantini tanlang

#### O'rnatishni boshlash

1. USB diskni joylashtiring
2. Mac'ingizni qayta ishga tushiring va yuklash qurilmalari ekrani paydo bo'lguncha _darhol_ Option tugmasini bosib turing
3. To'q sariq EFI Boot qurilmasini tanlang
4. [Odatdagidek o'rnatish](02-getting-started.md) bilan davom eting

O'rnatuvchi Mac uskunasini aniqlaydi va kerakli tuzatishlarni avtomatik qo'llaydi: Broadcom Wi-Fi drayverlari va mikrodasturi, unga muhtoj MacBook modellaridagi SPI klaviatura drayveri va o'sha modellar uchun NVMe uyqu rejimi tuzatishi.

### Ma'lum cheklovlar

Hamjamiyat a'zolari bu muammolarning yechimlari ustida doimiy ishlashmoqda, shuning uchun bular siz uchun muammo bo'lsa, [Discord](https://discord.gg/tXFUdasqhY) serverimizdagi #omarchy-on-other kanaliga qo'shiling va ularni hal qilishning dolzarb usullari bor-yo'qligini ko'rib chiqing.

#### T1 chipli qurilmalar

Apple T1 chipi 2016-yil oxirida taqdim etilgan va faqat Touch Bar'li birinchi avlod MacBook Pro modellarida ishlatilgan.
- MacBook Pro 13-dyuym (2016, ikkita Thunderbolt 3 porti) – Model: A1706
- MacBook Pro 13-dyuym (2016, to'rtta Thunderbolt 3 porti) – Model: A1708
- MacBook Pro 15-dyuym (2016) – Model: A1707

#### Ma'lum muammolar

- Touch Bar ishlamaydi
- Ovoz ishlamayapti

#### T2 chipli qurilmalar

Apple T2 Security Chip 2017-yilda taqdim etilgan. T2 chipi 2020-yildan boshlab Apple silicon (M-seriyali chiplar) ga o'tish bilan to'xtatilgan.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-dyuym (2018, to'rtta Thunderbolt 3 porti) – Model: A1989
- MacBook Pro 15-dyuym (2018) – Model: A1990
- MacBook Air (Retina, 13-dyuym, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-dyuym (2019, ikkita Thunderbolt 3 porti) – Model: A2159
- MacBook Pro 13-dyuym (2019, to'rtta Thunderbolt 3 porti) – Model: A2178
- MacBook Pro 15-dyuym (2019) – Model: A1990
- iMac (Retina 5K, 27-dyuym, 2020) – Model: A2115 (iMac20,1 va iMac20,2)
- MacBook Pro 13-dyuym (2020, ikkita Thunderbolt 3 porti) – Model: A2265
- MacBook Pro 15-dyuym (2020) – Model: A1990

Bu modellarda o'rnatuvchi avtomatik ravishda tuzatilgan `linux-t2` yadrosini, T2 audio konfiguratsiyasini, Apple'ning Broadcom Wi-Fi/Bluetooth mikrodasturini va `t2fanrd` orqali ventilyator boshqaruvini o'rnatadi. Touch Bar yadroning ichki Boot Camp uslubidagi qo'llab-quvvatlovi bilan ishlaydi.

#### iMac Retina 5K (2017)

2017-yilgi 27-dyuymli iMac'da T2 chipi yo'q, shuning uchun o'rnatuvchi uni boshqa Intel Maclar kabi sozlaydi.

- iMac (Retina 5K, 27-dyuym, 2017) – Model: A1419

#### Ma'lum muammolar

- Displey o'zining asli 5120×2880 o'lchamida ishlamaydi: panel ikkita plitkadan iborat, standart drayver esa faqat bittasini yoritadi
- Ovoz ishlamayapti
- Yorqinlik boshqaruvi hech qanday ta'sir ko'rsatmaydi
- Uyqu rejimi mashinani osib qo'yadi; faqat quvvatni o'chirib-yoqish uni tiklaydi

Bu model uchun hamjamiyat tuzatuvchisi displey, ovoz va yorqinlikni tuzatadi: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
