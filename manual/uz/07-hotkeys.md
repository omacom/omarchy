# Tezkor tugmalar

Asosiy klaviatura bog‘lamlarining barchasini `Super + K` bilan ko‘rishingiz mumkin (Tmux bog‘lamlari `Super + Alt + K` bilan va Herdr bog‘lamlari `Super + Ctrl + K` bilan).

## Tezkor tugmalar qanday joylashtirilgan

Har bir tezkor tugma o‘z modifikatorlari bilan belgilanadigan tekislikda joylashadi va har bir tekislikning bitta vazifasi bor. Tezkor tugmalarning bir-biriga aralashib ketmasligini mana shu ta’minlaydi va bu odatda biror narsa qayerda joylashganini taxmin qila olishingizni anglatadi.

| Tekislik | U yerda nimalar joylashgan | Misollar |
| --- | --- | --- |
| `Super + key` | Tizim: oynalar, ish maydonlari, tartiblar va asosiy menyular | `Super + Space` Omarchy menyusi, `Super + W` oynani yopish, `Super + F` to‘liq ekran |
| `Super + Shift + key` | Ilovalar | `Super + Shift + B` brauzer, `Super + Shift + E` elektron pochta, `Super + Shift + N` muharrir |
| `Super + Ctrl + key` | Panellar va tizim menyulari | `Super + Ctrl + A` audio, `Super + Ctrl + N` tarmoq, `Super + Ctrl + C` suratga olish menyusi |
| `Super + Ctrl + Alt + key` | Tezkor amallar va xabarnomalar | `Super + Ctrl + Alt + T` vaqtni ko‘rsatish, `Super + Ctrl + Alt + B` batareya, `Super + Ctrl + Alt + C` skrinshot |

Tezkor tugmaga `Alt` qo‘shish sizga o‘sha narsaning variantini beradi, hech qachon aloqasiz narsani emas:

- `Super + Shift + B` brauzerni ochadi; `Super + Shift + Alt + B` xususiy oynani ochadi
- `Super + Shift + E` elektron pochtani ochadi; `Super + Shift + Alt + E` yangisini boshlaydi
- `Super + F` to‘liq ekranga o‘tadi; `Super + Alt + F` to‘liq kenglikka o‘tadi
- `Super + Ctrl + C` suratga olish menyusini ochadi; `Super + Ctrl + Alt + C` menyuni o‘tkazib yuborib, skrinshot oladi

Tezkor tugma qo‘shayotganda:

1. U nima qilishiga qarab tekislikni tanlang, keyin tugmani tanlang.
2. Joy bo‘shatish uchun mavjud tezkor tugmani ko‘chirmang. To‘g‘ri tekislikda bo‘sh tugmani toping.
3. `Alt` dan faqat usiz tezkor tugmaning varianti uchun foydalaning.

Bir nechta tezkor tugmalar qulay bo‘lgani uchun ushbu qoidalarni buzadi. O‘q yoki `Tab` bilan `Shift` ilovani ochish o‘rniga ko‘chiradi yoki teskari yo‘nalishda ishlaydi, `Print`, media tugmalari, `Alt + Tab` va `Ctrl + Alt + Del` esa hamma joyda qanday ishlasa, shunday ishlaydi. Ular istisnolar, ko‘chirib olish uchun naqshlar emas.

Agar standart variant sizga to‘g‘ri kelmasa (aytaylik, Windows dagi kabi skrinshotlar uchun `Super + Shift + S` ni xohlasangiz), uni `~/.config/hypr/bindings.lua` da qayta bog‘lang.

