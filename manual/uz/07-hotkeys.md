# Tezkor klavishlar

Barcha asosiy klaviatura bog‘lanishlarini `Super + K` bilan ko‘rishingiz mumkin (Tmux bog‘lanishlari `Super + Alt + K` bilan va Herdr bog‘lanishlari `Super + Ctrl + K` bilan).

## Tezkor klavishlar qanday joylashtirilgan

Har bir tezkor klavish o‘z modifikatorlari bilan belgilanadigan tekislikda joylashadi va har bir tekislikning bitta vazifasi bor. Tezkor klavishlarning bir-biriga aralashib ketmasligini aynan shu ta’minlaydi va bu odatda biror narsa qayerda joylashganini taxmin qila olishingizni anglatadi.

| Tekislik | U yerda nimalar joylashadi | Misollar |
| --- | --- | --- |
| `Super + key` | Tizim: oynalar, ish maydonlari, joylashuvlar va asosiy menyular | `Super + Space` Omarchy menyusi, `Super + W` oynani yopish, `Super + F` to‘liq ekran |
| `Super + Shift + key` | Ilovalar | `Super + Shift + B` brauzer, `Super + Shift + E` elektron pochta, `Super + Shift + N` muharrir |
| `Super + Ctrl + key` | Panellar va tizim menyulari | `Super + Ctrl + A` audio, `Super + Ctrl + N` tarmoq, `Super + Ctrl + C` suratga olish menyusi |
| `Super + Ctrl + Alt + key` | Tezkor amallar va xabarnomalar | `Super + Ctrl + Alt + T` vaqtni ko‘rsatish, `Super + Ctrl + Alt + B` batareya, `Super + Ctrl + Alt + C` skrinshot |

Tezkor klavishga `Alt` qo‘shish sizga xuddi shu narsaning variantini beradi, hech qachon aloqasiz narsani emas:

- `Super + Shift + B` brauzerni ochadi; `Super + Shift + Alt + B` shaxsiy oynani ochadi
- `Super + Shift + E` elektron pochtani ochadi; `Super + Shift + Alt + E` yangisini boshlaydi
- `Super + F` to‘liq ekranga o‘tadi; `Super + Alt + F` to‘liq kenglikka o‘tadi
- `Super + Ctrl + C` suratga olish menyusini ochadi; `Super + Ctrl + Alt + C` menyuni o‘tkazib yuborib, skrinshot oladi

Tezkor klavish qo‘shayotganda:

1. U nima qilishiga qarab tekislikni tanlang, keyin klavishni tanlang.
2. Joy bo‘shatish uchun mavjud tezkor klavishni ko‘chirmang. To‘g‘ri tekislikda bo‘sh klavishni toping.
3. `Alt` dan faqat usiz bo‘lgan tezkor klavishning varianti uchungina foydalaning.

Bir nechta tezkor klavishlar qulay bo‘lgani uchun bu qoidalarni buzadi. O‘q yoki `Tab` bilan `Shift` ilovani ochish o‘rniga ko‘chiradi yoki teskari yo‘nalishda bajaradi, `Print`, media klavishlari, `Alt + Tab` va `Ctrl + Alt + Del` esa hamma joyda qanday ishlasa, shunday ishlaydi. Ular istisnolar, ko‘chirish uchun namunalar emas.

Agar standart variant sizga mos kelmasa (masalan, Windows dagidek skrinshotlar uchun `Super + Shift + S` ni xohlasangiz), uni `~/.config/hypr/bindings.lua` da qayta bog‘lang.

## Navigatsiya

