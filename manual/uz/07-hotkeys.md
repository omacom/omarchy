# Tezkor tugmalar

Barcha asosiy klaviatura bog‘lanishlarini `Super + K` bilan ko‘rishingiz mumkin (Tmux bog‘lanishlari `Super + Alt + K` bilan va Herdr bog‘lanishlari `Super + Ctrl + K` bilan).

## Tezkor tugmalar qanday joylashgan

Har bir tezkor tugma modifikatorlari bilan belgilanadigan tekislikda joylashgan va har bir tekislikning bitta vazifasi bor. Tezkor tugmalarning bir-biri bilan aralashib ketmasligini aynan shu ta’minlaydi va bu odatda biror narsa qayerda joylashganini taxmin qila olishingizni bildiradi.

| Tekislik | U yerda nimalar bor | Misollar |
| --- | --- | --- |
| `Super + key` | Tizim: oynalar, ish maydonlari, tartiblar va asosiy menyular | `Super + Space` Omarchy menyusi, `Super + W` oynani yopish, `Super + F` to‘liq ekran |
| `Super + Shift + key` | Ilovalar | `Super + Shift + B` brauzer, `Super + Shift + E` elektron pochta, `Super + Shift + N` muharrir |
| `Super + Ctrl + key` | Panellar va tizim menyulari | `Super + Ctrl + A` audio, `Super + Ctrl + N` tarmoq, `Super + Ctrl + C` suratga olish menyusi |
| `Super + Ctrl + Alt + key` | Tezkor amallar va xabarnomalar | `Super + Ctrl + Alt + T` vaqtni ko‘rsatish, `Super + Ctrl + Alt + B` batareya, `Super + Ctrl + Alt + C` skrinshot |

Tezkor tugmaga `Alt` ni qo‘shish sizga xuddi shu narsaning variantini beradi, hech qachon aloqasiz narsani emas:

- `Super + Shift + B` brauzerni ochadi; `Super + Shift + Alt + B` shaxsiy oynani ochadi
- `Super + Shift + E` elektron pochtani ochadi; `Super + Shift + Alt + E` yangisini boshlaydi
- `Super + F` to‘liq ekranga o‘tadi; `Super + Alt + F` to‘liq kenglikka o‘tadi
- `Super + Ctrl + C` suratga olish menyusini ochadi; `Super + Ctrl + Alt + C` menyuni o‘tkazib yuboradi va skrinshot oladi

Tezkor tugma qo‘shayotganda:

1. U nima qilishiga qarab tekislikni tanlang, keyin tugmani tanlang.
2. Joy bo‘shatish uchun mavjud tezkor tugmani ko‘chirmang. To‘g‘ri tekislikda bo‘sh tugmani toping.
3. `Alt` dan faqat usiz bo‘lgan tezkor tugmaning varianti uchun foydalaning.

Bir nechta tezkor tugmalar qulay bo‘lgani uchun bu qoidalarni buzadi. Strelka yoki `Tab` bilan `Shift` ilovani ochish o‘rniga ko‘chiradi yoki teskari yo‘nalishda bajaradi, `Print`, media tugmalari, `Alt + Tab` va `Ctrl + Alt + Del` esa hamma joyda qanday ishlasa, shunday ishlaydi. Ular istisnolar, ko‘chirib olish uchun namuna emas.

Agar standart variant sizga mos kelmasa (masalan, Windows dagi kabi skrinshotlar uchun `Super + Shift + S` ni xohlasangiz), uni `~/.config/hypr/bindings.lua` da qayta bog‘lang.