## Navigatsiya

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menyusi (ilovalar va boshqa hamma narsa)    |
| `Super + Alt + Space` | Ilovalar panjarasi |
| `Super + Escape` | Tizim menyusi (kutish rejimi, qayta ishga tushirish va hokazo)  |
| `Super + Ctrl + L` | Kompyuterni qulflash |
| `Super + W` yoki `Super + Q` | Oynani yopish             |
| `Ctrl + Alt + Del` | Barcha oynalarni yopish |
| `Super + T`               | Oynani plitkali/suzuvchi rejimlar o‘rtasida almashtirish             |
| `Super + J` | Oyna holatini almashtirish (gorizontal/vertikal) |
| `Super + O`               | Oynani sticky'n'floating rejimiga o‘tkazishni almashtirish |
| `Super + L`               | dwindle, scrolling va floating tartiblari bo‘ylab aylanish |
| `Super + Alt + L`         | Tartiblar bo‘ylab teskari yo‘nalishda aylanish |
| `Super + P`               | Pseudo oyna uslubini almashtirish (tabiiy va cho‘zilgan) |
| `Super + F`                 | To‘liq ekranga o‘tish              |
| `Super + Alt + F`                 | To‘liq kenglikka o‘tish              |
| `Super + Ctrl + F`                 | Oyna ichida to‘liq ekranga o‘tish              |
| `Super + 1/2/3/4`         | Fokuslangan monitordagi ma’lum ish maydoniga o‘tish |
| `Super + Tab` | Fokuslangan monitordagi keyingi ish maydoniga o‘tish |
| `Super + Shift + Tab` | Fokuslangan monitordagi oldingi ish maydoniga o‘tish |
| `Super + Ctrl + Tab` | Fokuslangan monitordagi avvalgi ish maydoniga o‘tish |
| `Super + Shift + 1/2/3/4` | Oynani fokuslangan monitordagi ish maydoniga ko‘chirish |
| `Super + Shift + Alt + 1/2/3/4` | Oynani fokuslangan monitordagi ish maydoniga ergashmasdan ko‘chirish |
| `Super + S` | To‘liq scratchpad ni almashtirish |
| `Super + Alt + S` | Oynani to‘liq scratchpad ga ko‘chirish |
| `Super + Grave` | Quake konsolini almashtirish |
| `Super + Shift + Grave` | Oynani Quake konsoliga ko‘chirish |
| `Super + Shift + Ctrl + Arrows` | Oynani o‘sha yo‘nalishdagi monitorga ko‘chirish |
| `Super + Shift + Alt + Arrows` | Ish maydonini o‘sha yo‘nalishdagi monitorga ko‘chirish |
| `Super + Arrow`  | Fokusni o‘q yo‘nalishidagi oynaga ko‘chirish, ekranning chetida o‘sha tomondagi monitorga o‘tish |
| `Super + Shift + Arrow`  | Oynani o‘q yo‘nalishidagi boshqa oyna bilan almashtirish, o‘sha tomondagi monitordagi oynani ham qo‘shib |
| `Super + Minus` | Oynani chapga kengaytirish |
| `Super + Equal` | Oynani chapga qisqartirish |
| `Super + Shift + Minus` | Oynani yuqoriga qisqartirish |
| `Super + Shift + Equal` | Oynani pastga kengaytirish |
| `Super + Alt + Minus/Equal` | Xuddi shu o‘lcham o‘zgartirish kichikroq qadamlar bilan |
| `Super + Ctrl + Minus/Equal` | Xuddi shu o‘lcham o‘zgartirish kattaroq qadamlar bilan |
| `Super + Alt + Home` | Oyna kengligini saqlash |
| `Super + Home` | Saqlangan oyna kengligini tiklash |
| `Super + Left Mouse` | Oynani sudrab yurish |
| `Super + Right Mouse` | Oyna o‘lchamini o‘zgartirish |
| `Super + Scroll Wheel` | Fokuslangan monitordagi ish maydonlari bo‘ylab aylanish |
| `Super + G`               | Oynalarni guruhlashni almashtirish      |
| `Super + Alt + G`               | Oynani guruhdan chiqarish      |
| `Super + Alt + Tab`               | Guruh ichidagi oynalar bo‘ylab aylanish      |
| `Super + Alt + Shift + Tab`               | Guruh ichidagi oynalar bo‘ylab teskari yo‘nalishda aylanish      |
| `Super + Alt + Scroll Wheel` | Guruh ichidagi oynalar bo‘ylab aylanish |
| `Super + Alt + 1/2/3/4/5`               | Guruhdagi ma’lum oynaga o‘tish      |
| `Super + Alt + Arrow`  | Oynani o‘q yo‘nalishida guruhga ko‘chirish, o‘sha tomondagi monitordagi oynani ham qo‘shib |
| `Super + Ctrl + Left/Right`  | Plitkali guruh ichidagi oynalar o‘rtasida harakatlanish |
| `Super + Ctrl + Z` | Ekranni yaqinlashtirish (kattaroq zoom uchun takrorlang) |
| `Super + Ctrl + Alt + Z` | Ekrandan to‘liq uzoqlashish |
| `Super + /` | Monitor masshtabi variantlari bo‘ylab oldinga o‘tish |
| `Super + Alt + /` | Monitor masshtabi variantlari bo‘ylab orqaga o‘tish |
| `Alt + Tab` | Faol ish maydonidagi oynalar bo‘ylab oldinga aylanish |
| `Alt + Shift + Tab` | Faol ish maydonidagi oynalar bo‘ylab teskari yo‘nalishda aylanish |
| `Ctrl + Alt + Tab`| Monitorlar bo‘ylab fokusni oldinga aylantirish |
| `Ctrl + Alt + Shift + Tab`| Monitorlar bo‘ylab fokusni orqaga aylantirish |

