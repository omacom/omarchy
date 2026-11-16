# Tarmoq

Omarchy'da tarmoq NetworkManager tomonidan boshqariladi, siz esa uni [yuqori panel](05-the-top-bar.md)dagi tarmoq belgisidan yoki `Super + Ctrl + N` bilan boshqarasiz.

O'sha panel Wi-Fi tarmoqlarini qidiradi, signal kuchini ko'rsatadi va ulanadi. Ethernet uchun hech narsa kerak emas — kabelni ulang va u ishlaydi. Agar terminalda qolishni afzal ko'rsangiz, `nmtui` xuddi o'sha boshqaruvlarni beradi, shuningdek `omarchy network` buyruqlar guruhi ham bor.

## Wi-Fi'ingizni ulashish

Uzun parolni ovoz chiqarib o'qib o'tirmasdan, Wi-Fi'ga ulangan paytingizda _Setup > Network > QR Code_ ni ishga tushiring. Bu ekranga istalgan telefon kamerasi skanerlab qo'shila oladigan QR code chiqaradi. Bu — borligini bilib olganingizdan keyin kutilganidan ko'proq ishlatadigan narsalardan biri.

Agar sizga aynan parolning o'zi kerak bo'lsa, `omarchy network password <interface>` uni chiqarib beradi.

## DNS

Omarchy tarmog'ingiz DHCP orqali bergan DNS'dan foydalanadi. Buni butun mashina uchun _Setup > Network > DNS_ ostida o'zgartirishingiz mumkin, u yerda Cloudflare va Google bir bosishda tayyor. O'zingizning serverlaringizni yozish uchun _Custom_ ni tanlang.

Terminaldan `omarchy dns` joriy providerni chiqaradi va `omarchy dns Cloudflare` bittasini o'rnatadi.

## Wi-Fi bandini qotirib qo'yish

Agar routeringiz 2.4GHz, 5GHz va 6GHz'ni bitta tarmoq nomi ostida bersa, noutbukingiz ba'zan sekiniga yopishib qoladi. `omarchy network band` qaysi bandda ekaningizni ko'rsatadi, `omarchy network band 5` esa uni qotirib qo'yadi. U yana o'zi tanlashiga ruxsat berish uchun `auto` dan foydalaning.

Bu muayyan access point'ni emas, bandni qotiradi, shuning uchun siz AP'lar orasida odatdagidek rouming qilib yuraverasiz.

## U qanchalik tez?

_Trigger > Speed Test > Network Speed Test_ bir juft shkalalar bilan haqiqiy yuklab olish va yuklash tezligingizni o'lchaydi. Terminaldan bu `omarchy network speedtest down` yoki `up`. U Omarchy'ning o'z xizmati bilan o'lchaydi va faqat o'zining test uzatishlarini hisobga oladi. Boshqa yuklab olishlar o'tkazish qobiliyati uchun raqobat qilishi mumkin, lekin ular speed-test natijasiga qo'shilmaydi. (Agar boshqa tor joyni benchmark qilayotgan bo'lsangiz, o'sha menyuda uning yonida disk speed test'i ham turibdi.)

## Firewall

Firewall sukut bo'yicha yoqilgan bo'ladi va barcha kiruvchi traffic'ni bloklaydi, bitta istisno bilan: 53317-port, shunda [LocalSend](22-guis.md) qutidan chiqqan zahoti ishlaydi.

SSH uni _Setup > Security > SSHD_ bilan yoqmaguningizcha o'chiq turadi, bu daemon'ni ishga tushiradi, brute force'ga qarshi rate-limited qilingan 22-portni ochadi va kalitni avtorizatsiya qiladi. Docker ham qattiq yopilgan, shuning uchun container'lar tasodifan o'zlarini dunyoga ochib qo'ya olmaydi. Butun hikoya uchun [security](48-security.md) ga qarang.

## Tailscale

[Tailscale](https://tailscale.com/) — barcha kompyuterlaringiz va serverlaringizga internet orqali yetib borishni oddiy va xavfsiz qiladigan mesh VPN. Uni _Install > Service > Tailscale_ bilan o'rnating.

Bu sizga panelda Tailscale panelini beradi, u tailnet'ga ulanadi va undan uziladi, account'larni almashtiradi va exit node tanlaydi — ro'yxatda o'zingizning mashinalaringiz ham, Mullvad region'lari ham chiqadi. U mashinalaringizni ham ko'rib chiqadi va Taildrop aynan o'sha yerda yashaydi: mashinani tanlang va unga fayllar yuborish uchun `s` ni bosing, yoki uning IP'si, nomi yoki to'liq DNS nomini nusxalash uchun `c`, `n` va `d` ni bosing. Terminaldagi muqobili `omarchy tailscale send <machine> [file...]`, sizga yuborilgan fayllar esa avtomatik ravishda `~/Downloads` ga tushadi. Kelganini e'lon qiladigan bildirishnoma siz uni ochish uchun bosmaguningizcha yoki yopib yubormaguningizcha kutib turadi, shuning uchun siz mashina oldida yo'qligingizda kelib tushgan fayl qaytib kelganingizda ham javob berishingiz uchun o'sha yerda turadi.

Uni o'rnatish Tailscale admin console uchun web app ham qo'shadi.

## U ishlashdan to'xtaganda

Reboot qilishdan oldin, aybdor bo'lakning o'zini qayta ishga tushirib ko'ring. _Update > Hardware_ da Wi-Fi, Bluetooth, Audio va Trackpad bor, ulardan birini qayta yuklash ko'pchilik "besh daqiqa oldin ishlayotgandi" vaziyatlarini to'g'rilaydi. [troubleshooting](45-troubleshooting.md) ga qarang.
