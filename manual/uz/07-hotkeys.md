# Tezkor tugmalar

Barcha asosiy klaviatura bog‘lanishlarini `Super + K` bilan ko‘rishingiz mumkin (Tmux bog‘lanishlari `Super + Alt + K` bilan va Herdr bog‘lanishlari `Super + Ctrl + K` bilan).

## Tezkor tugmalar qanday joylashgan

Har bir tezkor tugma o‘z modifikatorlari bilan belgilanadigan tekislikda joylashadi va har bir tekislikning bitta vazifasi bor. Tezkor tugmalar bir-biriga aralashib ketmasligini ham shu ta’minlaydi va bu odatda biror narsaning qayerda ekanini taxmin qila olishingizni bildiradi.

| Tekislik | U yerda nimalar joylashadi | Misollar |
| --- | --- | --- |
| `Super + key` | Tizim: oynalar, ish maydonlari, tartibotlar va asosiy menyular | `Super + Space` Omarchy menyusi, `Super + W` oynani yopish, `Super + F` to‘liq ekran |
| `Super + Shift + key` | Ilovalar | `Super + Shift + B` brauzer, `Super + Shift + E` elektron pochta, `Super + Shift + N` muharrir |
| `Super + Ctrl + key` | Panellar va tizim menyulari | `Super + Ctrl + A` audio, `Super + Ctrl + N` tarmoq, `Super + Ctrl + C` suratga olish menyusi |
| `Super + Ctrl + Alt + key` | Tezkor amallar va bildirishlar | `Super + Ctrl + Alt + T` vaqtni ko‘rsatish, `Super + Ctrl + Alt + B` batareya, `Super + Ctrl + Alt + C` ekran tasviri |

Tezkor tugmaga `Alt` qo‘shish sizga xuddi shu narsaning variantini beradi, hech qachon aloqasiz boshqa narsani emas:

- `Super + Shift + B` brauzerni ochadi; `Super + Shift + Alt + B` shaxsiy oynani ochadi
- `Super + Shift + E` elektron pochtani ochadi; `Super + Shift + Alt + E` yangisini boshlaydi
- `Super + F` to‘liq ekranga o‘tadi; `Super + Alt + F` to‘liq kenglikka o‘tadi
- `Super + Ctrl + C` suratga olish menyusini ochadi; `Super + Ctrl + Alt + C` menyuni o‘tkazib yuborib, ekran tasvirini oladi

Tezkor tugma qo‘shishda:

1. U nima qilishiga qarab tekislikni tanlang, keyin tugmani tanlang.
2. Joy bo‘shatish uchun mavjud tezkor tugmani ko‘chirmang. To‘g‘ri tekislikdan bo‘sh tugmani toping.
3. `Alt` dan faqat usiz bo‘lgan tezkor tugmaning varianti uchungina foydalaning.

Bir nechta tezkor tugmalar qulay bo‘lgani uchun bu qoidalarni buzadi. Strelka yoki `Tab` bilan `Shift` ilovani ochish o‘rniga ko‘chiradi yoki teskari qiladi, `Print`, media tugmalar, `Alt + Tab` va `Ctrl + Alt + Del` esa hamma joyda qanday ishlasa, shunday ishlaydi. Ular istisnolar, nusxa olish uchun naqshlar emas.

