# Tezkor tugmalar

Asosiy klaviatura bog‘lamalarining barchasini `Super + K` bilan ko‘rishingiz mumkin (Tmux bog‘lamalari `Super + Alt + K` bilan va Herdr bog‘lamalari `Super + Ctrl + K` bilan).

## Tezkor tugmalar qanday joylashgan

Har bir tezkor tugma o‘z modifikatorlari bilan belgilanadigan tekislikda joylashadi va har bir tekislikning bitta vazifasi bor. Tezkor tugmalar aynan shu sababli bir-biriga aralashib ketmaydi va bu odatda biror narsa qayerda joylashganini taxmin qila olishingizni anglatadi.

| Tekislik | U yerda nimalar joylashadi | Misollar |
| --- | --- | --- |
| `Super + key` | Tizim: oynalar, ish maydonlari, tartiblar va asosiy menyular | `Super + Space` Omarchy menyusi, `Super + W` oynani yopish, `Super + F` to‘liq ekran |
| `Super + Shift + key` | Ilovalar | `Super + Shift + B` brauzer, `Super + Shift + E` elektron pochta, `Super + Shift + N` muharrir |
| `Super + Ctrl + key` | Panellar va tizim menyulari | `Super + Ctrl + A` audio, `Super + Ctrl + N` tarmoq, `Super + Ctrl + C` tasvirga olish menyusi |
| `Super + Ctrl + Alt + key` | Tezkor amallar va xabarnomalar | `Super + Ctrl + Alt + T` vaqtni ko‘rsatish, `Super + Ctrl + Alt + B` batareya, `Super + Ctrl + Alt + C` skrinshot |

Tezkor tugmaga `Alt` qo‘shish sizga o‘sha narsaning variantini beradi, hech qachon unga aloqasiz narsani bermaydi:

- `Super + Shift + B` brauzerni ochadi; `Super + Shift + Alt + B` maxfiy oynani ochadi
- `Super + Shift + E` elektron pochtani ochadi; `Super + Shift + Alt + E` yangisini boshlaydi
- `Super + F` to‘liq ekranga o‘tadi; `Super + Alt + F` to‘liq kenglikka o‘tadi
- `Super + Ctrl + C` tasvirga olish menyusini ochadi; `Super + Ctrl + Alt + C` menyuni o‘tkazib yuboradi va skrinshot oladi

Tezkor tugma qo‘shganda:

1. U nima qilishiga qarab tekislikni tanlang, keyin tugmani tanlang.
2. Joy bo‘shatish uchun mavjud tezkor tugmani siljitmang. To‘g‘ri tekislikda bo‘sh tugmani toping.
3. `Alt` ni faqat usiz variantning varianti uchun ishlating.

Bir nechta tezkor tugmalar qulay bo‘lgani uchun ushbu qoidalarni buzadi. Strelka yoki `Tab` bilan `Shift` ilovani ochish o‘rniga siljitadi yoki teskarisiga qaytaradi va `Print`, media tugmalari, `Alt + Tab` hamda `Ctrl + Alt + Del` boshqa hamma joydagidek ishlaydi. Ular istisnolar, nusxa olinadigan naqshlar emas.

Agar standart variant sizga mos kelmasa (masalan, Windows dagidek skrinshotlar uchun `Super + Shift + S` ni xohlasangiz), uni `~/.config/hypr/bindings.lua` da qayta bog‘lang.

