# Tezkor tugmalar

Asosiy klaviatura bog‘lanishlarining barchasini `Super + K` bilan ko‘rishingiz mumkin (Tmux bog‘lanishlari `Super + Alt + K` bilan va Herdr bog‘lanishlari `Super + Ctrl + K` bilan).

## Tezkor tugmalar qanday joylashtirilgan

Har bir tezkor tugma o‘z modifikatorlari bilan belgilanadigan tekislikda joylashadi va har bir tekislikning bitta vazifasi bor. Tezkor tugmalarning bir-biriga aralashib ketmasligini aynan shu ta’minlaydi va bu odatda biror narsaning qayerda joylashganini taxmin qila olishingizni anglatadi.

| Tekislik | U yerda nimalar joylashadi | Misollar |
| --- | --- | --- |
| `Super + key` | Tizim: oynalar, ish maydonlari, tartiblar va asosiy menyular | `Super + Space` Omarchy menyusi, `Super + W` oynani yopish, `Super + F` to‘liq ekran |
| `Super + Shift + key` | Ilovalar | `Super + Shift + B` brauzer, `Super + Shift + E` elektron pochta, `Super + Shift + N` muharrir |
| `Super + Ctrl + key` | Panellar va tizim menyulari | `Super + Ctrl + A` audio, `Super + Ctrl + N` tarmoq, `Super + Ctrl + C` tasvirga olish menyusi |
| `Super + Ctrl + Alt + key` | Tezkor amallar va bildirishlar | `Super + Ctrl + Alt + T` vaqtni ko‘rsatish, `Super + Ctrl + Alt + B` batareya, `Super + Ctrl + Alt + C` skrinshot |

Tezkor tugmaga `Alt` qo‘shish sizga xuddi o‘sha narsaning variantini beradi, hech qachon unga aloqasi bo‘lmagan narsani emas:

- `Super + Shift + B` brauzerni ochadi; `Super + Shift + Alt + B` shaxsiy oynani ochadi
- `Super + Shift + E` elektron pochtani ochadi; `Super + Shift + Alt + E` yangisini boshlaydi
- `Super + F` to‘liq ekranga o‘tadi; `Super + Alt + F` to‘liq kenglikka o‘tadi
- `Super + Ctrl + C` tasvirga olish menyusini ochadi; `Super + Ctrl + Alt + C` menyuni o‘tkazib yuboradi va skrinshot oladi

Tezkor tugma qo‘shayotganda:

1. U nima qilishiga qarab tekislikni tanlang, keyin tugmani tanlang.
2. Joy bo‘shatish uchun mavjud tezkor tugmani ko‘chirmang. To‘g‘ri tekislikda bo‘sh tugmani toping.
3. `Alt` dan faqat usiz bo‘lgan tezkor tugmaning varianti uchun foydalaning.

Bir nechta tezkor tugmalar qulay bo‘lgani uchun bu qoidalarni buzadi. O‘q yoki `Tab` bilan `Shift` ilovani ochish o‘rniga ko‘chiradi yoki yo‘nalishni teskari qiladi, `Print`, media tugmalari, `Alt + Tab` va `Ctrl + Alt + Del` esa boshqa hamma joydagi kabi ishlaydi. Ular istisnolar, nusxa olish uchun namuna emas.

Agar standart variant sizga mos kelmasa (aytaylik, Windows dagi kabi skrinshotlar uchun `Super + Shift + S` ni xohlasangiz), uni `~/.config/hypr/bindings.lua` da qayta bog‘lang.