Agar standart variant sizga mos kelmasa (masalan, Windows dagi kabi ekran tasvirlari uchun `Super + Shift + S` ni xohlasangiz), uni `~/.config/hypr/bindings.lua` da qayta bog‘lang.

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
| `Super + M` | Oynani dock ga kichraytirish |
| `Super + T` | Oynani kafel/suzuvchi rejimlar orasida almashtirish |
| `Super + J` | Oyna holatini almashtirish (gorizontal/vertikal) |
| `Super + O` | Oynani sticky'n'floating rejimiga chiqarishni almashtirish |
| `Super + L` | dwindle, scrolling va floating tartibotlari orasida aylanish |
| `Super + Alt + L` | Tartibotlar orasida teskari yo‘nalishda aylanish |
| `Super + P` | pseudo oyna uslubini almashtirish (natural v stretch) |
| `Super + F` | To‘liq ekranga o‘tish |
| `Super + Alt + F` | To‘liq kenglikka o‘tish |
| `Super + Ctrl + F` | Oyna ichida to‘liq ekranga o‘tish |
| `Super + 1…9/0` | Fokusdagi monitordagi muayyan ish maydoniga o‘tish (0 — 10) |
| `Super + Tab` | Fokusdagi monitordagi keyingi ish maydoniga o‘tish |
| `Super + Shift + Tab` | Fokusdagi monitordagi oldingi ish maydoniga o‘tish |
| `Super + Ctrl + Tab` | Fokusdagi monitordagi avvalgi ish maydoniga o‘tish |
| `Super + Shift + 1…9/0` | Oynani fokusdagi monitordagi ish maydoniga ko‘chirish |
| `Super + Shift + Alt + 1…9/0` | Ortidan bormasdan oynani fokusdagi monitordagi ish maydoniga ko‘chirish |
| `Super + S` | To‘liq scratchpad ni almashtirish |
| `Super + Alt + S` | Oynani to‘liq scratchpad ga ko‘chirish |
| `Super + the key above Tab` (grave on US layouts) | Quake konsolini almashtirish |
| `Super + Shift + the key above Tab` (grave on US layouts) | Oynani Quake konsoliga ko‘chirish |
| `Super + Shift + Ctrl + Arrows` | Oynani o‘sha yo‘nalishdagi monitorga ko‘chirish |
| `Super + Shift + Alt + Arrows` | Ish maydonini o‘sha yo‘nalishdagi monitorga ko‘chirish |
| `Super + Arrow` | Fokusni strelka yo‘nalishidagi oynaga ko‘chirish, ekranning chetida o‘sha tomondagi monitorga o‘tib |
| `Super + Shift + Arrow` | Oynani strelka yo‘nalishidagi boshqa oyna bilan almashtirish, shu jumladan o‘sha tomondagi monitordagi oyna bilan ham |
| `Super + Minus` | Oynani chapga kengaytirish |
| `Super + Equal` | Oynani chapga qisqartirish |
| `Super + Shift + Minus` | Oynani yuqoriga qisqartirish |
| `Super + Shift + Equal` | Oynani pastga kengaytirish |
| `Super + Alt + Minus/Equal` | Xuddi shu o‘lcham o‘zgartirish, lekin kichikroq qadamlar bilan |
| `Super + Ctrl + Minus/Equal` | Xuddi shu o‘lcham o‘zgartirish, lekin kattaroq qadamlar bilan |
| `Super + Alt + Home` | Oyna kengligini saqlash |
| `Super + Home` | Saqlangan oyna kengligini tiklash |
| `Super + Left Mouse` | Oynani sudrab yurish |
| `Super + Right Mouse` | Oyna o‘lchamini o‘zgartirish |
| `Super + Scroll Wheel` | Fokusdagi monitordagi ish maydonlari orasida aylantirish |
| `Super + G` | Oynalarni guruhlashni almashtirish |
| `Super + Alt + G` | Oynani guruhdan chiqarish |
| `Super + Alt + Tab` | Guruhdagi oynalar orasida aylanish |
| `Super + Alt + Shift + Tab` | Guruhdagi oynalar orasida teskari aylanish |
| `Super + Alt + Scroll Wheel` | Guruhdagi oynalar orasida aylanish |
| `Super + Alt + 1/2/3/4/5` | Guruhdagi muayyan oynaga o‘tish |
| `Super + Alt + Arrow` | Oynani strelka yo‘nalishida guruhga ko‘chirish, shu jumladan o‘sha tomondagi monitordagi oynani ham |
| `Super + Ctrl + Left/Right` | Kafel guruhi ichidagi oynalar orasida harakatlanish |
| `Super + Ctrl + Z` | Ekranni yaqinlashtirish (ko‘proq yaqinlashtirish uchun takrorlang) |
| `Super + Ctrl + Alt + Z` | Ekran dan to‘liq uzoqlashish |
| `Super + /` | Monitor masshtabi variantlari bo‘ylab oldinga qadam tashlash |
| `Super + Alt + /` | Monitor masshtabi variantlari bo‘ylab orqaga qadam tashlash |
| `Alt + Tab` | Faol ish maydonidagi oynalar orasida oldinga aylanish |
| `Alt + Shift + Tab` | Faol ish maydonidagi oynalar orasida orqaga aylanish |
| `Ctrl + Alt + Tab` | Fokusni monitorlar orasida oldinga aylantirish |
| `Ctrl + Alt + Shift + Tab` | Fokusni monitorlar orasida orqaga aylantirish |
| `Super + I` | Kirish tilini almashtirish (bittadan ortiq tartibot yoki kiritish usuli bo‘lganda) |
| `Super + Shift + I` | Kirish tilini orqaga almashtirish |

