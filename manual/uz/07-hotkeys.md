# Tezkor tugmalar

Asosiy klaviatura bog‘lanishlarining barchasini `Super + K` bilan ko‘rishingiz mumkin (Tmux bog‘lanishlari `Super + Alt + K` bilan va Herdr bog‘lanishlari `Super + Ctrl + K` bilan).

## Tezkor tugmalar qanday tartibga solingan

Har bir tezkor tugma o‘z modifikatorlari belgilaydigan tekislikda joylashadi va har bir tekislikning bitta vazifasi bor. Tezkor tugmalarning bir-biriga aralashib ketmasligini aynan shu ta’minlaydi va bu odatda nimaning qayerda joylashganini taxmin qila olishingizni anglatadi.

| Tekislik | U yerda nimalar joylashadi | Misollar |
| --- | --- | --- |
| `Super + key` | Tizim: oynalar, ish maydonlari, tartiblar va asosiy menyular | `Super + Space` Omarchy menyusi, `Super + W` oynani yopish, `Super + F` to‘liq ekran |
| `Super + Shift + key` | Ilovalar | `Super + Shift + B` brauzer, `Super + Shift + E` elektron pochta, `Super + Shift + N` muharrir |
| `Super + Ctrl + key` | Panellar va tizim menyulari | `Super + Ctrl + A` audio, `Super + Ctrl + N` tarmoq, `Super + Ctrl + C` suratga olish menyusi |
| `Super + Ctrl + Alt + key` | Tezkor amallar va xabarnomalar | `Super + Ctrl + Alt + T` vaqtni ko‘rsatish, `Super + Ctrl + Alt + B` batareya, `Super + Ctrl + Alt + C` skrinshot |

Tezkor tugmaga `Alt` qo‘shish sizga o‘sha narsaning variantini beradi, hech qachon unga aloqasi yo‘q narsani emas:

- `Super + Shift + B` brauzerni ochadi; `Super + Shift + Alt + B` maxfiy oynani ochadi
- `Super + Shift + E` elektron pochtani ochadi; `Super + Shift + Alt + E` yangisini boshlaydi
- `Super + F` to‘liq ekranga o‘tadi; `Super + Alt + F` to‘liq kenglikka o‘tadi
- `Super + Ctrl + C` suratga olish menyusini ochadi; `Super + Ctrl + Alt + C` menyuni o‘tkazib yuborib, skrinshot oladi

Tezkor tugma qo‘shayotganda:

1. U nima qilishiga qarab tekislikni tanlang, keyin tugmani tanlang.
2. Joy bo‘shatish uchun mavjud tezkor tugmani ko‘chirmang. To‘g‘ri tekislikda bo‘sh tugmani toping.
3. `Alt` dan faqat usiz tezkor tugmaning varianti uchungina foydalaning.

Bir nechta tezkor tugmalar qulay bo‘lgani uchun bu qoidalarni buzadi. O‘q yoki `Tab` bilan `Shift` ilovani ochish o‘rniga ko‘chiradi yoki teskari yo‘nalishda ishlaydi, `Print`, media tugmalari, `Alt + Tab` va `Ctrl + Alt + Del` esa boshqa hamma joydagidek ishlaydi. Ular istisnolar, ko‘chiriladigan naqshlar emas.

Agar standart variant sizga mos kelmasa (aytaylik, Windows dagi kabi skrinshotlar uchun `Super + Shift + S` ni xohlasangiz), uni `~/.config/hypr/bindings.lua` da qayta bog‘lang.

