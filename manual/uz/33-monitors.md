# Monitorlar

Omarchy sukut bo'yicha siz 2x imkoniyatiga ega retina toifasidagi displeydan foydalanayapsiz deb hisoblaydi. O'sha yoqimli, tiniq dasturchi shriftlarini olish uchun aynan shu kerak. Deyarli barcha yangi premium noutbuklar yuqori aniqlikdagi ekranlari bilan aynan shu uchun optimallashtirilgan. 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) yoki 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) da ishlatishni xohlaysiz, aynan shuni.

Ammo agar siz PPI ko'rsatkichi 218 yoki undan yuqori bo'lgan displeydan foydalanmayotgan bo'lsangiz, monitor sozlamalarini o'zgartirishingiz kerak bo'ladi. Masalan, agar sizda 27" yoki 32" 4K bo'lsa, `~/.config/hypr/monitors.lua` ni ochib (Omarchy menyusida _Setup > Monitors_ orqali) va o'sha kombinatsiya uchun tavsiyaga o'tib, kasrli masshtablashdan foydalanishingiz mumkin:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Agar siz 1080p yoki 1440p displeydan foydalanayotgan bo'lsangiz, ehtimol shunchaki 1x masshtablashdan foydalanishni xohlaysiz, shuning uchun quyidagidan foydalanishingiz mumkin:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` ga kiritilgan o'zgarishlar o'zgarishdan keyin ishga tushirilgan ilovalarga qo'llaniladi (va GTK faqat butun sonlarni qabul qiladi, shuning uchun uni monitor masshtabingizga eng yaqin butun sonda saqlang). Shuning uchun o'zgarishdan keyin o'lchami kattalashib qolgan oynalaringizni yopganingizga ishonch hosil qiling (yoki barcha oynalarni `Ctrl + Alt + Del` bilan yoping!).

Shuningdek, yuqoriga o'tish uchun `Super + /` va pastga o'tish uchun `Super + Alt + /` dan foydalanib, yoki yuqori paneldagi monitor panelidan birini tanlab, asosiy monitor masshtablash nisbatlari (1x, 1.25x, 1.6x, 2x, 3x, 4x) bo'ylab tezda harakatlanishingiz mumkin. Bular faqat siz fokusda turgan monitorni o'zgartiradi, shuning uchun noutbuk ekrani va tashqi displeyning har biri o'z masshtabiga ega bo'lishi mumkin. Tanlov `~/.config/hypr/monitors.lua` ga o'sha monitor uchun `hl.monitor` qoidasi sifatida saqlanadi, shuning uchun u qayta yuklashdan keyin ham saqlanib qoladi va `omarchy_monitor_scale` dan ustun turadi, u esa o'z qoidasiga ega bo'lmagan har bir monitor uchun masshtab bo'lib qoladi. `GDK_SCALE` barcha ekranlar uchun bitta qiymat bo'lgani sababli, bu o'zgarishlar uni eng past masshtabli monitordan o'rnatadi, shuning uchun X11 ilovalari ikkinchisida kattalashib ketgandan ko'ra, zichroq ekranda biroz kichikroq chiqadi.

### Matnni kattalashtirish yoki kichiklashtirish

Monitor masshtablashi hamma narsaning o'lchamini o'zgartiradi. Agar siz xohlagan narsa faqat kattaroq yoki kichikroq _matn_ bo'lsa, buning uchun bitta tugma bor:

```
omarchy display text size 14
```

Bu 9 dan 20 gacha bo'lgan piksel o'lchamini oladi va Omarchy qobig'ini, GTK ilovalarini va terminalingizni birgalikda harakatlantiradi, shuning uchun butun ish stoli mutanosib bo'lib qoladi. Qayerda ekanligingizni ko'rish uchun uni argumentsiz ishga tushiring va sukut bo'yicha holatga qaytish uchun `omarchy display text size reset` ni ishga tushiring. Foot yagona ortda qoluvchi: uning konfiguratsiyasini qayta yuklashning imkoni yo'q, shuning uchun ishlayotgan terminallar siz yangisini ochmaguningizcha eski o'lchamlarini saqlab qoladi.

### Noutbuk displeylarini kengaytirish va aks ettirish

Tashqi ekranni noutbukingizga ulaganingizda, displey avtomatik ravishda kengaytiriladi. Ammo Omarchy menyusidagi _Trigger > Hardware_ yoki `Super + Ctrl + Alt + Delete` dan foydalanib, buning o'rniga uni aks ettirishga o'zgartirishingiz mumkin. Bu, ayniqsa, o'sha tashqi ekran proyektor bo'lsa va siz ishlayotganingizda biror narsani ko'rsatmoqchi bo'lsangiz, yordam beradi.

