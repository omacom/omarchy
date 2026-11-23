# Tezkor tugmalar

Barcha asosiy klaviatura bog‘lanishlarini `Super + K` bilan ko‘rishingiz mumkin (Tmux bog‘lanishlari `Super + Alt + K` bilan va Herdr bog‘lanishlari `Super + Ctrl + K` bilan).

## Tezkor tugmalar qanday joylashtirilgan

Har bir tezkor tugma o‘z modifikatorlari bilan belgilanadigan tekislikda joylashadi va har bir tekislikning bitta vazifasi bor. Tezkor tugmalar bir-biri bilan chalkashib ketmasligini mana shu ta’minlaydi va bu odatda biror narsa qayerda joylashganini taxmin qila olasiz, degani.

| Tekislik | U yerda nimalar joylashadi | Misollar |
| --- | --- | --- |
| `Super + key` | Tizim: oynalar, ish maydonlari, tartiblar va asosiy menyular | `Super + Space` Omarchy menyusi, `Super + W` oynani yopish, `Super + F` to‘liq ekran |
| `Super + Shift + key` | Ilovalar | `Super + Shift + B` brauzer, `Super + Shift + E` email, `Super + Shift + N` muharrir |
| `Super + Ctrl + key` | Panellar va tizim menyulari | `Super + Ctrl + A` audio, `Super + Ctrl + N` tarmoq, `Super + Ctrl + C` suratga olish menyusi |
| `Super + Ctrl + Alt + key` | Tezkor amallar va xabarnomalar | `Super + Ctrl + Alt + T` vaqtni ko‘rsatish, `Super + Ctrl + Alt + B` batareya, `Super + Ctrl + Alt + C` skrinshot |

Tezkor tugmaga `Alt` qo‘shish sizga xuddi shu narsaning variantini beradi, hech qachon aloqasiz narsani emas:

- `Super + Shift + B` brauzerni ochadi; `Super + Shift + Alt + B` maxfiy oynani ochadi
- `Super + Shift + E` emailni ochadi; `Super + Shift + Alt + E` yangisini boshlaydi
- `Super + F` to‘liq ekranga o‘tadi; `Super + Alt + F` to‘liq kenglikka o‘tadi
- `Super + Ctrl + C` suratga olish menyusini ochadi; `Super + Ctrl + Alt + C` menyuni o‘tkazib yuborib, skrinshot oladi

Tezkor tugma qo‘shayotganda:

1. U nima qilishiga qarab tekislikni tanlang, keyin tugmani tanlang.
2. Joy bo‘shatish uchun mavjud tezkor tugmani ko‘chirmang. To‘g‘ri tekislikda bo‘sh tugmani toping.
3. `Alt` dan faqat usiz tezkor tugmaning varianti uchungina foydalaning.

Bir nechta tezkor tugmalar qulay bo‘lgani uchun bu qoidalarni buzadi. O‘q yoki `Tab` bilan `Shift` ilovani ochish o‘rniga ko‘chiradi yoki orqaga qaytaradi, `Print`, media tugmalari, `Alt + Tab` va `Ctrl + Alt + Del` esa hamma joyda qanday ishlasa, shunday ishlaydi. Ular istisnolar, nusxa olish uchun naqshlar emas.

Agar standart variant sizga to‘g‘ri kelmasa (aytaylik, Windows dagidek skrinshotlar uchun `Super + Shift + S` ni xohlasangiz), uni `~/.config/hypr/bindings.lua` da qayta bog‘lang.