| Tezkor klavish                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menyusi (ilovalar va qolgan hamma narsa)    |
| `Super + Alt + Space` | Ilovalar panjarasi |
| `Super + Escape` | Tizim menyusi (kutish rejimi, qayta ishga tushirish va h.k.)  |
| `Super + Ctrl + L` | Kompyuterni qulflash |
| `Super + W` yoki `Super + Q` | Oynani yopish             |
| `Ctrl + Alt + Del` | Barcha oynalarni yopish |
| `Super + K` | Barcha tezkor klavishlarni ko‘rsatish |
| `Super + Alt + K` | Tmux tezkor klavishlarini ko‘rsatish |
| `Super + Ctrl + K` | Herdr tezkor klavishlarini ko‘rsatish |
| `Super + M` | Oynani dokka kichraytirish |
| `Super + T`               | Oynani kafel/suzuvchi rejimlar orasida almashtirish             |
| `Super + J` | Oyna holatini almashtirish (gorizontal/vertikal) |
| `Super + O`               | Oynani sticky'n'floating holatiga chiqarishni almashtirish |
| `Super + L`               | Dwindle, scrolling va floating joylashuvlari orasida aylanish |
| `Super + Alt + L`         | Joylashuvlar orasida teskari yo‘nalishda aylanish |
| `Super + P`               | Pseudo oyna uslubini almashtirish (tabiiy va cho‘zilgan) |
| `Super + F`                 | To‘liq ekranga o‘tish              |
| `Super + Alt + F`                 | To‘liq kenglikka o‘tish              |
| `Super + Ctrl + F`                 | Oyna ichida to‘liq ekranga o‘tish              |
| `Super + 1…9/0`         | Fokusdagi monitorda muayyan ish maydoniga o‘tish (0 — bu 10) |
| `Super + Tab` | Fokusdagi monitorda keyingi ish maydoniga o‘tish |
| `Super + Shift + Tab` | Fokusdagi monitorda oldingi ish maydoniga o‘tish |
| `Super + Ctrl + Tab` | Fokusdagi monitorda avvalgi ish maydoniga o‘tish |
| `Super + Shift + 1…9/0` | Oynani fokusdagi monitordagi ish maydoniga ko‘chirish |
| `Super + Shift + Alt + 1…9/0` | Oynani fokusdagi monitordagi ish maydoniga ortidan bormasdan ko‘chirish |
| `Super + S` | To‘liq scratchpad ni almashtirish |
| `Super + Alt + S` | Oynani to‘liq scratchpad ga ko‘chirish |
| `Super + the key above Tab` (AQSh joylashuvlarida grave) | Quake konsolini almashtirish |
| `Super + Shift + the key above Tab` (AQSh joylashuvlarida grave) | Oynani Quake konsoliga ko‘chirish |
| `Super + Shift + Ctrl + Arrows` | Oynani shu yo‘nalishdagi monitorga ko‘chirish |
| `Super + Shift + Alt + Arrows` | Ish maydonini shu yo‘nalishdagi monitorga ko‘chirish |
| `Super + Arrow`  | Fokusni o‘q yo‘nalishidagi oynaga ko‘chirish, ekran chetida shu tomondagi monitorga o‘tish |
| `Super + Shift + Arrow`  | Oynani o‘q yo‘nalishidagi boshqa oyna bilan almashtirish, shu tomondagi monitordagi oynani ham qo‘shib |
| `Super + Minus` | Oynani chapga kengaytirish |
| `Super + Equal` | Oynani chapga kichraytirish |
| `Super + Shift + Minus` | Oynani yuqoriga kichraytirish |
| `Super + Shift + Equal` | Oynani pastga kengaytirish |
| `Super + Alt + Minus/Equal` | Xuddi shu o‘lcham o‘zgartirish kichikroq qadamlar bilan |
| `Super + Ctrl + Minus/Equal` | Xuddi shu o‘lcham o‘zgartirish kattaroq qadamlar bilan |
| `Super + Alt + Home` | Oyna kengligini saqlash |
| `Super + Home` | Saqlangan oyna kengligini tiklash |
| `Super + Left Mouse` | Oynani sudrab yurish |
| `Super + Right Mouse` | Oyna o‘lchamini o‘zgartirish |
| `Super + Scroll Wheel` | Fokusdagi monitorda ish maydonlari orasida aylantirish |
| `Super + G`               | Oynalarni guruhlashni almashtirish      |
| `Super + Alt + G`               | Oynani guruhdan chiqarish      |
| `Super + Alt + Tab`               | Guruhdagi oynalar orasida aylanish      |
| `Super + Alt + Shift + Tab`               | Guruhdagi oynalar orasida orqaga aylanish      |
| `Super + Alt + Scroll Wheel` | Guruhdagi oynalar orasida aylanish |
| `Super + Alt + 1/2/3/4/5`               | Guruhdagi muayyan oynaga o‘tish      |
| `Super + Alt + Arrow`  | Oynani o‘q yo‘nalishida guruhga ko‘chirish, shu tomondagi monitordagi oynani ham qo‘shib |
| `Super + Ctrl + Left/Right`  | Kafel guruhi ichidagi oynalar orasida harakatlanish |
| `Super + Ctrl + Z` | Ekranni yaqinlashtirish (ko‘proq yaqinlashtirish uchun takrorlang) |
| `Super + Ctrl + Alt + Z` | Ekrandan to‘liq uzoqlashtirish |
| `Super + /` | Monitor masshtabi variantlari bo‘ylab oldinga qadam tashlash |
| `Super + Alt + /` | Monitor masshtabi variantlari bo‘ylab orqaga qadam tashlash |
| `Alt + Tab` | Faol ish maydonidagi oynalar orasida oldinga aylanish |
| `Alt + Shift + Tab` | Faol ish maydonidagi oynalar orasida orqaga aylanish |
| `Ctrl + Alt + Tab`| Monitorlar orasida fokusni oldinga aylantirish |
| `Ctrl + Alt + Shift + Tab`| Monitorlar orasida fokusni orqaga aylantirish |
| `Super + I` | Kiritish tilini almashtirish (bittadan ortiq joylashuv yoki kiritish usuli bo‘lsa) |
| `Super + Shift + I` | Kiritish tilini orqaga almashtirish |

