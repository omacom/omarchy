# Tezkor tugmalar

Siz barcha asosiy klaviatura bog‘lamalarini `Super + K` bilan ko‘rishingiz mumkin (Tmux bog‘lamalari `Super + Alt + K` bilan va Herdr bog‘lamalari `Super + Ctrl + K` bilan).

## Tezkor tugmalar qanday joylashgan

Har bir tezkor tugma o‘z modifikatorlari bilan belgilanadigan tekislikda joylashgan va har bir tekislikning bitta vazifasi bor. Tezkor tugmalar bir-biriga aralashib ketmasligini shu ta’minlaydi va bu odatda nimaning qayerda joylashganini taxmin qila olishingizni anglatadi.

| Tekislik | U yerda nimalar joylashgan | Misollar |
| --- | --- | --- |
| `Super + key` | Tizim: oynalar, ish maydonlari, tartiblar va asosiy menyular | `Super + Space` Omarchy menyusi, `Super + W` oynani yopish, `Super + F` to‘liq ekran |
| `Super + Shift + key` | Ilovalar | `Super + Shift + B` brauzer, `Super + Shift + E` elektron pochta, `Super + Shift + N` muharrir |
| `Super + Ctrl + key` | Panellar va tizim menyulari | `Super + Ctrl + A` audio, `Super + Ctrl + N` tarmoq, `Super + Ctrl + C` tasvirga olish menyusi |
| `Super + Ctrl + Alt + key` | Tezkor amallar va xabarlar | `Super + Ctrl + Alt + T` vaqtni ko‘rsatish, `Super + Ctrl + Alt + B` batareya, `Super + Ctrl + Alt + C` skrinshot |

Tezkor tugmaga `Alt` qo‘shish sizga xuddi shu narsaning variantini beradi, hech qachon aloqasiz narsani emas:

- `Super + Shift + B` brauzerni ochadi; `Super + Shift + Alt + B` maxfiy oynani ochadi
- `Super + Shift + E` elektron pochtani ochadi; `Super + Shift + Alt + E` yangisini boshlaydi
- `Super + F` to‘liq ekranga o‘tadi; `Super + Alt + F` to‘liq kenglikka o‘tadi
- `Super + Ctrl + C` tasvirga olish menyusini ochadi; `Super + Ctrl + Alt + C` menyuni o‘tkazib yuboradi va skrinshot oladi

Tezkor tugma qo‘shayotganda:

1. U nima qilishiga qarab tekislikni tanlang, keyin tugmani tanlang.
2. O‘rin bo‘shatish uchun mavjud tezkor tugmani ko‘chirmang. To‘g‘ri tekislikda bo‘sh tugmani toping.
3. `Alt` dan faqat usiz variant uchungina foydalaning.

Bir nechta tezkor tugmalar qulay bo‘lgani uchun bu qoidalarni buzadi. Strelka yoki `Tab` bilan `Shift` ilovani ochish o‘rniga ko‘chiradi yoki teskari yo‘nalishda harakatlanadi, `Print`, media tugmalari, `Alt + Tab` va `Ctrl + Alt + Del` esa hamma joyda qanday bo‘lsa, shunday ishlaydi. Bular istisnolar, nusxa olish uchun naqshlar emas.

Agar standart variant sizga mos kelmasa (aytalik, Windows dagi kabi skrinshotlar uchun `Super + Shift + S` ni istaysiz), uni `~/.config/hypr/bindings.lua` da qayta bog‘lang.