## Navigatsiya

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy menyusi (ilovalar va qolgan hamma narsa) |
| `Super + Alt + Space` | Ilovalar panjarasi |
| `Super + Escape` | Tizim menyusi (kutish, qayta ishga tushirish va h.k.) |
| `Super + Ctrl + L` | Kompyuterni qulflash |
| `Super + W` or `Super + Q` | Oynani yopish |
| `Ctrl + Alt + Del` | Barcha oynalarni yopish |
| `Super + T` | Oynani plitka/suzuvchi rejimlar orasida almashtirish |
| `Super + J` | Oyna holatini almashtirish (gorizontal/vertikal) |
| `Super + O` | Oynani sticky'n'floating holatiga chiqarishni yoqish/o‘chirish |
| `Super + L` | dwindle, scrolling va floating tartiblari orasida aylanish |
| `Super + Alt + L` | Tartiblar orasida teskari tartibda aylanish |
| `Super + P` | Pseudo oyna uslubini almashtirish (tabiiy / cho‘zilgan) |
| `Super + F` | To‘liq ekranga o‘tish |
| `Super + Alt + F` | To‘liq kenglikka o‘tish |
| `Super + Ctrl + F` | Oyna ichida to‘liq ekranga o‘tish |
| `Super + 1/2/3/4` | Fokusdagi monitordagi ma’lum ish maydoniga o‘tish |
| `Super + Tab` | Fokusdagi monitordagi keyingi ish maydoniga o‘tish |
| `Super + Shift + Tab` | Fokusdagi monitordagi oldingi ish maydoniga o‘tish |
| `Super + Ctrl + Tab` | Fokusdagi monitordagi avvalgi ish maydoniga o‘tish |
| `Super + Shift + 1/2/3/4` | Oynani fokusdagi monitordagi ish maydoniga ko‘chirish |
| `Super + Shift + Alt + 1/2/3/4` | Oynani o‘zi ergashmasdan fokusdagi monitordagi ish maydoniga ko‘chirish |
| `Super + S` | To‘liq scratchpad ni yoqish/o‘chirish |
| `Super + Alt + S` | Oynani to‘liq scratchpad ga ko‘chirish |
| `Super + Grave` | Quake konsolini yoqish/o‘chirish |
| `Super + Shift + Grave` | Oynani Quake konsoliga ko‘chirish |
| `Super + Shift + Ctrl + Arrows` | Oynani o‘sha yo‘nalishdagi monitorga ko‘chirish |
| `Super + Shift + Alt + Arrows` | Ish maydonini o‘sha yo‘nalishdagi monitorga ko‘chirish |
| `Super + Arrow` | Fokusni o‘q yo‘nalishidagi oynaga ko‘chirish, ekran chetida o‘sha tomondagi monitorga o‘tish |
| `Super + Shift + Arrow` | Oynani o‘q yo‘nalishidagi boshqa oyna bilan almashtirish, shu jumladan o‘sha tomondagi monitordagi oyna bilan ham |
| `Super + Minus` | Oynani chapga kengaytirish |
| `Super + Equal` | Oynani chapdan qisqartirish |
| `Super + Shift + Minus` | Oynani yuqoridan qisqartirish |
| `Super + Shift + Equal` | Oynani pastga kengaytirish |
| `Super + Alt + Minus/Equal` | Xuddi shu o‘lcham o‘zgartirish, lekin kichikroq qadamlar bilan |
| `Super + Ctrl + Minus/Equal` | Xuddi shu o‘lcham o‘zgartirish, lekin kattaroq qadamlar bilan |
| `Super + Alt + Home` | Oyna kengligini saqlash |
| `Super + Home` | Saqlangan oyna kengligini tiklash |
| `Super + Left Mouse` | Oynani sudrab yurish |
| `Super + Right Mouse` | Oyna o‘lchamini o‘zgartirish |
| `Super + Scroll Wheel` | Fokusdagi monitordagi ish maydonlari orasida aylantirish |
| `Super + G` | Oynalarni guruhlashni yoqish/o‘chirish |
| `Super + Alt + G` | Oynani guruhdan chiqarish |
| `Super + Alt + Tab` | Guruhdagi oynalar orasida aylanish |
| `Super + Alt + Shift + Tab` | Guruhdagi oynalar orasida orqaga aylanish |
| `Super + Alt + Scroll Wheel` | Guruhdagi oynalar orasida aylanish |
| `Super + Alt + 1/2/3/4/5` | Guruhdagi ma’lum oynaga o‘tish |
| `Super + Alt + Arrow` | Oynani o‘q yo‘nalishi bo‘yicha guruhga ko‘chirish, shu jumladan o‘sha tomondagi monitordagi oynani ham |
| `Super + Ctrl + Left/Right` | Plitka guruhi ichidagi oynalar orasida harakatlanish |
| `Super + Ctrl + Z` | Ekranni yaqinlashtirish (ko‘proq yaqinlashtirish uchun takrorlang) |
| `Super + Ctrl + Alt + Z` | Ekrandan to‘liq uzoqlashish |
| `Super + /` | Monitor masshtabi variantlari bo‘yicha oldinga qadam tashlash |
| `Super + Alt + /` | Monitor masshtabi variantlari bo‘yicha orqaga qadam tashlash |
| `Alt + Tab` | Faol ish maydonidagi oynalar orasida oldinga aylanish |
| `Alt + Shift + Tab` | Faol ish maydonidagi oynalar orasida orqaga aylanish |
| `Ctrl + Alt + Tab` | Fokusni monitorlar orasida oldinga aylantirish |
| `Ctrl + Alt + Shift + Tab` | Fokusni monitorlar orasida orqaga aylantirish |

