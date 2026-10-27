# Monitorlar

Omarchy sukut boʻyicha siz 2x imkoniyatiga ega retina darajasidagi displeydan foydalanayapsiz, deb hisoblaydi. Ana shu yoqimli, tiniq dasturchi shriftlarini olish uchun aynan shu kerak. Deyarli barcha yangi premium noutbuklar yuqori aniqlikdagi ekranlar bilan aynan shunga moslashtirilgan. 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) yoki 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) da ham aynan shuni xohlaysiz.

Ammo agar PPI koʻrsatkichi 218 yoki undan yuqori boʻlgan displeydan foydalanmayotgan boʻlsangiz, monitor sozlamalarini oʻzgartirishni xohlaysiz. Masalan, agar sizda 27" yoki 32" 4K boʻlsa, `~/.config/hypr/monitors.lua` faylini ochib (Omarchy menyusidagi _Sozlash > Monitorlar_ orqali), shu kombinatsiya uchun tavsiya etilganiga oʻtish orqali kasrli masshtabdan foydalanishingiz mumkin:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Agar 1080p yoki 1440p displeydan foydalanayotgan boʻlsangiz, ehtimol shunchaki 1x masshtabdan foydalanishni xohlaysiz, shuning uchun quyidagini ishlatishingiz mumkin:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` ga kiritilgan oʻzgarishlar oʻzgarishdan keyin ishga tushirilgan ilovalarga taʼsir qiladi (GTK esa faqat butun sonlarni qabul qiladi, shuning uchun uni monitor masshtabingizga eng yaqin butun sonda saqlang). Shuning uchun oʻzgarishdan keyin haddan tashqari katta boʻlib qolgan oynalaringizni yopganingizga ishonch hosil qiling (yoki barcha oynalarni `Ctrl + Alt + Del` bilan yoping!).

Shuningdek, `Super + /` yordamida yuqoriga va `Super + Alt + /` yordamida pastga oʻtib, asosiy monitor masshtab nisbatlari (1x, 1.25x, 1.6x, 2x, 3x, 4x) boʻylab tez oʻtishingiz mumkin. Agar sizda standart konfiguratsiya boʻlsa, bu oʻzgarishlar qayta yuklashdan keyin ham saqlanib qoladi.

### Matnni kattalashtirish yoki kichraytirish

Monitor masshtabi hamma narsaning oʻlchamini oʻzgartiradi. Agar siz xohlagan narsa faqat kattaroq yoki kichikroq _matn_ boʻlsa, buning uchun bitta tugma bor:

```
omarchy display text size 14
```

U 9 dan 20 gacha boʻlgan piksel oʻlchamini qabul qiladi va Omarchy qobigʻini, GTK ilovalarini hamda terminalingizni birga siljitadi, shu tariqa butun ish stoli mutanosib boʻlib qoladi. Qayerda ekaningizni koʻrish uchun uni argumentsiz ishga tushiring va standart holatga qaytish uchun `omarchy display text size reset` ni ishga tushiring. Foot yagona orqada qoluvchi: uning konfiguratsiyasini qayta yuklashning imkoni yoʻq, shuning uchun ishlayotgan terminallar yangisini ochmaguningizcha eski oʻlchamida qoladi.

### Noutbuk displeylarini kengaytirish va aks ettirish

Tashqi ekranni noutbukingizga ulaganingizda, displey avtomatik ravishda kengaytiriladi. Ammo buning oʻrniga uni aks ettirishga oʻzgartirishingiz mumkin: buning uchun Omarchy menyusidagi _Trigger > Qurilma_ dan yoki `Super + Ctrl + Alt + Delete` dan foydalaning. Bu, ayniqsa, agar oʻsha tashqi ekran proyektor boʻlsa va ishlayotganingizda biror narsani koʻrsatmoqchi boʻlsangiz, foydali.

Kengaytirayotganingizda, noutbuk qopqogʻini yopish ichki ekranni avtomatik ravishda oʻchiradi. Qopqoqni ochish uni qayta yoqadi. Buni Omarchy menyusidagi _Trigger > Qurilma_ orqali yoki `Super + Ctrl + Delete` yordamida qoʻlda ham boshqarishingiz mumkin.

### Bir nechta ekranni tartibga solish

Hyprland bir nechta ekranlar bilan ajoyib ishlaydi. Ularni qanday joylashtirish haqida [Hyprland monitor hujjatlarida](https://wiki.hypr.land/Configuring/Basics/Monitors/) batafsil oʻqing. Omarchy da bular `~/.config/hypr/monitors.lua` ga `hl.monitor` yozuvlari sifatida kiritiladi — fayl muayyan monitorni aniqlik, joylashuv va burilishga biriktirish uchun izohli misollar bilan birga keladi.

Har bir monitorning oʻzining 1 dan 10 gacha boʻlgan ish maydonlari bor, shuning uchun `Super + 1` har doim siz turgan monitorning birinchi ish maydonini anglatadi. Parda ortida Hyprland baribir ish maydonlarini barcha monitorlar boʻylab raqamlaydi: noutbuk ekraningiz (yoki birinchi monitoringiz) 1–10 ni, keyingi monitor 11–20 ni oladi va hokazo, har bir monitor esa uni har safar ulaganingizda oʻz blokini saqlab qoladi. Muayyan monitor uchun [ish maydoni qoidalari](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) yoki oyna qoidalarini yozsangiz, shu raqamlardan foydalaning, shunda 12-ish maydoni ikkinchi monitoringizning ikkinchi ish maydoni boʻladi. `~/.local/state/omarchy/monitor-workspaces` har bir monitor qaysi blokka ega ekanini sanab beradi.

Strelka tugmalari joylashuvingizda umumiy qirraga ega boʻlgan monitorlar orasida ishlaydi. Faqat burchakda tegib turadigan yoki orasida boʻshliq boʻlgan ekranlar qoʻshni emas, shuning uchun ular orasida oʻtish uchun `Ctrl + Alt + Tab` dan foydalaning.

| Tezkor tugma | Monitorlar orasida |
| --- | --- |
| `Super + Arrow` | Bu yoʻnalishda boshqa oyna qolmagach, fokusni oʻsha tomondagi monitorga oʻtkazadi |
| `Super + Shift + Arrow` | Oʻsha tomondagi monitordagi oyna bilan almashtiradi |
| `Super + Alt + Arrow` | Oynani oʻsha tomondagi monitordagi guruhga koʻchiradi |
| `Super + Shift + Ctrl + Arrow` | Oynani oʻsha tomondagi monitorga, u koʻrsatayotgan ish maydoniga koʻchiradi |
| `Super + Shift + Alt + Arrow` | Ish maydonini oʻsha tomondagi monitorga koʻchiradi, agar boʻsh boʻlsa, uning raqamini saqlab qoladi |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Joylashuv qanday boʻlishidan qatʼi nazar, fokusni keyingi yoki oldingi monitorga oʻtkazadi |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Siz turgan monitorda qoladi |

Agar bir nechta ekranni joylashtirishda sizga yordam beradigan TUI kerak boʻlsa, [Hyprmon](https://github.com/erans/hyprmon/) ni ham koʻrib chiqishingiz mumkin.

### Yorqinlikni boshqarish

Monitor yorqinligi yorqinlikni oshirish/pasaytirish uchun ajratilgan funksiya tugmalari orqali boshqariladi. Agar ularni bosayotganda Shift ni bosib tursangiz, maksimal yoki minimal yorqinlikka oʻtasiz. Tugmalar siz fokusda turgan displeyni boshqaradi, shuning uchun DDC/CI orqali gaplashadigan tashqi monitorlar ham noutbuk ekrani kabi sozlanadi.

### Apple displeylari

Agar Apple displeyidan foydalanayotgan boʻlsangiz, Apple displeyida fokusda boʻlsangiz, oddiy klaviatura yorqinlik tugmalari ham avtomatik ishlaydi. Bu `asdcontrol` buyrugʻi orqali amalga oshiriladi.

Eʼtibor bering, agar Apple 6K XDR displeyidan foydalanayotgan boʻlsangiz, `hyprctl monitors` roʻyxatida arvoh ekranni koʻrishingiz mumkin. Buni _Sozlash > Monitorlar_ orqali `hl.monitor({ output = "DP-2", disabled = true })` kabi biror narsa bilan oʻchirishingiz mumkin.

Intel mashinalarida Apple displeylariga oddiy Thunderbolt kabeli yordamida ulanishingiz kerak. Thunderbolt boʻlmagan boshqa mashinalarda, odatda, uni ishlatish uchun [DP + USB-A -> USB-C kabelidan](https://www.amazon.com/dp/B0BNX7MS6N) foydalanishingizga toʻgʻri keladi.