## Navigatsiya

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy menyusi (ilovalar va qolgan hamma narsa) |
| `Super + Alt + Space` | Ilovalar panjarasi |
| `Super + Escape` | Tizim menyusi (kutish rejimi, qayta ishga tushirish va h.k.) |
| `Super + Ctrl + L` | Kompyuterni qulflash |
| `Super + W` or `Super + Q` | Oynani yopish |
| `Ctrl + Alt + Del` | Barcha oynalarni yopish |
| `Super + K` | Barcha tezkor tugmalarni ko‘rsatish |
| `Super + Alt + K` | tmux tezkor tugmalarini ko‘rsatish |
| `Super + Ctrl + K` | herdr tezkor tugmalarini ko‘rsatish |
| `Super + M` | Oynani dokka kichraytirish |
| `Super + T` | Oynani plitka/suzuvchi rejimlari o‘rtasida almashtirish |
| `Super + J` | Oyna holatini almashtirish (gorizontal/vertikal) |
| `Super + O` | Oynani sticky'n'floating ko‘rinishiga chiqarishni yoqish/o‘chirish |
| `Super + L` | dwindle, scrolling va floating tartiblari bo‘ylab aylanish |
| `Super + Alt + L` | Tartiblar bo‘ylab teskari yo‘nalishda aylanish |
| `Super + P` | Pseudo oyna uslubini almashtirish (natural v stretch) |
| `Super + F` | To‘liq ekranga o‘tish |
| `Super + Alt + F` | To‘liq kenglikka o‘tish |
| `Super + Ctrl + F` | Oyna ichida to‘liq ekranga o‘tish |
| `Super + 1…9/0` | Fokusdagi monitorda ma’lum ish maydoniga o‘tish (0 — bu 10) |
| `Super + Tab` | Fokusdagi monitorda keyingi ish maydoniga o‘tish |
| `Super + Shift + Tab` | Fokusdagi monitorda oldingi ish maydoniga o‘tish |
| `Super + Ctrl + Tab` | Fokusdagi monitorda avvalgi ish maydoniga o‘tish |
| `Super + Shift + 1…9/0` | Oynani fokusdagi monitordagi ish maydoniga ko‘chirish |
| `Super + Shift + Alt + 1…9/0` | Oynani fokusdagi monitordagi ish maydoniga ortidan bormasdan ko‘chirish |
| `Super + S` | To‘liq scratchpad ni yoqish/o‘chirish |
| `Super + Alt + S` | Oynani to‘liq scratchpad ga ko‘chirish |
| `Super + Grave` | Quake konsolini yoqish/o‘chirish |
| `Super + Shift + Grave` | Oynani Quake konsoliga ko‘chirish |
| `Super + Shift + Ctrl + Arrows` | Oynani shu yo‘nalishdagi monitorga ko‘chirish |
| `Super + Shift + Alt + Arrows` | Ish maydonini shu yo‘nalishdagi monitorga ko‘chirish |
| `Super + Arrow` | Fokusni strelka yo‘nalishidagi oynaga ko‘chirish, ekranning chetida shu tomondagi monitorga o‘tish |
| `Super + Shift + Arrow` | Oynani strelka yo‘nalishidagi boshqa oyna bilan almashtirish, shu tomondagi monitordagi oynani ham qo‘shib |
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
| `Super + Scroll Wheel` | Fokusdagi monitorda ish maydonlari bo‘ylab aylantirish |
| `Super + G` | Oynalarni guruhlashni yoqish/o‘chirish |
| `Super + Alt + G` | Oynani guruhdan chiqarish |
| `Super + Alt + Tab` | Guruh ichidagi oynalar bo‘ylab aylanish |
| `Super + Alt + Shift + Tab` | Guruh ichidagi oynalar bo‘ylab teskari aylanish |
| `Super + Alt + Scroll Wheel` | Guruh ichidagi oynalar bo‘ylab aylanish |
| `Super + Alt + 1/2/3/4/5` | Guruhdagi ma’lum oynaga o‘tish |
| `Super + Alt + Arrow` | Oynani strelka yo‘nalishida guruhga ko‘chirish, shu tomondagi monitordagi oynani ham qo‘shib |
| `Super + Ctrl + Left/Right` | Plitka guruhi ichidagi oynalar orasida harakatlanish |
| `Super + Ctrl + Z` | Ekranni yaqinlashtirish (ko‘proq yaqinlashtirish uchun takrorlang) |
| `Super + Ctrl + Alt + Z` | Ekranni to‘liq uzoqlashtirish |
| `Super + /` | Monitor masshtabi variantlari bo‘ylab oldinga qadam tashlash |
| `Super + Alt + /` | Monitor masshtabi variantlari bo‘ylab orqaga qadam tashlash |
| `Alt + Tab` | Faol ish maydonidagi oynalar bo‘ylab oldinga aylanish |
| `Alt + Shift + Tab` | Faol ish maydonidagi oynalar bo‘ylab teskari aylanish |
| `Ctrl + Alt + Tab` | Monitorlar bo‘ylab fokusni oldinga aylantirish |
| `Ctrl + Alt + Shift + Tab` | Monitorlar bo‘ylab fokusni orqaga aylantirish |
| `Super + I` | Kiritish tilini almashtirish (bir nechta tartib yoki kiritish usuli bo‘lganda) |
| `Super + Shift + I` | Kiritish tilini orqaga almashtirish |

