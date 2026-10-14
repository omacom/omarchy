# Monitorlar

Omarchy standart tarzda siz 2x imkoniyatli retina sinfidagi displeyda ishlayotganingizni faraz qiladi. Bu oʻsha chiroyli, tiniq dasturchi shriftlarini olish uchun sizga kerak boʻlgan narsadir. Bu yuqori aniqlikdagi ekranli deyarli barcha yangi premium noutbuklar nima uchun optimallashtirilganidir. Bu siz 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) yoki 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) da ishlatishni xohlagan narsangizdir.

Lekin agar siz PPI si 218 yoki undan yuqori boʻlgan displeyni ishlatmayotgan boʻlsangiz, monitor sozlamalarini oʻzgartirishni xohlaysiz. Masalan, agar sizda 27" yoki 32" 4K boʻlsa, `~/.config/hypr/monitors.lua` ni ochish (Omarchy menyusidagi _Sozlash > Monitors_ orqali) va oʻsha kombinatsiya uchun tavsiyaga oʻtish orqali kasr miqyoslashdan foydalanishingiz mumkin:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Agar siz 1080p yoki 1440p displeydan foydalanayotgan boʻlsangiz, ehtimol shunchaki 1x miqyoslashdan foydalanishni xohlaysiz, shuning uchun foydalanishingiz mumkin:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` ga oʻzgarishlar oʻzgarishdan keyin boshlangan ilovalarga qoʻllanadi (va GTK faqat butun sonlarni hurmat qiladi, shuning uchun uni monitor miqyosingizning eng yaqin butunida saqlang). Shunday qilib, oʻzgarishdan keyin katta oʻlchamli boʻlgan oynalaringizni yopganingizga ishonch hosil qiling (yoki `Ctrl + Alt + Del` bilan barcha oynalarni yoping!).

Yuqoriga chiqish uchun `Super + /` va pastga tushish uchun `Super + Alt + /` yordamida asosiy monitor miqyoslash nisbatlari (1x, 1.25x, 1.6x, 2x, 3x, 4x) boʻylab tez qadam tashlashingiz ham mumkin. Agar sizda standart konfiguratsiya boʻlsa, bu oʻzgarishlar qayta yuklashdan keyin ham saqlanadi.

### Matnni kattaroq yoki kichikroq qilish

Monitor miqyoslash hamma narsaning oʻlchamini oʻzgartiradi. Agar siz xohlagan narsa faqat kattaroq yoki kichikroq _matn_ boʻlsa, buni uchun bitta tugma bor:

```
omarchy display text size 14
```

Bu 9 dan 20 gacha boʻlgan piksel oʻlchamini oladi va Omarchy shellini, GTK ilovalarini va terminalingizni birga koʻchiradi, shuning uchun butun ish stoli proporsiyada qoladi. Qayerda turganingizni koʻrish uchun uni argumentsiz ishga tushiring va standartga qaytish uchun `omarchy display text size reset` ni ishga tushiring. Foot bitta kechikuvchi: uning konfiguratsiyasini qayta yuklash usuli yoʻq, shuning uchun ishlayotgan terminallar siz yangisini ochganingizgacha eski oʻlchamini saqlaydi.

### Noutbuk displeylarini kengaytirish va aks ettirish

Noutbukingizga tashqi ekranni ulaganingizda, displey avtomatik kengaytiriladi. Lekin Omarchy menyusidagi _Ishga tushirish > Hardware_ yoki `Super + Ctrl + Alt + Delete` yordamida buni uning oʻrniga aks ettirishga oʻzgartirishingiz mumkin. Bu ayniqsa oʻsha tashqi ekran proyektor boʻlsa va siz ishlayotgan paytingizda biror narsani koʻrsatmoqchi boʻlsangiz foydalidir.

Kengaytiriayotganingizda, noutbukdagi qopqoqni yopish ichki ekranni avtomatik oʻchiradi. Qopqoqni ochish uni qayta yoqadi. Buni Omarchy menyusidagi _Ishga tushirish > Hardware_ yoki `Super + Ctrl + Delete` yordamida qoʻlda ham boshqarishingiz mumkin.

### Bir nechta ekranni tartibga solish

Hyprland bir nechta ekran bilan ajoyib ishlaydi. Ularni qanday joylashtirish haqida [Hyprland monitor hujjatlari](https://wiki.hypr.land/Configuring/Basics/Monitors/) da koʻproq oʻqing. [Maxsus ish maydonlarini maxsus monitorlarga bogʻlash](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ni ham qilishingiz mumkin. Omarchy da bu qoidalar `~/.config/hypr/monitors.lua` ga `hl.monitor` yozuvlari sifatida kiradi — fayl maxsus monitorni aniqlik, joy va aylanishga mahkamlash uchun izohlangan misollar bilan keladi.

Agar bir nechta ekranlarning joylashuviga yordam beradigan TUI ni istasangiz, [Hyprmon](https://github.com/erans/hyprmon/) ni ham tekshirishingiz mumkin.

### Yorqinlikni boshqarish

Monitor yorqinligi yorqinlikni oshirish/tushirish uchun maxsus funksiya tugmalari tomonidan boshqariladi. Agar ularni bosayotganda shift ni ushlab tursangiz, maksimum yoki minimum yorqinlikka borasiz. Tugmalar siz fokuslangan displeyni boshqaradi, shuning uchun DDC/CI gapiradigan tashqi monitorlar noutbuk ekrani bilan bir xil tarzda sozlanadi.

### Apple displeylari

Agar Apple displeyidan foydalanayotgan boʻlsangiz, Apple displeyiga fokuslangan boʻlsangiz, oddiy klaviatura yorqinlik tugmalari ham avtomatik ishlaydi. Bu `asdcontrol` buyrugʻi orqali amalga oshiriladi.

Eʼtibor bering, agar Apple 6K XDR displeyidan foydalanayotgan boʻlsangiz, `hyprctl monitors` roʻyxatingizda xayoliy ekranni koʻrishingiz mumkin. Buni _Sozlash > Monitors_ orqali `hl.monitor({ output = "DP-2", disabled = true })` kabi narsa bilan oʻchirishingiz mumkin.

Intel mashinalarda siz Apple displeylariga oddiy Thunderbolt kabeli yordamida ulanishingiz kerak. Thunderboltsiz boshqa mashinalarda siz odatda u ishlashi uchun [DP + USB-A -> USB-C kabeli](https://www.amazon.com/dp/B0BNX7MS6N) dan foydalanishingizga toʻgʻri keladi.
