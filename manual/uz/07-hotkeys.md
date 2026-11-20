# Tezkor tugmalar

Barcha asosiy klaviatura bog‘lanishlarini `Super + K` bilan ko‘rishingiz mumkin (Tmux bog‘lanishlarini `Super + Alt + K` bilan va Herdr bog‘lanishlarini `Super + Ctrl + K` bilan).

## Tezkor tugmalar qanday joylashgan

Har bir tezkor tugma o‘z modifikatorlari belgilaydigan tekislikda joylashadi va har bir tekislikning bitta vazifasi bor. Tezkor tugmalar bir-biri bilan chalkashib ketmasligini aynan shu ta’minlaydi va bu odatda biror narsa qayerda joylashganini taxmin qila olishingizni bildiradi.

| Tekislik | U yerda nimalar joylashadi | Misollar |
| --- | --- | --- |
| `Super + key` | Tizim: oynalar, ish maydonlari, joylashuvlar va asosiy menyular | `Super + Space` Omarchy menyusi, `Super + W` oynani yopish, `Super + F` to‘liq ekran |
| `Super + Shift + key` | Ilovalar | `Super + Shift + B` brauzer, `Super + Shift + E` elektron pochta, `Super + Shift + N` muharrir |
| `Super + Ctrl + key` | Panellar va tizim menyulari | `Super + Ctrl + A` audio, `Super + Ctrl + N` tarmoq, `Super + Ctrl + C` suratga olish menyusi |
| `Super + Ctrl + Alt + key` | Tezkor harakatlar va bildirishnomalar | `Super + Ctrl + Alt + T` vaqtni ko‘rsatish, `Super + Ctrl + Alt + B` batareya, `Super + Ctrl + Alt + C` skrinshot |

Tezkor tugmaga `Alt` qo‘shish sizga xuddi shu narsaning variantini beradi, hech qachon aloqasiz narsani emas:

- `Super + Shift + B` brauzerni ochadi; `Super + Shift + Alt + B` shaxsiy oynani ochadi
- `Super + Shift + E` elektron pochtani ochadi; `Super + Shift + Alt + E` yangisini boshlaydi
- `Super + F` to‘liq ekranga o‘tadi; `Super + Alt + F` to‘liq kenglikka o‘tadi
- `Super + Ctrl + C` suratga olish menyusini ochadi; `Super + Ctrl + Alt + C` menyuni o‘tkazib yuboradi va skrinshot oladi

Tezkor tugma qo‘shayotganda:

1. Avval u nima qilishiga qarab tekislikni, keyin tugmani tanlang.
2. Joy bo‘shatish uchun mavjud tezkor tugmani ko‘chirmang. To‘g‘ri tekislikda bo‘sh tugmani toping.
3. `Alt` ni faqat usiz tezkor tugmaning varianti uchungina ishlating.

Bir nechta tezkor tugmalar qulay bo‘lgani uchun bu qoidalarni buzadi. Strelka yoki `Tab` bilan `Shift` ilovani ochish o‘rniga ko‘chiradi yoki orqaga o‘tkazadi, `Print`, media tugmalari, `Alt + Tab` va `Ctrl + Alt + Del` esa hamma joyda qanday bo‘lsa, shunday ishlaydi. Bular istisnolar, ko‘chirish uchun namunalar emas.

Agar standart variant sizga mos kelmasa (aytaylik, Windows dagi kabi skrinshotlar uchun `Super + Shift + S` ni istaysiz), uni `~/.config/hypr/bindings.lua` da qayta bog‘lang.