## Navigatsiya

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menyusi (ilovalar va qolgan hamma narsa)    |
| `Super + Alt + Space` | Ilovalar panjarasi |
| `Super + Escape` | Tizim menyusi (kutish rejimi, qayta ishga tushirish va h.k.)  |
| `Super + Ctrl + L` | Kompyuterni qulflash |
| `Super + W` yoki `Super + Q` | Oynani yopish             |
| `Ctrl + Alt + Del` | Barcha oynalarni yopish |
| `Super + K` | Barcha tezkor tugmalarni ko‘rsatish |
| `Super + Alt + K` | tmux tezkor tugmalarini ko‘rsatish |
| `Super + Ctrl + K` | herdr tezkor tugmalarini ko‘rsatish |
| `Super + M` | Oynani dokka kichraytirish |
| `Super + T`               | Oynani plitka/yuzuvchi rejimlar o‘rtasida almashtirish             |
| `Super + J` | Oyna holatini almashtirish (gorizontal/vertikal) |
| `Super + O`               | Oynani sticky'n'floating rejimiga chiqarishni almashtirish |
| `Super + L`               | dwindle, scrolling va floating tartiblari bo‘ylab aylanish |
| `Super + Alt + L`         | Tartiblar bo‘ylab teskari yo‘nalishda aylanish |
| `Super + P`               | Pseudo oyna uslubini almashtirish (natural v stretch) |
| `Super + F`                 | To‘liq ekranga o‘tish              |
| `Super + Alt + F`                 | To‘liq kenglikka o‘tish              |
| `Super + Ctrl + F`                 | Oyna ichida to‘liq ekranga o‘tish              |
| `Super + 1…9/0`         | Fokusdagi monitordagi muayyan ish maydoniga o‘tish (0 — 10) |
| `Super + Tab` | Fokusdagi monitordagi keyingi ish maydoniga o‘tish |
| `Super + Shift + Tab` | Fokusdagi monitordagi avvalgi ish maydoniga o‘tish |
| `Super + Ctrl + Tab` | Fokusdagi monitordagi ilgari bo‘lgan ish maydoniga o‘tish |
| `Super + Shift + 1…9/0` | Oynani fokusdagi monitordagi ish maydoniga ko‘chirish |
| `Super + Shift + Alt + 1…9/0` | Oynani fokusdagi monitordagi ish maydoniga ortidan bormasdan ko‘chirish |
| `Super + S` | To‘liq scratchpad ni almashtirish |
| `Super + Alt + S` | Oynani to‘liq scratchpad ga ko‘chirish |
| `Super + the key above Tab` (AQSH tartiblarida grave) | Quake konsolini almashtirish |
| `Super + Shift + the key above Tab` (AQSH tartiblarida grave) | Oynani Quake konsoliga ko‘chirish |
| `Super + Shift + Ctrl + Arrows` | Oynani o‘sha yo‘nalishdagi monitorga ko‘chirish |
| `Super + Shift + Alt + Arrows` | Ish maydonini o‘sha yo‘nalishdagi monitorga ko‘chirish |
| `Super + Arrow`  | Fokusni o‘q yo‘nalishidagi oynaga ko‘chirish, ekranning chetida o‘sha tomondagi monitorga o‘tish |
| `Super + Shift + Arrow`  | Oynani o‘q yo‘nalishidagi boshqa oyna bilan almashtirish, shu jumladan o‘sha tomondagi monitordagisi bilan |
| `Super + Minus` | Oynani chapga kengaytirish |
| `Super + Equal` | Oynani chapga qisqartirish |
| `Super + Shift + Minus` | Oynani tepaga qisqartirish |
| `Super + Shift + Equal` | Oynani pastga kengaytirish |
| `Super + Alt + Minus/Equal` | Xuddi shu o‘lcham o‘zgartirish kichikroq qadamlarda |
| `Super + Ctrl + Minus/Equal` | Xuddi shu o‘lcham o‘zgartirish kattaroq qadamlarda |
| `Super + Alt + Home` | Oyna kengligini saqlash |
| `Super + Home` | Saqlangan oyna kengligini tiklash |
| `Super + Left Mouse` | Oynani sudrab yurish |
| `Super + Right Mouse` | Oyna o‘lchamini o‘zgartirish |
| `Super + Scroll Wheel` | Fokusdagi monitordagi ish maydonlari bo‘ylab aylantirish |
| `Super + G`               | Oynalarni guruhlashni almashtirish      |
| `Super + Alt + G`               | Oynani guruhdan chiqarish      |
| `Super + Alt + Tab`               | Guruh ichidagi oynalar bo‘ylab aylanish      |
| `Super + Alt + Shift + Tab`               | Guruh ichidagi oynalar bo‘ylab orqaga aylanish      |
| `Super + Alt + Scroll Wheel` | Guruh ichidagi oynalar bo‘ylab aylanish |
| `Super + Alt + 1/2/3/4/5`               | Guruhdagi muayyan oynaga o‘tish      |
| `Super + Alt + Arrow`  | Oynani o‘q yo‘nalishida guruh ichiga ko‘chirish, shu jumladan o‘sha tomondagi monitordagisini |
| `Super + Ctrl + Left/Right`  | Plitka guruhi ichidagi oynalar o‘rtasida harakatlanish |
| `Super + Ctrl + Z` | Ekranni yaqinlashtirish (ko‘proq yaqinlashtirish uchun takrorlang) |
| `Super + Ctrl + Alt + Z` | Ekrandan to‘liq uzoqlashish |
| `Super + /` | Monitor masshtablash variantlari bo‘ylab oldinga qadam tashlash |
| `Super + Alt + /` | Monitor masshtablash variantlari bo‘ylab orqaga qadam tashlash |
| `Alt + Tab` | Faol ish maydonidagi oynalar bo‘ylab oldinga aylanish |
| `Alt + Shift + Tab` | Faol ish maydonidagi oynalar bo‘ylab orqaga aylanish |
| `Ctrl + Alt + Tab`| Fokusni monitorlar bo‘ylab oldinga aylantirish |
| `Ctrl + Alt + Shift + Tab`| Fokusni monitorlar bo‘ylab orqaga aylantirish |
| `Super + I` | Kiritish tilini almashtirish (bir nechta tartib yoki kiritish usuli bo‘lganda) |
| `Super + Shift + I` | Kiritish tilini orqaga almashtirish |