## Navigatsiya

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menyusi (ilovalar va boshqa hamma narsa)    |
| `Super + Alt + Space` | Ilovalar panjarasi |
| `Super + Escape` | Tizim menyusi (kutish rejimi, qayta ishga tushirish va boshqalar)  |
| `Super + Ctrl + L` | Kompyuterni qulflash |
| `Super + W` yoki `Super + Q` | Oynani yopish             |
| `Ctrl + Alt + Del` | Barcha oynalarni yopish |
| `Super + T`               | Oynani plitka tartibi/suzuvchi rejim o‘rtasida almashtirish             |
| `Super + J` | Oyna holatini almashtirish (gorizontal/vertikal) |
| `Super + O`               | Oynani sticky'n'floating rejimiga chiqarishni almashtirish |
| `Super + L`               | dwindle, scrolling va floating tartiblari bo‘ylab aylanish |
| `Super + Alt + L`         | Tartiblar bo‘ylab teskari aylanish |
| `Super + P`               | Pseudo oyna uslubini almashtirish (tabiiy va cho‘zilgan) |
| `Super + F`                 | To‘liq ekranga o‘tish              |
| `Super + Alt + F`                 | To‘liq kenglikka o‘tish              |
| `Super + Ctrl + F`                 | Oyna ichida to‘liq ekranga o‘tish              |
| `Super + 1/2/3/4`         | Fokuslangan monitordagi ma’lum ish maydoniga o‘tish |
| `Super + Tab` | Fokuslangan monitordagi keyingi ish maydoniga o‘tish |
| `Super + Shift + Tab` | Fokuslangan monitordagi oldingi ish maydoniga o‘tish |
| `Super + Ctrl + Tab` | Fokuslangan monitordagi avvalgi ish maydoniga o‘tish |
| `Super + Shift + 1/2/3/4` | Oynani fokuslangan monitordagi ish maydoniga ko‘chirish |
| `Super + Shift + Alt + 1/2/3/4` | Oynani fokuslangan monitordagi ish maydoniga ortidan o‘tmasdan ko‘chirish |
| `Super + S` | To‘liq scratchpad ni almashtirish |
| `Super + Alt + S` | Oynani to‘liq scratchpad ga ko‘chirish |
| `Super + Grave` | Quake konsolini almashtirish |
| `Super + Shift + Grave` | Oynani Quake konsoliga ko‘chirish |
| `Super + Shift + Ctrl + Arrows` | Oynani shu yo‘nalishdagi monitorga ko‘chirish |
| `Super + Shift + Alt + Arrows` | Ish maydonini shu yo‘nalishdagi monitorga ko‘chirish |
| `Super + Arrow`  | Fokusni strelka yo‘nalishidagi oynaga ko‘chirish, ekran chetida shu tomondagi monitorga o‘tish bilan |
| `Super + Shift + Arrow`  | Oynani strelka yo‘nalishidagi boshqasi bilan almashtirish, shu tomondagi monitordagi oynani ham qo‘shib |
| `Super + Minus` | Oynani chapga kengaytirish |
| `Super + Equal` | Oynani chapdan qisqartirish |
| `Super + Shift + Minus` | Oynani yuqoridan qisqartirish |
| `Super + Shift + Equal` | Oynani pastga kengaytirish |
| `Super + Alt + Minus/Equal` | Xuddi shu o‘lcham o‘zgartirish kichikroq qadamlar bilan |
| `Super + Ctrl + Minus/Equal` | Xuddi shu o‘lcham o‘zgartirish kattaroq qadamlar bilan |
| `Super + Alt + Home` | Oyna kengligini saqlash |
| `Super + Home` | Saqlangan oyna kengligini tiklash |
| `Super + Left Mouse` | Oynani sudrab yurish |
| `Super + Right Mouse` | Oyna o‘lchamini o‘zgartirish |
| `Super + Scroll Wheel` | Fokuslangan monitordagi ish maydonlarini aylantirish |
| `Super + G`               | Oynalarni guruhlashni almashtirish      |
| `Super + Alt + G`               | Oynani guruhdan chiqarish      |
| `Super + Alt + Tab`               | Guruh ichidagi oynalar bo‘ylab aylanish      |
| `Super + Alt + Shift + Tab`               | Guruh ichidagi oynalar bo‘ylab orqaga aylanish      |
| `Super + Alt + Scroll Wheel` | Guruh ichidagi oynalar bo‘ylab aylanish |
| `Super + Alt + 1/2/3/4/5`               | Guruhdagi ma’lum oynaga o‘tish      |
| `Super + Alt + Arrow`  | Oynani strelka yo‘nalishida guruhga ko‘chirish, shu tomondagi monitordagi oynani ham qo‘shib |
| `Super + Ctrl + Left/Right`  | Plitka guruhi ichidagi oynalar o‘rtasida harakatlanish |
| `Super + Ctrl + Z` | Ekranni yaqinlashtirish (ko‘proq yaqinlashtirish uchun takrorlang) |
| `Super + Ctrl + Alt + Z` | Ekrandan to‘liq uzoqlashish |
| `Super + /` | Monitor masshtabi variantlari bo‘ylab oldinga qadam tashlash |
| `Super + Alt + /` | Monitor masshtabi variantlari bo‘ylab orqaga qadam tashlash |
| `Alt + Tab` | Faol ish maydonidagi oynalar bo‘ylab oldinga aylanish |
| `Alt + Shift + Tab` | Faol ish maydonidagi oynalar bo‘ylab orqaga aylanish |
| `Ctrl + Alt + Tab`| Monitorlar bo‘ylab fokusni oldinga aylantirish |
| `Ctrl + Alt + Shift + Tab`| Monitorlar bo‘ylab fokusni orqaga aylantirish |