## Navigatsiya

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menyusi (ilovalar va qolgan hamma narsa)    |
| `Super + Alt + Space` | Ilovalar panjarasi |
| `Super + Escape` | Tizim menyusi (kutish rejimi, qayta ishga tushirish va h.k.)  |
| `Super + Ctrl + L` | Kompyuterni qulflash |
| `Super + W` or `Super + Q` | Oynani yopish             |
| `Ctrl + Alt + Del` | Barcha oynalarni yopish |
| `Super + K` | Barcha tezkor tugmalarni ko‘rsatish |
| `Super + Alt + K` | tmux tezkor tugmalarini ko‘rsatish |
| `Super + Ctrl + K` | herdr tezkor tugmalarini ko‘rsatish |
| `Super + M` | Oynani dock ga kichraytirish |
| `Super + T`               | Oynani mozaika/suzuvchi holat o‘rtasida almashtirish             |
| `Super + J` | Oyna holatini almashtirish (gorizontal/vertikal) |
| `Super + O`               | Oynani sticky'n'floating ga chiqarishni almashtirish |
| `Super + L`               | dwindle, scrolling va floating tartiblari bo‘ylab aylanish |
| `Super + Alt + L`         | Tartiblar bo‘ylab teskari aylanish |
| `Super + P`               | pseudo oyna uslubini almashtirish (tabiiy va cho‘zilgan) |
| `Super + F`                 | To‘liq ekranga o‘tish              |
| `Super + Alt + F`                 | To‘liq kenglikka o‘tish              |
| `Super + Ctrl + F`                 | Oyna ichida to‘liq ekranga o‘tish              |
| `Super + 1…9/0`         | Fokusdagi monitorda muayyan ish maydoniga o‘tish (0 — 10) |
| `Super + Tab` | Fokusdagi monitorda keyingi ish maydoniga o‘tish |
| `Super + Shift + Tab` | Fokusdagi monitorda oldingi ish maydoniga o‘tish |
| `Super + Ctrl + Tab` | Fokusdagi monitorda avvalgi ish maydoniga o‘tish |
| `Super + Shift + 1…9/0` | Oynani fokusdagi monitordagi ish maydoniga ko‘chirish |
| `Super + Shift + Alt + 1…9/0` | Oynani fokusdagi monitordagi ish maydoniga ortidan bormasdan ko‘chirish |
| `Super + S` | To‘liq scratchpad ni almashtirish |
| `Super + Alt + S` | Oynani to‘liq scratchpad ga ko‘chirish |
| `Super + the key above Tab` (grave on US layouts) | Quake konsolini almashtirish |
| `Super + Shift + the key above Tab` (grave on US layouts) | Oynani Quake konsoliga ko‘chirish |
| `Super + Shift + Ctrl + Arrows` | Oynani shu yo‘nalishdagi monitorga ko‘chirish |
| `Super + Shift + Alt + Arrows` | Ish maydonini shu yo‘nalishdagi monitorga ko‘chirish |
| `Super + Arrow`  | Fokusni o‘q yo‘nalishidagi oynaga ko‘chirish, ekran chetida shu tomondagi monitorga o‘tib |
| `Super + Shift + Arrow`  | Oynani o‘q yo‘nalishidagi boshqa oyna bilan almashtirish, shu tomondagi monitordagi oynani ham qo‘shib |
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
| `Super + G`               | Oynalarni guruhlashni almashtirish      |
| `Super + Alt + G`               | Oynani guruhdan chiqarish      |
| `Super + Alt + Tab`               | Guruhdagi oynalar o‘rtasida aylanish      |
| `Super + Alt + Shift + Tab`               | Guruhdagi oynalar o‘rtasida orqaga aylanish      |
| `Super + Alt + Scroll Wheel` | Guruhdagi oynalar o‘rtasida aylanish |
| `Super + Alt + 1/2/3/4/5`               | Guruhdagi muayyan oynaga o‘tish      |
| `Super + Alt + Arrow`  | Oynani o‘q yo‘nalishida guruh ichiga ko‘chirish, shu tomondagi monitordagi oynani ham qo‘shib |
| `Super + Ctrl + Left/Right`  | Mozaika guruhi ichidagi oynalar o‘rtasida harakatlanish |
| `Super + Ctrl + Z` | Ekranni yaqinlashtirish (ko‘proq yaqinlashtirish uchun takrorlang) |
| `Super + Ctrl + Alt + Z` | Ekrandan to‘liq uzoqlashish |
| `Super + /` | Monitor masshtablash variantlari bo‘ylab oldinga qadam tashlash |
| `Super + Alt + /` | Monitor masshtablash variantlari bo‘ylab orqaga qadam tashlash |
| `Alt + Tab` | Faol ish maydonidagi oynalar bo‘ylab oldinga aylanish |
| `Alt + Shift + Tab` | Faol ish maydonidagi oynalar bo‘ylab orqaga aylanish |
| `Ctrl + Alt + Tab`| Monitorlar bo‘ylab fokusni oldinga aylantirish |
| `Ctrl + Alt + Shift + Tab`| Monitorlar bo‘ylab fokusni orqaga aylantirish |
| `Super + I` | Kirish tilini almashtirish (bittadan ortiq tartib yoki kiritish usuli bo‘lganda) |
| `Super + Shift + I` | Kirish tilini orqaga almashtirish |