Sensor panelda uch va to‘rt barmoqli surishlar ish maydonlarini almashtiradi, oynalarni ko‘chiradi hamda menyu va Quake konsolini ochadi; imo-ishoralarni [klaviatura, sichqoncha va trekpad](34-keyboard-mouse-trackpad.md) dan ko‘ring.

O‘lcham o‘zgartirish tezkor tugmalari klaviaturada bosilgan belgilardan qat’i nazar, fizik `code:20` va `code:21` tugmalaridan (XKB `<AE11>` va `<AE12>`) foydalanadi. AQSH klaviaturalarida bu tugmalar `-` va `=`; yapon (JIS) klaviaturalarida ular `-` va `^`; ispan klaviaturalarida ular `'` va `¡`. JIS da `Super + ^` — bu `Super + Equal`, `Super + Shift + -` esa (`=` ni yozadi) `Super + Shift + Minus` dir.

## Tizim boshqaruvi

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Audio paneli |
| `Super + Ctrl + B` | Bluetooth paneli |
| `Super + Ctrl + N` | Wifi/tarmoq paneli |
| `Super + Ctrl + D` | Displey paneli |
| `Super + Ctrl + P` | Quvvat paneli |
| `Super + Ctrl + X` | Agentlar paneli |
| `Super + Ctrl + Alt + X` | Mahalliy modellar paneli |
| `Super + Ctrl + Alt + D` | Kalendar paneli |
| `Super + Ctrl + Alt + E` | Jahon soati paneli |
| `Super + Ctrl + 1-9` | Panel satrini pozitsiyasi bo‘yicha almashtirish |
| `Super + Ctrl + S` | Ulashish menyusi (LocalSend orqali) |
| `Super + Ctrl + C` | Suratga olish boshqaruvi (ekran tasviri/-yozuv/tanlagich) |
| `Super + Ctrl + O` | Menyuni almashtirish |
| `Super + Ctrl + H` | Apparat menyusi |
| `Super + Ctrl + E` | Emoji tanlagichi |
| `Super + Ctrl + .` | Mediani transkodlash |
| `Super + Shift + Ctrl + A` | Standart agentingizni ishga tushirish |
| `Power` key | Tizim menyusi |
| `Super + Shift + Copilot` key | Omarchy menyusi |

## Sozlashlar

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Ekran yorqinligining maksimumi |
| `Shift + Brightness Down` | Ekran yorqinligining minimumi |
| `Alt + Brightness Up/Down` | Yorqinlikni aniq 1% ga o‘zgartirish |
| `Alt + Volume Up/Down` | Ovoz balandligini aniq 1% ga o‘zgartirish |
| `Keyboard Brightness Up/Down` | Klaviatura yoritgichi yorqinroq/xiraroq |
| `Keyboard Backlight` | Klaviatura yoritgichi darajalari orasida aylanish |
| `Ctrl + Brightness Up/Down` | O‘z tugmalari bo‘lmagan klaviaturalarda klaviatura yoritgichi yorqinroq/xiraroq |
| `Mic Mute` | Mikrofonni o‘chirish |
| `Shift + Mute` | Audio chiqishini almashtirish |
| `Touchpad Toggle` | Sensor panelni yoqish yoki o‘chirish |
| `Display` key | Ish maydoni tartibotini aylantirish |
| `Alt + Play` | Keyingi trek |
| `Alt + Shift + Play` | Oldingi trek |