Sensor panelda uch va to‘rt barmoqli surishlar ish maydonlarini almashtiradi, oynalarni ko‘chiradi hamda menyu va Quake konsolini ochadi; imo-ishoralar uchun [klaviatura, sichqoncha va trekpad](34-keyboard-mouse-trackpad.md) ga qarang.

O‘lcham o‘zgartirish yorliqlari klaviaturada qanday belgilar bosilganidan qat’i nazar, fizik `code:20` va `code:21` tugmalaridan (XKB `<AE11>` va `<AE12>`) foydalanadi. AQSH klaviaturalarida bu tugmalar `-` va `=`; yapon (JIS) klaviaturalarida ular `-` va `^`; ispan klaviaturalarida ular `'` va `¡`. JIS da `Super + ^` — bu `Super + Equal`, `Super + Shift + -` esa (u `=` ni yozadi) `Super + Shift + Minus` dir.

## Tizim boshqaruvi

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Audio paneli |
| `Super + Ctrl + B` | Bluetooth paneli |
| `Super + Ctrl + N` | Wi-Fi/tarmoq paneli |
| `Super + Ctrl + D` | Displey paneli |
| `Super + Ctrl + P` | Quvvat paneli |
| `Super + Ctrl + X` | Agentlar paneli |
| `Super + Ctrl + Shift + X` | Mahalliy modellar paneli |
| `Super + Ctrl + Alt + D` | Kalendar paneli |
| `Super + Ctrl + Alt + E` | Jahon soati paneli |
| `Super + Ctrl + 1-9` | Bar panelini joylashuvi bo‘yicha almashtirish |
| `Super + Ctrl + S` | Ulashish menyusi (LocalSend orqali) |
| `Super + Ctrl + C` | Suratga olish boshqaruvi (skrinshot/-yozuv/tanlagich) |
| `Super + Ctrl + O` | Menyuni yoqish/o‘chirish |
| `Super + Ctrl + H` | Uskuna menyusi |
| `Super + Ctrl + E` | Emoji tanlagich |
| `Super + Ctrl + .` | Mediani transkodlash |
| `Super + Shift + Ctrl + A` | AI agentni tanlash |
| `Power` key | Tizim menyusi |
| `Super + Shift + Copilot` key | Omarchy menyusi |

## Sozlashlar

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Ekranning maksimal yorqinligi |
| `Shift + Brightness Down` | Ekranning minimal yorqinligi |
| `Alt + Brightness Up/Down` | Yorqinlikni aniq 1% ga o‘zgartirish |
| `Alt + Volume Up/Down` | Ovoz balandligini aniq 1% ga o‘zgartirish |
| `Keyboard Brightness Up/Down` | Klaviatura yoritgichi yorqinroq/xiraroq |
| `Keyboard Backlight` | Klaviatura yoritgichi darajalari bo‘ylab aylanish |
| `Ctrl + Brightness Up/Down` | Klaviatura yoritgichi yorqinroq/xiraroq, o‘z tugmalari bo‘lmagan klaviaturalarda |
| `Mic Mute` | Mikrofonni o‘chirish |
| `Shift + Mute` | Audio chiqishini almashtirish |
| `Touchpad Toggle` | Sensor panelni yoqish yoki o‘chirish |
| `Display` key | Ish maydoni tartibini aylantirish |
| `Alt + Play` | Keyingi trek |
| `Alt + Shift + Play` | Oldingi trek |

## Ilovalarni ishga tushirish

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Tmux terminali |
| `Super + Ctrl + Return` | Herdr (agentlar boshqaruvchisi) |
| `Super + Shift + Return` or `Super + Shift + B` | Brauzer |
| `Super + Shift + Alt + B` | Brauzer (shaxsiy/inkognito) |
| `Super + Shift + F` | Fayl boshqaruvchisi |
| `Super + Shift + Alt + F` | Terminalning cwd sidagi fayl boshqaruvchisi |
| `Super + Shift + M` | Musiqa (Spotify) |
| `Super + Shift + Alt + M` | Musiqa (cliamp) |
| `Super + Shift + /` | Parollar boshqaruvchisi (1password) |
| `Super + Shift + Q` or `Calculator` key | Kalkulyator (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, o‘rnatilgandan keyin) |
| `Super + Shift + T` | Faollik (btop) |
| `Super + Shift + N` | Muharrir (Plain, yoki siz tanlagan standart) |
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
| `Super + Shift + Alt + X` | X (yangi post) |
| `Super + Shift + Y` | YouTube |

