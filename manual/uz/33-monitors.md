# Monitorlar

Omarchy sukut boʻyicha siz 2x imkoniyatiga ega retina sinfidagi displeydan foydalanayapsiz deb hisoblaydi. Yoqimli, tiniq dasturchi shriftlari uchun sizga aynan shu kerak. Deyarli barcha yangi premium noutbuklar yuqori aniqlikdagi ekranlari bilan aynan shunga moslashtirilgan. 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) yoki 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) da ham aynan shuni ishlatishni xohlaysiz.

Ammo PPI koʻrsatkichi 218 yoki undan yuqori boʻlgan displeydan foydalanmayotgan boʻlsangiz, monitor sozlamalarini oʻzgartirishni xohlaysiz. Masalan, sizda 27" yoki 32" 4K boʻlsa, yuqori paneldagi monitor panelidan unga kasrli masshtab tanlashingiz yoki `~/.config/hypr/monitors.lua` faylini ochib, oʻsha kombinatsiya uchun tavsiyaga oʻtish orqali har bir monitor uchun sukut boʻyicha qiymatni belgilashingiz mumkin:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Agar 1080p yoki 1440p displeydan foydalanayotgan boʻlsangiz, ehtimol shunchaki 1x masshtabdan foydalanishni xohlaysiz, GTK va X11 ilovalari uchun ham xuddi shunday, shuning uchun quyidagini ishlatishingiz mumkin:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` ga kiritilgan oʻzgarishlar oʻzgarishdan keyin ishga tushirilgan ilovalarga taʼsir qiladi (va GTK faqat butun sonlarni qabul qiladi, shuning uchun uni monitor masshtabingizga eng yaqin butun sonda saqlang). Shuning uchun oʻzgarishdan keyin juda katta boʻlib qolgan oynalaringizni yopganingizga ishonch hosil qiling (yoki barcha oynalarni `Ctrl + Alt + Del` bilan yoping!).

Shuningdek, kattaroqqa oʻtish uchun `Super + /` va kichikroqqa oʻtish uchun `Super + Alt + /` yordamida asosiy monitor masshtab nisbatlari (1x, 1.25x, 1.6x, 2x, 3x, 4x) boʻylab tez oʻtishingiz yoki yuqori paneldagi monitor panelidan bittasini tanlashingiz mumkin. Bular faqat siz fokusda boʻlgan monitorni oʻzgartiradi, shuning uchun noutbuk ekrani va tashqi displey har biri oʻz masshtabiga ega boʻlishi mumkin. Panel har bir monitorning aniqligi, yangilanish tezligi va burilishini ham belgilaydi. Tanlovlaringiz oʻsha jismoniy monitor uchun `~/.local/state/omarchy/monitors/settings` da saqlanadi, shuning uchun ular qayta yuklashdan keyin ham saqlanib qoladi va monitor keyingi safar qaysi port yoki dokka ulangan boʻlsa, oʻshanga ergashadi. Ular Omarchy hech qachon tahrir qilmaydigan `~/.config/hypr/monitors.lua` dagi ayni monitor uchun har qanday qoidadan ustun turadi. Agar monitorlaringizni toʻliq oʻsha faylda belgilashni afzal koʻrsangiz, unga `omarchy_monitor_panel_settings = false` ni qoʻshing, shunda paneldagi oʻzgarishlar faqat Hyprland qayta yuklanguniga qadar davom etadi. `GDK_SCALE` barcha ekranlar uchun bitta qiymat boʻlgani sababli, tanlangan masshtab uni eng past masshtabli monitordan belgilaydi, shuning uchun X11 ilovalari boshqa ekranda juda katta boʻlib qolish oʻrniga zichroq ekranda biroz kichik chiqadi.

### Matnni kattalashtirish yoki kichiklashtirish

Monitor masshtabi hamma narsaning oʻlchamini oʻzgartiradi. Agar siz xohlagan narsa faqat kattaroq yoki kichikroq _matn_ boʻlsa, buning uchun bitta tugma bor:

```
omarchy display text size 14
```

Bu 9 dan 20 gacha boʻlgan piksel oʻlchamini qabul qiladi va Omarchy qobigʻi, GTK ilovalari hamda terminalingizni birga siljitadi, shuning uchun butun ish stoli mutanosib boʻlib qoladi. Qayerda ekaningizni koʻrish uchun uni argumentsiz ishga tushiring, sukut boʻyicha qiymatga qaytish uchun esa `omarchy display text size reset` ni ishga tushiring. Foot yagona orqada qoluvchi: uning konfiguratsiyani qayta yuklash usuli yoʻq, shuning uchun ishlayotgan terminallar yangisini ochmaguningizcha eski oʻlchamini saqlab qoladi.

### Noutbuk displeylarini kengaytirish va aks ettirish

Tashqi ekranni noutbukingizga ulaganingizda, displey avtomatik ravishda kengaytiriladi. Ammo Omarchy menyusidagi _Trigger > Hardware_ yoki `Super + Ctrl + Alt + Delete` yordamida buning oʻrniga aks ettirishga oʻzgartirishingiz mumkin. Bu, ayniqsa, oʻsha tashqi ekran proyektor boʻlsa va ishlayotganingizda biror narsani koʻrsatmoqchi boʻlsangiz, yordam beradi.

Kengaytirayotganingizda, noutbuk qopqogʻini yopish ichki ekranni avtomatik ravishda oʻchiradi. Qopqoqni ochish uni qayta yoqadi. Buni Omarchy menyusidagi _Trigger > Hardware_ yoki `Super + Ctrl + Delete` yordamida qoʻlda ham boshqarishingiz mumkin.

### Bir nechta ekranni tartibga solish

Hyprland bir nechta ekran bilan ajoyib ishlaydi. Yuqori paneldagi monitor paneli ularni turgan joyida chizadi: bittasini boshqasining yoniga sudrab olib boring, shunda u oʻsha yerga koʻchadi va tartib har bir monitorning boshqa sozlamalari bilan birga saqlanadi. Panel qamrab olmaydigan har qanday narsa uchun ularni qanday joylashtirish haqida [Hyprland monitorlari boʻyicha hujjatlarda](https://wiki.hypr.land/Configuring/Basics/Monitors/) koʻproq oʻqing. Omarchy da bular `~/.config/hypr/monitors.lua` ga `hl.monitor` yozuvlari sifatida kiradi — fayl monitorni oʻchirilgan holda saqlash, panel taklif qilmaydigan rejimlar, 10-bit rang va oʻzgaruvchan yangilanish tezligi uchun izohlangan misollar bilan yetkaziladi.

Har bir monitorning oʻzining 1 dan 10 gacha ish maydonlari bor, shuning uchun `Super + 1` har doim siz turgan monitorning birinchi ish maydonini anglatadi. Sahna ortida Hyprland baribir ish maydonlarini barcha monitorlar boʻylab raqamlaydi: noutbuk ekraningiz (yoki birinchi monitoringiz) 1–10 ni, keyingi monitor 11–20 ni va hokazoni oladi va har bir monitor uni har safar ulaganingizda oʻz blokini saqlab qoladi. Muayyan monitor uchun [ish maydoni qoidalari](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) yoki oyna qoidalarini yozsangiz, oʻsha raqamlardan foydalaning, shuning uchun 12-ish maydoni ikkinchi monitoringizning ikkinchi ish maydonidir. `~/.local/state/omarchy/monitors/workspaces` har bir monitorda qaysi blok borligini roʻyxatga oladi.

Strelka tugmalari tartibingizda chekka ulashadigan monitorlar boʻylab ishlaydi. Faqat burchakda tegib turadigan yoki orasida boʻshliq boʻlgan ekranlar qoʻshni emas, shuning uchun ular orasiga oʻtish uchun `Ctrl + Alt + Tab` dan foydalaning.

| Tezkor tugma | Monitorlar aro |
| --- | --- |
| `Super + Arrow` | Oʻsha yoʻnalishda oyna qolmagach, fokusni oʻsha tomondagi monitorga koʻchiradi |
| `Super + Shift + Arrow` | Oʻsha tomondagi monitordagi oyna bilan almashadi |
| `Super + Alt + Arrow` | Oynani oʻsha tomondagi monitordagi guruhga koʻchiradi |
| `Super + Shift + Ctrl + Arrow` | Oynani oʻsha tomondagi monitorga, u koʻrsatayotgan ish maydoniga koʻchiradi |
| `Super + Shift + Alt + Arrow` | Ish maydonini oʻsha tomondagi monitorga koʻchiradi, agar boʻsh boʻlsa, uning raqamini saqlab qoladi |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Tartib qanday boʻlishidan qatʼi nazar, fokusni keyingi yoki oldingi monitorga koʻchiradi |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Siz turgan monitorda qoladi |

Agar bir nechta ekranni joylashtirishda sizga yordam beradigan TUI ni xohlasangiz, [Hyprmon](https://github.com/erans/hyprmon/) ni ham koʻrib chiqishingiz mumkin.

### Yorqinlikni boshqarish

Monitor yorqinligi yorqinlikni oshirish/pasaytirish uchun moʻljallangan maxsus funksiya tugmalari bilan boshqariladi. Agar bu tugmalarni bosayotganda Shift ni bosib tursangiz, maksimal yoki minimal yorqinlikka oʻtasiz. Tugmalar siz fokusda boʻlgan displeyni boshqaradi, shuning uchun DDC/CI orqali gaplashadigan tashqi monitorlar noutbuk ekrani bilan bir xil tarzda sozlanadi.

### Apple displeylari

Agar Apple displeyidan foydalanayotgan boʻlsangiz, Apple displeyida fokusda boʻlganingizda oddiy klaviatura yorqinlik tugmalari ham avtomatik ravishda ishlaydi. Bu `asdcontrol` buyrugʻi orqali amalga oshiriladi.

Esda tuting, agar Apple 6K XDR displeyidan foydalanayotgan boʻlsangiz, `hyprctl monitors` roʻyxatingizda xayoliy ekranni koʻrishingiz mumkin. Buni `~/.config/hypr/monitors.lua` dagi `hl.monitor({ output = "DP-2", disabled = true })` kabi narsa bilan oʻchirishingiz mumkin.

Intel mashinalarida Apple displeylariga oddiy Thunderbolt kabeli yordamida ulanishingiz kerak. Thunderbolt boʻlmagan boshqa mashinalarda buni ishlashi uchun odatda [DP + USB-A -> USB-C kabelidan](https://www.amazon.com/dp/B0BNX7MS6N) foydalanishingizga toʻgʻri keladi.