## Navigatsiya

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menyusi (ilovalar va boshqa hamma narsa)    |
| `Super + Alt + Space` | Ilovalar panjarasi |
| `Super + Escape` | Tizim menyusi (to‘xtatib turish, qayta ishga tushirish va h.k.)  |
| `Super + Ctrl + L` | Kompyuterni qulflash |
| `Super + W` yoki `Super + Q` | Oynani yopish             |
| `Ctrl + Alt + Del` | Barcha oynalarni yopish |
| `Super + K` | Barcha tezkor tugmalarni ko‘rsatish |
| `Super + Alt + K` | tmux tezkor tugmalarini ko‘rsatish |
| `Super + Ctrl + K` | herdr tezkor tugmalarini ko‘rsatish |
| `Super + M` | Oynani dokga kichraytirish |
| `Super + T`               | Oynani plitka/suzuvchi rejim o‘rtasida almashtirish             |
| `Super + J` | Oyna pozitsiyasini almashtirish (gorizontal/vertikal) |
| `Super + O`               | Oynani yopishqoq suzuvchi holatga chiqarishni almashtirish |
| `Super + L`               | dwindle, scrolling va floating joylashuvlari bo‘ylab aylanish |
| `Super + Alt + L`         | Joylashuvlar bo‘ylab teskari aylanish |
| `Super + P`               | Soxta oyna uslubini almashtirish (tabiiy va cho‘zilgan) |
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
| `Super + Grave` | Quake konsolini almashtirish |
| `Super + Shift + Grave` | Oynani Quake konsoliga ko‘chirish |
| `Super + Shift + Ctrl + Arrows` | Oynani shu yo‘nalishdagi monitorga ko‘chirish |
| `Super + Shift + Alt + Arrows` | Ish maydonini shu yo‘nalishdagi monitorga ko‘chirish |
| `Super + Arrow`  | Fokusni strelka yo‘nalishidagi oynaga ko‘chirish, ekran chetida shu tomondagi monitorga o‘tish |
| `Super + Shift + Arrow`  | Oynani strelka yo‘nalishidagi boshqa oyna bilan almashtirish, shu tomondagi monitordagi oynani ham qo‘shib |
| `Super + Minus` | Oynani chapga kengaytirish |
| `Super + Equal` | Oynani chapga kichraytirish |
| `Super + Shift + Minus` | Oynani yuqoriga kichraytirish |
| `Super + Shift + Equal` | Oynani pastga kengaytirish |
| `Super + Alt + Minus/Equal` | Xuddi shu o‘lcham o‘zgartirish kichikroq qadamlar bilan |
| `Super + Ctrl + Minus/Equal` | Xuddi shu o‘lcham o‘zgartirish kattaroq qadamlar bilan |
| `Super + Alt + Home` | Oyna kengligini saqlash |
| `Super + Home` | Saqlangan oyna kengligini tiklash |
| `Super + Left Mouse` | Oynani sudrab ko‘chirish |
| `Super + Right Mouse` | Oyna o‘lchamini o‘zgartirish |
| `Super + Scroll Wheel` | Fokusdagi monitorda ish maydonlari bo‘ylab aylantirish |
| `Super + G`               | Oynalarni guruhlashni almashtirish      |
| `Super + Alt + G`               | Oynani guruhdan chiqarish      |
| `Super + Alt + Tab`               | Guruhdagi oynalar o‘rtasida aylanish      |
| `Super + Alt + Shift + Tab`               | Guruhdagi oynalar o‘rtasida orqaga aylanish      |
| `Super + Alt + Scroll Wheel` | Guruhdagi oynalar o‘rtasida aylanish |
| `Super + Alt + 1/2/3/4/5`               | Guruhdagi muayyan oynaga o‘tish      |
| `Super + Alt + Arrow`  | Oynani strelka yo‘nalishida guruhga ko‘chirish, shu tomondagi monitordagi oynani ham qo‘shib |
| `Super + Ctrl + Left/Right`  | Plitka guruhi ichidagi oynalar o‘rtasida harakatlanish |
| `Super + Ctrl + Z` | Ekranni yaqinlashtirish (ko‘proq yaqinlashtirish uchun takrorlang) |
| `Super + Ctrl + Alt + Z` | Ekrandan to‘liq uzoqlashish |
| `Super + /` | Monitor masshtablash variantlari bo‘ylab oldinga qadamlash |
| `Super + Alt + /` | Monitor masshtablash variantlari bo‘ylab orqaga qadamlash |
| `Alt + Tab` | Faol ish maydonidagi oynalar bo‘ylab oldinga aylanish |
| `Alt + Shift + Tab` | Faol ish maydonidagi oynalar bo‘ylab orqaga aylanish |
| `Ctrl + Alt + Tab`| Monitorlar bo‘ylab fokusni oldinga aylantirish |
| `Ctrl + Alt + Shift + Tab`| Monitorlar bo‘ylab fokusni orqaga aylantirish |
| `Super + I` | Kiritish tilini almashtirish (bittadan ortiq joylashuv yoki kiritish usuli bilan) |
| `Super + Shift + I` | Kiritish tilini orqaga almashtirish |