O‘lcham o‘zgartirish yorliqlari klaviaturada bosilgan belgilardan qat’i nazar, fizik `code:20` va `code:21` tugmalaridan (XKB `<AE11>` va `<AE12>`) foydalanadi. AQSH klaviaturalarida bu tugmalar `-` va `=`; yapon (JIS) klaviaturalarida ular `-` va `^`; ispan klaviaturalarida ular `'` va `¡`. JIS da `Super + ^` — `Super + Equal`, `Super + Shift + -` esa (u `=` ni kiritadi) `Super + Shift + Minus` dir.

## Tizim boshqaruvlari

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Audio paneli    |
| `Super + Ctrl + B`           | Bluetooth paneli    |
| `Super + Ctrl + N`           | Wi-Fi/tarmoq paneli    |
| `Super + Ctrl + D`           | Displey paneli    |
| `Super + Ctrl + P`           | Quvvat paneli    |
| `Super + Ctrl + X`           | Agentlar paneli    |
| `Super + Ctrl + Alt + D`           | Kalendar paneli    |
| `Super + Ctrl + Alt + E`           | Jahon soati paneli    |
| `Super + Ctrl + 1-9`           | Pozitsiyasi bo‘yicha panelni almashtirish    |
| `Super + Ctrl + S` | Ulashish menyusi (LocalSend orqali) |
| `Super + Ctrl + C` | Suratga olish boshqaruvlari (skrinshot/yozib olish/tanlagich) |
| `Super + Ctrl + O` | Menyuni almashtirish |
| `Super + Ctrl + H` | Uskuna menyusi |
| `Super + Ctrl + E` | Emoji tanlagich |
| `Super + Ctrl + .` | Mediani transkodlash |
| `Super + Shift + Ctrl + A` | AI agentni tanlash |

## Sozlashlar

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Ekran yorqinligining maksimumi |
| `Shift + Brightness Down` | Ekran yorqinligining minimumi |
| `Alt + Brightness Up/Down` | Aniq 1% yorqinlik o‘zgarishlari |
| `Alt + Volume Up/Down` | Aniq 1% ovoz balandligi o‘zgarishlari |
| `Keyboard Brightness Up/Down` | Klaviatura yoritgichi yorqinroq/xiraroq |
| `Keyboard Backlight` | Klaviatura yoritgichi darajalari bo‘ylab aylanish |
| `Alt + Play` | Keyingi trek |
| `Alt + Shift + Play` | Oldingi trek |