O‘lcham o‘zgartirish yorliqlari klaviaturada bosilgan belgilardan qat’i nazar, `code:20` va `code:21` jismoniy tugmalaridan (XKB `<AE11>` va `<AE12>`) foydalanadi. AQSh klaviaturalarida bu tugmalar `-` va `=`; yapon (JIS) klaviaturalarida ular `-` va `^`; ispan klaviaturalarida ular `'` va `¡`. JIS da `Super + ^` — bu `Super + Equal`, `Super + Shift + -` esa (`=` ni yozadi) `Super + Shift + Minus` dir.

## Tizim boshqaruvi

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Audio paneli    |
| `Super + Ctrl + B`           | Bluetooth paneli    |
| `Super + Ctrl + N`           | Wi-Fi/tarmoq paneli    |
| `Super + Ctrl + D`           | Displey paneli    |
| `Super + Ctrl + P`           | Quvvat paneli    |
| `Super + Ctrl + X`           | Agentlar paneli    |
| `Super + Ctrl + Alt + D`           | Kalendar paneli    |
| `Super + Ctrl + Alt + E`           | Jahon soati paneli    |
| `Super + Ctrl + 1-9`           | Panelni holati bo‘yicha almashtirish    |
| `Super + Ctrl + S` | Ulashish menyusi (LocalSend orqali) |
| `Super + Ctrl + C` | Tasvirga olish boshqaruvi (skrinshot/-yozib olish/tanlagich) |
| `Super + Ctrl + O` | Menyuni almashtirish |
| `Super + Ctrl + H` | Qurilmalar menyusi |
| `Super + Ctrl + E` | Emoji tanlagich |
| `Super + Ctrl + .` | Mediani transkodlash |
| `Super + Shift + Ctrl + A` | AI agentni tanlash |

## Sozlashlar

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Ekran yorqinligining maksimal darajasi |
| `Shift + Brightness Down` | Ekran yorqinligining minimal darajasi |
| `Alt + Brightness Up/Down` | Aniq 1% yorqinlik o‘zgarishlari |
| `Alt + Volume Up/Down` | Aniq 1% ovoz o‘zgarishlari |
| `Keyboard Brightness Up/Down` | Klaviatura yoritgichi yorqinroq/xiraroq |
| `Keyboard Backlight` | Klaviatura yoritgichi darajalarini aylanish |
| `Alt + Play` | Keyingi trek |
| `Alt + Shift + Play` | Oldingi trek |

## Ilovalarni ishga tushirish

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux terminali |
| `Super + Ctrl + Return` | Herdr (agentlar menejeri) |
| `Super + Shift + Return`           | Brauzer    |
| `Super + Shift + Alt + B`           | Brauzer (maxfiy/inkognito)    |
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

Bog‘lamalarni `~/.config/hypr/bindings.lua` da o‘zgartiring/qo‘shing.

