# Mac qo'llab-quvvatlashi

## Apple Silicon uchun Omarchy

Apple Silicon uchun Omarchy — bu Omacom'ning rasmiy yechimi bo'lib, birinchi marta Omarchy 4.5 bilan chiqarilgan. U macOS yoniga o'rnatiladi va Mac ishga tushganda ikkalasidan birini tanlaysiz.

Omarchy Mac haqida xabarnoma oldingizmi? [Omarchy Mac'dan kelayotganlar](#coming-from-omarchy-mac) bo'limiga o'ting.

U quyidagi Mac'larda ishlaydi:

| Mac | Chiplar |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4 va undan yangi Mac'lar hali qo'llab-quvvatlanmaydi. M4 qo'llab-quvvatlashi edge kanalida sinovdan o'tkazilmoqda va keyingi navbatda keladi. O'rnatuvchi biror narsani o'zgartirishdan oldin Mac'ingizni tekshiradi.

Har qanday Apple Silicon Mac'da, jumladan M4 va undan yangilarida ham, Omarchy'ni [Try Omarchy](https://github.com/omacom/try-omarchy) bilan virtual mashinada ishga tushirishingiz mumkin.

### Sizga kerak bo'ladiganlar

- macOS 15 Sequoia yoki undan yangiroq versiya va administrator hisobi
- Omarchy uchun bo'sh disk joyi. O'rnatuvchi o'lcham taklif qiladi va uni o'zgartirishga imkon beradi.
- Mac'ingizning zaxira nusxasi, quvvat va internet aloqasi. O'rnatish bir necha gigabayt yuklab oladi.

### O'rnatish

O'rnatishni macOS'dan amalga oshirasiz. Omarchy Installer'ni [Homebrew](https://brew.sh) bilan o'rnating:

```sh
brew install omacom/mac/omarchy
```

Yoki eng yangi Omarchy Installer'ni uning [chiqarilishlar sahifasi](https://github.com/omacom/omarchy-mac-installer/releases)dan yuklab olib, oching.

O'rnatuvchi Mac'ingizni tekshiradi, sizga rejani ko'rsatadi va macOS bo'limini kichraytirish orqali Omarchy uchun joy ajratadi. macOS diskda qoladi va USB drayv kerak emas. Birinchi bosqich tugagach, u sizni macOS Recovery'da sozlashni yakunlash bo'yicha yo'naltiradi: o'chiring, "Loading startup options" yozuvi paydo bo'lguncha quvvat tugmasini bosib turing, Omarchy'ni tanlang va bosqichlarni bajaring.

Birinchi ishga tushishda Omarchy diskini shifrlaydigan parol so'raydi. Tiklash kaliti yo'q: agar parolni unutsangiz, Omarchy fayllaringizni tiklab bo'lmaydi.

Keyinchalik Omarchy va macOS o'rtasida almashish uchun o'chiring, so'ng startup options paydo bo'lguncha quvvat tugmasini bosib turing va birini tanlang.

### Omarchy Mac'dan kelayotganlar

Omarchy Mac endi Apple Silicon uchun Omarchy'ning bir qismi va uni ishlatgan har bir Mac qo'llab-quvvatlanadi. Hozirgi o'rnatmangiz ishlashda davom etadi va uning tizim paketlari hali ham yangilanadi, lekin u endi Omarchy yangilanishlarini olmaydi. Muddat yo'q va joyida yangilash ham yo'q: zaxira nusxa yaratasiz, eski o'rnatmani olib tashlaysiz, yangidan o'rnatasiz va tiklaysiz. 2 dan 5 gacha bosqichlar macOS'da amalga oshiriladi, shuning uchun qayta ishga tushirishdan oldin ushbu sahifani telefoningizda oching.

1. **Omarchy'dan, Mac'dan tashqariga zaxira nusxa yarating.** Eski o'rnatmani olib tashlash uni o'chirib tashlaydi va macOS Omarchy diskini o'qiy olmaydi. Uy papkangizni tashqi drayvga yoki boshqa kompyuterga nusxalang, jumladan SSH va GPG kalitlari, brauzer profillari va push qilinmagan ishlarni ham. Paketlar ro'yxatingizni `pacman -Qqe > ~/packages.txt` bilan saqlang. macOS'ning ham zaxira nusxasini yarating, chunki olib tashlash ham, o'rnatish ham uning diskini qayta o'lchaydi.
2. **Mac'ingizni macOS'da ishga tushiring.** O'chiring, startup options paydo bo'lguncha quvvat tugmasini bosib turing va macOS'ni tanlang.
3. **Omarchy Installer'ni o'rnating** [O'rnatish](#installing) bo'limida ko'rsatilganidek.
4. **Eski o'rnatmani olib tashlang.** Omarchy Installer'ni oching va Installation > Remove Omarchy'ni tanlang. U nimani o'chirib tashlashini ko'rsatadi va joyni macOS'ga qaytaradi. Agar u o'rnatmangizni tanimasa, diskni o'zgartirmasdan to'xtaydi. Bo'limlarni qo'lda o'chirib tashlash o'rniga [Discord](https://discord.gg/tXFUdasqhY)da yordam so'rang, chunki bu macOS'ni o'chirib tashlashi mumkin.
5. **Apple Silicon uchun Omarchy'ni** o'rnatuvchi bilan o'rnating.
6. **Fayllaringizni tiklang.** Barcha `~/.config`'ni yangi standart sozlamalar ustiga nusxalash o'rniga, sozlamalaringizni birma-bir qaytarib olib keling, chunki eski sozlamalar ularni bekor qilishi mumkin.

### Bilish foydali

- M1 va M2 MacBook'larda qopqoqni ochish yoki quvvat tugmasini bosish orqali uyqudan uyg'oning.
- Savollar yoki muammolar: bizning [Discord](https://discord.gg/tXFUdasqhY)imizda so'rang.

[O'rnatuvchining README](https://github.com/omacom/omarchy-mac-installer#readme)si chiqarilish kanallari, o'rnatuvchini yangilash va Omarchy'ni olib tashlashni qamrab oladi.

## Intel Mac'lar

Oddiy testda biz 2019-yilgi MacBook Pro'ga shunchaki Omarchy o'rnatish orqali 36% samaradorlik o'sishiga erisha oldik.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Mac'ga Omarchy o'rnatish

Omarchy hozirda o'rnatilgan **yagona** OT bo'lishnigina qo'llab-quvvatlaydi. O'rnatish paytida drayv tozalanadi va MacOS endi ishga tushirilmaydigan bo'ladi.

Agar xohlasangiz, uni keyinroq Internet Recovery orqali hali ham tiklashingiz mumkin.

Ushbu qism uchun siz allaqachon [Ishni boshlash](02-getting-started.md)ni ko'rib chiqqansiz va USB drayvingiz tayyor deb faraz qilamiz. Agar unday bo'lmasa, hozir borib shuni qiling.

#### Secure Boot'ni o'chirish

Yuklanadigan USB'ni, shuningdek OT'ni ishga tushirish uchun Apple'ning Secure Boot'ini o'chirish zarur. Uni o'chirish uchun quyidagilarni bajaring:

1. Mac'ingizni o'chiring
2. Uni yoqing va yuklanish ekrani paydo bo'lishini ko'rguningizcha _darhol_ Command-R'ni bosib turing
3. Foydalanuvchingizni tanlang va so'ralsa parolingizni kiriting
4. Tiklash ekraniga kirganingizdan so'ng, menyu panelidan **Utilities > Startup Security Utility**ni tanlang
5. Autentifikatsiya qilish so'ralganda parolingizni kiriting
6. Secure Boot variantlaridan "No Security"ni tanlang
7. External Boot variantlaridan "Allow booting from external or removable media"ni tanlang

#### O'rnatishni boshlash

1. USB drayvni joylashtiring
2. Mac'ingizni qayta ishga tushiring va yuklash qurilmalari ekranini ko'rguningizcha _darhol_ Option'ni bosib turing
3. To'q sariq EFI Boot qurilmasini tanlang
4. [O'rnatishni odatdagidek](02-getting-started.md) davom ettiring

O'rnatuvchi Mac apparat qismini aniqlaydi va kerakli tuzatishlarni avtomatik qo'llaydi: Broadcom Wi-Fi drayverlari va proshivkasi, unga muhtoj MacBook modellaridagi SPI klaviatura drayveri va o'sha modellar uchun NVMe uyquga ketish tuzatishi.

### Ma'lum cheklovlar

Hamjamiyat a'zolari ushbu qiyinchiliklarga yechimlar ustida doimiy ishlamoqda, shuning uchun agar bular siz uchun muammoli bo'lsa, bizning [Discord](https://discord.gg/tXFUdasqhY)imizdagi #omarchy-on-other'ga qo'shiling va ularni hal qilishning dolzarb usullari bor-yo'qligini ko'ring.

#### T1 chipiga ega qurilmalar

Apple T1 chipi 2016-yil oxirida taqdim etilgan va faqat Touch Bar'li birinchi avlod MacBook Pro modellarida ishlatilgan.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Ma'lum muammolar

- Touch Bar ishlamaydi
- Ovoz ishlamayapti

#### T2 chipiga ega qurilmalar

Apple T2 Security Chip 2017-yilda taqdim etilgan. T2 chipi 2020-yildan boshlab Apple silicon'ga (M-seriyali chiplarga) o'tish bilan to'xtatilgan.

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

Ushbu modellarda o'rnatuvchi avtomatik ravishda tuzatilgan `linux-t2` yadrosini, T2 audio konfiguratsiyasini, Apple'ning Broadcom Wi-Fi/Bluetooth proshivkasini va `t2fanrd` orqali ventilyator boshqaruvini sozlaydi. Touch Bar yadroning o'rnatilgan Boot Camp uslubidagi qo'llab-quvvatlashida ishlaydi.

#### iMac Retina 5K (2017)

2017-yilgi 27 dyuymli iMac'da T2 chipi yo'q, shuning uchun o'rnatuvchi uni boshqa Intel Mac'lar kabi sozlaydi.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Ma'lum muammolar

- Displey o'zining asl 5120×2880 o'lchamida ishlamaydi: panel ikkita plitkadan iborat va standart drayver faqat bittasini yoritadi
- Ovoz ishlamayapti
- Yorqinlik boshqaruvi hech qanday ta'sir ko'rsatmaydi
- Uyqu mashinani osib qo'yadi; uni faqat quvvatni o'chirib-yoqish tiklaydi

Ushbu model uchun hamjamiyat patcheri displey, ovoz va yorqinlikni tuzatadi: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