Bog‘lanishlarni `~/.config/hypr/bindings.lua` da o‘zgartiring/qo‘shing.

## Universal almashish buferi

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Super + A` | `Ctrl + A` ni qo‘llab-quvvatlaydigan ilovalarda hammasini tanlash |
| `Super + C` | Nusxalash |
| `Super + X` | Kesish (terminalda emas) |
| `Super + V` | Qo‘yish |
| `Super + Ctrl + V` | Almashish buferi boshqaruvchisi |

Odatda Linux da terminalda nusxalash va qo‘yish uchun `Ctrl + Shift + C/V`, qolgan hamma joyda esa `Ctrl + C/V` kerak bo‘ladi. Bu Omarchy ning birlashtirilgan almashish buferi tezkor tugmalari hamma joyda ishlaydi.

## Suratga olish

| Tezkor tugma | Funksiya |
| ------------------- | ------------------------------ |
| `Print Screen` | Skrinshot |
| `Super + Ctrl + Alt + C` | Skrinshot (xuddi shu surat, Print Screen tugmasi bo‘lmagan klaviaturalar uchun) |
| `Super + Ctrl + C` | Suratga olish menyusi |
| `Alt + Print Screen` | Ekranni yozib olish |
| `Super + Shift + Ctrl + Alt + C` | Audiosiz ekranni yozib olish, menyuni o‘tkazib yuborib (to‘xtatish uchun yana bosing) |
| `Super + Print Screen` | Rang tanlagich |
| `Super + Ctrl + Print Screen` | Matnni almashish buferiga chiqarib olish |
| `Super + Alt + [` | Yozib olish paytida veb-kamera qoplamasini kichraytirish |
| `Super + Alt + ]` | Yozib olish paytida veb-kamera qoplamasini kattalashtirish |
| `Alt + Shift + L` | Veb-ilova yoki brauzerdan joriy URL ni nusxalash |
| `Alt + Shift + D` | Joriy sahifadagi videoni `~/Videos` ga yuklab olish |
| `Alt + Space` | Diktovkani boshlash/to‘xtatish (_Setup > Defaults > Dictation_ talab qilinadi) |
| `Right Alt` | Diktovka qilish uchun bosib turish (_Setup > Defaults > Dictation_ talab qilinadi) |

Ekran yozuvlarida tezkor tugma avval qaysi audioni xohlashingizni so‘raydi, keyin yozishni boshlaydi. To‘xtatish uchun uni yana bosing. Tafsilotlar uchun [skrinshotlar va yozib olish](12-screenshots-recording.md) ga qarang.

Barcha suratga olish variantlariga Omarchy menyusidagi _Trigger > Capture_ bo‘limi orqali ham kirish mumkin (`Super + Space`).

## Bildirishnomalar

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Super + ,` | Eng so‘nggi bildirishnoma bo‘yicha amal bajarish: uni ochish yoki uning yagona tugmasini bosish, uning variantlaridan tanlash yoki varianti bo‘lmasa uni bekor qilish |
| `Super + Shift + ,` | Barcha bildirishnomalarni bekor qilish |
| `Super + Ctrl + ,` | Bildirishnomalarni klaviatura bilan boshqarish |
| `Super + Alt + ,` | Eng so‘nggi bildirishnomani bekor qilish |
| `Super + Shift + Alt + ,` | Bildirishnomalar tarixini ochish |
| `Super + Ctrl + Alt + ,` | Bildirishnomalarni jim qilishni almashtirish |