## Universal almashuv buferi

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + A`           | `Ctrl + A` ni qo‘llab-quvvatlaydigan ilovalarda hammasini tanlash    |
| `Super + C`           | Nusxalash    |
| `Super + X`           | Kesish (terminalda emas)    |
| `Super + V`           | Joylashtirish    |
| `Super + Ctrl + V`           | Almashuv buferi menejeri    |

Odatda Linux da terminalda nusxalash va joylashtirish uchun `Ctrl + Shift + C/V`, boshqa hamma joyda esa `Ctrl + C/V` kerak bo‘ladi. Ushbu Omarchy birlashtirilgan almashuv buferi tezkor tugmalari hamma joyda ishlaydi.

## Tasvirga olish

| Tezkor tugma              | Funksiya                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Skrinshot                      |
| `Super + Ctrl + Alt + C`            | Skrinshot (o‘sha tasvir, Print Screen tugmasi yo‘q klaviaturalar uchun) |
| `Super + Ctrl + C` | Tasvirga olish menyusi |
| `Alt + Print Screen`            | Ekranni yozib olish                     |
| `Super + Shift + Ctrl + Alt + C` | Audiosiz ekranni yozib olish, menyuni o‘tkazib yuborib (to‘xtatish uchun yana bosing) |
| `Super + Print Screen` | Rang tanlagich |
| `Super + Ctrl + Print Screen` | Matnni almashuv buferiga chiqarib olish |
| `Super + Alt + [` | Yozib olish vaqtida veb-kamera qoplamasini kichraytirish |
| `Super + Alt + ]` | Yozib olish vaqtida veb-kamera qoplamasini kattalashtirish |
| `Alt + Shift + L` | Veb-ilova yoki brauzerdan joriy URL ni nusxalash |
| `Alt + Shift + D` | Joriy sahifadagi videoni `~/Videos` ga yuklab olish |
| `Alt + Space` | Diktovkani boshlash/to‘xtatish (_Setup > Defaults > Dictation_ talab qilinadi) |
| `Right Alt` | Diktovka qilish uchun bosib turish (_Setup > Defaults > Dictation_ talab qilinadi) |

Ekranni yozib olishda tezkor tugma avval qaysi audioni istashingizni so‘raydi, keyin yozishni boshlaydi. To‘xtatish uchun uni yana bosing. Batafsil ma’lumot uchun [skrinshotlar va yozib olish](12-screenshots-recording.md) ga qarang.

Tasvirga olishning barcha variantlari Omarchy menyusidagi (`Super + Space`) _Trigger > Capture_ ostida ham mavjud.

## Bildirishnomalar

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + ,` | Eng so‘nggi bildirishnoma ustida amal bajarish: uni ochish yoki uning yagona tugmasini bosish, uning variantlaridan tanlash yoki hech biri bo‘lmasa uni yopish  |
| `Super + Shift + ,` | Barcha bildirishnomalarni yopish |
| `Super + Ctrl + ,` | Bildirishnomalarni klaviatura bilan boshqarish  |
| `Super + Alt + ,` | Eng so‘nggi bildirishnomani yopish  |
| `Super + Shift + Alt + ,` | Bildirishnomalar tarixini ochish  |
| `Super + Ctrl + Alt + ,` | Bildirishnomalarni ovozsiz qilishni almashtirish  |