Sensor panelda uch va to‘rt barmoqli surishlar ish maydonlarini almashtiradi, oynalarni ko‘chiradi hamda menyu va Quake konsolini ochadi; ishoralar uchun [klaviatura, sichqoncha va trekpad](34-keyboard-mouse-trackpad.md) ga qarang.

O‘lcham o‘zgartirish yorliqlari klaviaturada bosilgan belgilardan qat’i nazar fizik `code:20` va `code:21` tugmalarini (XKB `<AE11>` va `<AE12>`) ishlatadi. AQSH klaviaturalarida bu tugmalar `-` va `=`; yapon (JIS) klaviaturalarida ular `-` va `^`; ispan klaviaturalarida ular `'` va `¡`. JIS da `Super + ^` — `Super + Equal`, `Super + Shift + -` esa (`=` ni yozadi) `Super + Shift + Minus` dir.

## Tizim boshqaruvi

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Audio paneli    |
| `Super + Ctrl + B`           | Bluetooth paneli    |
| `Super + Ctrl + N`           | Wi-Fi/tarmoq paneli    |
| `Super + Ctrl + D`           | Display paneli    |
| `Super + Ctrl + P`           | Quvvat paneli    |
| `Super + Ctrl + X`           | Agents paneli    |
| `Super + Ctrl + Alt + D`           | Kalendar paneli    |
| `Super + Ctrl + Alt + E`           | Dunyo soati paneli    |
| `Super + Ctrl + 1-9`           | Panelni pozitsiyasi bo‘yicha almashtirish    |
| `Super + Ctrl + S` | Ulashish menyusi (LocalSend orqali) |
| `Super + Ctrl + C` | Suratga olish boshqaruvi (skrinshot/yozib olish/tanlagich) |
| `Super + Ctrl + O` | Menyuni almashtirish |
| `Super + Ctrl + H` | Uskuna menyusi |
| `Super + Ctrl + E` | Emoji tanlagich |
| `Super + Ctrl + .` | Mediani transkodlash |
| `Super + Shift + Ctrl + A` | AI agentni tanlash |
| `Power` tugmasi | Tizim menyusi |
| `Super + Shift + Copilot` tugmasi | Omarchy menyusi |

## Sozlashlar

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Ekran yorqinligining maksimumi |
| `Shift + Brightness Down` | Ekran yorqinligining minimumi |
| `Alt + Brightness Up/Down` | Aniq 1% yorqinlik o‘zgarishlari |
| `Alt + Volume Up/Down` | Aniq 1% ovoz o‘zgarishlari |
| `Keyboard Brightness Up/Down` | Klaviatura yoritgichi yorqinroq/xiraroq |
| `Keyboard Backlight` | Klaviatura yoritgichi darajalarini aylantirish |
| `Ctrl + Brightness Up/Down` | Klaviatura yoritgichi yorqinroq/xiraroq, o‘z tugmalari bo‘lmagan klaviaturalarda |
| `Mic Mute` | Mikrofonni o‘chirish |
| `Shift + Mute` | Audio chiqishni almashtirish |
| `Touchpad Toggle` | Sensor panelni yoqish yoki o‘chirish |
| `Display` tugmasi | Ish maydoni joylashuvini aylantirish |
| `Alt + Play` | Keyingi trek |
| `Alt + Shift + Play` | Oldingi trek |

