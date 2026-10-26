# Tarmoq

Omarchy'da tarmoq NetworkManager tomonidan boshqariladi, va siz uni [yuqori panel](05-the-top-bar.md)dagi tarmoq belgisidan yoki `Super + Ctrl + N` bilan boshqarasiz.

Ushbu panel Wi-Fi tarmoqlarini qidiradi, signal kuchini ko'rsatadi va ulanadi. Ethernet umuman hech narsani talab qilmaydi — kabelni ulang va u ishlaydi. Agar terminalda qolishni afzal ko'rsangiz, `nmtui` sizga xuddi shu boshqaruvlarni beradi, va `omarchy network` buyruqlar guruhi ham bor.

## Wi-Fi'ingizni ulashish

Uzoq parolni ovoz chiqarib o'qish o'rniga, Wi-Fi'ga ulanganingizda _Sozlash > Tarmoq > QR Code_ ni ishga tushiring. Bu ekranga istalgan telefon kamerasi skanerlab ulanishi mumkin bo'lgan QR kodni chiqaradi. Bu — borligini bilganingizdan keyin kutilganidan ko'proq ishlatadigan narsalardan biri.

Agar sizga aynan parolning o'zi kerak bo'lsa, `omarchy network password <interface>` uni chiqaradi.

## DNS

Omarchy tarmog'ingiz DHCP orqali bergan DNS'dan foydalanadi. Siz buni butun mashina uchun _Sozlash > Tarmoq > DNS_ ostida o'zgartirishingiz mumkin, bu yerda Cloudflare va Google bir bosishda mavjud. O'zingizning serverlaringizni kiritish uchun _Custom_ ni tanlang.

Terminaldan, `omarchy dns` joriy provayderni chiqaradi va `omarchy dns Cloudflare` birini o'rnatadi.

## Wi-Fi diapazonini qotirish

Agar routeringiz 2.4GHz, 5GHz va 6GHz ni bir xil tarmoq nomiga qo'ysa, noutbukingiz ba'zan sekiniga yopishib qoladi. `omarchy network band` qaysi diapazonda ekanligingizni ko'rsatadi, va `omarchy network band 5` uni qotiradi. Yana o'zi tanlashiga ruxsat berish uchun `auto` dan foydalaning.

Bu muayyan kirish nuqtasini emas, diapazonni qotiradi, shuning uchun siz AP'lar orasida odatdagidek rouming qilishda davom etasiz.

## U qanchalik tez?

_Trigger > Speed Test > Network Speed Test_ haqiqiy yuklab olish va yuklash tezligingizni bir juft siferblat bilan o'lchaydi. Terminaldan bu `omarchy network speedtest down` yoki `up`. (Agar boshqa tor bo'g'inni benchmark qilayotgan bo'lsangiz, o'sha menyuda uning yonida disk tezligi testi ham bor.)

## Firewall

Firewall sukut bo'yicha yoqilgan va barcha kiruvchi trafikni bloklaydi, bitta istisno bilan: 53317-port, shuning uchun [LocalSend](22-guis.md) qutidan chiqqan holda ishlaydi.

SSH siz uni _Sozlash > Xavfsizlik > SSHD_ bilan yoqmaguningizcha o'chirilgan bo'ladi, bu daemon'ni ishga tushiradi, 22-portni brute force'ga qarshi tezlik cheklovi bilan ochadi va kalitni avtorizatsiya qiladi. Docker ham qulflangan, shuning uchun konteynerlar tasodifan o'zlarini dunyoga ochib yubora olmaydi. Butun hikoya uchun [xavfsizlik](48-security.md) ga qarang.

## Tailscale

[Tailscale](https://tailscale.com/) — barcha kompyuterlaringiz va serverlaringizga internet orqali yetib borishni sodda va xavfsiz qiladigan mesh VPN. Uni _O'rnatish > Xizmat > Tailscale_ bilan o'rnating.

Bu sizga panelda Tailscale panelini beradi, u tailnet'ga ulanadi va undan uziladi, hisoblarni almashtiradi va chiqish tugunini tanlaydi — ro'yxatda o'zingizning mashinalaringiz ham, Mullvad mintaqalari ham chiqadi. U shuningdek mashinalaringizni ko'rib chiqadi, va Taildrop aynan shu yerda yashaydi: mashinani tanlang va unga fayllar yuborish uchun `s` ni bosing, yoki uning IP, nomi yoki to'liq DNS nomini nusxalash uchun `c`, `n` va `d` ni bosing. Terminaldagi muqobili `omarchy tailscale send <machine> [file...]`, va sizga yuborilgan fayllar avtomatik ravishda `~/Downloads` ga tushadi. Kelganlik haqidagi bildirishnoma siz uni bosib ochmaguningizcha yoki rad etmaguningizcha kutadi, shuning uchun siz mashinadan uzoqda bo'lganingizda kelgan fayl, qaytganingizda javob berishingiz uchun hali ham shu yerda bo'ladi.

Uni o'rnatish Tailscale admin konsoli uchun veb-ilovani ham qo'shadi.

## U ishlashdan to'xtaganda

Qayta yuklashdan oldin, buzilgan qismni o'zini alohida qayta ishga tushirib ko'ring. _Yangilash > Uskuna_ da Wi-Fi, Bluetooth, Audio va Trackpad bor, va ulardan birini qayta yuklash ko'pchilik "besh daqiqa oldin ishlayotgan edi" holatlarini tozalaydi. [muammolarni bartaraf etish](45-troubleshooting.md) ga qarang.