Kengaytirayotganingizda, noutbuk qopqog'ini yopish ichki ekranni avtomatik ravishda o'chiradi. Qopqoqni ochish uni qayta yoqadi. Buni Omarchy menyusidagi _Trigger > Hardware_ yoki `Super + Ctrl + Delete` dan foydalanib qo'lda ham boshqarishingiz mumkin.

### Bir nechta ekranlarni joylashtirish

Hyprland bir nechta ekranlar bilan ajoyib ishlaydi. Ularni qanday joylashtirish haqida ko'proq [Hyprland monitor hujjatlarida](https://wiki.hypr.land/Configuring/Basics/Monitors/) o'qing. Omarchy da bular `~/.config/hypr/monitors.lua` ga `hl.monitor` yozuvlari sifatida kiradi — fayl ma'lum bir monitorni aniqlik, joylashuv va burilishga biriktirish uchun izohlangan misollar bilan birga keladi.

Har bir monitorning o'zining 1 dan 10 gacha ish joylari bor, shuning uchun `Super + 1` har doim siz turgan monitorning birinchi ish joyini bildiradi. Orqa planda Hyprland baribir ish joylarini barcha monitorlar bo'ylab raqamlaydi: noutbuk ekraningiz (yoki birinchi monitoringiz) 1–10 ni, keyingi monitor 11–20 ni oladi va hokazo, va har bir monitor uni har safar ulaganingizda o'z blokini saqlab qoladi. Agar ma'lum bir monitor uchun [ish joyi qoidalarini](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) yoki oyna qoidalarini yozsangiz, o'sha raqamlardan foydalaning, shuning uchun 12-ish joyi ikkinchi monitoringizning ikkinchi ish joyi bo'ladi. `~/.local/state/omarchy/monitor-workspaces` har bir monitorda qaysi blok borligini ro'yxatlaydi.

Yo'nalish tugmalari joylashuvingizda umumiy chetga ega monitorlar o'rtasida ishlaydi. Faqat burchakda tegib turadigan yoki orasida bo'shliq bo'lgan ekranlar qo'shni emas, shuning uchun ular orasida harakatlanish uchun `Ctrl + Alt + Tab` dan foydalaning.

| Hotkey | Monitorlar o'rtasida |
| --- | --- |
| `Super + Arrow` | O'sha yo'nalishda oyna qolmagach, fokusni o'sha tomondagi monitorga o'tkazadi |
| `Super + Shift + Arrow` | O'sha tomondagi monitordagi oyna bilan almashtiradi |
| `Super + Alt + Arrow` | Oynani o'sha tomondagi monitordagi guruhga o'tkazadi |
| `Super + Shift + Ctrl + Arrow` | Oynani o'sha tomondagi monitorga, u ko'rsatayotgan ish joyiga o'tkazadi |
| `Super + Shift + Alt + Arrow` | Ish joyini o'sha tomondagi monitorga o'tkazadi, agar bo'sh bo'lsa uning raqamini saqlaydi |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Joylashuvdan qat'i nazar, fokusni keyingi yoki oldingi monitorga o'tkazadi |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Siz turgan monitorda qoladi |

Bir nechta ekranlarni joylashtirishda sizga yordam beradigan TUI ni xohlasangiz, [Hyprmon](https://github.com/erans/hyprmon/) ni ham ko'rib chiqishingiz mumkin.

### Yorqinlikni boshqarish

Monitor yorqinligi yorqinlikni oshirish/pasaytirish uchun mo'ljallangan maxsus funksiya tugmalari bilan boshqariladi. Agar ularni bosayotganda shift ni bosib tursangiz, maksimal yoki minimal yorqinlikka o'tasiz. Tugmalar siz fokusda turgan displeyni boshqaradi, shuning uchun DDC/CI orqali gaplashadigan tashqi monitorlar noutbuk ekrani bilan bir xil tarzda sozlanadi.

### Apple displeylari

Agar siz Apple displeyidan foydalanayotgan bo'lsangiz, agar siz Apple displeyida fokusda bo'lsangiz, oddiy klaviatura yorqinlik tugmalari ham avtomatik ravishda ishlaydi. Bu `asdcontrol` buyrug'i orqali amalga oshiriladi.

E'tibor bering, agar siz Apple 6K XDR displeyidan foydalanayotgan bo'lsangiz, `hyprctl monitors` ro'yxatingizda xayoliy ekranni ko'rishingiz mumkin. Buni _Setup > Monitors_ orqali `hl.monitor({ output = "DP-2", disabled = true })` kabi narsa bilan o'chirib qo'yishingiz mumkin.

Intel mashinalarida siz Apple displeylariga oddiy Thunderbolt kabeli yordamida ulanishingiz kerak. Thunderbolt bo'lmagan boshqa mashinalarda, odatda, uni ishlashi uchun [DP + USB-A -> USB-C kabelidan](https://www.amazon.com/dp/B0BNX7MS6N) foydalanishingizga to'g'ri keladi.