## Ilovalarni ishga tushirish

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux terminali |
| `Super + Ctrl + Return` | Herdr (agent boshqaruvchisi) |
| `Super + Shift + Return` yoki `Super + Shift + B`  | Brauzer    |
| `Super + Shift + Alt + B`           | Brauzer (shaxsiy/incognito)    |
| `Super + Shift + F`           | Fayl boshqaruvchisi    |
| `Super + Shift + Alt + F`           | Terminalning cwd dagi fayl boshqaruvchisi    |
| `Super + Shift + M`           | Musiqa (Spotify)    |
| `Super + Shift + Alt + M`           | Musiqa (cliamp)    |
| `Super + Shift + /`           | Parol boshqaruvchisi (1password)    |
| `Super + Shift + Q` yoki `Calculator` tugmasi  | Kalkulyator (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, o‘rnatilgandan keyin)    |
| `Super + Shift + T`           | Faollik (btop)    |
| `Super + Shift + N`           | Muharrir (Plain yoki siz tanlagan standart)  |
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
| `Super + Shift + Alt + X`           | X (yangi post) |
| `Super + Shift + Y`           | YouTube |

Bog‘lanishlarni `~/.config/hypr/bindings.lua` da o‘zgartiring/qo‘shing.

## Universal almashuv buferi

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + A`           | `Ctrl + A` ni qo‘llab-quvvatlaydigan ilovalarda hammasini tanlash    |
| `Super + C`           | Nusxalash    |
| `Super + X`           | Kesish (terminalda emas)    |
| `Super + V`           | Qo‘yish    |
| `Super + Ctrl + V`           | Almashuv buferi boshqaruvchisi    |

Odatda Linux da terminalda nusxalash va qo‘yish uchun `Ctrl + Shift + C/V`, boshqa hamma joyda buni qilish uchun esa `Ctrl + C/V` kerak bo‘ladi. Bu Omarchy ning birlashtirilgan almashuv buferi tezkor tugmalari hamma joyda ishlaydi.

## Suratga olish

| Tezkor tugma              | Vazifasi                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Skrinshot                      |
| `Super + Ctrl + Alt + C`            | Skrinshot (xuddi shu surat, Print Screen tugmasi bo‘lmagan klaviaturalar uchun) |
| `Super + Ctrl + C` | Suratga olish menyusi |
| `Alt + Print Screen`            | Ekranni yozib olish                     |
| `Super + Shift + Ctrl + Alt + C` | Audiosiz, menyuni o‘tkazib yuborib ekranni yozib olish (to‘xtatish uchun yana bosing) |
| `Super + Print Screen` | Rang tanlagich |
| `Super + Ctrl + Print Screen` | Matnni almashuv buferiga chiqarish |
| `Super + Alt + [` | Yozib olish paytida veb-kamera qoplamasini kichikroq qilish |
| `Super + Alt + ]` | Yozib olish paytida veb-kamera qoplamasini kattaroq qilish |
| `Alt + Shift + L` | Veb-ilova yoki brauzerdan joriy URL ni nusxalash |
| `Alt + Shift + D` | Joriy sahifadagi videoni `~/Videos` ga yuklab olish |
| `Alt + Space` | Diktovkani boshlash/to‘xtatish (_Setup > Defaults > Dictation_ talab qilinadi) |
| `Right Alt` | Diktovka uchun bosib turish (_Setup > Defaults > Dictation_ talab qilinadi) |

Ekran yozuvlari bilan tezkor tugma avval qaysi audioni istashingizni so‘raydi, keyin yozishni boshlaydi. To‘xtatish uchun uni yana bosing. Tafsilotlar uchun [skrinshotlar va yozib olish](12-screenshots-recording.md) ga qarang.

Barcha suratga olish variantlariga Omarchy menyusidagi (`Super + Space`) _Trigger > Capture_ ostida ham kirish mumkin.

## Bildirishnomalar

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + ,` | Eng so‘nggi bildirishnoma bo‘yicha harakat qilish: uni ochish yoki uning yagona tugmasini bosish, variantlaridan tanlash yoki hech biri bo‘lmasa uni yopish  |
| `Super + Shift + ,` | Barcha bildirishnomalarni yopish |
| `Super + Ctrl + ,` | Bildirishnomalarni klaviatura bilan boshqarish  |
| `Super + Alt + ,` | Eng so‘nggi bildirishnomani yopish  |
| `Super + Shift + Alt + ,` | Bildirishnomalar tarixini ochish  |
| `Super + Ctrl + Alt + ,` | Bildirishnomalarni jim qilishni almashtirish  |