## Uslub

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Yangi mavzuni tanlash (shuningdek `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Mavzu fonini tanlash (shuningdek `Super + Ctrl + Space`) |
| `Super + Backspace` | Oynada shaffoflikni yoqish/o‘chirish |
| `Super + Ctrl + Backspace` | Bitta oynali kvadrat nisbatni yoqish/o‘chirish |

Qo‘shimcha fon rasmlari `~/.config/omarchy/backgrounds/<theme name>` da joylashgan. Omarchy menyusidagi _Install > Style > Background_ orqali ham mavjud.

Barcha uslub variantlariga Omarchy menyusidagi _Appearance_ bo‘limi orqali ham kirish mumkin (`Super + Space`).

## Almashtirgichlar

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Bo‘sh turganda qulflashni yoqish/o‘chirish |
| `Super + Ctrl + Delete` | Noutbuk displeyini yoqish/o‘chirish |
| `Super + Ctrl + Alt + Delete` | Noutbuk displeyini aks ettirishni yoqish/o‘chirish |
| `Super + Shift + Space` | Yuqori panelni yoqish/o‘chirish |
| `Shift + Mute` | Keyingi audio chiqishiga o‘tish |
| `Shift + Play` | Keyingi media manbasiga o‘tish |
| `Super + Shift + Backspace` | Oyna bo‘shliqlarini yoqish/o‘chirish |
| `Super + Ctrl + Alt + F` | To‘liq ekranli ish stolini yoqish/o‘chirish (yuqori panel + oyna bo‘shliqlari) |

## Eslatmalar

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Eslatma o‘rnatish |
| `Super + Ctrl + Alt + R` | Barcha eslatmalarni ko‘rish |
| `Super + Ctrl + Shift + R` | Barcha eslatmalarni tozalash |

## Xabarnomalar

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Vaqtni bildirishnoma sifatida ko‘rsatish |
| `Super + Ctrl + Alt + B` | Batareyani bildirishnoma sifatida ko‘rsatish |
| `Super + Ctrl + Alt + W` | Ob-havoni bildirishnoma sifatida yoqish/o‘chirish |

## Tmux

Prefiks tugmasi `Ctrl + Space` (`Ctrl + B` ham ishlaydi). Bu bog‘lanishlarni `~/.config/tmux/tmux.conf` da o‘zgartirishingiz mumkin.

### Panellar

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Prefix + v` | Panelni yoniga bo‘lish (vertikal) |
| `Prefix + h` | Panelni pastga bo‘lish (gorizontal) |
| `Prefix + x` | Panelni tugatish |
| `Prefix + z` | Panelni kattalashtirishni yoqish/o‘chirish (to‘liq ekran) |
| `Alt + Enter` | Panelni pastga bo‘lish (prefikssiz) |
| `Alt + Shift + Enter` | Panelni yoniga bo‘lish (prefikssiz) |
| `Alt + Escape` | Panelni tugatish (prefikssiz) |
| `Ctrl + Alt + Arrows` | Panellar orasida harakatlanish |
| `Ctrl + Alt + Shift + Arrows` | Panellar o‘lchamini o‘zgartirish |

### Oynalar

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Prefix + c` | Yangi oyna |
| `Prefix + k` | Oynani tugatish |
| `Prefix + r` | Oyna nomini o‘zgartirish |
| `Alt + 1-9` | Ma’lum oynaga o‘tish |
| `Alt + Arrow Left/Right` | Oynalar orasida harakatlanish |
| `Alt + Shift + Arrow Left/Right` | Oynani chapga/o‘ngga ko‘chirish |

### Sessiyalar

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Prefix + C` | Yangi sessiya |
| `Prefix + K` | Sessiyani tugatish |
| `Prefix + R` | Sessiya nomini o‘zgartirish |
| `Prefix + N` | Keyingi sessiya |
| `Prefix + P` | Oldingi sessiya |
| `Alt + Arrow Up/Down` | Sessiyalar orasida harakatlanish |
| `Prefix + s` | Sessiyalarni ro‘yxatlash |
| `Prefix + d` | Sessiyadan uzilish |

### Nusxalash rejimi (vi uslubida)

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Prefix + [` | Nusxalash rejimiga kirish |
| `v` | Tanlashni boshlash (nusxalash rejimida) |
| `y` | Tanlanganni nusxalash (nusxalash rejimida) |

### Umumiy

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Prefix + q` | Konfiguratsiyani qayta yuklash |
| `Prefix + ?` | Tmux tugma bog‘lanishlarini ko‘rsatish |
| `Prefix + :` | Buyruq satri |

### Tmux tartib funksiyalari

Bu funksiyalar Tmux sessiyasi ichida ishga tushirilishi kerak.

| Buyruq | Funksiya |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Muharrir, AI va terminal bilan ishlab chiqish tartibini yaratish |
| `tdlm <ai> [<second_ai>]` | Har bir ichki katalog uchun ishlab chiqish tartibini yaratish |
| `tsl <count> <command>` | Ko‘p panelli swarm tartibini yaratish |

## Ghostty Terminal

Ghostty terminali Omarchy menyusi orqali _Install > Terminal_ yordamida o‘rnatiladi.

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Pastga yangi bo‘linish |
| `Ctrl + Shift + O` | Yoniga yangi bo‘linish |
| `Ctrl + Alt + Arrows` | Bo‘linishlar orasida harakatlanish |
| `Super + Ctrl + Shift + Arrows` | Bo‘linish o‘lchamini 10 qatorga o‘zgartirish |
| `Super + Ctrl + Shift + Alt + Arrows` | Bo‘linish o‘lchamini 100 qatorga o‘zgartirish |
| `Ctrl + Shift + T` | Yangi tab |
| `Ctrl + Shift + Arrows` | Tablar orasida harakatlanish |
| `Alt + Numbers` | Ma’lum tabga o‘tish |
| `Shift + Pg Up/Down` | Tarixni aylantirish |
| `Ctrl + Left mouse` | Havolani brauzerda ochish |

## Fayl boshqaruvchisi

| Tezkor tugma | Funksiya |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Yo‘lga o‘tish |
| `Space` | Faylni oldindan ko‘rish (strelkalar bilan navigatsiya) |
| `Alt + Up` | Yuqoridagi ota katalogga o‘tish |

## Neovim (w/ lazyvim)

### Navigatsiya

| Tezkor tugma | Funksiya |
| ------------------------ | ------------------------------- |
| `Space` | Buyruq variantlarini ko‘rsatish |
| `Space Space` | Faylni noaniq qidiruv orqali ochish |
| `Space E` | Yon panelni yoqish/o‘chirish |
| `Space G G` | git boshqaruvini ko‘rsatish |
| `Space S G` | Fayl mazmunini qidirish |
| `Ctrl + W W` | Yon panel va muharrir orasida sakrash |
| `Ctrl + Left/right arrow` | Yon panel o‘lchamini o‘zgartirish |
| `Shift + H` | Chap fayl tabiga o‘tish |
| `Shift + L` | O‘ng fayl tabiga o‘tish |
| `Space B D` | Fayl tabini yopish |

### Yon panelda bo‘lganda

| Tezkor tugma | Funksiya |
| ------------------------ | ------------------------------- |
| `A` | Ota katalogda yangi fayl qo‘shish |
| `Shift + A` | Ota katalogda yangi ichki katalog qo‘shish |
| `D` | Belgilangan fayl/katalogni o‘chirish |
| `M` | Belgilangan fayl/katalogni ko‘chirish |
| `R` | Belgilangan fayl/katalog nomini o‘zgartirish |
| `?` | Barcha buyruqlar uchun yordamni ko‘rsatish |

[LazyVim tomonidan sozlangan barcha Neovim tezkor tugmalarini ko‘ring](https://www.lazyvim.org/keymaps).

## Tezkor emojilar

To‘liq emoji tanlagichni ko‘rsatish uchun `Super + Ctrl + E` dan foydalanishingiz mumkin, u tanlanganni almashish buferiga qo‘yadi, yoki mana bu tezkor kirish variantlaridan foydalanishingiz mumkin.

| Tezkor tugma | EM | Ishora |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | tabassum |
| `Shift + CapsLock M C` | 😂 | yig‘i |
| `Shift + CapsLock M L` | 😍 | sevgi |
| `Shift + CapsLock M V` | ✌️ | g‘alaba |
| `Shift + CapsLock M H` | ❤️ | yurak |
| `Shift + CapsLock M Y` | 👍 | ha |
| `Shift + CapsLock M N` | 👎 | yo‘q |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | tilak |
| `Shift + CapsLock M R` | 🤘 | rok |
| `Shift + CapsLock M K` | 😘 | o‘pish |
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
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | Ismingiz (sozlashda kiritilganidek) |
| `Shift + CapsLock Space E` | Elektron pochtangiz (sozlashda kiritilganidek) |

O‘zingiznikidan ko‘proq qo‘shish uchun `~/.XCompose` ni tahrirlang, keyin o‘zgarishlar qabul qilinishi uchun terminalda `omarchy restart xcompose` ni ishga tushiring.