Sensor panelda uch va to‘rt barmoqli surishlar ish maydonlarini almashtiradi, oynalarni ko‘chiradi hamda menyu va Quake konsolini ochadi; imo-ishoralar uchun [klaviatura, sichqoncha va trekpad](34-keyboard-mouse-trackpad.md) ga qarang.

O‘lcham o‘zgartirish 0 ning o‘ng tomonidagi ikkita klavishdan foydalanadi, klaviaturangizda ularga nima yozilganidan qat’i nazar: AQSh klaviaturalarida `-` va `=`, Daniya va Shvetsiya klaviaturalarida `+` va `´`, Norvegiya klaviaturasida `+` va `\\`, Nemis klaviaturasida `ß` va `´`, Ispan klaviaturasida `'` va `¡`, Yapon (JIS) klaviaturasida esa `-` va `^`. `Super + K` ularni klaviaturangizda qanday yozilgan bo‘lsa, shunday ro‘yxatlaydi. JIS da `Super + ^` — bu `Super + Equal`, `Super + Shift + -` (u `=` ni yozadi) esa `Super + Shift + Minus` dir. Monitor masshtabi va parollar menejeri `/` dan foydalanadi; `/` ni faqat Shift bilan yozadigan joylashuvlarda, aksariyat Yevropa joylashuvlarida bo‘lgani kabi, ular o‘ng Shift ning chap tomonidagi klavishdan foydalanadi (Daniya va Nemis joylashuvlarida `-`).

## Tizim boshqaruvi