## Navigatsiya

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy menyusi (ilovalar va qolgan hamma narsa) |
| `Super + Alt + Space` | Ilovalar panjarasi |
| `Super + Escape` | Tizim menyusi (to‘xtatib turish, qayta ishga tushirish va boshqalar) |
| `Super + Ctrl + L` | Kompyuterni qulflash |
| `Super + W` or `Super + Q` | Oynani yopish |
| `Ctrl + Alt + Del` | Barcha oynalarni yopish |
| `Super + K` | Barcha tezkor tugmalarni ko‘rsatish |
| `Super + Alt + K` | Tmux tezkor tugmalarini ko‘rsatish |
| `Super + Ctrl + K` | Herdr tezkor tugmalarini ko‘rsatish |
| `Super + M` | Oynani dokka kichraytirish |
| `Super + T` | Oynani plitka/suzuvchi rejimlar orasida almashtirish |
| `Super + J` | Oyna pozitsiyasini almashtirish (gorizontal/vertikal) |
| `Super + O` | Oynani sticky'n'floating rejimiga chiqarishni yoqish/o‘chirish |
| `Super + L` | dwindle, scrolling va floating tartiblarini aylanib o‘tish |
| `Super + Alt + L` | Tartiblarni teskari tartibda aylanib o‘tish |
| `Super + P` | Pseudo oyna uslubini almashtirish (natural v stretch) |
| `Super + F` | To‘liq ekranga o‘tish |
| `Super + Alt + F` | To‘liq kenglikka o‘tish |
| `Super + Ctrl + F` | Oyna ichida to‘liq ekranga o‘tish |
| `Super + 1…9/0` | Fokusdagi monitorda muayyan ish maydoniga sakrash (0 — 10) |
| `Super + Tab` | Fokusdagi monitorda keyingi ish maydoniga sakrash |
| `Super + Shift + Tab` | Fokusdagi monitorda oldingi ish maydoniga sakrash |
| `Super + Ctrl + Tab` | Fokusdagi monitorda avvalgi ish maydoniga sakrash |
| `Super + Shift + 1…9/0` | Oynani fokusdagi monitordagi ish maydoniga siljitish |
| `Super + Shift + Alt + 1…9/0` | Oynani fokusdagi monitordagi ish maydoniga ortidan ergashmasdan siljitish |
| `Super + S` | To‘liq scratchpad ni yoqish/o‘chirish |
| `Super + Alt + S` | Oynani to‘liq scratchpad ga siljitish |
| `Super + Grave` | Quake konsolini yoqish/o‘chirish |
| `Super + Shift + Grave` | Oynani Quake konsoliga siljitish |
| `Super + Shift + Ctrl + Arrows` | Oynani shu yo‘nalishdagi monitorga siljitish |
| `Super + Shift + Alt + Arrows` | Ish maydonini shu yo‘nalishdagi monitorga siljitish |
| `Super + Arrow` | Fokusni strelka yo‘nalishidagi oynaga siljitish, ekran chetida shu tomondagi monitorga o‘tish |
| `Super + Shift + Arrow` | Oynani strelka yo‘nalishidagi boshqa oyna bilan almashtirish, shu tomondagi monitordagi oynani ham qo‘shib |
| `Super + Minus` | Oynani chapga kengaytirish |
| `Super + Equal` | Oynani chapdan qisqartirish |
| `Super + Shift + Minus` | Oynani yuqoriga qisqartirish |
| `Super + Shift + Equal` | Oynani pastga kengaytirish |
| `Super + Alt + Minus/Equal` | Xuddi shu o‘lcham o‘zgartirish kichikroq qadamlar bilan |
| `Super + Ctrl + Minus/Equal` | Xuddi shu o‘lcham o‘zgartirish kattaroq qadamlar bilan |
| `Super + Alt + Home` | Oyna kengligini saqlash |
| `Super + Home` | Saqlangan oyna kengligini tiklash |
| `Super + Left Mouse` | Oynani sudrab yurish |
| `Super + Right Mouse` | Oyna o‘lchamini o‘zgartirish |
| `Super + Scroll Wheel` | Fokusdagi monitorda ish maydonlarini aylantirish |
| `Super + G` | Oynalarni guruhlashni yoqish/o‘chirish |
| `Super + Alt + G` | Oynani guruhdan chiqarish |
| `Super + Alt + Tab` | Guruhdagi oynalar orasida aylanish |
| `Super + Alt + Shift + Tab` | Guruhdagi oynalar orasida orqaga aylanish |
| `Super + Alt + Scroll Wheel` | Guruhdagi oynalar orasida aylanish |
| `Super + Alt + 1/2/3/4/5` | Guruhdagi muayyan oynaga sakrash |
| `Super + Alt + Arrow` | Oynani strelka yo‘nalishida guruhga siljitish, shu tomondagi monitordagi oynani ham qo‘shib |
| `Super + Ctrl + Left/Right` | Plitka guruhi ichidagi oynalar orasida harakatlanish |
| `Super + Ctrl + Z` | Ekranni kattalashtirish (ko‘proq kattalashtirish uchun takrorlang) |
| `Super + Ctrl + Alt + Z` | Ekranni to‘liq kichraytirish |
| `Super + /` | Monitor masshtablash variantlari bo‘ylab oldinga qadam tashlash |
| `Super + Alt + /` | Monitor masshtablash variantlari bo‘ylab orqaga qadam tashlash |
| `Alt + Tab` | Faol ish maydonidagi oynalar orasida oldinga aylanish |
| `Alt + Shift + Tab` | Faol ish maydonidagi oynalar orasida orqaga aylanish |
| `Ctrl + Alt + Tab` | Monitorlar orasida fokusni oldinga aylantirish |
| `Ctrl + Alt + Shift + Tab` | Monitorlar orasida fokusni orqaga aylantirish |
| `Super + I` | Kiritish tilini almashtirish (bir nechta tartib yoki kiritish usuli bo‘lganda) |
| `Super + Shift + I` | Kiritish tilini orqaga almashtirish |