Sensor panelda uch va to‘rt barmoqli surishlar ish maydonlarini almashtiradi, oynalarni ko‘chiradi hamda menyu va Quake konsolini ochadi; imo-ishoralar uchun [klaviatura, sichqoncha va trekpad](34-keyboard-mouse-trackpad.md) ga qarang.

O‘lcham o‘zgartirish 0 ning o‘ng tomonidagi ikkita tugmadan foydalanadi, klaviaturangizda ularga nima yozilganidan qat’i nazar: AQSh klaviaturalarida `-` va `=`, Daniya va Shvetsiya klaviaturalarida `+` va `´`, Norvegiya klaviaturasida `+` va `\`, Nemis klaviaturasida `ß` va `´`, Ispan klaviaturasida `'` va `¡`, Yapon (JIS) klaviaturasida esa `-` va `^`. `Super + K` ularni klaviaturangizda qanday yozilgan bo‘lsa, shunday ko‘rsatadi. JIS da `Super + ^` — `Super + Equal`, `Super + Shift + -` (u `=` yozadi) esa `Super + Shift + Minus` dir. Monitor masshtablash va parollar menejeri `/` dan foydalanadi; `/` ni faqat Shift bilan yozadigan tartiblarda, aksariyat Yevropa tartiblarida bo‘lgani kabi, ular o‘rniga o‘ng Shift ning chap tomonidagi tugmadan foydalanadi (Daniya va Nemis tartiblarida `-`).

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
| `Super + Ctrl + 1-9`           | Bar panelini o‘rni bo‘yicha almashtirish    |
| `Super + Ctrl + S` | Ulashish menyusi (LocalSend orqali) |
| `Super + Ctrl + C` | Suratga olish boshqaruvlari (skrinshot/-yozib olish/tanlagich) |
| `Super + Ctrl + O` | Menyuni almashtirish |
| `Super + Ctrl + H` | Uskuna menyusi |
| `Super + Ctrl + E` | Emoji tanlagich |
| `Super + Ctrl + .` | Mediani transkodlash |
| `Super + Shift + Ctrl + A` | Standart agentingizni ishga tushirish |
| `Power` key | Tizim menyusi |
| `Super + Shift + Copilot` key | Omarchy menyusi |

## Sozlashlar

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Ekran yorqinligining maksimumi |
| `Shift + Brightness Down` | Ekran yorqinligining minimumi |
| `Alt + Brightness Up/Down` | Aniq 1% yorqinlik o‘zgarishlari |
| `Alt + Volume Up/Down` | Aniq 1% ovoz o‘zgarishlari |
| `Keyboard Brightness Up/Down` | Klaviatura yoritgichini yorqinroq/xiraroq qilish |
| `Keyboard Backlight` | Klaviatura yoritgichi darajalari bo‘ylab aylanish |
| `Ctrl + Brightness Up/Down` | O‘z tugmalari bo‘lmagan klaviaturalarda klaviatura yoritgichini yorqinroq/xiraroq qilish |
| `Mic Mute` | Mikrofonni o‘chirish |
| `Shift + Mute` | Audio chiqishini almashtirish |
| `Touchpad Toggle` | Sensor panelni yoqish yoki o‘chirish |
| `Display` key | Ish maydoni tartibi bo‘ylab aylanish |
| `Alt + Play` | Keyingi trek |
| `Alt + Shift + Play` | Oldingi trek |