O‘lcham o‘zgartirish tezkor tugmalari klaviaturada bosilgan belgilardan qat’i nazar, fizik `code:20` va `code:21` tugmalaridan (XKB `<AE11>` va `<AE12>`) foydalanadi. AQSH klaviaturalarida bu tugmalar `-` va `=`; yapon (JIS) klaviaturalarida ular `-` va `^`; ispan klaviaturalarida ular `'` va `¡`. JIS da `Super + ^` — bu `Super + Equal`, `Super + Shift + -` esa (`=` ni yozadi) `Super + Shift + Minus` dir.

## Tizim boshqaruvlari

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Audio paneli |
| `Super + Ctrl + B` | Bluetooth paneli |
| `Super + Ctrl + N` | Wi-Fi/tarmoq paneli |
| `Super + Ctrl + D` | Displey paneli |
| `Super + Ctrl + P` | Quvvat paneli |
| `Super + Ctrl + X` | Agentlar paneli |
| `Super + Ctrl + Alt + D` | Kalendar paneli |
| `Super + Ctrl + Alt + E` | Jahon soati paneli |
| `Super + Ctrl + 1-9` | Panelni joylashuvi bo‘yicha yoqish/o‘chirish |
| `Super + Ctrl + S` | Ulashish menyusi (LocalSend orqali) |
| `Super + Ctrl + C` | Suratga olish boshqaruvlari (skrinshot/-yozuv/tanlagich) |
| `Super + Ctrl + O` | Menyuni yoqish/o‘chirish |
| `Super + Ctrl + H` | Uskuna menyusi |
| `Super + Ctrl + E` | Emoji tanlagich |
| `Super + Ctrl + .` | Mediani transkodlash |
| `Super + Shift + Ctrl + A` | AI agentni tanlash |

## Sozlashlar

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Ekranning maksimal yorqinligi |
| `Shift + Brightness Down` | Ekranning minimal yorqinligi |
| `Alt + Brightness Up/Down` | Yorqinlikni aniq 1% ga o‘zgartirish |
| `Alt + Volume Up/Down` | Ovoz balandligini aniq 1% ga o‘zgartirish |
| `Keyboard Brightness Up/Down` | Klaviatura yoritgichini yorqinroq/xiraroq qilish |
| `Keyboard Backlight` | Klaviatura yoritgichi darajalari orasida aylanish |
| `Alt + Play` | Keyingi trek |
| `Alt + Shift + Play` | Oldingi trek |