Sensorli panelda uch va to‘rt barmoqli surish harakatlari ish maydonlarini almashtiradi, oynalarni siljitadi hamda menyu va Quake konsolini ochadi; imo-ishoralar uchun [klaviatura, sichqoncha va trekpad](34-keyboard-mouse-trackpad.md) ga qarang.

O‘lcham o‘zgartirish tezkor tugmalari klaviaturada bosilgan belgilardan qat’i nazar, `code:20` va `code:21` fizik tugmalaridan (XKB `<AE11>` va `<AE12>`) foydalanadi. US klaviaturalarida bu tugmalar `-` va `=`; yapon (JIS) klaviaturalarida ular `-` va `^`; ispan klaviaturalarida ular `'` va `¡`. JIS da `Super + ^` — `Super + Equal`, `Super + Shift + -` (u `=` ni yozadi) esa `Super + Shift + Minus` dir.

## Tizim boshqaruvlari

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Audio paneli |
| `Super + Ctrl + B` | Bluetooth paneli |
| `Super + Ctrl + N` | Wifi/tarmoq paneli |
| `Super + Ctrl + D` | Displey paneli |
| `Super + Ctrl + P` | Quvvat paneli |
| `Super + Ctrl + X` | Agentlar paneli |
| `Super + Ctrl + Alt + X` | Mahalliy modellar paneli |
| `Super + Ctrl + Alt + D` | Taqvim paneli |
| `Super + Ctrl + Alt + E` | Jahon soati paneli |
| `Super + Ctrl + 1-9` | Panelni pozitsiyasi bo‘yicha yoqish/o‘chirish |
| `Super + Ctrl + S` | Ulashish menyusi (LocalSend orqali) |
| `Super + Ctrl + C` | Tasvirga olish boshqaruvlari (skrinshot/yozib olish/tanlagich) |
| `Super + Ctrl + O` | Menyuni yoqish/o‘chirish |
| `Super + Ctrl + H` | Uskuna menyusi |
| `Super + Ctrl + E` | Emoji tanlagich |
| `Super + Ctrl + .` | Mediani transkod qilish |
| `Super + Shift + Ctrl + A` | Standart agentingizni ishga tushirish |
| `Power` key | Tizim menyusi |
| `Super + Shift + Copilot` key | Omarchy menyusi |