| Tezkor klavish                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Audio paneli    |
| `Super + Ctrl + B`           | Bluetooth paneli    |
| `Super + Ctrl + N`           | Wifi/tarmoq paneli    |
| `Super + Ctrl + D`           | Displey paneli    |
| `Super + Ctrl + P`           | Quvvat paneli    |
| `Super + Ctrl + X`           | Agentlar paneli    |
| `Super + Ctrl + Alt + D`           | Kalendar paneli    |
| `Super + Ctrl + Alt + E`           | Jahon soati paneli    |
| `Super + Ctrl + 1-9`           | Bar panelini pozitsiyasi bo‘yicha almashtirish    |
| `Super + Ctrl + S` | Ulashish menyusi (LocalSend orqali) |
| `Super + Ctrl + C` | Suratga olish boshqaruvi (skrinshot/yozib olish/tanlagich) |
| `Super + Ctrl + O` | Menyuni almashtirish |
| `Super + Ctrl + H` | Uskuna menyusi |
| `Super + Ctrl + E` | Emoji tanlagichi |
| `Super + Ctrl + .` | Medianı transkodlash |
| `Super + Shift + Ctrl + A` | Standart agentingizni ishga tushirish |
| `Power` klavishi | Tizim menyusi |
| `Super + Shift + Copilot` klavishi | Omarchy menyusi |

## Sozlashlar

| Tezkor klavish                  | Funksiya              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Ekranning maksimal yorqinligi |
| `Shift + Brightness Down` | Ekranning minimal yorqinligi |
| `Alt + Brightness Up/Down` | Yorqinlikni aniq 1% ga o‘zgartirish |
| `Alt + Volume Up/Down` | Ovoz balandligini aniq 1% ga o‘zgartirish |
| `Keyboard Brightness Up/Down` | Klaviatura yoritgichi yorqinroq/xiraroq |
| `Keyboard Backlight` | Klaviatura yoritgichi darajalari orasida aylanish |
| `Ctrl + Brightness Up/Down` | Klaviatura yoritgichi yorqinroq/xiraroq, o‘z klavishlariga ega bo‘lmagan klaviaturalarda |
| `Mic Mute` | Mikrofonni o‘chirish |
| `Shift + Mute` | Audio chiqishini almashtirish |
| `Touchpad Toggle` | Sensor panelni yoqish yoki o‘chirish |
| `Display` klavishi | Ish maydoni joylashuvini aylantirish |
| `Alt + Play` | Keyingi trek |
| `Alt + Shift + Play` | Oldingi trek |

## Ilovalarni ishga tushirish

| Tezkor klavish                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux terminali |
| `Super + Ctrl + Return` | Herdr (agent menejeri) |
| `Super + Shift + Return` yoki `Super + Shift + B`  | Brauzer    |
| `Super + Shift + Alt + B`           | Brauzer (shaxsiy/incognito)    |
| `Super + Shift + F`           | Fayl menejeri    |
| `Super + Shift + Alt + F`           | Terminalning cwd katalogidagi fayl menejeri    |
| `Super + Shift + M`           | Musiqa (Spotify)    |
| `Super + Shift + Alt + M`           | Musiqa (cliamp)    |
| `Super + Shift + /`           | Parollar menejeri (1password)    |
| `Super + Shift + Q` yoki `Calculator` klavishi  | Kalkulyator (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, o‘rnatilgandan keyin)    |
| `Super + Shift + T`           | Faollik (btop)    |
| `Super + Shift + N`           | Muharrir (Plain yoki siz tanlagan standart)  |
| `Super + Shift + C`           | Kalendar ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Elektron pochta ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Yangi elektron pochta ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
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

## Universal almashish buferi

