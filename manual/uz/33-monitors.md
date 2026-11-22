# Monitorlar

Omarchy sukut bo'yicha 2x imkoniyatiga ega retina darajasidagi displeyda ishlayapsiz deb hisoblaydi. Bu sizga o'sha yoqimli, tiniq dasturchi shriftlarini olish uchun kerak bo'lgan narsa. Deyarli barcha yangi yuqori aniqlikdagi ekranli premium noutbuklar aynan shunga optimallashtirilgan. 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) yoki 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) da ishlatishni xohlagan bo'lardingiz.

Ammo agar siz PPI ko'rsatkichi 218 yoki undan yuqori bo'lgan displeyda ishlamayotgan bo'lsangiz, monitor sozlamalarini o'zgartirishni xohlaysiz. Masalan, agar sizda 27" yoki 32" 4K bo'lsa, yuqori paneldagi monitor panelidan unga kasrli masshtab tanlashingiz yoki `~/.config/hypr/monitors.lua` ni ochib, o'sha kombinatsiya uchun tavsiyaga o'tish orqali har bir monitor uchun sukut bo'yicha qiymatni o'rnatishingiz mumkin:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Agar 1080p yoki 1440p displeydan foydalanayotgan bo'lsangiz, ehtimol shunchaki 1x masshtabdan foydalanishni xohlaysiz, GTK va X11 ilovalari uchun ham xuddi shunday, shuning uchun quyidagidan foydalanishingiz mumkin:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` ga kiritilgan o'zgarishlar o'zgarishdan keyin ishga tushirilgan ilovalarga qo'llaniladi (va GTK faqat butun sonlarni qabul qiladi, shuning uchun uni monitor masshtabingizga eng yaqin butun sonda saqlang). Shuning uchun o'zgarishdan keyin o'lchami kattalashib qolgan oynalaringizni yopganingizga ishonch hosil qiling (yoki `Ctrl + Alt + Del` bilan barcha oynalarni yoping!).

Shuningdek, `Super + /` yordamida yuqoriga va `Super + Alt + /` yordamida pastga o'tib asosiy monitor masshtablash nisbatlari (1x, 1.25x, 1.6x, 2x, 3x, 4x) bo'ylab tez o'tishingiz yoki yuqori paneldagi monitor panelidan birini tanlashingiz mumkin. Bular faqat siz fokusda bo'lgan monitorni o'zgartiradi, shuning uchun noutbuk ekrani va tashqi displey har birining o'z masshtabi bo'lishi mumkin. Panel shuningdek har bir monitorning ruxsatini, yangilanish tezligini va burilishini o'rnatadi. Sizning tanlovlaringiz o'sha jismoniy monitor uchun `~/.local/state/omarchy/monitors/settings` da saqlanadi, shuning uchun ular qayta yuklashdan keyin ham saqlanadi va monitor keyingi safar qaysi port yoki dokka ulangan bo'lsa ham unga ergashadi. Ular `~/.config/hypr/monitors.lua` dagi xuddi shu monitor uchun har qanday qoidadan ustun turadi, Omarchy bu faylni hech qachon tahrirlamaydi. Agar monitorlaringizni butunlay o'sha faylda o'rnatishni afzal ko'rsangiz, unga `omarchy_monitor_panel_settings = false` ni qo'shing, va panelning o'zgarishlari faqat Hyprland qayta yuklangunicha davom etadi. `GDK_SCALE` barcha ekranlar uchun bitta qiymat bo'lganligi sababli, tanlangan masshtab uni eng past masshtabli monitordan o'rnatadi, shuning uchun X11 ilovalari boshqa ekranda o'lchami kattalashib ketgandan ko'ra zichroq ekranda biroz kichikroq chiqadi.

### Matnni kattalashtirish yoki kichiklashtirish

Monitor masshtabi hamma narsaning o'lchamini o'zgartiradi. Agar siz xohlagan narsa faqat kattaroq yoki kichikroq _matn_ bo'lsa, buning uchun bitta tugma mavjud:

```
omarchy display text size 14
```

U 9 dan 20 gacha bo'lgan piksel o'lchamini qabul qiladi va Omarchy qobig'ini, GTK ilovalarini va terminalingizni birgalikda harakatlantiradi, shuning uchun butun ish stoli mutanosib bo'lib qoladi. Qayerda ekanligingizni ko'rish uchun uni argumentsiz ishga tushiring va sukut bo'yicha qiymatga qaytish uchun `omarchy display text size reset` ni ishga tushiring. Foot yagona orqada qoluvchi: uning konfiguratsiyasini qayta yuklashning imkoni yo'q, shuning uchun ishlayotgan terminallar yangi terminal ochmaguningizcha eski o'lchamini saqlaydi.

### Noutbuk displeylarini kengaytirish va aks ettirish

Tashqi ekranni noutbukingizga ulaganingizda, displey avtomatik ravishda kengaytiriladi. Ammo yuqori paneldagi monitor panelidagi _Extend_ | _Mirror_, Omarchy menyusidagi _Trigger > Hardware_ yoki `Super + Ctrl + Alt + Delete` yordamida uni o'rniga aks ettirishga o'zgartirishingiz mumkin. Bu ayniqsa o'sha tashqi ekran proyektor bo'lsa va siz ishlayotganingizda biror narsani ko'rsatmoqchi bo'lsangiz foydali.

Kengaytirayotganingizda, noutbuk qopqog'ini yopish ichki ekranni avtomatik ravishda o'chiradi. Qopqoqni ochish uni qayta yoqadi. Buni Omarchy menyusidagi _Trigger > Hardware_ yoki `Super + Ctrl + Delete` yordamida qo'lda ham boshqarishingiz mumkin.

### Bir nechta ekranlarni joylashtirish

Hyprland bir nechta ekranlar bilan ajoyib ishlaydi. Yuqori paneldagi monitor paneli ularni turgan joyida chizadi: birini boshqasining yoniga sudrab u yerga ko'chiring, va joylashuv har bir monitorning boshqa sozlamalari bilan saqlanadi. Panel qamrab olmaydigan har qanday narsa uchun ularni qanday joylashtirish haqida [Hyprland monitor hujjatlarida](https://wiki.hypr.land/Configuring/Basics/Monitors/) ko'proq o'qing. Omarchy da bular `~/.config/hypr/monitors.lua` ga `hl.monitor` yozuvlari sifatida kiradi — fayl monitorni o'chiq holda saqlash, panel taklif qilmaydigan rejimlar, 10-bit rang va o'zgaruvchan yangilanish tezligi uchun izohlangan misollar bilan birga keladi.

Har bir monitorning o'zining 1 dan 10 gacha ish maydonlari bor, shuning uchun `Super + 1` har doim siz turgan monitorning birinchi ish maydonini anglatadi. Orqa fonda Hyprland ish maydonlarini hali ham barcha monitorlar bo'ylab raqamlaydi: noutbuk ekraningiz (yoki birinchi monitor) 1–10 ni, keyingi monitor 11–20 ni va hokazoni oladi, va har bir monitor har safar ulaganingizda o'z blokini saqlaydi. Agar ma'lum bir monitor uchun [ish maydoni qoidalarini](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) yoki oyna qoidalarini yozsangiz o'sha raqamlardan foydalaning, shuning uchun 12-ish maydoni ikkinchi monitoringizning ikkinchi ish maydonidir. `~/.local/state/omarchy/monitors/workspaces` qaysi monitor qaysi blokka ega ekanligini sanab o'tadi.

Strelka tugmalari joylashuvingizda umumiy qirraga ega monitorlar bo'ylab ishlaydi. Faqat burchakda tegadigan yoki orasida bo'shliq bo'lgan ekranlar qo'shni emas, shuning uchun ular orasida o'tish uchun `Ctrl + Alt + Tab` dan foydalaning.

| Tezkor tugma | Monitorlar orasida |
| --- | --- |
| `Super + Arrow` | O'sha yo'nalishda oyna qolmaganidan keyin o'sha tomondagi monitorga fokusni ko'chiradi |
| `Super + Shift + Arrow` | O'sha tomondagi monitordagi oyna bilan almashadi |
| `Super + Alt + Arrow` | Oynani o'sha tomondagi monitordagi guruhga ko'chiradi |
| `Super + Shift + Ctrl + Arrow` | Oynani o'sha tomondagi monitorga, u ko'rsatayotgan ish maydoniga ko'chiradi |
| `Super + Shift + Alt + Arrow` | Ish maydonini o'sha tomondagi monitorga ko'chiradi, agar bo'sh bo'lsa uning raqamini saqlaydi |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Joylashuv qanday bo'lishidan qat'i nazar, fokusni keyingi yoki oldingi monitorga ko'chiradi |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Siz turgan monitorda qoladi |

Agar bir nechta ekranlarning joylashuvida sizga yordam beradigan TUI ni xohlasangiz, [Hyprmon](https://github.com/erans/hyprmon/) ni ham ko'rib chiqishingiz mumkin.

### Yorqinlikni boshqarish

Monitor yorqinligi yorqinlikni oshirish/pasaytirish uchun maxsus funksiya tugmalari bilan boshqariladi. Agar ushbu tugmalarni bosayotganda shift ni bosib tursangiz, maksimal yoki minimal yorqinlikka o'tasiz. Tugmalar siz fokusda bo'lgan displeyni boshqaradi, shuning uchun DDC/CI orqali gaplashadigan tashqi monitorlar noutbuk ekrani bilan bir xil tarzda sozlanadi.

### Apple displeylari

Agar Apple displeyidan foydalanayotgan bo'lsangiz, agar Apple displeyida fokusda bo'lsangiz, odatdagi klaviatura yorqinlik tugmalari ham avtomatik ravishda ishlaydi. Bu `asdcontrol` buyrug'i orqali amalga oshiriladi.

E'tibor bering, agar Apple 6K XDR displeyidan foydalanayotgan bo'lsangiz, `hyprctl monitors` ro'yxatingizda xayoliy ekranni ko'rishingiz mumkin. Buni `~/.config/hypr/monitors.lua` da `hl.monitor({ output = "DP-2", disabled = true })` kabi narsa bilan o'chirishingiz mumkin.

Intel mashinalarida Apple displeylariga odatdagi Thunderbolt kabeli yordamida ulanishingiz kerak. Thunderbolt bo'lmagan boshqa mashinalarda uni ishlashi uchun odatda [DP + USB-A -> USB-C kabelidan](https://www.amazon.com/dp/B0BNX7MS6N) foydalanishingiz kerak bo'ladi.