Touchpad da uch va to‘rt barmoqli surishlar ish maydonlarini almashtiradi, oynalarni ko‘chiradi hamda menyu va Quake konsolini ochadi; imo-ishoralar uchun [klaviatura, sichqoncha va trekpad](34-keyboard-mouse-trackpad.md) ga qarang.

O‘lcham o‘zgartirish 0 ning o‘ngidagi ikki tugmadan foydalanadi, klaviaturangizda ularga nima bosilganidan qat’i nazar: AQSH klaviaturalarida `-` va `=`, Daniya va Shvetsiya klaviaturalarida `+` va `´`, Norvegiya klaviaturasida `+` va `\\`, Nemis klaviaturasida `ß` va `´`, Ispan klaviaturasida `'` va `¡`, Yapon (JIS) klaviaturasida esa `-` va `^`. `Super + K` ularni klaviaturangizda bosilganidek ro‘yxatlaydi. JIS da `Super + ^` — `Super + Equal`, `Super + Shift + -` (u `=` ni yozadi) esa `Super + Shift + Minus` dir. Monitor masshtabi va parollar menejeri `/` dan foydalanadi; `/` ni faqat Shift bilan yozadigan tartiblarda, aksariyat Yevropa tartiblaridagi kabi, ular o‘rniga o‘ng Shift ning chapidagi tugma ishlatiladi (Daniya va Nemis tartiblarida `-`).

## Tizim boshqaruvi

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Audio paneli    |
| `Super + Ctrl + B`           | Bluetooth paneli    |
| `Super + Ctrl + N`           | Wi-Fi/tarmoq paneli    |
| `Super + Ctrl + D`           | Displey paneli    |
| `Super + Ctrl + P`           | Quvvat paneli    |
| `Super + Ctrl + X`           | Agentlar paneli    |
| `Super + Ctrl + Alt + X`           | Lokal modellar paneli    |
| `Super + Ctrl + Alt + D`           | Kalendar paneli    |
| `Super + Ctrl + Alt + E`           | Jahon soati paneli    |
| `Super + Ctrl + 1-9`           | Bar panelini o‘rni bo‘yicha almashtirish    |
| `Super + Ctrl + S` | Ulashish menyusi (LocalSend orqali) |
| `Super + Ctrl + C` | Tasvirga olish boshqaruvi (skrinshot/-yozib olish/tanlagich) |
| `Super + Ctrl + O` | Menyuni almashtirish |
| `Super + Ctrl + H` | Qurilma menyusi |
| `Super + Ctrl + E` | Emoji tanlagich |
| `Super + Ctrl + .` | Mediani transkodlash |
| `Super + Shift + Ctrl + A` | Standart agentingizni ishga tushirish |
| `Power` tugmasi | Tizim menyusi |
| `Super + Shift + Copilot` tugmasi | Omarchy menyusi |

