# Mac qo‘llab-quvvatlash

## Apple Silicon uchun Omarchy

Apple Silicon uchun Omarchy — bu Omacom’ning rasmiy yechimi bo‘lib, birinchi marta Omarchy 4.5 bilan chiqarilgan. U macOS yoniga o‘rnatiladi va Mac’ingiz ishga tushganda ikkisidan birini tanlaysiz.

Omarchy Mac haqida xabar oldingizmi? [Omarchy Mac’dan kelish](#coming-from-omarchy-mac) bo‘limiga o‘ting.

U quyidagi Mac’larda ishlaydi:

| Mac | Chiplar |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4 va undan yangiroq Mac’lar hali qo‘llab-quvvatlanmaydi. M4 qo‘llab-quvvatlovi edge kanalida sinovdan o‘tmoqda va keyingi navbatda keladi. O‘rnatuvchi hech narsani o‘zgartirishidan oldin Mac’ingizni tekshiradi.

Har qanday Apple Silicon Mac’da, jumladan M4 va undan yangiroqlarida ham, Omarchy’ni [Try Omarchy](https://github.com/omacom/try-omarchy) bilan virtual mashinada ishga tushirishingiz mumkin.

### Nimalar kerak

- macOS 15 Sequoia yoki undan yangiroq versiya va administrator hisobi
- Omarchy uchun bo‘sh disk joyi. O‘rnatuvchi o‘lcham taklif qiladi va uni o‘zgartirishga imkon beradi.
- Mac’ingizning zaxira nusxasi, quvvat va internet aloqasi. O‘rnatish bir necha gigabayt yuklab oladi.

### O‘rnatish

Siz macOS’dan o‘rnatasiz. Omarchy Installer’ni [Homebrew](https://brew.sh) bilan o‘rnating:

```sh
brew install omacom/mac/omarchy
```

Yoki eng yangi Omarchy Installer’ni uning [relizlar sahifasi](https://github.com/omacom/omarchy-mac-installer/releases)dan yuklab olib, oching.

O‘rnatuvchi Mac’ingizni tekshiradi, sizga rejani ko‘rsatadi va macOS bo‘limini kichraytirish orqali Omarchy uchun joy ajratadi. macOS diskda qoladi va USB disk kerak emas. Birinchi bosqich tugagach, u sizni macOS Recovery’da sozlashni yakunlash bo‘yicha yo‘naltiradi: o‘chiring, "Loading startup options" yozuvi paydo bo‘lguncha quvvat tugmasini bosib turing, Omarchy’ni tanlang va qadamlarni bajaring.

Birinchi ishga tushishda Omarchy diskini shifrlaydigan parol so‘raydi. Tiklash kaliti yo‘q: parolni unutsangiz, Omarchy fayllaringizni tiklab bo‘lmaydi.

Keyinroq Omarchy va macOS o‘rtasida almashish uchun o‘chiring, so‘ng ishga tushirish variantlari paydo bo‘lguncha quvvat tugmasini bosib turing va bittasini tanlang.

### Omarchy Mac’dan kelish

Omarchy Mac endi Apple Silicon uchun Omarchy tarkibiga kiradi va uni ishlatgan har bir Mac qo‘llab-quvvatlanadi. Joriy o‘rnatmangiz ishlashda davom etadi va uning tizim paketlari hali ham yangilanadi, lekin u boshqa Omarchy yangilanishlarini olmaydi. Muddat yo‘q va joyida yangilash ham yo‘q: siz zaxira nusxasini yaratasiz, eski o‘rnatmani olib tashlaysiz, yangidan o‘rnatasiz va tiklaysiz. 2–5-qadamlar macOS’da amalga oshiriladi, shuning uchun qayta ishga tushirishdan oldin bu sahifani telefoningizda oching.

1. **Omarchy’dan, Mac’dan tashqariga zaxira nusxasini yarating.** Eski o‘rnatmani olib tashlash uni o‘chirib tashlaydi va macOS Omarchy diskini o‘qiy olmaydi. Uy papkangizni tashqi diskka yoki boshqa kompyuterga nusxalang, jumladan SSH va GPG kalitlarini, brauzer profillarini va push qilinmagan ishlarni ham. Paketlar ro‘yxatingizni `pacman -Qqe > ~/packages.txt` bilan saqlang. macOS’ning ham zaxira nusxasini yarating, chunki olib tashlash ham, o‘rnatish ham uning diskini qayta o‘lchamlaydi.
2. **Mac’ingizni macOS’da ishga tushiring.** O‘chiring, ishga tushirish variantlari paydo bo‘lguncha quvvat tugmasini bosib turing va macOS’ni tanlang.
3. **Omarchy Installer’ni o‘rnating** — [O‘rnatish](#installing) bo‘limida ko‘rsatilganidek.
4. **Eski o‘rnatmani olib tashlang.** Omarchy Installer’ni oching va Installation > Remove Omarchy’ni tanlang. U nimalarni o‘chirishini ko‘rsatadi va joyni macOS’ga qaytaradi. Agar u o‘rnatmangizni tanimasa, diskni o‘zgartirmasdan to‘xtaydi. Bo‘limlarni qo‘lda o‘chirish o‘rniga [Discord](https://discord.gg/tXFUdasqhY)da yordam so‘rang, bu macOS’ni o‘chirib tashlashi mumkin.
5. **Apple Silicon uchun Omarchy’ni o‘rnating** — o‘rnatuvchi bilan.
6. **Fayllaringizni tiklang.** Barcha `~/.config` ni yangi standart sozlamalar ustiga nusxalash o‘rniga sozlamalaringizni birma-bir qaytaring, chunki eski sozlamalar ularni bekor qilishi mumkin.

### Bilish foydali

- M1 va M2 MacBook’larda qopqoqni ochish yoki quvvat tugmasini bosish orqali uyqudan uyg‘oting.
- Savollar yoki muammolar: [Discord](https://discord.gg/tXFUdasqhY)imizda so‘rang.

[O‘rnatuvchining README](https://github.com/omacom/omarchy-mac-installer#readme)si reliz kanallarini, o‘rnatuvchini yangilashni va Omarchy’ni olib tashlashni qamrab oladi.

## Intel Mac’lar

Oddiy testda biz 2019-yilgi MacBook Pro’ga shunchaki Omarchy o‘rnatish orqali 36% unumdorlik o‘sishiga erisha oldik.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Mac’ga Omarchy o‘rnatish

Omarchy hozirda **yagona** OS sifatida o‘rnatilishni qo‘llab-quvvatlaydi. O‘rnatish paytida disk tozalanadi va MacOS endi yuklanadigan bo‘lmaydi.

Xohlasangiz, uni keyinroq Internet Recovery orqali tiklashingiz mumkin.

Ushbu qism uchun siz allaqachon [Getting Started](02-getting-started.md)ni ko‘rib chiqqansiz va USB diskingiz tayyor deb faraz qilamiz. Agar unday bo‘lmasa, hozir buni qiling.

#### Secure Boot’ni o‘chirib qo‘yish

Yuklanadigan USB’ni, shuningdek OS’ni ham yuklash uchun Apple’ning Secure Boot’ini o‘chirib qo‘yish zarur. Uni o‘chirib qo‘yish uchun quyidagilarni bajaring:

1. Mac’ingizni o‘chiring
2. Uni yoqing va yuklash ekrani paydo bo‘lguncha Command-R tugmalarini _darhol_ bosib turing
3. Foydalanuvchingizni tanlang va so‘ralsa parolingizni kiriting
4. Tiklash ekraniga kirgach, menyu panelidan **Utilities > Startup Security Utility** ni tanlang
5. Autentifikatsiya qilish so‘ralganda parolingizni kiriting
6. Secure Boot variantlaridan "No Security" ni tanlang
7. External Boot variantlaridan "Allow booting from external or removable media" ni tanlang

#### O‘rnatishni boshlash

1. USB diskni joylashtiring
2. Mac’ingizni qayta ishga tushiring va yuklash qurilmalari ekrani paydo bo‘lguncha Option tugmasini _darhol_ bosib turing
3. To‘q sariq EFI Boot qurilmasini tanlang
4. [Odatdagidek o‘rnatish](02-getting-started.md) bilan davom eting

O‘rnatuvchi Mac uskunasini aniqlaydi va kerakli tuzatishlarni avtomatik qo‘llaydi: Broadcom Wi-Fi drayverlari va proshivkasi, Broadcom 1570’ga ega mashinalardagi FaceTime HD kamera drayveri (uning proshivkasi Mac onlayn bo‘lgach Apple’dan yuklab olinadi, chunki o‘rnatuvchi oflayn ishlaydi), unga muhtoj MacBook modellaridagi SPI klaviatura drayveri va o‘sha modellar uchun NVMe uyqu tuzatishi.

### Ma’lum cheklovlar

Jamiyat a’zolari bu qiyinchiliklarga yechimlar ustida doimiy ishlamoqda, shuning uchun agar bular siz uchun muammo bo‘lsa, [Discord](https://discord.gg/tXFUdasqhY)imizdagi #omarchy-on-other kanaliga qo‘shiling va ularni hal qilishning dolzarb usullari bor-yo‘qligini ko‘ring.

#### FaceTime HD Camera

Kamera drayveri, agar Mac qishki uyquga ketayotganda yuklangan bo‘lsa, mashinani osib qo‘yadi, shuning uchun u avval tushiriladi. Ilova kamerani ochib turgan paytda uni tushirib bo‘lmaydi, shuning uchun qishki uyqu ilova nomi ko‘rsatilgan bildirishnoma bilan bekor qilinadi: uni yoping va yana qishki uyquga o‘tkazing. Bunga batareya kritik darajada bo‘lganda avtomatik qishki uyquga o‘tish ham, shuningdek uyquga ketishidan oldin rad etiladigan suspend-then-hibernate ham kiradi. Oddiy uyqu, kamera ochiq bo‘lganda, bildirishnomasiz drayverning o‘zi tomonidan rad etiladi.

Kameraning proshivkasi Apple’dan yuklab olinadi, shuning uchun kamera faqat Mac onlayn bo‘lgandan keyin ishlaydi. Yuklab olish ishga tushishda boshlanadi va muammo tarmoqda bo‘lsa, har 15 daqiqada qayta urinib ko‘riladi; agar Apple fayli o‘zgargan bo‘lsa, u to‘xtaydi va Omarchy yangilanishini kutadi. Agar kamera paydo bo‘lmasa, `journalctl -u facetimehd-firmware-fetcher` nima uchunligini aytadi, `sudo systemctl restart facetimehd-firmware-fetcher` yana urinib ko‘radi va agar yuklab olish tugagan bo‘lsa-yu, lekin kamera hali ham bo‘lmasa, qayta ishga tushirish drayverni yuklaydi.

#### T1 chipli qurilmalar

Apple T1 chipi 2016-yil oxirida taqdim etilgan va faqat Touch Bar’li birinchi avlod MacBook Pro modellarida ishlatilgan.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Ma’lum muammolar

- Touch Bar ishlamaydi
- Ovoz ishlamayapti

#### T2 chipli qurilmalar

Apple T2 Security Chip 2017-yilda taqdim etilgan. T2 chipi 2020-yildan boshlab Apple silicon (M-series chiplari)ga o‘tish bilan to‘xtatilgan.

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

Ushbu modellarda o‘rnatuvchi avtomatik ravishda tuzatilgan `linux-t2` yadrosini, T2 ovoz konfiguratsiyasini, Apple’ning Broadcom Wi-Fi/Bluetooth proshivkasini va `t2fanrd` orqali ventilyator boshqaruvini o‘rnatadi. Touch Bar yadroning o‘rnatilgan Boot Camp uslubidagi qo‘llab-quvvatlovida ishlaydi.

#### iMac Retina 5K (2017)

2017-yilgi 27-inch iMac’da T2 chipi yo‘q, shuning uchun o‘rnatuvchi uni boshqa Intel Mac’lar kabi o‘rnatadi.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Ma’lum muammolar

- Displey o‘zining asl 5120×2880 o‘lchamida ishlamaydi: panel ikkita plitkadan iborat va standart drayver faqat bittasini yoritadi
- Ovoz ishlamayapti
- Yorqinlik boshqaruvi hech qanday ta’sir ko‘rsatmaydi
- Uyqu mashinani osib qo‘yadi; uni faqat quvvatni o‘chirib-yoqish tiklaydi

Ushbu model uchun jamiyat patcheri displey, ovoz va yorqinlikni tuzatadi: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