| Tezkor klavish                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + A`           | `Ctrl + A` ni qo‘llab-quvvatlaydigan ilovalarda hammasini tanlash    |
| `Super + C`           | Nusxalash    |
| `Super + X`           | Kesish (terminalda emas)    |
| `Super + V`           | Qo‘yish    |
| `Super + Ctrl + V`           | Almashish buferi menejeri    |

Odatda Linux da terminalda nusxalash va qo‘yish uchun `Ctrl + Shift + C/V`, qolgan hamma joyda bajarish uchun esa `Ctrl + C/V` kerak bo‘ladi. Ushbu Omarchy ning birlashtirilgan almashish buferi tezkor klavishlari hamma joyda ishlaydi.

## Suratga olish

| Tezkor klavish              | Funksiya                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Skrinshot                      |
| `Super + Ctrl + Alt + C`            | Skrinshot (xuddi shu surat, Print Screen klavishi bo‘lmagan klaviaturalar uchun) |
| `Super + Ctrl + C` | Suratga olish menyusi |
| `Alt + Print Screen`            | Ekranni yozib olish                     |
| `Super + Shift + Ctrl + Alt + C` | Audiosiz ekranni yozib olish, menyuni o‘tkazib yuborish (to‘xtatish uchun yana bosing) |
| `Super + Print Screen` | Rang tanlagichi |
| `Super + Ctrl + Print Screen` | Matnni ajratib almashish buferiga olish |
| `Super + Alt + [` | Yozib olish paytida veb-kamera ustki qatlamini kichraytirish |
| `Super + Alt + ]` | Yozib olish paytida veb-kamera ustki qatlamini kattalashtirish |
| `Alt + Shift + L` | Veb-ilova yoki brauzerdan joriy URL ni nusxalash |
| `Alt + Shift + D` | Joriy sahifadagi videoni `~/Videos` ga yuklab olish |
| `Alt + Space` | Diktovkani boshlash/to‘xtatish (_Setup > Defaults > Dictation_ ni talab qiladi) |
| `Right Alt` | Diktovka qilish uchun bosib turish (_Setup > Defaults > Dictation_ ni talab qiladi) |

Ekran yozuvlarida tezkor klavish avval qaysi audioni xohlashingizni so‘raydi, keyin yozishni boshlaydi. To‘xtatish uchun uni yana bosing. Tafsilotlar uchun [skrinshotlar va yozib olish](12-screenshots-recording.md) ga qarang.

Barcha suratga olish variantlari Omarchy menyusidagi (`Super + Space`) _Trigger > Capture_ ostida ham mavjud.

## Bildirishnomalar

| Tezkor klavish                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + ,` | Eng so‘nggi bildirishnoma bo‘yicha amal qilish: uni ochish yoki uning yagona tugmasini bosish, uning variantlaridan tanlash yoki hech biri bo‘lmasa, uni rad etish  |
| `Super + Shift + ,` | Barcha bildirishnomalarni rad etish |
| `Super + Ctrl + ,` | Bildirishnomalarni klaviatura bilan boshqarish  |
| `Super + Alt + ,` | Eng so‘nggi bildirishnomani rad etish  |
| `Super + Shift + Alt + ,` | Bildirishnomalar tarixini ochish  |
| `Super + Ctrl + Alt + ,` | Bildirishnomalarni jim qilishni almashtirish  |

## Uslub