## Sozlashlar

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimal ekran yorqinligi |
| `Shift + Brightness Down` | Minimal ekran yorqinligi |
| `Alt + Brightness Up/Down` | Aniq 1% yorqinlik o‘zgarishlari |
| `Alt + Volume Up/Down` | Aniq 1% ovoz balandligi o‘zgarishlari |
| `Keyboard Brightness Up/Down` | Klaviatura yoritgichi yorqinroq/xiraroq |
| `Keyboard Backlight` | Klaviatura yoritgichi darajalari bo‘ylab aylanish |
| `Ctrl + Brightness Up/Down` | O‘z tugmalari bo‘lmagan klaviaturalarda klaviatura yoritgichi yorqinroq/xiraroq |
| `Mic Mute` | Mikrofonni o‘chirish |
| `Shift + Mute` | Audio chiqishini almashtirish |
| `Touchpad Toggle` | Touchpad ni yoqish yoki o‘chirish |
| `Display` tugmasi | Ish maydoni tartibi bo‘ylab aylanish |
| `Alt + Play` | Keyingi trek |
| `Alt + Shift + Play` | Avvalgi trek |

## Ilovalarni ishga tushirish

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux terminali |
| `Super + Ctrl + Return` | Herdr (agent menejeri) |
| `Super + Shift + Return` yoki `Super + Shift + B`  | Brauzer    |
| `Super + Shift + Alt + B`           | Brauzer (shaxsiy/inkognito)    |
| `Super + Shift + F`           | Fayl menejeri    |
| `Super + Shift + Alt + F`           | Terminalning cwd sidagi fayl menejeri    |
| `Super + Shift + M`           | Musiqa (Spotify)    |
| `Super + Shift + Alt + M`           | Musiqa (cliamp)    |
| `Super + Shift + /`           | Parollar menejeri (1password)    |
| `Super + Shift + Q` yoki `Calculator` tugmasi  | Kalkulyator (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, o‘rnatilgandan keyin)    |
| `Super + Shift + T`           | Faollik (btop)    |
| `Super + Shift + N`           | Muharrir (Plain yoki siz tanlagan standart)  |
| `Super + Shift + C`           | Kalendar ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Elektron pochta ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Yangi elektron pochta ([HEY](https://hey.com/))  |
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

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + A`           | `Ctrl + A` ni qo‘llab-quvvatlaydigan ilovalarda hammasini tanlash    |
| `Super + C`           | Nusxalash    |
| `Super + X`           | Kesish (terminalda emas)    |
| `Super + V`           | Qo‘yish    |
| `Super + Ctrl + V`           | Almashuv buferi menejeri    |

Odatda Linux da terminalda nusxalash-qo‘yish uchun `Ctrl + Shift + C/V`, boshqa hamma joyda esa `Ctrl + C/V` kerak bo‘ladi. Ushbu Omarchy ning birlashtirilgan almashuv buferi tezkor tugmalari hamma joyda ishlaydi.

## Tasvirga olish

| Tezkor tugma              | Funksiya                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Skrinshot                      |
| `Super + Ctrl + Alt + C`            | Skrinshot (o‘sha surat, Print Screen tugmasi bo‘lmagan klaviaturalar uchun) |
| `Super + Ctrl + C` | Tasvirga olish menyusi |
| `Alt + Print Screen`            | Ekranni yozib olish                     |
| `Super + Shift + Ctrl + Alt + C` | Menyuni o‘tkazib yuborib, audiosiz ekranni yozib olish (to‘xtatish uchun yana bosing) |
| `Super + Print Screen` | Rang tanlagich |
| `Super + Ctrl + Print Screen` | Matnni almashuv buferiga chiqarib olish |
| `Super + Alt + [` | Yozib olish paytida veb-kamera qoplamasini kichiklashtirish |
| `Super + Alt + ]` | Yozib olish paytida veb-kamera qoplamasini kattalashtirish |
| `Alt + Shift + L` | Veb-ilova yoki brauzerdan joriy URL ni nusxalash |
| `Alt + Shift + D` | Joriy sahifadagi videoni `~/Videos` ga yuklab olish |
| `Alt + Space` | Diktovkani boshlash/to‘xtatish (_Setup > Defaults > Dictation_ talab qilinadi) |
| `Right Alt` | Diktovka qilish uchun bosib turish (_Setup > Defaults > Dictation_ talab qilinadi) |

Ekranni yozib olishda tezkor tugma avval qaysi audioni xohlayotganingizni so‘raydi, keyin yozishni boshlaydi. To‘xtatish uchun uni yana bosing. Tafsilotlar uchun [skrinshotlar va yozib olish](12-screenshots-recording.md) ga qarang.

Barcha tasvirga olish variantlariga Omarchy menyusidagi _Trigger > Capture_ ostida ham kirish mumkin (`Super + Space`).

## Bildirishlar

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + ,` | Eng so‘nggi bildirishga amal qilish: uni ochish yoki uning yagona tugmasini bosish, variantlaridan tanlash yoki varianti bo‘lmaganda uni bekor qilish  |
| `Super + Shift + ,` | Barcha bildirishlarni bekor qilish |
| `Super + Ctrl + ,` | Bildirishlarni klaviatura bilan boshqarish  |
| `Super + Alt + ,` | Eng so‘nggi bildirishni bekor qilish  |
| `Super + Shift + Alt + ,` | Bildirishlar tarixini ochish  |
| `Super + Ctrl + Alt + ,` | Bildirishlarni jim qilishni almashtirish  |

## Uslub

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Yangi mavzuni tanlash (shuningdek `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Mavzu fonini tanlash (shuningdek `Super + Ctrl + Space`) |
| `Super + Backspace` | Oynadagi shaffoflikni almashtirish |
| `Super + Ctrl + Backspace` | Bitta oyna kvadrat formatini almashtirish |

Qo‘shimcha fon rasmlari `~/.config/omarchy/backgrounds/<theme name>` da joylashgan. Omarchy menyusidagi _Install > Style > Background_ orqali ham mavjud.

Barcha uslub variantlariga Omarchy menyusidagi _Appearance_ ostida ham kirish mumkin (`Super + Space`).

## Almashtirgichlar

| Tezkor tugma                  | Funksiya              |
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

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Eslatma o‘rnatish  |
| `Super + Ctrl + Alt + R` | Barcha eslatmalarni ko‘rish  |
| `Super + Ctrl + Shift + R` | Barcha eslatmalarni tozalash  |

## Ma’lumotlar

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Vaqtni bildirish sifatida ko‘rsatish  |
| `Super + Ctrl + Alt + B` | Batareyani bildirish sifatida ko‘rsatish  |
| `Super + Ctrl + Alt + W` | Ob-havoni bildirish sifatida almashtirish  |

## Tmux

Prefiks tugmasi `Ctrl + Space` (`Ctrl + B` ham ishlaydi). Bu bog‘lanishlarni `~/.config/tmux/tmux.conf` da o‘zgartirishingiz mumkin.

### Panellar

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Prefix + v` | Panelni yoniga bo‘lish (vertikal) |
| `Prefix + h` | Panelni pastiga bo‘lish (gorizontal) |
| `Prefix + x` | Panelni tugatish |
| `Prefix + z` | Panelni kattalashtirishni almashtirish (to‘liq ekran) |
| `Alt + Enter` | Panelni pastiga bo‘lish (prefikssiz) |
| `Alt + Shift + Enter` | Panelni yoniga bo‘lish (prefikssiz) |
| `Alt + Escape` | Panelni tugatish (prefikssiz) |
| `Ctrl + Alt + Arrows` | Panellar o‘rtasida harakatlanish |
| `Ctrl + Alt + Shift + Arrows` | Panellar o‘lchamini o‘zgartirish |

### Oynalar

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Prefix + c` | Yangi oyna |
| `Prefix + k` | Oynani tugatish |
| `Prefix + r` | Oyna nomini o‘zgartirish |
| `Alt + 1-9` | Muayyan oynaga o‘tish |
| `Alt + Arrow Left/Right` | Oynalar o‘rtasida harakatlanish |
| `Alt + Shift + Arrow Left/Right` | Oynani chapga/o‘ngga ko‘chirish |

### Sessiyalar

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Prefix + C` | Yangi sessiya |
| `Prefix + K` | Sessiyani tugatish |
| `Prefix + R` | Sessiya nomini o‘zgartirish |
| `Prefix + N` | Keyingi sessiya |
| `Prefix + P` | Avvalgi sessiya |
| `Alt + Arrow Up/Down` | Sessiyalar o‘rtasida harakatlanish |
| `Prefix + s` | Sessiyalarni ro‘yxatlash |
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
| `Prefix + ?` | Tmux tugma bog‘lanishlarini ko‘rsatish |
| `Prefix + :` | Buyruq satri |

### Tmux tartib funksiyalari

Bu funksiyalar Tmux sessiyasi ichida ishlatilishi kerak.

| Buyruq | Funksiya |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Muharrir, AI va terminal bilan dasturlash tartibini yaratish |
| `tdlm <ai> [<second_ai>]` | Har bir pastki katalog uchun dasturlash tartibini yaratish |
| `tsl <count> <command>` | Ko‘p panelli swarm tartibini yaratish |

## Ghostty Terminal

Ghostty terminali Omarchy menyusi orqali _Install > Terminal_ yordamida o‘rnatiladi.

| Tezkor tugma                  | Funksiya              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Pastda yangi bo‘linma |
| `Ctrl + Shift + O` | Yonida yangi bo‘linma |
| `Ctrl + Alt + Arrows` | Bo‘linmalar o‘rtasida harakatlanish |
| `Super + Ctrl + Shift + Arrows` | Bo‘linma o‘lchamini 10 qatorga o‘zgartirish |
| `Super + Ctrl + Shift + Alt + Arrows` | Bo‘linma o‘lchamini 100 qatorga o‘zgartirish |
| `Ctrl + Shift + T` | Yangi varaq  |
| `Ctrl + Shift + Arrows` | Varaqlar o‘rtasida harakatlanish |
| `Alt + Numbers` | Muayyan varaqqa o‘tish |
| `Shift + Pg Up/Down` | Tarixni aylantirish |
| `Ctrl + Left mouse` | Havolani brauzerda ochish |

## Fayl menejeri

| Tezkor tugma              | Funksiya                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Yo‘lga o‘tish                     |
| `Space`               | Faylni oldindan ko‘rish (o‘qlar bilan navigatsiya) |
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
| `Shift + H`                      | Chap fayl varag‘iga o‘tish             |
| `Shift + L`                      | O‘ng fayl varag‘iga o‘tish            |
| `Space B D`                | Fayl varag‘ini yopish                  |

### Yon panelda bo‘lganda

| Tezkor tugma                   | Funksiya                        |
| ------------------------ | ------------------------------- |
| `A`                        | Ota katalogda yangi fayl qo‘shish      |
| `Shift + A`                | Ota katalogda yangi pastki katalog qo‘shish    |
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
| `Shift + CapsLock M C` | 😂 | yig‘i        |
| `Shift + CapsLock M L` | 😍 | sevgi       |
| `Shift + CapsLock M V` | ✌️ | g‘alaba    |
| `Shift + CapsLock M H` | ❤️ | yurak      |
| `Shift + CapsLock M Y` | 👍 | ha        |
| `Shift + CapsLock M N` | 👎 | yo‘q         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | tilak       |
| `Shift + CapsLock M R` | 🤘 | rok       |
| `Shift + CapsLock M K` | 😘 | o‘pich       |
| `Shift + CapsLock M E` | 🙄 | ko‘z aylantirish    |
| `Shift + CapsLock M I` | 😉 | ko‘z qisish       |
| `Shift + CapsLock M P` | 🙏 | ibodat |
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

`~/.XCompose` ni tahrirlash orqali o‘zingiznikidan ko‘proq qo‘shishingiz, keyin o‘zgarishlar qabul qilinishi uchun terminalda `omarchy restart xcompose` ni ishga tushirishingiz mumkin.