## Ilovalarni ishga tushirish

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Tmux terminali |
| `Super + Ctrl + Return` | Herdr (agentlar menejeri) |
| `Super + Shift + Return` | Brauzer |
| `Super + Shift + Alt + B` | Brauzer (maxfiy/incognito) |
| `Super + Shift + F` | Fayl menejeri |
| `Super + Shift + Alt + F` | Terminalning cwd dagi fayl menejeri |
| `Super + Shift + M` | Musiqa (Spotify) |
| `Super + Shift + Alt + M` | Musiqa (cliamp) |
| `Super + Shift + /` | Parollar menejeri (1password) |
| `Super + Shift + Q` | Kalkulyator (Omacalc) |
| `Super + Shift + T` | Faollik (btop) |
| `Super + Shift + N` | Muharrir (Neovim) |
| `Super + Shift + C` | Kalendar ([HEY](https://hey.com/)) |
| `Super + Shift + E` | Elektron pochta ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Yangi elektron pochta ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Messenjer (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Messenjer (WhatsApp) |
| `Super + Shift + Ctrl + G` | Messenjer (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Yozuv (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X Compose |
| `Super + Shift + Y` | YouTube |

Bog‘lanishlarni `~/.config/hypr/bindings.lua` da o‘zgartiring/qo‘shing.

## Universal almashuv buferi

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Super + A` | `Ctrl + A` ni qo‘llab-quvvatlaydigan ilovalarda hammasini tanlash |
| `Super + C` | Nusxalash |
| `Super + X` | Qirqish (terminalda emas) |
| `Super + V` | Joylashtirish |
| `Super + Ctrl + V` | Almashuv buferi menejeri |

Odatda Linux da terminalda copy'n'paste qilish uchun `Ctrl + Shift + C/V`, boshqa hamma joyda buni qilish uchun esa `Ctrl + C/V` kerak bo‘ladi. Omarchy ning bu birlashtirilgan almashuv buferi tezkor tugmalari hamma joyda ishlaydi.

## Suratga olish

| Tezkor tugma | Vazifasi |
| ------------------- | ------------------------------ |
| `Print Screen` | Skrinshot |
| `Super + Ctrl + Alt + C` | Skrinshot (o‘sha surat, Print Screen tugmasi yo‘q klaviaturalar uchun) |
| `Super + Ctrl + C` | Suratga olish menyusi |
| `Alt + Print Screen` | Ekranni yozib olish |
| `Super + Print Screen` | Rang tanlagich |
| `Super + Ctrl + Print Screen` | Matnni ajratib almashuv buferiga olish |
| `Super + Alt + [` | Yozib olish paytida veb-kamera qoplamasini kichiklashtirish |
| `Super + Alt + ]` | Yozib olish paytida veb-kamera qoplamasini kattalashtirish |
| `Alt + Shift + L` | Veb-ilova yoki brauzerdan joriy URL ni nusxalash |
| `Alt + Shift + D` | Joriy sahifadagi videoni `~/Videos` ga yuklab olish |
| `Alt + Space` | Diktovkani boshlash/to‘xtatish (_Setup > Defaults > Dictation_ talab qilinadi) |
| `Right Alt` | Diktovka qilish uchun bosib turish (_Setup > Defaults > Dictation_ talab qilinadi) |

Ekran yozuvlarida tezkor tugma avval qaysi audioni xohlashingizni so‘raydi, keyin yozib olishni boshlaydi. To‘xtatish uchun uni yana bosing. Tafsilotlar uchun [skrinshotlar va yozib olish](12-screenshots-recording.md) ga qarang.

Suratga olishning barcha variantlari Omarchy menyusida (`Super + Space`) _Trigger > Capture_ ostida ham mavjud.

## Bildirishnomalar

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Super + ,` | Eng so‘nggi bildirishnoma ustida amal bajarish: uni ochish yoki uning yagona tugmasini bosish, uning variantlaridan tanlash, yoki varianti bo‘lmasa uni yopish |
| `Super + Shift + ,` | Barcha bildirishnomalarni yopish |
| `Super + Ctrl + ,` | Bildirishnomalarni klaviatura bilan boshqarish |
| `Super + Alt + ,` | Eng so‘nggi bildirishnomani yopish |
| `Super + Shift + Alt + ,` | Bildirishnomalar tarixini ochish |
| `Super + Ctrl + Alt + ,` | Bildirishnomalarni ovozsiz qilishni yoqish/o‘chirish |

## Uslub

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Yangi mavzuni tanlash (shuningdek `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Mavzu fonini tanlash (shuningdek `Super + Ctrl + Space`) |
| `Super + Backspace` | Oynada shaffoflikni yoqish/o‘chirish |
| `Super + Ctrl + Backspace` | Bitta oyna uchun kvadrat nisbatni yoqish/o‘chirish |

Qo‘shimcha fon rasmlari `~/.config/omarchy/backgrounds/<theme name>` da joylashgan. Omarchy menyusida _Install > Style > Background_ orqali ham mavjud.

Uslubning barcha variantlari Omarchy menyusida (`Super + Space`) _Style_ ostida ham mavjud.

## Yoqish/o‘chirish

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Harakatsizlikda qulflashni yoqish/o‘chirish |
| `Super + Ctrl + Delete` | Noutbuk displeyini yoqish/o‘chirish |
| `Super + Ctrl + Alt + Delete` | Noutbuk displeyini aks ettirishni yoqish/o‘chirish |
| `Super + Shift + Space` | Yuqori panelni yoqish/o‘chirish |
| `Shift + Mute` | Keyingi audio chiqishiga o‘tish |
| `Shift + Play` | Keyingi media manbasiga o‘tish |
| `Super + Shift + Backspace` | Oyna oraliqlarini yoqish/o‘chirish |
| `Super + Ctrl + Alt + F` | To‘liq ekranli ish stolini yoqish/o‘chirish (yuqori panel + oyna oraliqlari) |

## Eslatmalar

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Eslatma o‘rnatish |
| `Super + Ctrl + Alt + R` | Barcha eslatmalarni ko‘rish |
| `Super + Ctrl + Shift + R` | Barcha eslatmalarni tozalash |

## Xabarnomalar

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Vaqtni bildirishnoma sifatida ko‘rsatish |
| `Super + Ctrl + Alt + B` | Batareyani bildirishnoma sifatida ko‘rsatish |
| `Super + Ctrl + Alt + W` | Ob-havoni bildirishnoma sifatida ko‘rsatishni yoqish/o‘chirish |

## Tmux

Prefiks tugmasi — `Ctrl + Space` (`Ctrl + B` ham ishlaydi). Bu bog‘lanishlarni `~/.config/tmux/tmux.conf` da o‘zgartirishingiz mumkin.

### Panellar

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Prefix + v` | Panelni yoniga bo‘lish (vertikal) |
| `Prefix + h` | Panelni ostiga bo‘lish (gorizontal) |
| `Prefix + x` | Panelni yopish |
| `Prefix + z` | Panelni kattalashtirishni yoqish/o‘chirish (to‘liq ekran) |
| `Alt + Enter` | Panelni ostiga bo‘lish (prefikssiz) |
| `Alt + Shift + Enter` | Panelni yoniga bo‘lish (prefikssiz) |
| `Alt + Escape` | Panelni yopish (prefikssiz) |
| `Ctrl + Alt + Arrows` | Panellar orasida harakatlanish |
| `Ctrl + Alt + Shift + Arrows` | Panellar o‘lchamini o‘zgartirish |

### Oynalar

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Prefix + c` | Yangi oyna |
| `Prefix + k` | Oynani yopish |
| `Prefix + r` | Oyna nomini o‘zgartirish |
| `Alt + 1-9` | Ma’lum oynaga o‘tish |
| `Alt + Arrow Left/Right` | Oynalar orasida harakatlanish |
| `Alt + Shift + Arrow Left/Right` | Oynani chapga/o‘ngga ko‘chirish |

### Sessiyalar

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Prefix + C` | Yangi sessiya |
| `Prefix + K` | Sessiyani yopish |
| `Prefix + R` | Sessiya nomini o‘zgartirish |
| `Prefix + N` | Keyingi sessiya |
| `Prefix + P` | Oldingi sessiya |
| `Alt + Arrow Up/Down` | Sessiyalar orasida harakatlanish |
| `Prefix + s` | Sessiyalarni ro‘yxatlash |
| `Prefix + d` | Sessiyadan uzilish |

### Nusxalash rejimi (vi uslubida)

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Prefix + [` | Nusxalash rejimiga kirish |
| `v` | Tanlashni boshlash (nusxalash rejimida) |
| `y` | Tanlovni nusxalash (nusxalash rejimida) |

### Umumiy

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Prefix + q` | Konfiguratsiyani qayta yuklash |
| `Prefix + ?` | Tmux tugma bog‘lanishlarini ko‘rsatish |
| `Prefix + :` | Buyruq satri |

### Tmux tartib funksiyalari

Bu funksiyalarni Tmux sessiyasi ichida ishga tushirish kerak.

| Buyruq | Vazifasi |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Muharrir, AI va terminal bilan dev tartibini yaratish |
| `tdlm <ai> [<second_ai>]` | Har bir ichki katalog uchun dev tartibini yaratish |
| `tsl <count> <command>` | Ko‘p panelli swarm tartibini yaratish |

## Ghostty Terminal

Ghostty terminali Omarchy menyusi orqali _Install > Terminal_ yordamida o‘rnatiladi.

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Ostiga yangi bo‘linish |
| `Ctrl + Shift + O` | Yoniga yangi bo‘linish |
| `Ctrl + Alt + Arrows` | Bo‘linishlar orasida harakatlanish |
| `Super + Ctrl + Shift + Arrows` | Bo‘linish o‘lchamini 10 qatorga o‘zgartirish |
| `Super + Ctrl + Shift + Alt + Arrows` | Bo‘linish o‘lchamini 100 qatorga o‘zgartirish |
| `Ctrl + Shift + T` | Yangi yorliq |
| `Ctrl + Shift + Arrows` | Yorliqlar orasida harakatlanish |
| `Alt + Numbers` | Ma’lum yorliqqa o‘tish |
| `Shift + Pg Up/Down` | Tarixni aylantirish |
| `Ctrl + Left mouse` | Havolani brauzerda ochish |

## Fayl menejeri

| Tezkor tugma | Vazifasi |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Yo‘lga o‘tish |
| `Space` | Faylni oldindan ko‘rish (o‘qlar bilan navigatsiya) |
| `Alt + Up` | Yuqoridagi ota katalogga o‘tish |

## Neovim (lazyvim bilan)

### Navigatsiya

| Tezkor tugma | Vazifasi |
| ------------------------ | ------------------------------- |
| `Space` | Buyruq variantlarini ko‘rsatish |
| `Space Space` | Faylni noaniq qidiruv orqali ochish |
| `Space E` | Yon panelni yoqish/o‘chirish |
| `Space G G` | git boshqaruvlarini ko‘rsatish |
| `Space S G` | Fayl mazmunini qidirish |
| `Ctrl + W W` | Yon panel va muharrir orasida o‘tish |
| `Ctrl + Left/right arrow` | Yon panel o‘lchamini o‘zgartirish |
| `Shift + H` | Chapdagi fayl yorlig‘iga o‘tish |
| `Shift + L` | O‘ngdagi fayl yorlig‘iga o‘tish |
| `Space B D` | Fayl yorlig‘ini yopish |

### Yon panelda bo‘lganda

| Tezkor tugma | Vazifasi |
| ------------------------ | ------------------------------- |
| `A` | Ota katalogda yangi fayl qo‘shish |
| `Shift + A` | Ota katalogda yangi ichki katalog qo‘shish |
| `D` | Belgilangan fayl/katalogni o‘chirish |
| `M` | Belgilangan fayl/katalogni ko‘chirish |
| `R` | Belgilangan fayl/katalog nomini o‘zgartirish |
| `?` | Barcha buyruqlar uchun yordamni ko‘rsatish |

[LazyVim tomonidan sozlangan barcha Neovim tezkor tugmalarini ko‘ring](https://www.lazyvim.org/keymaps).

## Tezkor emojilar

To‘liq emoji tanlagichni ko‘rsatish uchun `Super + Ctrl + E` dan foydalanishingiz mumkin, u tanlovni almashuv buferiga joylashtiradi, yoki ushbu tezkor kirish variantlaridan foydalanishingiz mumkin.

| Tezkor tugma | EM | Ishora |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | tabassum |
| `Shift + CapsLock M C` | 😂 | yig‘lash |
| `Shift + CapsLock M L` | 😍 | sevgi |
| `Shift + CapsLock M V` | ✌️ | g‘alaba |
| `Shift + CapsLock M H` | ❤️ | yurak |
| `Shift + CapsLock M Y` | 👍 | ha |
| `Shift + CapsLock M N` | 👎 | yo‘q |
| `Shift + CapsLock M F` | 🖕 | so‘kinish |
| `Shift + CapsLock M W` | 🤞 | tilak |
| `Shift + CapsLock M R` | 🤘 | rok |
| `Shift + CapsLock M K` | 😘 | o‘pich |
| `Shift + CapsLock M E` | 🙄 | ko‘z aylantirish |
| `Shift + CapsLock M I` | 😉 | ko‘z qisish |
| `Shift + CapsLock M P` | 🙏 | duo |
| `Shift + CapsLock M D` | 🤤 | so‘lak oqishi |
| `Shift + CapsLock M M` | 💰 | pul |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | tost |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | salomlashish |
| `Shift + CapsLock M A` |💪 | qo‘l |
| `Shift + CapsLock M B` |🤯 | portlash |

## Tezkor to‘ldirishlar

| Tezkor tugma | To‘ldirish |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (uzun tire) |
| `Shift + CapsLock Space N` | Ismingiz (o‘rnatishda kiritilganidek) |
| `Shift + CapsLock Space E` | Elektron pochtangiz (o‘rnatishda kiritilganidek) |

O‘zingiznikidan ko‘proq qo‘shish uchun `~/.XCompose` ni tahrirlang, keyin o‘zgarishlar kuchga kirishi uchun terminalda `omarchy-restart-xcompose` ni ishga tushiring.
