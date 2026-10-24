# Tarmoq

Omarchy-da tarmoq bilan NetworkManager shugʻullanadi va siz uni [yuqori paneldagi](05-the-top-bar.md) tarmoq belgisidan yoki `Super + Ctrl + W` bilan boshqarasz.

Bu panel Wi-Fi tarmoqlarni qidiradi, signal kuchini koʻrsatadi va ulanadi. Ethernet umuman hech narsa talab qilmaydi — uni ulang va ishlaydi. Agar terminalda qolishni afzal koʻrsangiz, `nmtui` sizga bir xil boshqaruvni beradi va `omarchy network` buyruqlar guruhi ham mavjud.

## Wi-Fi-ingizni ulashish

Uzoq parolni ovoz chiqarib oʻqish oʻrniga, Wi-Fi-da boʻlganingizda _Sozlash > Tarmoq > QR kod_ ni ishga tushiring. Bu ekranga istalgan telefon kamerasi skanerlab ulanishi mumkin boʻlgan QR kod chiqaradi. Bu mavjudligini bilganingizdan keyin kutilgandan koʻproq ishlatadigan narsalardan biridir.

Agar sizga parolning oʻzi haqiqatan kerak boʻlsa, `omarchy network password <interface>` uni chop etadi.

## DNS

Omarchy sizning tarmogʻingiz DHCP orqali bergan DNS-dan foydalanadi. Butun mashina uchun buni _Sozlash > Tarmoq > DNS_ ostida bekor qilishingiz mumkin, u yerda Cloudflare va Google bir bosishda mavjud. Oʻz serverlaringizni yozish uchun _Maxsus_ ni tanlang.

Terminaldan `omarchy dns` joriy provayderni chop etadi va `omarchy dns Cloudflare` birini oʻrnatadi.

## Wi-Fi diapazonini qotirib qoʻyish

Agar routeringiz 2.4GHz, 5GHz va 6GHz ni bir xil tarmoq nomiga qoʻysa, noutbukingiz baʼzan sekinrogʻiga yopishib qoladi. `omarchy network band` qaysi diapazonda ekaningizni koʻrsatadi va `omarchy network band 5` uni qotirib qoʻyadi. Uni yana tanlashiga ruxsat berish uchun `auto` dan foydalaning.

Bu muayyan kirish nuqtasi emas, diapazonni qotirib qoʻyadi, shuning uchun siz APlar oʻrtasida odatdagidek roumingda qolasiz.

## Qanchalik tez?

_Ishga tushirish > Tezlik testi > Tarmoq tezligi testi_ sizning yuqoriga va pastga haqiqiy tezligingizni bir juft tsiferblat bilan oʻlchaydi. Terminaldan bu `omarchy network speedtest down` yoki `up`. (Agar boshqa tor joyini benchmark qilayotgan boʻlsangiz, oʻsha menyuda uning yonida disk tezligi testi joylashgan.)

## Firewall

Firewall standart holatda yoqilgan va barcha kiruvchi trafigi bloklaydi, bitta istisno bilan: 53317 port, shuning uchun [LocalSend](22-guis.md) qutidan chiqqan zahoti ishlaydi.

SSH siz uni _Sozlash > Xavfsizlik > SSHD_ bilan yoqquningizga qadar oʻchirilgan boʻladi, bu demonni ishga tushiradi, brute force ga qarshi tezlik cheklangan holda 22 portini ochadi va kalitni avtorizatsiya qiladi. Docker ham yopilgan, shuning uchun konteynerlar tasodifan dunyoga oʻzlarini ochib qoʻya olmaydi. Toʻliq hikoyani [xavfsizlikda](48-security.md) koʻring.

## Tailscale

[Tailscale](https://tailscale.com/) sizning barcha kompyuterlaringiz va serverlaringizga internet orqali yetishni oddiy va xavfsiz qiladigan mesh VPN. Uni _Oʻrnatish > Xizmat > Tailscale_ bilan oʻrnating.

Bu sizga panelda Tailscale panelini beradi, u tailnet ni ulaydi va uzadi, hisoblarni almashtiradi va chiqish tugunini tanlaydi — oʻzingizning mashinalaringiz va Mullvad hududlari roʻyxatda koʻrinadi. Bu ham mashinalaringizni koʻrib chiqadi va Taildrop shu yerda yashaydi: mashinani tanlang va unga fayllar yuborish uchun `s` ni, uning IP sini, ismini yoki toʻliq DNS nomini nusxalash uchun `c`, `n` va `d` ni bosing. Terminal ekvivalenti `omarchy tailscale send <machine> [file...]` va sizga yuborilgan fayllar avtomatik `~/Downloads` ga tushadi. Yetib kelganini eʼlon qiladigan bildirishnoma siz uni ochish uchun bosguningizcha yoki rad etguningizcha kutadi, shuning uchun siz mashinadan uzoqda ekaningizda kelgan fayl qaytganda javob berish uchun hamon shu yerda boʻladi.

Uni oʻrnatish Tailscale admin konsoli uchun veb-ilovani ham qoʻshadi.

## U ishlashni toʻxtatganda

Qayta yuklashdan oldin, aybdor boʻlakni oʻz-oʻzidan qayta ishga tushirishni sinab koʻring. _Yangilash > Qurilmalar_ da Wi-Fi, Bluetooth, Audio va Trackpad mavjud va ulardan birini qayta yuklash aksariyat «besh daqiqa oldin ishlayotgandi» holatlarini bartaraf etadi. [Muammolarni hal qilishni](45-troubleshooting.md) koʻring.