## Ilovalarni ishga tushirish

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Tmux terminali |
| `Super + Ctrl + Return` | Herdr (agentlar menejeri) |
| `Super + Shift + Return` or `Super + Shift + B` | Brauzer |
| `Super + Shift + Alt + B` | Brauzer (shaxsiy/inkognito) |
| `Super + Shift + F` | Fayl menejeri |
| `Super + Shift + Alt + F` | Terminalning cwd dagi fayl menejeri |
| `Super + Shift + M` | Musiqa (Spotify) |
| `Super + Shift + Alt + M` | Musiqa (cliamp) |
| `Super + Shift + /` | Parollar menejeri (1password) |
| `Super + Shift + Q` or `Calculator` key | Kalkulyator (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, o‘rnatilgandan keyin) |
| `Super + Shift + T` | Faollik (btop) |
| `Super + Shift + N` | Muharrir (Plain, yoki siz tanlagan standart) |
| `Super + Shift + C` | Kalendar ([HEY](https://hey.com/)) |
| `Super + Shift + E` | Elektron pochta ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Yangi elektron pochta ([HEY](https://hey.com/)) |
| `Super + Shift + A` | Standart agentingiz, yoki birini tanlaguningizcha ChatGPT |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Messenjer (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Messenjer (WhatsApp) |
| `Super + Shift + Ctrl + G` | Messenjer (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Yozish (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (yangi post) |
| `Super + Shift + Y` | YouTube |

Bog‘lanishlarni `~/.config/hypr/bindings.lua` da o‘zgartiring/qo‘shing.

## Universal almashish buferi

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Super + A` | `Ctrl + A` ni qo‘llab-quvvatlaydigan ilovalarda hammasini tanlash |
| `Super + C` | Nusxalash |
| `Super + X` | Qirqish (terminalda emas) |
| `Super + V` | Joylashtirish |
| `Super + Ctrl + V` | Almashish buferi menejeri |

Odatda Linux da terminalda nusxalash va joylashtirish uchun `Ctrl + Shift + C/V`, qolgan hamma joyda buni qilish uchun esa `Ctrl + C/V` kerak bo‘ladi. Ushbu Omarchy ning birlashtirilgan almashish buferi tezkor tugmalari hamma joyda ishlaydi.

## Suratga olish

| Tezkor tugma | Funksiya |
| ------------------- | ------------------------------ |
| `Print Screen` | Ekran tasviri |
| `Super + Ctrl + Alt + C` | Ekran tasviri (Print Screen tugmasi bo‘lmagan klaviaturalar uchun xuddi shu tasvir) |
| `Super + Ctrl + C` | Suratga olish menyusi |
| `Alt + Print Screen` | Ekran yozuvi |
| `Super + Shift + Ctrl + Alt + C` | Audiosiz ekran yozuvi, menyuni o‘tkazib yuborib (to‘xtatish uchun yana bosing) |
| `Super + Print Screen` | Rang tanlagichi |
| `Super + Ctrl + Print Screen` | Matnni almashish buferiga chiqarib olish |
| `Super + Alt + [` | Yozib olish paytida veb-kamera qoplamasini kichikroq qilish |
| `Super + Alt + ]` | Yozib olish paytida veb-kamera qoplamasini kattaroq qilish |
| `Alt + Shift + L` | Veb-ilova yoki brauzerdan joriy URL ni nusxalash |
| `Alt + Shift + D` | Joriy sahifadagi videoni `~/Videos` ga yuklab olish |
| `Alt + Space` | Diktovkani boshlash/to‘xtatish (_Setup > Defaults > Dictation_ talab qilinadi) |
| `Right Alt` | Diktovka qilish uchun bosib turish (_Setup > Defaults > Dictation_ talab qilinadi) |

Ekran yozuvlarida tezkor tugma avval qaysi audioni xohlayotganingizni so‘raydi, keyin yozishni boshlaydi. To‘xtatish uchun uni yana bosing. Tafsilotlar uchun [ekran tasvirlari va yozish](12-screenshots-recording.md) ga qarang.

Suratga olishning barcha variantlariga Omarchy menyusida (`Super + Space`) _Trigger > Capture_ ostida ham kirish mumkin.

## Bildirishnomalar

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Super + ,` | Eng so‘nggi bildirishnoma ustida amal bajarish: uni ochish yoki uning yagona tugmasini bosish, uning variantlaridan tanlash, yoki hech biri bo‘lmasa uni bekor qilish |
| `Super + Shift + ,` | Barcha bildirishnomalarni bekor qilish |
| `Super + Ctrl + ,` | Bildirishnomalarni klaviatura bilan boshqarish |
| `Super + Alt + ,` | Eng so‘nggi bildirishnomani bekor qilish |
| `Super + Shift + Alt + ,` | Bildirishnomalar tarixini ochish |
| `Super + Ctrl + Alt + ,` | Bildirishnomalarni ovozsiz qilishni almashtirish |

## Uslub

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Yangi mavzuni tanlash (shuningdek `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Mavzu fonini tanlash (shuningdek `Super + Ctrl + Space`) |
| `Super + Backspace` | Oynadagi shaffoflikni almashtirish |
| `Super + Ctrl + Backspace` | Bitta oyna kvadrat nisbatini almashtirish |

Qo‘shimcha fon tasvirlari `~/.config/omarchy/backgrounds/<theme name>` da joylashgan. Omarchy menyusida _Install > Style > Background_ orqali ham mavjud.

Uslubning barcha variantlariga Omarchy menyusida (`Super + Space`) _Appearance_ ostida ham kirish mumkin.

## Almashtirishlar

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Bekor turganda qulflashni almashtirish |
| `Super + Ctrl + Delete` | Laptop displeyini yoqish/o‘chirishni almashtirish |
| `Super + Ctrl + Alt + Delete` | Laptop displeyini aks ettirishni almashtirish |
| `Super + Shift + Space` | Yuqori panelni almashtirish |
| `Shift + Mute` | Keyingi audio chiqishiga o‘tish |
| `Shift + Play` | Keyingi media manbasiga o‘tish |
| `Super + Shift + Backspace` | Oyna oralig‘larini almashtirish |
| `Super + Ctrl + Alt + F` | To‘liq ekran ish stolini almashtirish (yuqori panel + oyna oralig‘lari) |

## Eslatmalar

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Eslatma o‘rnatish |
| `Super + Ctrl + Alt + R` | Barcha eslatmalarni ko‘rish |
| `Super + Ctrl + Shift + R` | Barcha eslatmalarni tozalash |

## Xabarlar

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Vaqtni bildirishnoma sifatida ko‘rsatish |
| `Super + Ctrl + Alt + B` | Batareyani bildirishnoma sifatida ko‘rsatish |
| `Super + Ctrl + Alt + W` | Ob-havoni bildirishnoma sifatida almashtirish |

## Tmux

Prefiks tugmasi `Ctrl + Space` (`Ctrl + B` ham ishlaydi). Bu bog‘lanishlarni `~/.config/tmux/tmux.conf` da o‘zgartirishingiz mumkin.

### Panellar

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Prefix + v` | Panelni yoniga bo‘lish (vertikal) |
| `Prefix + h` | Panelni ostiga bo‘lish (gorizontal) |
| `Prefix + x` | Panelni tugatish |
| `Prefix + z` | Panel masshtabini almashtirish (to‘liq ekran) |
| `Alt + Enter` | Panelni ostiga bo‘lish (prefikssiz) |
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
| `Alt + 1-9` | Muayyan oynaga o‘tish |
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

### Nusxalash rejimi (vi-style)

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Prefix + [` | Nusxalash rejimiga kirish |
| `v` | Tanlashni boshlash (nusxalash rejimida) |
| `y` | Tanlovni nusxalash (nusxalash rejimida) |

### Umumiy

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Prefix + q` | Konfiguratsiyani qayta yuklash |
| `Prefix + ?` | Tmux tugma bog‘lanishlarini ko‘rsatish |
| `Prefix + :` | Buyruq satri |

### Tmux tartiboti funksiyalari

Bu funksiyalarni Tmux sessiyasi ichida ishga tushirish kerak.

| Buyruq | Funksiya |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Muharrir, AI va terminal bilan dev tartibotini yaratish |
| `tdlm <ai> [<second_ai>]` | Har bir pastki katalog uchun dev tartibotini yaratish |
| `tsl <count> <command>` | Ko‘p panelli swarm tartibotini yaratish |

## Ghostty Terminal

Ghostty terminali Omarchy menyusi orqali _Install > Terminal_ yordamida o‘rnatiladi.

| Tezkor tugma | Funksiya |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Ostiga yangi bo‘lish |
| `Ctrl + Shift + O` | Yoniga yangi bo‘lish |
| `Ctrl + Alt + Arrows` | Bo‘linmalar orasida harakatlanish |
| `Super + Ctrl + Shift + Arrows` | Bo‘linma o‘lchamini 10 qatorga o‘zgartirish |
| `Super + Ctrl + Shift + Alt + Arrows` | Bo‘linma o‘lchamini 100 qatorga o‘zgartirish |
| `Ctrl + Shift + T` | Yangi varaq |
| `Ctrl + Shift + Arrows` | Varaqlar orasida harakatlanish |
| `Alt + Numbers` | Muayyan varaqqa o‘tish |
| `Shift + Pg Up/Down` | Tarixni aylantirish |
| `Ctrl + Left mouse` | Havolani brauzerda ochish |

## Fayl menejeri

| Tezkor tugma | Funksiya |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Yo‘lga o‘tish |
| `Space` | Faylni oldindan ko‘rish (strelkalar bilan navigatsiya) |
| `Alt + Up` | Ota papkaga chiqish |

## Neovim (w/ lazyvim)

### Navigatsiya

| Tezkor tugma | Funksiya |
| ------------------------ | ------------------------------- |
| `Space` | Buyruq variantlarini ko‘rsatish |
| `Space Space` | Faylni noaniq qidiruv orqali ochish |
| `Space E` | Yon panelni almashtirish |
| `Space G G` | git boshqaruvini ko‘rsatish |
| `Space S G` | Fayl tarkibini qidirish |
| `Ctrl + W W` | Yon panel va muharrir orasida sakrash |
| `Ctrl + Left/right arrow` | Yon panel o‘lchamini o‘zgartirish |
| `Shift + H` | Chap fayl varag‘iga o‘tish |
| `Shift + L` | O‘ng fayl varag‘iga o‘tish |
| `Space B D` | Fayl varag‘ini yopish |

### Yon panelda bo‘lganda

| Tezkor tugma | Funksiya |
| ------------------------ | ------------------------------- |
| `A` | Ota katalogda yangi fayl qo‘shish |
| `Shift + A` | Ota katalogda yangi pastki katalog qo‘shish |
| `D` | Belgilangan fayl/katalogni o‘chirish |
| `M` | Belgilangan fayl/katalogni ko‘chirish |
| `R` | Belgilangan fayl/katalog nomini o‘zgartirish |
| `?` | Barcha buyruqlar uchun yordamni ko‘rsatish |

[LazyVim tomonidan sozlangan barcha Neovim tezkor tugmalarini ko‘ring](https://www.lazyvim.org/keymaps).

## Tezkor emojilar

To‘liq emoji tanlagichini ko‘rsatish uchun `Super + Ctrl + E` dan foydalanishingiz mumkin, u tanlovni almashish buferiga joylashtiradi, yoki ushbu tezkor kirish variantlaridan foydalanishingiz mumkin.

| Tezkor tugma | EM | Ishora |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | tabassum |
| `Shift + CapsLock M C` | 😂 | yig‘lash |
| `Shift + CapsLock M L` | 😍 | sevgi |
| `Shift + CapsLock M V` | ✌️ | g‘alaba |
| `Shift + CapsLock M H` | ❤️ | yurak |
| `Shift + CapsLock M Y` | 👍 | ha |
| `Shift + CapsLock M N` | 👎 | yo‘q |
| `Shift + CapsLock M F` | 🖕 | so‘kish |
| `Shift + CapsLock M W` | 🤞 | tilak |
| `Shift + CapsLock M R` | 🤘 | rok |
| `Shift + CapsLock M K` | 😘 | bo‘sa |
| `Shift + CapsLock M E` | 🙄 | ko‘z aylantirish |
| `Shift + CapsLock M I` | 😉 | ko‘z qisish |
| `Shift + CapsLock M P` | 🙏 | ibodat |
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

`~/.XCompose` ni tahrirlash orqali o‘zingiznikilarni ko‘proq qo‘shishingiz mumkin, keyin o‘zgarishlar qabul qilinishi uchun terminalda `omarchy restart xcompose` ni ishga tushiring.