| Tezkor klavish                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Yangi mavzuni tanlash (shuningdek `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Mavzu fonini tanlash (shuningdek `Super + Ctrl + Space`) |
| `Super + Backspace` | Oynada shaffoflikni almashtirish |
| `Super + Ctrl + Backspace` | Bitta oynaning kvadrat nisbatini almashtirish |

Qo‘shimcha fon rasmlari `~/.config/omarchy/backgrounds/<theme name>` da joylashadi. Omarchy menyusidagi _Install > Style > Background_ orqali ham mavjud.

Barcha uslub variantlari Omarchy menyusidagi (`Super + Space`) _Appearance_ ostida ham mavjud.

## Almashtirgichlar

| Tezkor klavish                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Bo‘sh turganda qulflashni almashtirish |
| `Super + Ctrl + Delete` | Noutbuk displeyini yoqish/o‘chirish |
| `Super + Ctrl + Alt + Delete` | Noutbuk displeyini aks ettirishni almashtirish |
| `Super + Shift + Space` | Yuqori panelni almashtirish  |
| `Shift + Mute` | Keyingi audio chiqishiga o‘tish |
| `Shift + Play` | Keyingi media manbasiga o‘tish |
| `Super + Shift + Backspace` | Oyna bo‘shliqlarini almashtirish |
| `Super + Ctrl + Alt + F` | To‘liq ekran ish stolini almashtirish (yuqori panel + oyna bo‘shliqlari) |

## Eslatmalar

| Tezkor klavish                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Eslatma o‘rnatish  |
| `Super + Ctrl + Alt + R` | Barcha eslatmalarni ko‘rish  |
| `Super + Ctrl + Shift + R` | Barcha eslatmalarni tozalash  |

## Xabarnomalar

| Tezkor klavish                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Vaqtni bildirishnoma sifatida ko‘rsatish  |
| `Super + Ctrl + Alt + B` | Batareya holatini bildirishnoma sifatida ko‘rsatish  |
| `Super + Ctrl + Alt + W` | Ob-havoni bildirishnoma sifatida almashtirish  |

## Tmux

Prefiks klavishi `Ctrl + Space` (`Ctrl + B` ham ishlaydi). Ushbu bog‘lanishlarni `~/.config/tmux/tmux.conf` da o‘zgartirishingiz mumkin.

### Panellar

| Tezkor klavish                  | Funksiya              |
| ----------------------- | --------------------- |
| `Prefix + v` | Panelni yoniga bo‘lish (vertikal) |
| `Prefix + h` | Panelni pastiga bo‘lish (gorizontal) |
| `Prefix + x` | Panelni yopish |
| `Prefix + z` | Panelni kattalashtirishni almashtirish (to‘liq ekran) |
| `Alt + Enter` | Panelni pastiga bo‘lish (prefikssiz) |
| `Alt + Shift + Enter` | Panelni yoniga bo‘lish (prefikssiz) |
| `Alt + Escape` | Panelni yopish (prefikssiz) |
| `Ctrl + Alt + Arrows` | Panellar orasida harakatlanish |
| `Ctrl + Alt + Shift + Arrows` | Panellar o‘lchamini o‘zgartirish |

### Oynalar

| Tezkor klavish                  | Funksiya              |
| ----------------------- | --------------------- |
| `Prefix + c` | Yangi oyna |
| `Prefix + k` | Oynani yopish |
| `Prefix + r` | Oyna nomini o‘zgartirish |
| `Alt + 1-9` | Muayyan oynaga o‘tish |
| `Alt + Arrow Left/Right` | Oynalar orasida harakatlanish |
| `Alt + Shift + Arrow Left/Right` | Oynani chapga/o‘ngga ko‘chirish |

### Sessiyalar

| Tezkor klavish                  | Funksiya              |
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

| Tezkor klavish                  | Funksiya              |
| ----------------------- | --------------------- |
| `Prefix + [` | Nusxalash rejimiga kirish |
| `v` | Tanlashni boshlash (nusxalash rejimida) |
| `y` | Tanlovni nusxalash (nusxalash rejimida) |

### Umumiy

| Tezkor klavish                  | Funksiya              |
| ----------------------- | --------------------- |
| `Prefix + q` | Konfiguratsiyani qayta yuklash |
| `Prefix + ?` | Tmux klavish bog‘lanishlarini ko‘rsatish |
| `Prefix + :` | Buyruq satri |

### Tmux joylashuv funksiyalari

Ushbu funksiyalarni Tmux sessiyasi ichida ishga tushirish kerak.

| Buyruq | Funksiya |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Muharrir, AI va terminal bilan dev joylashuvini yaratish |
| `tdlm <ai> [<second_ai>]` | Har bir pastki katalog uchun dev joylashuvini yaratish |
| `tsl <count> <command>` | Ko‘p panelli swarm joylashuvini yaratish |

## Ghostty Terminal

Ghostty terminali Omarchy menyusi orqali _Install > Terminal_ yordamida o‘rnatiladi.

| Tezkor klavish                  | Funksiya              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Pastga yangi bo‘linish |
| `Ctrl + Shift + O` | Yoniga yangi bo‘linish |
| `Ctrl + Alt + Arrows` | Bo‘linishlar orasida harakatlanish |
| `Super + Ctrl + Shift + Arrows` | Bo‘linish o‘lchamini 10 qatorga o‘zgartirish |
| `Super + Ctrl + Shift + Alt + Arrows` | Bo‘linish o‘lchamini 100 qatorga o‘zgartirish |
| `Ctrl + Shift + T` | Yangi yorliq  |
| `Ctrl + Shift + Arrows` | Yorliqlar orasida harakatlanish |
| `Alt + Numbers` | Muayyan yorliqqa o‘tish |
| `Shift + Pg Up/Down` | Tarixni aylantirish |
| `Ctrl + Left mouse` | Havolani brauzerda ochish |

## Fayl menejeri

| Tezkor klavish              | Funksiya                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Yo‘lga o‘tish                     |
| `Space`               | Faylni oldindan ko‘rish (o‘qlar bilan navigatsiya) |
| `Alt + Up`       | Yuqoridagi ota katalogga o‘tish        |

## Neovim (lazyvim bilan)

### Navigatsiya

| Tezkor klavish                   | Funksiya                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Buyruq variantlarini ko‘rsatish            |
| `Space Space`              | Noaniq qidiruv orqali faylni ochish      |
| `Space E`                  | Yon panelni almashtirish                  |
| `Space G G`                | Git boshqaruvlarini ko‘rsatish               |
| `Space S G`                | Fayl tarkibini qidirish             |
| `Ctrl + W W`               | Yon panel va muharrir orasida sakrash |
| `Ctrl + Left/right arrow`  | Yon panel o‘lchamini o‘zgartirish          |
| `Shift + H`                      | Chap fayl yorlig‘iga o‘tish             |
| `Shift + L`                      | O‘ng fayl yorlig‘iga o‘tish            |
| `Space B D`                | Fayl yorlig‘ini yopish                  |

### Yon panelda bo‘lganda

| Tezkor klavish                   | Funksiya                        |
| ------------------------ | ------------------------------- |
| `A`                        | Ota katalogda yangi fayl qo‘shish      |
| `Shift + A`                | Ota katalogda yangi pastki katalog qo‘shish    |
| `D`                        | Belgilangan fayl/katalogni o‘chirish     |
| `M`                        | Belgilangan fayl/katalogni ko‘chirish       |
| `R`                        | Belgilangan fayl/katalog nomini o‘zgartirish     |
| `?`                        | Barcha buyruqlar uchun yordamni ko‘rsatish      |

[LazyVim tomonidan sozlangan barcha Neovim tezkor klavishlarini ko‘ring](https://www.lazyvim.org/keymaps).

## Tezkor emojilar

To‘liq emoji tanlagichini ko‘rsatish uchun `Super + Ctrl + E` dan foydalanishingiz mumkin, u tanlovni almashish buferiga qo‘yadi, yoki ushbu tezkor kirish variantlaridan foydalanishingiz mumkin.

| Tezkor klavish       | EM | Ishora       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | tabassum      |
| `Shift + CapsLock M C` | 😂 | yig‘lash        |
| `Shift + CapsLock M L` | 😍 | sevgi       |
| `Shift + CapsLock M V` | ✌️ | g‘alaba    |
| `Shift + CapsLock M H` | ❤️ | yurak      |
| `Shift + CapsLock M Y` | 👍 | ha        |
| `Shift + CapsLock M N` | 👎 | yo‘q         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | tilak       |
| `Shift + CapsLock M R` | 🤘 | rok       |
| `Shift + CapsLock M K` | 😘 | o‘pich       |
| `Shift + CapsLock M E` | 🙄 | ko‘zni aylantirish    |
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

| Tezkor klavish       | To‘ldirish       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Ismingiz (sozlashda kiritilganidek)  |
| `Shift + CapsLock Space E` | Elektron pochtangiz (sozlashda kiritilganidek)  |

O‘zingiznikidan ko‘proq qo‘shish uchun `~/.XCompose` ni tahrirlang, keyin o‘zgarishlar qabul qilinishi uchun terminalda `omarchy restart xcompose` ni ishga tushiring.