## Ilovalarni ishga tushirish

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux terminali |
| `Super + Ctrl + Return` | Herdr (agent menejeri) |
| `Super + Shift + Return` or `Super + Shift + B`  | Brauzer    |
| `Super + Shift + Alt + B`           | Brauzer (maxfiy/incognito)    |
| `Super + Shift + F`           | Fayl menejeri    |
| `Super + Shift + Alt + F`           | Terminalning cwd sidagi fayl menejeri    |
| `Super + Shift + M`           | Musiqa (Spotify)    |
| `Super + Shift + Alt + M`           | Musiqa (cliamp)    |
| `Super + Shift + /`           | Parollar menejeri (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Kalkulyator (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, o‘rnatilgandan keyin)    |
| `Super + Shift + T`           | Faollik (btop)    |
| `Super + Shift + N`           | Muharrir (Plain yoki siz tanlagan standart)  |
| `Super + Shift + C`           | Kalendar ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Email ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Yangi email ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Standart agentingiz yoki bitta tanlaguningizcha ChatGPT |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Messenjer (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Messenjer (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Messenjer (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Yozish (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (yangi post) |
| `Super + Shift + Y`           | YouTube |

Bog‘lanishlarni `~/.config/hypr/bindings.lua` da o‘zgartiring/qo‘shing.

## Universal almashuv buferi

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + A`           | `Ctrl + A` ni qo‘llab-quvvatlaydigan ilovalarda hammasini tanlash    |
| `Super + C`           | Nusxalash    |
| `Super + X`           | Qirqish (terminalda emas)    |
| `Super + V`           | Qo‘yish    |
| `Super + Ctrl + V`           | Almashuv buferi menejeri    |

Odatda Linux da terminalda nusxalash va qo‘yish uchun `Ctrl + Shift + C/V`, qolgan hamma joyda esa `Ctrl + C/V` kerak bo‘ladi. Bu Omarchy birlashtirilgan almashuv buferi tezkor tugmalari hamma joyda ishlaydi.

## Suratga olish

| Tezkor tugma              | Vazifasi                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Skrinshot                      |
| `Super + Ctrl + Alt + C`            | Skrinshot (xuddi shu surat, Print Screen tugmasi bo‘lmagan klaviaturalar uchun) |
| `Super + Ctrl + C` | Suratga olish menyusi |
| `Alt + Print Screen`            | Ekran yozuvi                     |
| `Super + Shift + Ctrl + Alt + C` | Audiosiz ekran yozuvi, menyuni o‘tkazib yuborib (to‘xtatish uchun yana bosing) |
| `Super + Print Screen` | Rang tanlagich |
| `Super + Ctrl + Print Screen` | Matnni almashuv buferiga chiqarish |
| `Super + Alt + [` | Yozib olayotganda veb-kamera qoplamasini kichraytirish |
| `Super + Alt + ]` | Yozib olayotganda veb-kamera qoplamasini kattalashtirish |
| `Alt + Shift + L` | Veb-ilova yoki brauzerdan joriy URL ni nusxalash |
| `Alt + Shift + D` | Joriy sahifadagi videoni `~/Videos` ga yuklab olish |
| `Alt + Space` | Diktovkani boshlash/to‘xtatish (_Setup > Defaults > Dictation_ talab qilinadi) |
| `Right Alt` | Diktovka uchun ushlab turing (_Setup > Defaults > Dictation_ talab qilinadi) |

Ekran yozuvlarida tezkor tugma avval qaysi audioni xohlashingizni so‘raydi, keyin yozishni boshlaydi. To‘xtatish uchun uni yana bosing. Tafsilotlar uchun [skrinshotlar va yozib olish](12-screenshots-recording.md) ga qarang.

Barcha suratga olish variantlariga Omarchy menyusida (`Super + Space`) _Trigger > Capture_ ostida ham kirish mumkin.

## Bildirishnomalar

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + ,` | Eng so‘nggi bildirishnoma bo‘yicha amal qilish: uni ochish yoki uning yagona tugmasini bosish, uning variantlaridan tanlash yoki hech biri bo‘lmasa, uni rad etish  |
| `Super + Shift + ,` | Barcha bildirishnomalarni rad etish |
| `Super + Ctrl + ,` | Bildirishnomalarni klaviatura bilan boshqarish  |
| `Super + Alt + ,` | Eng so‘nggi bildirishnomani rad etish  |
| `Super + Shift + Alt + ,` | Bildirishnomalar tarixini ochish  |
| `Super + Ctrl + Alt + ,` | Bildirishnomalarni jim qilishni almashtirish  |

## Uslub

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Yangi mavzuni tanlash (shuningdek `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Mavzu fonini tanlash (shuningdek `Super + Ctrl + Space`) |
| `Super + Backspace` | Oynada shaffoflikni almashtirish |
| `Super + Ctrl + Backspace` | Bitta oynada kvadrat nisbatni almashtirish |

Qo‘shimcha fon rasmlari `~/.config/omarchy/backgrounds/<theme name>` da joylashadi. Omarchy menyusida _Install > Style > Background_ orqali ham mavjud.

Barcha uslub variantlariga Omarchy menyusida (`Super + Space`) _Appearance_ ostida ham kirish mumkin.

## Almashtirishlar

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Bo‘sh turganda qulflashni almashtirish |
| `Super + Ctrl + Delete` | Noutbuk displeyini yoqish/o‘chirishni almashtirish |
| `Super + Ctrl + Alt + Delete` | Noutbuk displeyini aks ettirishni almashtirish |
| `Super + Shift + Space` | Yuqori panelni almashtirish  |
| `Shift + Mute` | Keyingi audio chiqishiga o‘tish |
| `Shift + Play` | Keyingi media manbasiga o‘tish |
| `Super + Shift + Backspace` | Oyna oraliqlarini almashtirish |
| `Super + Ctrl + Alt + F` | To‘liq ekran ish stolini almashtirish (yuqori panel + oyna oraliqlari) |

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
| `Super + Ctrl + Alt + B` | Batareyni bildirishnoma sifatida ko‘rsatish  |
| `Super + Ctrl + Alt + W` | Ob-havoni bildirishnoma sifatida almashtirish  |

## Tmux

Prefiks tugmasi `Ctrl + Space` (`Ctrl + B` ham ishlaydi). Bu bog‘lanishlarni `~/.config/tmux/tmux.conf` da o‘zgartirishingiz mumkin.

### Panellar

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Prefix + v` | Panelni yoniga bo‘lish (vertikal) |
| `Prefix + h` | Panelni pastiga bo‘lish (gorizontal) |
| `Prefix + x` | Panelni tugatish |
| `Prefix + z` | Panel masshtabini almashtirish (to‘liq ekran) |
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
| `Prefix + r` | Oynani qayta nomlash |
| `Alt + 1-9` | Muayyan oynaga o‘tish |
| `Alt + Arrow Left/Right` | Oynalar o‘rtasida harakatlanish |
| `Alt + Shift + Arrow Left/Right` | Oynani chapga/o‘ngga ko‘chirish |

### Sessiyalar

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Prefix + C` | Yangi sessiya |
| `Prefix + K` | Sessiyani tugatish |
| `Prefix + R` | Sessiyani qayta nomlash |
| `Prefix + N` | Keyingi sessiya |
| `Prefix + P` | Oldingi sessiya |
| `Alt + Arrow Up/Down` | Sessiyalar o‘rtasida harakatlanish |
| `Prefix + s` | Sessiyalarni ro‘yxatlash |
| `Prefix + d` | Sessiyadan uzilish |

### Nusxalash rejimi (vi uslubi)

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Prefix + [` | Nusxalash rejimiga kirish |
| `v` | Tanlashni boshlash (nusxalash rejimida) |
| `y` | Tanlanganni nusxalash (nusxalash rejimida) |

### Umumiy

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Prefix + q` | Konfiguratsiyani qayta yuklash |
| `Prefix + ?` | Tmux tugma bog‘lanishlarini ko‘rsatish |
| `Prefix + :` | Buyruq satri |

### Tmux tartib funksiyalari

Bu funksiyalar Tmux sessiyasi ichida ishga tushirilishi kerak.

| Buyruq | Vazifasi |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Muharrir, AI va terminal bilan dev tartibini yaratish |
| `tdlm <ai> [<second_ai>]` | Har bir ichki katalog uchun dev tartibini yaratish |
| `tsl <count> <command>` | Ko‘p panelli swarm tartibini yaratish |

## Ghostty Terminal

Ghostty terminali Omarchy menyusi orqali _Install > Terminal_ yordamida o‘rnatiladi.

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Pastda yangi bo‘linish |
| `Ctrl + Shift + O` | Yonida yangi bo‘linish |
| `Ctrl + Alt + Arrows` | Bo‘linishlar o‘rtasida harakatlanish |
| `Super + Ctrl + Shift + Arrows` | Bo‘linish o‘lchamini 10 qatorga o‘zgartirish |
| `Super + Ctrl + Shift + Alt + Arrows` | Bo‘linish o‘lchamini 100 qatorga o‘zgartirish |
| `Ctrl + Shift + T` | Yangi varaq  |
| `Ctrl + Shift + Arrows` | Varaqlar o‘rtasida harakatlanish |
| `Alt + Numbers` | Muayyan varaqqa o‘tish |
| `Shift + Pg Up/Down` | Tarixni aylantirish |
| `Ctrl + Left mouse` | Havolani brauzerda ochish |

## Fayl menejeri

| Tezkor tugma              | Vazifasi                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Yo‘lga o‘tish                     |
| `Space`               | Faylni oldindan ko‘rish (o‘qlar navigatsiya qiladi) |
| `Alt + Up`       | Yuqoridagi ota katalogga o‘tish        |

## Neovim (w/ lazyvim)

### Navigatsiya

| Tezkor tugma                   | Vazifasi                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Buyruq variantlarini ko‘rsatish            |
| `Space Space`              | Faylni noaniq qidiruv orqali ochish      |
| `Space E`                  | Yon panelni almashtirish                  |
| `Space G G`                | git boshqaruvlarini ko‘rsatish               |
| `Space S G`                | Fayl mazmunini qidirish             |
| `Ctrl + W W`               | Yon panel va muharrir o‘rtasida sakrash |
| `Ctrl + Left/right arrow`  | Yon panel o‘lchamini o‘zgartirish          |
| `Shift + H`                      | Chapdagi fayl varag‘iga o‘tish             |
| `Shift + L`                      | O‘ngdagi fayl varag‘iga o‘tish            |
| `Space B D`                | Fayl varag‘ini yopish                  |

### Yon panelda bo‘lganda

| Tezkor tugma                   | Vazifasi                        |
| ------------------------ | ------------------------------- |
| `A`                        | Ota katalogda yangi fayl qo‘shish      |
| `Shift + A`                | Ota katalogda yangi ichki katalog qo‘shish    |
| `D`                        | Belgilangan fayl/katalogni o‘chirish     |
| `M`                        | Belgilangan fayl/katalogni ko‘chirish       |
| `R`                        | Belgilangan fayl/katalogni qayta nomlash     |
| `?`                        | Barcha buyruqlar uchun yordamni ko‘rsatish      |

[LazyVim tomonidan sozlangan barcha Neovim tezkor tugmalarini ko‘ring](https://www.lazyvim.org/keymaps).

## Tezkor emojilar

To‘liq emoji tanlagichni ko‘rsatish uchun `Super + Ctrl + E` dan foydalanishingiz mumkin, u tanlanganni almashuv buferiga qo‘yadi, yoki mana bu tezkor kirish variantlaridan foydalanishingiz mumkin.

| Tezkor tugma       | EM | Clue       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | smile      |
| `Shift + CapsLock M C` | 😂 | cry        |
| `Shift + CapsLock M L` | 😍 | love       |
| `Shift + CapsLock M V` | ✌️ | victory    |
| `Shift + CapsLock M H` | ❤️ | heart      |
| `Shift + CapsLock M Y` | 👍 | yes        |
| `Shift + CapsLock M N` | 👎 | no         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | wish       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | kiss       |
| `Shift + CapsLock M E` | 🙄 | eyeroll    |
| `Shift + CapsLock M I` | 😉 | wink       |
| `Shift + CapsLock M P` | 🙏 | pray |
| `Shift + CapsLock M D` | 🤤 | drool      |
| `Shift + CapsLock M M` | 💰 | money      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toast      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | greeting |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | blowing |

## Tezkor to‘ldirishlar

| Tezkor tugma       | To‘ldirish       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Ismingiz (sozlashda kiritilganidek)  |
| `Shift + CapsLock Space E` | Emailingiz (sozlashda kiritilganidek)  |

O‘zingiznikidan ko‘proq qo‘shish uchun `~/.XCompose` ni tahrirlang, keyin o‘zgarishlar qabul qilinishi uchun terminalda `omarchy restart xcompose` ni ishga tushiring.