## Ilovalarni ishga tushirish

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux terminali |
| `Super + Ctrl + Return` | Herdr (agentlar menejeri) |
| `Super + Shift + Return`           | Brauzer    |
| `Super + Shift + Alt + B`           | Brauzer (xususiy/inkognito)    |
| `Super + Shift + F`           | Fayl menejeri    |
| `Super + Shift + Alt + F`           | Terminalning cwd dagi fayl menejeri    |
| `Super + Shift + M`           | Musiqa (Spotify)    |
| `Super + Shift + Alt + M`           | Musiqa (cliamp)    |
| `Super + Shift + /`           | Parollar menejeri (1password)    |
| `Super + Shift + Q`           | Kalkulyator (Omacalc)    |
| `Super + Shift + T`           | Faollik (btop)    |
| `Super + Shift + N`           | Muharrir (Neovim)  |
| `Super + Shift + C`           | Kalendar ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Elektron pochta ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Yangi elektron pochta ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Xabar almashish (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Xabar almashish (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Xabar almashish (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Yozish (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Bog‘lamlarni `~/.config/hypr/bindings.lua` da o‘zgartiring/qo‘shing.

## Universal almashuv buferi

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + A`           | `Ctrl + A` ni qo‘llab-quvvatlaydigan ilovalarda hammasini tanlash    |
| `Super + C`           | Nusxalash    |
| `Super + X`           | Kesish (terminalda emas)    |
| `Super + V`           | Joylashtirish    |
| `Super + Ctrl + V`           | Almashuv buferi menejeri    |

Odatda Linux da terminalda nusxalash/joylashtirish uchun `Ctrl + Shift + C/V`, boshqa hamma joyda esa `Ctrl + C/V` kerak bo‘ladi. Ushbu Omarchy birlashtirilgan almashuv buferi tezkor tugmalari hamma joyda ishlaydi.

## Suratga olish

| Tezkor tugma              | Vazifasi                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Skrinshot                      |
| `Super + Ctrl + Alt + C`            | Skrinshot (Print Screen tugmasi yo‘q klaviaturalar uchun xuddi shu surat) |
| `Super + Ctrl + C` | Suratga olish menyusi |
| `Alt + Print Screen`            | Ekranni yozib olish                     |
| `Super + Print Screen` | Rang tanlagich |
| `Super + Ctrl + Print Screen` | Matnni almashuv buferiga chiqarib olish |
| `Super + Alt + [` | Yozib olish paytida veb-kamera ustki qatlamini kichiklashtirish |
| `Super + Alt + ]` | Yozib olish paytida veb-kamera ustki qatlamini kattalashtirish |
| `Alt + Shift + L` | Veb-ilova yoki Chromium dan joriy URL ni nusxalash |
| `Alt + Shift + D` | Joriy sahifadagi videoni `~/Videos` ga yuklab olish |
| `Alt + Space` | Diktovkani boshlash/to‘xtatish (_Sozlash > Standartlar > Diktovka_ talab qilinadi) |
| `Right Alt` | Diktovka qilish uchun bosib turish (_Sozlash > Standartlar > Diktovka_ talab qilinadi) |

Ekranni yozib olishda tezkor tugma avval qaysi audioni xohlashingizni so‘raydi, keyin yozishni boshlaydi. To‘xtatish uchun uni yana bosing. Tafsilotlar uchun [skrinshotlar va yozib olish](12-screenshots-recording.md) ga qarang.

Barcha suratga olish variantlariga Omarchy menyusida (`Super + Space`) _Trigger > Capture_ ostida ham kirish mumkin.

## Bildirishnomalar

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + ,` | Eng so‘nggi bildirishnoma ustida amal bajarish: uni ochish yoki uning yagona tugmasini bosish, uning variantlaridan tanlash, yoki varianti bo‘lmasa uni bekor qilish  |
| `Super + Shift + ,` | Barcha bildirishnomalarni bekor qilish |
| `Super + Ctrl + ,` | Bildirishnomalarni klaviatura bilan boshqarish  |
| `Super + Alt + ,` | Eng so‘nggi bildirishnomani bekor qilish  |
| `Super + Shift + Alt + ,` | Bildirishnomalar tarixini ochish  |
| `Super + Ctrl + Alt + ,` | Bildirishnomalarni sukutga olishni almashtirish  |

## Uslub

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Yangi mavzuni tanlash (shuningdek `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Mavzu fonini tanlash (shuningdek `Super + Ctrl + Space`) |
| `Super + Backspace` | Oynadagi shaffoflikni almashtirish |
| `Super + Ctrl + Backspace` | Bitta oyna uchun kvadrat nisbatni almashtirish |

Qo‘shimcha fon rasmlari `~/.config/omarchy/backgrounds/<theme name>` da joylashgan. Omarchy menyusida _O‘rnatish > Uslub > Fon_ orqali ham mavjud.

Barcha uslub variantlariga Omarchy menyusida (`Super + Space`) _Uslub_ ostida ham kirish mumkin.

## Almashtirgichlar

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Harakatsizlikda qulflashni almashtirish |
| `Super + Ctrl + Delete` | Noutbuk displeyini yoqish/o‘chirishni almashtirish |
| `Super + Ctrl + Alt + Delete` | Noutbuk displeyini aks ettirishni almashtirish |
| `Super + Shift + Space` | Yuqori panelni almashtirish  |
| `Shift + Mute` | Keyingi audio chiqishiga o‘tish |
| `Shift + Play` | Keyingi media manbasiga o‘tish |
| `Super + Shift + Backspace` | Oyna bo‘shliqlarini almashtirish |
| `Super + Ctrl + Alt + F` | To‘liq ekran ish stolini almashtirish (yuqori panel + oyna bo‘shliqlari) |

## Eslatmalar

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Eslatma o‘rnatish  |
| `Super + Ctrl + Alt + R` | Barcha eslatmalarni ko‘rish  |
| `Super + Ctrl + Shift + R` | Barcha eslatmalarni tozalash  |

## Xabarnomalar

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Vaqtni bildirishnoma sifatida ko‘rsatish  |
| `Super + Ctrl + Alt + B` | Batareyani bildirishnoma sifatida ko‘rsatish  |
| `Super + Ctrl + Alt + W` | Ob-havoni bildirishnoma sifatida almashtirish  |

## Tmux

Prefiks tugmasi `Ctrl + Space` (`Ctrl + B` ham ishlaydi). Ushbu bog‘lamlarni `~/.config/tmux/tmux.conf` da o‘zgartirishingiz mumkin.

### Panellar

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Prefix + v` | Panelni yoniga bo‘lish (vertikal) |
| `Prefix + h` | Panelni pastiga bo‘lish (gorizontal) |
| `Prefix + x` | Panelni tugatish |
| `Prefix + z` | Panel zoomini almashtirish (to‘liq ekran) |
| `Alt + Enter` | Panelni pastiga bo‘lish (prefikssiz) |
| `Alt + Shift + Enter` | Panelni yoniga bo‘lish (prefikssiz) |
| `Alt + Escape` | Panelni tugatish (prefikssiz) |
| `Ctrl + Alt + Arrows` | Panellar o‘rtasida harakatlanish |
| `Ctrl + Alt + Shift + Arrows` | Panellar o‘lchamini o‘zgartirish |

### Oynalar

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Prefix + c` | Yangi oyna |
| `Prefix + k` | Oynani tugatish |
| `Prefix + r` | Oyna nomini o‘zgartirish |
| `Alt + 1-9` | Ma’lum oynaga o‘tish |
| `Alt + Arrow Left/Right` | Oynalar o‘rtasida harakatlanish |
| `Alt + Shift + Arrow Left/Right` | Oynani chapga/o‘ngga ko‘chirish |

### Sessiyalar

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Prefix + C` | Yangi sessiya |
| `Prefix + K` | Sessiyani tugatish |
| `Prefix + R` | Sessiya nomini o‘zgartirish |
| `Prefix + N` | Keyingi sessiya |
| `Prefix + P` | Oldingi sessiya |
| `Alt + Arrow Up/Down` | Sessiyalar o‘rtasida harakatlanish |
| `Prefix + s` | Sessiyalarni ro‘yxatlash |
| `Prefix + d` | Sessiyadan uzilish |

### Nusxalash rejimi (vi uslubida)

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Prefix + [` | Nusxalash rejimiga kirish |
| `v` | Tanlashni boshlash (nusxalash rejimida) |
| `y` | Tanlanganini nusxalash (nusxalash rejimida) |

### Umumiy

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Prefix + q` | Konfiguratsiyani qayta yuklash |
| `Prefix + ?` | Tmux tugma bog‘lamlarini ko‘rsatish |
| `Prefix + :` | Buyruq satri |

### Tmux tartib funksiyalari

Ushbu funksiyalar Tmux sessiyasi ichida bajarilishi kerak.

| Buyruq | Vazifasi |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Muharrir, AI va terminal bilan dasturlash tartibini yaratish |
| `tdlm <ai> [<second_ai>]` | Har bir pastki katalog uchun dasturlash tartibini yaratish |
| `tsl <count> <command>` | Ko‘p panelli swarm tartibini yaratish |

## Ghostty Terminali

Ghostty terminali Omarchy menyusi orqali _O‘rnatish > Terminal_ yordamida o‘rnatiladi.

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Pastga yangi bo‘linish |
| `Ctrl + Shift + O` | Yoniga yangi bo‘linish |
| `Ctrl + Alt + Arrows` | Bo‘linishlar o‘rtasida harakatlanish |
| `Super + Ctrl + Shift + Arrows` | Bo‘linish o‘lchamini 10 qatorga o‘zgartirish |
| `Super + Ctrl + Shift + Alt + Arrows` | Bo‘linish o‘lchamini 100 qatorga o‘zgartirish |
| `Ctrl + Shift + T` | Yangi varaq  |
| `Ctrl + Shift + Arrows` | Varaqlar o‘rtasida harakatlanish |
| `Alt + Numbers` | Ma’lum varaqqa o‘tish |
| `Shift + Pg Up/Down` | Tarixni aylantirish |
| `Ctrl + Left mouse` | Havolani brauzerda ochish |

## Fayl menejeri

| Tezkor tugma              | Vazifasi                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Yo‘lga o‘tish                     |
| `Space`               | Faylni oldindan ko‘rish (o‘qlar navigatsiya qiladi) |
| `Alt + Up`       | Yuqoridagi ota katalogga o‘tish        |

## Neovim (lazyvim bilan)

### Navigatsiya

| Tezkor tugma                   | Vazifasi                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Buyruq variantlarini ko‘rsatish            |
| `Space Space`              | Faylni noaniq qidiruv orqali ochish      |
| `Space E`                  | Yon panelni almashtirish                  |
| `Space G G`                | git boshqaruvlarini ko‘rsatish               |
| `Space S G`                | Fayl mazmunini qidirish             |
| `Ctrl + W W`               | Yon panel va muharrir o‘rtasida o‘tish |
| `Ctrl + Left/right arrow`  | Yon panel o‘lchamini o‘zgartirish          |
| `Shift + H`                      | Chapdagi fayl varag‘iga o‘tish             |
| `Shift + L`                      | O‘ngdagi fayl varag‘iga o‘tish            |
| `Space B D`                | Fayl varag‘ini yopish                  |

### Yon panelda bo‘lganda

| Tezkor tugma                   | Vazifasi                        |
| ------------------------ | ------------------------------- |
| `A`                        | Ota katalogda yangi fayl qo‘shish      |
| `Shift + A`                | Ota katalogda yangi pastki katalog qo‘shish    |
| `D`                        | Belgilangan fayl/katalogni o‘chirish     |
| `M`                        | Belgilangan fayl/katalogni ko‘chirish       |
| `R`                        | Belgilangan fayl/katalog nomini o‘zgartirish     |
| `?`                        | Barcha buyruqlar uchun yordamni ko‘rsatish      |

[LazyVim tomonidan sozlangan barcha Neovim tezkor tugmalarini ko‘ring](https://www.lazyvim.org/keymaps).

## Tezkor emojilar

To‘liq emoji tanlagichni ko‘rsatish uchun `Super + Ctrl + E` dan foydalanishingiz mumkin, u tanlanganini almashuv buferiga joylashtiradi, yoki ushbu tezkor kirish variantlaridan foydalanishingiz mumkin.

| Tezkor tugma       | EM | Ishora       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | tabassum      |
| `Shift + CapsLock M C` | 😂 | yig‘lash        |
| `Shift + CapsLock M L` | 😍 | sevgi       |
| `Shift + CapsLock M V` | ✌️ | g‘alaba    |
| `Shift + CapsLock M H` | ❤️ | yurak      |
| `Shift + CapsLock M Y` | 👍 | ha        |
| `Shift + CapsLock M N` | 👎 | yo‘q         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | istak       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | o‘pich       |
| `Shift + CapsLock M E` | 🙄 | ko‘z aylantirish    |
| `Shift + CapsLock M I` | 😉 | ko‘z qisish       |
| `Shift + CapsLock M P` | 🙏 | duo |
| `Shift + CapsLock M D` | 🤤 | so‘lak oqishi      |
| `Shift + CapsLock M M` | 💰 | pul      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | tost      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | salomlashish |
| `Shift + CapsLock M A` |💪 | qo‘l |
| `Shift + CapsLock M B` |🤯 | portlash |

## Tezkor to‘ldirishlar

| Tezkor tugma       | To‘ldirish       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Ismingiz (sozlashda kiritilganidek)  |
| `Shift + CapsLock Space E` | Elektron pochtangiz (sozlashda kiritilganidek)  |

`~/.XCompose` ni tahrirlash orqali o‘zingiznikidan ko‘proq qo‘shishingiz mumkin, keyin o‘zgarishlar kuchga kirishi uchun terminalda `omarchy-restart-xcompose` ni bajaring.
