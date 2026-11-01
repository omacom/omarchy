# Mac qoʻllab-quvvatlash

Omarchy **Intel Maclar** uchun ichki qoʻllab-quvvatlashga ega. Hozirgi vaqtda maʼlum cheklovlar mavjud, ammo siz xabardor boʻlsangiz va ular bilan rozi boʻlsangiz; Omarchy ni yuklash orqali eski Mac-laringizga yangi hayot bera olasiz.

Iltimos, hozirgi vaqtda M-seriyali Macga oʻrnatish toʻgʻridan-toʻgʻri qoʻllab-quvvatlanmasligini unutmang. Buning holati haqida bizning [Discord](https://discord.gg/tXFUdasqhY) dagi #omarchy-on-other da koʻproq bilib olishingiz mumkin.

Oddiy testda biz 2019 MacBook Pro da shunchaki Omarchy ni oʻrnatish bilan 36% unumdorlikka erisha oldik.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy ni Macga oʻrnatish

Omarchy hozirda **yagona** OT oʻrnatilishini qoʻllab-quvvatlaydi. Oʻrnatish davomida drayv tozalanadi va MacOS endi yuklanmaydi.

Agar istasangiz, uni keyinchalik Internet Recovery orqali tiklashingiz mumkin.

Ushbu qism uchun biz siz allaqachon [Ishni boshlashni](02-getting-started.md) koʻrib chiqqansiz va USB drayvingiz tayor deb taxmin qilamiz. Boʻlmasa, hozir buni qiling.

#### Secure Bootni oʻchirish

Yuklanishi mumkin USB ni, shuningdek OTni yuklash uchun Apple-ning Secure Bootini oʻchirish kerak. Uni oʻchirish uchun quyidagilarni bajaring:

1. Macingizni oʻchiring
2. Uni yoqing va _darhol_ yuklash ekrani paydo boʻlguncha Command-R ni bosib ushlab turing
3. Foydalanuvchingizni tanlang va soʻralsa parolingizni kiriting
4. Qayta tiklash ekranida boʻlgach, menyu panelidan **Utilities > Startup Security Utility** ni tanlang
5. Autentifikatsiya uchun soʻralganda parolingizni kiriting
6. Secure Boot variantlaridan "No Security" ni tanlang
7. External Boot variantlaridan "Allow booting from external or removable media" ni tanlang

#### Oʻrnatishni boshlash

1. USB drayvni joylashtiring
2. Macingizni qayta ishga tushiring va _darhol_ yuklash qurilmalari ekranini koʻrguncha Option ni bosib ushlab turing
3. Toʻq sariq EFI Boot qurilmasini tanlang
4. [Odatdagidek oʻrnatish](02-getting-started.md) bilan davom eting

Oʻrnatuvchi Mac uskunani aniqlaydi va kerakli tuzatishlarni avtomatik qoʻllaydi: Broadcom Wi-Fi drayverlari va firmware, unga muhtoj MacBook modellarida SPI klaviatura drayveri va shu modellar uchun NVMe kutish tuzatishi.

### Maʼlum cheklovlar

Hamjamiyat aʼzolari doimiy ravishda ushbu muammolarga yechimlar ustida ishlashmoqda, shuning uchun agar ular siz uchun muammoli boʻlsa, [Discord](https://discord.gg/tXFUdasqhY) dagi #omarchy-on-other ga qoʻshiling va ularni hal qilishning dolzarb usullari mavjudligini koʻring.

#### T1 chipi bor qurilmalar

Apple T1 chipi 2016-yil oxirida joriy qilingan va Touch Bar bilan birinchi avlod MacBook Pro modellarida eksklyuziv ishlatilgan.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Maʼlum muammolar

- Touch Bar ishlamaydi
- Ovoz ishlamaydi

#### T2 chipi bor qurilmalar

Apple T2 Security Chipi 2017 yilda joriy qilingan. T2 chipi 2020-yildan boshlangan Apple silicon (M-seriya chiplar) ga oʻtish bilan toʻxtatilgan.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Ushbu modellarda oʻrnatuvchi avtomatik yamoqlangan `linux-t2` yadrosini, T2 audio konfiguratsiyasini, Apple-ning Broadcom Wi-Fi/Bluetooth firmware ini va `t2fanrd` orqali ventilyator boshqaruvini sozlaydi. Touch Bar yadroning ichki Boot Camp uslubidagi qoʻllab-quvvatlashida ishlaydi.