## Sozlamalar

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Ekran yorqinligining maksimal darajasi |
| `Shift + Brightness Down` | Ekran yorqinligining minimal darajasi |
| `Alt + Brightness Up/Down` | Aniq 1% yorqinlik o‘zgarishlari |
| `Alt + Volume Up/Down` | Aniq 1% ovoz balandligi o‘zgarishlari |
| `Keyboard Brightness Up/Down` | Klaviatura yoritgichi yorqinroq/xiraroq |
| `Keyboard Backlight` | Klaviatura yoritgichi darajalarini aylanib o‘tish |
| `Ctrl + Brightness Up/Down` | O‘z tugmalari bo‘lmagan klaviaturalarda klaviatura yoritgichi yorqinroq/xiraroq |
| `Mic Mute` | Mikrofonni o‘chirish |
| `Shift + Mute` | Audio chiqishini almashtirish |
| `Touchpad Toggle` | Sensorli panelni yoqish yoki o‘chirish |
| `Display` key | Ish maydoni tartibini aylanib o‘tish |
| `Alt + Play` | Keyingi trek |
| `Alt + Shift + Play` | Oldingi trek |

## Ilovalarni ishga tushirish

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Tmux terminali |
| `Super + Ctrl + Return` | Herdr (agent menejeri) |
| `Super + Shift + Return` or `Super + Shift + B` | Brauzer |
| `Super + Shift + Alt + B` | Brauzer (maxfiy/inkognito) |
| `Super + Shift + F` | Fayl menejeri |
| `Super + Shift + Alt + F` | Terminalning cwd katalogidagi fayl menejeri |
| `Super + Shift + M` | Musiqa (Spotify) |
| `Super + Shift + Alt + M` | Musiqa (cliamp) |
| `Super + Shift + /` | Parollar menejeri (1password) |
| `Super + Shift + Q` or `Calculator` key | Kalkulyator (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, o‘rnatilgandan keyin) |
| `Super + Shift + T` | Faollik (btop) |
| `Super + Shift + N` | Muharrir (Plain, yoki siz tanlagan standart) |
| `Super + Shift + C` | Taqvim ([HEY](https://hey.com/)) |
| `Super + Shift + E` | Elektron pochta ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Yangi elektron pochta ([HEY](https://hey.com/)) |
| `Super + Shift + A` | Standart agentingiz, yoki tanlaguningizcha ChatGPT |
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

Bog‘lamalarni `~/.config/hypr/bindings.lua` da o‘zgartiring/qo‘shing.

## Universal almashuv buferi

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Super + A` | `Ctrl + A` ni qo‘llab-quvvatlaydigan ilovalarda barchasini tanlash |
| `Super + C` | Nusxalash |
| `Super + X` | Qirqish (terminalda emas) |
| `Super + V` | Qo‘yish |
| `Super + Ctrl + V` | Almashuv buferi menejeri |

Odatda Linux da terminalda copy'n'paste qilish uchun `Ctrl + Shift + C/V`, boshqa hamma joyda esa buni qilish uchun `Ctrl + C/V` kerak bo‘ladi. Omarchy ning ushbu birlashtirilgan almashuv buferi tezkor tugmalari hamma joyda ishlaydi.

## Tasvirga olish

| Tezkor tugma | Vazifasi |
| ------------------- | ------------------------------ |
| `Print Screen` | Skrinshot |
| `Super + Ctrl + Alt + C` | Skrinshot (o‘sha surat, Print Screen tugmasi yo‘q klaviaturalar uchun) |
| `Super + Ctrl + C` | Tasvirga olish menyusi |
| `Alt + Print Screen` | Ekranni yozib olish |
| `Super + Shift + Ctrl + Alt + C` | Audiosiz ekranni yozib olish, menyuni o‘tkazib yuborish (to‘xtatish uchun yana bosing) |
| `Super + Print Screen` | Rang tanlagich |
| `Super + Ctrl + Print Screen` | Matnni almashuv buferiga chiqarib olish |
| `Super + Alt + [` | Yozib olish paytida veb-kamera qoplamasini kichraytirish |
| `Super + Alt + ]` | Yozib olish paytida veb-kamera qoplamasini kattalashtirish |
| `Alt + Shift + L` | Veb-ilova yoki brauzerdan joriy URL ni nusxalash |
| `Alt + Shift + D` | Joriy sahifadagi videoni `~/Videos` ga yuklab olish |
| `Alt + Space` | Diktovkani boshlash/to‘xtatish (_Setup > Defaults > Dictation_ kerak) |
| `Right Alt` | Diktovka qilish uchun bosib turish (_Setup > Defaults > Dictation_ kerak) |

Ekran yozuvlarida tezkor tugma avval qaysi audioni xohlashingizni so‘raydi, keyin yozishni boshlaydi. To‘xtatish uchun uni yana bosing. Tafsilotlar uchun [skrinshotlar va yozib olish](12-screenshots-recording.md) ga qarang.

Barcha tasvirga olish variantlari Omarchy menyusidagi (`Super + Space`) _Trigger > Capture_ ostida ham mavjud.

## Bildirishnomalar

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Super + ,` | Eng so‘nggi bildirishnoma bilan amal bajarish: uni ochish yoki uning yagona tugmasini bosish, variantlaridan tanlash, yoki varianti bo‘lmasa uni yopish |
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
| `Super + Ctrl + Backspace` | Bitta oynali kvadrat formatni yoqish/o‘chirish |

Qo‘shimcha fon rasmlari `~/.config/omarchy/backgrounds/<theme name>` da joylashgan. Omarchy menyusidagi _Install > Style > Background_ orqali ham mavjud.

Barcha uslub variantlari Omarchy menyusidagi (`Super + Space`) _Appearance_ ostida ham mavjud.

## Almashtirgichlar

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Bekor turganda qulflashni yoqish/o‘chirish |
| `Super + Ctrl + Delete` | Noutbuk displeyini yoqish/o‘chirish |
| `Super + Ctrl + Alt + Delete` | Noutbuk displeyini aks ettirishni yoqish/o‘chirish |
| `Super + Shift + Space` | Yuqori panelni yoqish/o‘chirish |
| `Shift + Mute` | Keyingi audio chiqishiga o‘tish |
| `Shift + Play` | Keyingi media manbasiga o‘tish |
| `Super + Shift + Backspace` | Oyna oralig‘ini yoqish/o‘chirish |
| `Super + Ctrl + Alt + F` | To‘liq ekranli ish stolini yoqish/o‘chirish (yuqori panel + oyna oralig‘i) |

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

Prefiks tugmasi `Ctrl + Space` (`Ctrl + B` ham ishlaydi). Bu bog‘lamalarni `~/.config/tmux/tmux.conf` da o‘zgartirishingiz mumkin.

### Panellar

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Prefix + v` | Panelni yoniga bo‘lish (vertikal) |
| `Prefix + h` | Panelni pastga bo‘lish (gorizontal) |
| `Prefix + x` | Panelni yopish |
| `Prefix + z` | Panelni kattalashtirishni yoqish/o‘chirish (to‘liq ekran) |
| `Alt + Enter` | Panelni pastga bo‘lish (prefikssiz) |
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
| `Alt + 1-9` | Muayyan oynaga o‘tish |
| `Alt + Arrow Left/Right` | Oynalar orasida harakatlanish |
| `Alt + Shift + Arrow Left/Right` | Oynani chapga/o‘ngga siljitish |

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
| `Prefix + ?` | Tmux tugmalar birikmalarini ko‘rsatish |
| `Prefix + :` | Buyruq satri |

### Tmux tartib funksiyalari

Bu funksiyalarni Tmux sessiyasi ichida ishga tushirish kerak.

| Buyruq | Vazifasi |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Muharrir, AI va terminal bilan dev tartibini yaratish |
| `tdlm <ai> [<second_ai>]` | Har bir pastki katalog uchun dev tartibini yaratish |
| `tsl <count> <command>` | Ko‘p panelli swarm tartibini yaratish |

## Ghostty Terminal

Ghostty terminali Omarchy menyusi orqali _Install > Terminal_ yordamida o‘rnatiladi.

| Tezkor tugma | Vazifasi |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Pastda yangi bo‘linma |
| `Ctrl + Shift + O` | Yonida yangi bo‘linma |
| `Ctrl + Alt + Arrows` | Bo‘linmalar orasida harakatlanish |
| `Super + Ctrl + Shift + Arrows` | Bo‘linma o‘lchamini 10 qatorga o‘zgartirish |
| `Super + Ctrl + Shift + Alt + Arrows` | Bo‘linma o‘lchamini 100 qatorga o‘zgartirish |
| `Ctrl + Shift + T` | Yangi yorliq |
| `Ctrl + Shift + Arrows` | Yorliqlar orasida harakatlanish |
| `Alt + Numbers` | Muayyan yorliqqa o‘tish |
| `Shift + Pg Up/Down` | Tarixni aylantirish |
| `Ctrl + Left mouse` | Havolani brauzerda ochish |

## Fayl menejeri

| Tezkor tugma | Vazifasi |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Yo‘lga o‘tish |
| `Space` | Faylni oldindan ko‘rish (strelkalar bilan navigatsiya) |
| `Alt + Up` | Yuqoridagi ota katalogga o‘tish |

## Neovim (w/ lazyvim)

### Navigatsiya

| Tezkor tugma | Vazifasi |
| ------------------------ | ------------------------------- |
| `Space` | Buyruq variantlarini ko‘rsatish |
| `Space Space` | Noaniq qidiruv orqali faylni ochish |
| `Space E` | Yon panelni yoqish/o‘chirish |
| `Space G G` | git boshqaruvlarini ko‘rsatish |
| `Space S G` | Fayl mazmunini qidirish |
| `Ctrl + W W` | Yon panel va muharrir orasida sakrash |
| `Ctrl + Left/right arrow` | Yon panel o‘lchamini o‘zgartirish |
| `Shift + H` | Chap fayl yorlig‘iga o‘tish |
| `Shift + L` | O‘ng fayl yorlig‘iga o‘tish |
| `Space B D` | Fayl yorlig‘ini yopish |

### Yon panelda bo‘lganda

| Tezkor tugma | Vazifasi |
| ------------------------ | ------------------------------- |
| `A` | Ota katalogda yangi fayl qo‘shish |
| `Shift + A` | Ota katalogda yangi pastki katalog qo‘shish |
| `D` | Belgilangan fayl/katalogni o‘chirish |
| `M` | Belgilangan fayl/katalogni siljitish |
| `R` | Belgilangan fayl/katalog nomini o‘zgartirish |
| `?` | Barcha buyruqlar uchun yordamni ko‘rsatish |

[LazyVim tomonidan sozlangan barcha Neovim tezkor tugmalarini ko‘ring](https://www.lazyvim.org/keymaps).

## Tezkor emojilar

To‘liq emoji tanlagichni ko‘rsatish uchun `Super + Ctrl + E` ni ishlatishingiz mumkin, u tanlovni almashuv buferiga qo‘yadi, yoki ushbu tezkor kirish variantlaridan foydalanishingiz mumkin.

| Tezkor tugma | EM | Ishora |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | tabassum |
| `Shift + CapsLock M C` | 😂 | yig‘lash |
| `Shift + CapsLock M L` | 😍 | sevgi |
| `Shift + CapsLock M V` | ✌️ | g‘alaba |
| `Shift + CapsLock M H` | ❤️ | yurak |
| `Shift + CapsLock M Y` | 👍 | ha |
| `Shift + CapsLock M N` | 👎 | yo‘q |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | tilak |
| `Shift + CapsLock M R` | 🤘 | rok |
| `Shift + CapsLock M K` | 😘 | o‘pich |
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

`~/.XCompose` ni tahrirlash orqali o‘zingiznikidan ko‘proq qo‘shishingiz mumkin, keyin o‘zgarishlar qabul qilinishi uchun terminalda `omarchy restart xcompose` ni ishga tushiring.