## Uslub

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Yangi mavzuni tanlash (shuningdek `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Mavzu fonini tanlash (shuningdek `Super + Ctrl + Space`) |
| `Super + Backspace` | Oynadagi shaffoflikni almashtirish |
| `Super + Ctrl + Backspace` | Bitta oyna uchun kvadrat nisbatni almashtirish |

Qo‘shimcha fon rasmlari `~/.config/omarchy/backgrounds/<theme name>` da joylashgan. Omarchy menyusidagi _Install > Style > Background_ orqali ham mavjud.

Uslubning barcha variantlari Omarchy menyusidagi (`Super + Space`) _Style_ ostida ham mavjud.

## Almashtirgichlar

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Bo‘sh vaqtda qulflashni almashtirish |
| `Super + Ctrl + Delete` | Noutbuk displeyini yoqish/o‘chirishni almashtirish |
| `Super + Ctrl + Alt + Delete` | Noutbuk displeyini aks ettirishni almashtirish |
| `Super + Shift + Space` | Yuqori panelni almashtirish  |
| `Shift + Mute` | Keyingi audio chiqishiga o‘tish |
| `Shift + Play` | Keyingi media manbasiga o‘tish |
| `Super + Shift + Backspace` | Oyna bo‘shliqlarini almashtirish |
| `Super + Ctrl + Alt + F` | To‘liq ekran ish stolini almashtirish (yuqori panel + oyna bo‘shliqlari) |

## Eslatmalar

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Eslatma o‘rnatish  |
| `Super + Ctrl + Alt + R` | Barcha eslatmalarni ko‘rish  |
| `Super + Ctrl + Shift + R` | Barcha eslatmalarni tozalash  |

## Xabarlar

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Vaqtni bildirishnoma sifatida ko‘rsatish  |
| `Super + Ctrl + Alt + B` | Batareyani bildirishnoma sifatida ko‘rsatish  |
| `Super + Ctrl + Alt + W` | Ob-havoni bildirishnoma sifatida ko‘rsatishni almashtirish  |

## Tmux

Prefiks tugmasi `Ctrl + Space` (`Ctrl + B` ham ishlaydi). Ushbu bog‘lamalarni `~/.config/tmux/tmux.conf` da o‘zgartirishingiz mumkin.

### Panellar

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Prefix + v` | Panelni yoniga bo‘lish (vertikal) |
| `Prefix + h` | Panelni pastga bo‘lish (gorizontal) |
| `Prefix + x` | Panelni yopish |
| `Prefix + z` | Panelni kattalashtirishni almashtirish (to‘liq ekran) |
| `Alt + Enter` | Panelni pastga bo‘lish (prefikssiz) |
| `Alt + Shift + Enter` | Panelni yoniga bo‘lish (prefikssiz) |
| `Alt + Escape` | Panelni yopish (prefikssiz) |
| `Ctrl + Alt + Arrows` | Panellar o‘rtasida harakatlanish |
| `Ctrl + Alt + Shift + Arrows` | Panellar o‘lchamini o‘zgartirish |

### Oynalar

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Prefix + c` | Yangi oyna |
| `Prefix + k` | Oynani yopish |
| `Prefix + r` | Oyna nomini o‘zgartirish |
| `Alt + 1-9` | Ma’lum oynaga o‘tish |
| `Alt + Arrow Left/Right` | Oynalar o‘rtasida harakatlanish |
| `Alt + Shift + Arrow Left/Right` | Oynani chapga/o‘ngga ko‘chirish |

### Sessiyalar

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Prefix + C` | Yangi sessiya |
| `Prefix + K` | Sessiyani yopish |
| `Prefix + R` | Sessiya nomini o‘zgartirish |
| `Prefix + N` | Keyingi sessiya |
| `Prefix + P` | Oldingi sessiya |
| `Alt + Arrow Up/Down` | Sessiyalar o‘rtasida harakatlanish |
| `Prefix + s` | Sessiyalar ro‘yxati |
| `Prefix + d` | Sessiyadan uzilish |

### Nusxalash rejimi (vi uslubida)

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Prefix + [` | Nusxalash rejimiga kirish |
| `v` | Tanlashni boshlash (nusxalash rejimida) |
| `y` | Tanlovni nusxalash (nusxalash rejimida) |

### Umumiy

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Prefix + q` | Konfiguratsiyani qayta yuklash |
| `Prefix + ?` | Tmux tugmalar bog‘lamalarini ko‘rsatish |
| `Prefix + :` | Buyruq satri |

### Tmux tartib funksiyalari

Ushbu funksiyalar Tmux sessiyasi ichida ishga tushirilishi kerak.

| Buyruq | Funksiya |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Muharrir, AI va terminal bilan ishlab chiqish tartibini yaratish |
| `tdlm <ai> [<second_ai>]` | Har bir ichki katalog uchun ishlab chiqish tartibini yaratish |
| `tsl <count> <command>` | Ko‘p panelli swarm tartibini yaratish |

## Ghostty Terminal

Ghostty terminali Omarchy menyusi orqali _Install > Terminal_ yordamida o‘rnatiladi.

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Pastga yangi bo‘linish |
| `Ctrl + Shift + O` | Yoniga yangi bo‘linish |
| `Ctrl + Alt + Arrows` | Bo‘linishlar o‘rtasida harakatlanish |
| `Super + Ctrl + Shift + Arrows` | Bo‘linish o‘lchamini 10 satrga o‘zgartirish |
| `Super + Ctrl + Shift + Alt + Arrows` | Bo‘linish o‘lchamini 100 satrga o‘zgartirish |
| `Ctrl + Shift + T` | Yangi yorliq  |
| `Ctrl + Shift + Arrows` | Yorliqlar o‘rtasida harakatlanish |
| `Alt + Numbers` | Ma’lum yorliqqa o‘tish |
| `Shift + Pg Up/Down` | Tarixni aylantirish |
| `Ctrl + Left mouse` | Havolani brauzerda ochish |

## Fayl menejeri

| Tezkor tugma              | Funksiya                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Yo‘lga o‘tish                     |
| `Space`               | Faylni oldindan ko‘rish (strelkalar navigatsiya qiladi) |
| `Alt + Up`       | Yuqoridagi ota katalogga o‘tish        |

## Neovim (lazyvim bilan)

### Navigatsiya

| Tezkor tugma                   | Funksiya                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Buyruq variantlarini ko‘rsatish            |
| `Space Space`              | Faylni noaniq qidiruv orqali ochish      |
| `Space E`                  | Yon panelni almashtirish                  |
| `Space G G`                | git boshqaruvini ko‘rsatish               |
| `Space S G`                | Fayl mazmunini qidirish             |
| `Ctrl + W W`               | Yon panel va muharrir o‘rtasida o‘tish |
| `Ctrl + Left/right arrow`  | Yon panel o‘lchamini o‘zgartirish          |
| `Shift + H`                      | Chap fayl yorlig‘iga o‘tish             |
| `Shift + L`                      | O‘ng fayl yorlig‘iga o‘tish            |
| `Space B D`                | Fayl yorlig‘ini yopish                  |

### Yon panelda bo‘lganda

| Tezkor tugma                   | Funksiya                        |
| ------------------------ | ------------------------------- |
| `A`                        | Ota katalogda yangi fayl qo‘shish      |
| `Shift + A`                | Ota katalogda yangi ichki katalog qo‘shish    |
| `D`                        | Belgilangan fayl/katalogni o‘chirish     |
| `M`                        | Belgilangan fayl/katalogni ko‘chirish       |
| `R`                        | Belgilangan fayl/katalog nomini o‘zgartirish     |
| `?`                        | Barcha buyruqlar uchun yordamni ko‘rsatish      |

[LazyVim tomonidan sozlangan barcha Neovim tezkor tugmalarini ko‘ring](https://www.lazyvim.org/keymaps).

## Tezkor emojilar

To‘liq emoji tanlagichni ko‘rsatish uchun `Super + Ctrl + E` dan foydalanishingiz mumkin, u tanlovni almashuv buferiga joylashtiradi, yoki ushbu tezkor kirish variantlaridan foydalanishingiz mumkin.

| Tezkor tugma       | EM | Ishora       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | tabassum      |
| `Shift + CapsLock M C` | 😂 | yig‘lash        |
| `Shift + CapsLock M L` | 😍 | muhabbat       |
| `Shift + CapsLock M V` | ✌️ | g‘alaba    |
| `Shift + CapsLock M H` | ❤️ | yurak      |
| `Shift + CapsLock M Y` | 👍 | ha        |
| `Shift + CapsLock M N` | 👎 | yo‘q         |
| `Shift + CapsLock M F` | 🖕 | so‘kinish       |
| `Shift + CapsLock M W` | 🤞 | tilak       |
| `Shift + CapsLock M R` | 🤘 | rok       |
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
| `Shift + CapsLock Space Space` | — (uzun tire)   |
| `Shift + CapsLock Space N` | Ismingiz (sozlashda kiritilganidek)  |
| `Shift + CapsLock Space E` | Elektron pochtangiz (sozlashda kiritilganidek)  |

`~/.XCompose` ni tahrirlash orqali o‘zingiznikilarni yanada ko‘proq qo‘shishingiz mumkin, keyin o‘zgarishlar qabul qilinishi uchun terminalda `omarchy-restart-xcompose` ni ishga tushiring.