## Uslub

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Yangi mavzuni tanlash (shuningdek `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Mavzu fonini tanlash (shuningdek `Super + Ctrl + Space`) |
| `Super + Backspace` | Oynada shaffoflikni almashtirish |
| `Super + Ctrl + Backspace` | Bitta oynada kvadrat tomonlar nisbatini almashtirish |

Qo‘shimcha fon rasmlari `~/.config/omarchy/backgrounds/<theme name>` da joylashadi. Omarchy menyusidagi _Install > Style > Background_ orqali ham mavjud.

Barcha uslub variantlariga Omarchy menyusidagi (`Super + Space`) _Appearance_ ostida ham kirish mumkin.

## Almashtirishlar

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Bekor turganda qulflashni almashtirish |
| `Super + Ctrl + Delete` | Noutbuk displeyini yoqish/o‘chirishni almashtirish |
| `Super + Ctrl + Alt + Delete` | Noutbuk displeyini aks ettirishni almashtirish |
| `Super + Shift + Space` | Yuqori panelni almashtirish  |
| `Shift + Mute` | Keyingi audio chiqishga o‘tish |
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

Prefiks tugmasi `Ctrl + Space` (`Ctrl + B` ham ishlaydi). Bu bog‘lanishlarni `~/.config/tmux/tmux.conf` da o‘zgartirishingiz mumkin.

### Panellar

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Prefix + v` | Panelni yoniga bo‘lish (vertikal) |
| `Prefix + h` | Panelni pastiga bo‘lish (gorizontal) |
| `Prefix + x` | Panelni yopish |
| `Prefix + z` | Panelni kattalashtirishni almashtirish (to‘liq ekran) |
| `Alt + Enter` | Panelni pastiga bo‘lish (prefikssiz) |
| `Alt + Shift + Enter` | Panelni yoniga bo‘lish (prefikssiz) |
| `Alt + Escape` | Panelni yopish (prefikssiz) |
| `Ctrl + Alt + Arrows` | Panellar o‘rtasida harakatlanish |
| `Ctrl + Alt + Shift + Arrows` | Panellar o‘lchamini o‘zgartirish |

### Oynalar

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Prefix + c` | Yangi oyna |
| `Prefix + k` | Oynani yopish |
| `Prefix + r` | Oyna nomini o‘zgartirish |
| `Alt + 1-9` | Muayyan oynaga o‘tish |
| `Alt + Arrow Left/Right` | Oynalar o‘rtasida harakatlanish |
| `Alt + Shift + Arrow Left/Right` | Oynani chapga/o‘ngga ko‘chirish |

### Sessiyalar

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Prefix + C` | Yangi sessiya |
| `Prefix + K` | Sessiyani yopish |
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
| `y` | Tanlovni nusxalash (nusxalash rejimida) |

### Umumiy

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Prefix + q` | Konfiguratsiyani qayta yuklash |
| `Prefix + ?` | Tmux tugma bog‘lanishlarini ko‘rsatish |
| `Prefix + :` | Buyruq satri |

### Tmux joylashuv funksiyalari

Bu funksiyalar Tmux sessiyasi ichida ishga tushirilishi kerak.

| Buyruq | Vazifasi |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Muharrir, AI va terminal bilan dasturchi joylashuvini yaratish |
| `tdlm <ai> [<second_ai>]` | Har bir ichki katalog uchun dasturchi joylashuvini yaratish |
| `tsl <count> <command>` | Ko‘p panelli swarm joylashuvini yaratish |

## Ghostty Terminal

Ghostty terminali Omarchy menyusi orqali _Install > Terminal_ yordamida o‘rnatiladi.

| Tezkor tugma                  | Vazifasi              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Pastda yangi bo‘linish |
| `Ctrl + Shift + O` | Yonida yangi bo‘linish |
| `Ctrl + Alt + Arrows` | Bo‘linishlar o‘rtasida harakatlanish |
| `Super + Ctrl + Shift + Arrows` | Bo‘linish o‘lchamini 10 satrga o‘zgartirish |
| `Super + Ctrl + Shift + Alt + Arrows` | Bo‘linish o‘lchamini 100 satrga o‘zgartirish |
| `Ctrl + Shift + T` | Yangi varaq  |
| `Ctrl + Shift + Arrows` | Varaqlar o‘rtasida harakatlanish |
| `Alt + Numbers` | Muayyan varaqqa o‘tish |
| `Shift + Pg Up/Down` | Tarixni aylantirish |
| `Ctrl + Left mouse` | Havolani brauzerda ochish |

## Fayl boshqaruvchisi

| Tezkor tugma              | Vazifasi                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Yo‘lga o‘tish                     |
| `Space`               | Faylni oldindan ko‘rish (strelkalar navigatsiya qiladi) |
| `Alt + Up`       | Yuqoridagi ota katalogga o‘tish        |

## Neovim (lazyvim bilan)

### Navigatsiya

| Tezkor tugma                   | Vazifasi                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Buyruq variantlarini ko‘rsatish            |
| `Space Space`              | Faylni noaniq qidiruv orqali ochish      |
| `Space E`                  | Yon panelni almashtirish                  |
| `Space G G`                | git boshqaruvini ko‘rsatish               |
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
| `Shift + A`                | Ota katalogda yangi ichki katalog qo‘shish    |
| `D`                        | Belgilangan fayl/katalogni o‘chirish     |
| `M`                        | Belgilangan fayl/katalogni ko‘chirish       |
| `R`                        | Belgilangan fayl/katalog nomini o‘zgartirish     |
| `?`                        | Barcha buyruqlar uchun yordamni ko‘rsatish      |

[LazyVim tomonidan sozlangan barcha Neovim tezkor tugmalarini ko‘ring](https://www.lazyvim.org/keymaps).

## Tezkor emojilar

To‘liq emoji tanlagichni ko‘rsatish uchun `Super + Ctrl + E` dan foydalanishingiz mumkin, u tanlovni almashuv buferiga qo‘yadi, yoki ushbu tezkor kirish variantlaridan foydalanishingiz mumkin.

| Tezkor tugma       | EM | Ishora       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | tabassum      |
| `Shift + CapsLock M C` | 😂 | yig‘i        |
| `Shift + CapsLock M L` | 😍 | sevgi       |
| `Shift + CapsLock M V` | ✌️ | g‘alaba    |
| `Shift + CapsLock M H` | ❤️ | yurak      |
| `Shift + CapsLock M Y` | 👍 | ha        |
| `Shift + CapsLock M N` | 👎 | yo‘q         |
| `Shift + CapsLock M F` | 🖕 | so‘kinish       |
| `Shift + CapsLock M W` | 🤞 | tilak       |
| `Shift + CapsLock M R` | 🤘 | rok       |
| `Shift + CapsLock M K` | 😘 | o‘pish       |
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
| `Shift + CapsLock Space N` | Ismingiz (o‘rnatishda kiritilganidek)  |
| `Shift + CapsLock Space E` | Elektron pochtangiz (o‘rnatishda kiritilganidek)  |

`~/.XCompose` ni tahrirlash orqali o‘zingiznikidan ko‘proq qo‘shishingiz mumkin, keyin o‘zgarishlar qabul qilinishi uchun terminalda `omarchy restart xcompose` ni ishga tushiring.
