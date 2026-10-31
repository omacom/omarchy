# Monitorlar

Omarchy sukut bo'yicha siz 2x imkoniyatiga ega retina sinfidagi displeydan foydalanayapsiz deb hisoblaydi. Ana shunda o'sha yoqimli, tiniq dasturchi shriftlariga ega bo'lasiz. Deyarli barcha yangi premium noutbuklar yuqori aniqlikdagi ekranlari bilan shunga optimallashtirilgan. 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) yoki 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) da ham aynan shunda ishlashni xohlaysiz.

Ammo agar siz PPI ko'rsatkichi 218 yoki undan yuqori bo'lgan displeydan foydalanmayotgan bo'lsangiz, monitor sozlamalarini o'zgartirishni xohlaysiz. Masalan, agar sizda 27" yoki 32" 4K bo'lsa, yuqori paneldagi monitor panelidan unga kasrli masshtab tanlashingiz yoki `~/.config/hypr/monitors.lua` ni ochib, o'sha kombinatsiya uchun tavsiyaga o'tish orqali har bir monitor uchun sukut bo'yicha qiymatni belgilashingiz mumkin:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Agar 1080p yoki 1440p displeydan foydalanayotgan bo'lsangiz, ehtimol shunchaki 1x masshtabdan foydalanishni xohlaysiz, GTK va X11 ilovalari uchun ham xuddi shunday, shuning uchun quyidagidan foydalanishingiz mumkin:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` ga kiritilgan o'zgarishlar o'zgarishdan keyin ishga tushirilgan ilovalarga taalluqli bo'ladi (va GTK faqat butun sonlarni qabul qiladi, shuning uchun uni monitor masshtabingizga eng yaqin butun sonda saqlang). Shuning uchun o'zgarishdan keyin o'lchami kattalashib qolgan oynalaringizni yopganingizga ishonch hosil qiling (yoki barcha oynalarni `Ctrl + Alt + Del` bilan yoping!).

Shuningdek, asosiy monitor masshtab nisbatlari (1x, 1.25x, 1.6x, 2x, 3x, 4x) orasida `Super + /` yordamida yuqoriga va `Super + Alt + /` yordamida pastga tez o'tishingiz yoki yuqori paneldagi monitor panelidan bittasini tanlashingiz mumkin. Bular faqat siz fokusda turgan monitorni o'zgartiradi, shuning uchun noutbuk ekrani va tashqi displey har biri o'z masshtabiga ega bo'lishi mumkin. Panel har bir monitorning ruxsatini ham belgilaydi. Tanlovlaringiz o'sha jismoniy monitor uchun `~/.local/state/omarchy/monitors/settings` da saqlanadi, shuning uchun ular qayta yuklashdan keyin ham saqlanib qoladi va monitor keyingi safar qaysi port yoki dokka ulanganidan qat'i nazar, uni kuzatib boradi. Ular Omarchy hech qachon tahrirlamaydigan `~/.config/hypr/monitors.lua` dagi ayni monitor uchun har qanday qoidadan ustun turadi. Agar monitorlaringizni butunlay o'sha faylda sozlashni afzal ko'rsangiz, unga `omarchy_monitor_panel_settings = false` ni qo'shing, shunda paneldagi o'zgarishlar faqat Hyprland qayta yuklangunicha amal qiladi. `GDK_SCALE` barcha ekranlar uchun bitta qiymat bo'lgani sababli, tanlangan masshtab uni eng past masshtabli monitordan belgilaydi, shuning uchun X11 ilovalari boshqa ekranda o'lchami kattalashib ketishi o'rniga zichroq ekranda biroz kichikroq chiqadi.

### Matnni kattalashtirish yoki kichraytirish

Monitor masshtabi hamma narsaning o'lchamini o'zgartiradi. Agar siz faqat kattaroq yoki kichikroq _matn_ ni xohlasangiz, buning uchun bitta sozlama bor:

```
omarchy display text size 14
```

Bu 9 dan 20 gacha bo'lgan piksel o'lchamini qabul qiladi va Omarchy qobig'i, GTK ilovalari hamda terminalingizni birgalikda siljitadi, shuning uchun butun ish stoli mutanosib bo'lib qoladi. Qayerda ekaningizni ko'rish uchun uni argumentsiz ishga tushiring va sukut bo'yicha qiymatga qaytish uchun `omarchy display text size reset` ni ishga tushiring. Foot yagona qolib ketuvchi: unda konfiguratsiyasini qayta yuklash usuli yo'q, shuning uchun ishlayotgan terminallar yangisini ochmaguningizcha eski o'lchamini saqlab qoladi.

### Noutbuk displeylarini kengaytirish va aks ettirish

Tashqi ekranni noutbukingizga ulaganingizda, displey avtomatik ravishda kengaytiriladi. Ammo Omarchy menyusidagi _Trigger > Hardware_ yoki `Super + Ctrl + Alt + Delete` yordamida buning o'rniga aks ettirishga o'zgartirishingiz mumkin. Bu, ayniqsa, o'sha tashqi ekran proyektor bo'lsa va siz ishlayotganingizda biror narsani ko'rsatmoqchi bo'lsangiz, yordam beradi.

Kengaytirib ishlayotganingizda, noutbuk qopqog'ini yopish ichki ekranni avtomatik ravishda o'chiradi. Qopqoqni ochish uni qayta yoqadi. Buni Omarchy menyusidagi _Trigger > Hardware_ yoki `Super + Ctrl + Delete` yordamida qo'lda ham boshqarishingiz mumkin.

### Bir nechta ekranni joylashtirish

Hyprland bir nechta ekran bilan ajoyib ishlaydi. Yuqori paneldagi monitor paneli ularni turgan joyida chizadi: bittasini boshqasining yoniga sudrab olib boring, shunda u o'sha yerga ko'chadi va joylashuv har bir monitorning boshqa sozlamalari bilan birga saqlanadi. Panel qamrab olmaydigan narsalar uchun ularni qanday joylashtirish haqida [Hyprland monitor hujjatlarida](https://wiki.hypr.land/Configuring/Basics/Monitors/) ko'proq o'qing. Omarchy da bular `~/.config/hypr/monitors.lua` ga `hl.monitor` yozuvlari sifatida kiradi — fayl muayyan monitorni ruxsat, joylashuv va burilishga biriktirish uchun sharhlangan misollar bilan yetkaziladi.

Har bir monitorda o'zining 1 dan 10 gacha bo'lgan ish maydonlari bor, shuning uchun `Super + 1` har doim siz turgan monitorning birinchi ish maydonini bildiradi. Orqa planda Hyprland hali ham ish maydonlarini barcha monitorlar bo'ylab raqamlaydi: noutbukingiz ekrani (yoki birinchi monitor) 1–10 ni, keyingi monitor 11–20 ni va hokazoni oladi, va har bir monitor har safar ulaganingizda o'z blokini saqlab qoladi. Agar muayyan monitor uchun [ish maydoni qoidalarini](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) yoki oyna qoidalarini yozsangiz, o'sha raqamlardan foydalaning, shuning uchun 12-ish maydoni ikkinchi monitoringizning ikkinchi ish maydoni bo'ladi. `~/.local/state/omarchy/monitors/workspaces` har bir monitorda qaysi blok borligini ro'yxatlaydi.

Strelka tugmalari joylashuvingizda umumiy chekkaga ega monitorlar o'rtasida ishlaydi. Faqat burchakda tegib turadigan yoki orasida bo'shliq bo'lgan ekranlar qo'shni emas, shuning uchun ular o'rtasida o'tish uchun `Ctrl + Alt + Tab` dan foydalaning.

| Tezkor tugma | Monitorlar o'rtasida |
| --- | --- |
| `Super + Arrow` | O'sha yo'nalishda oyna qolmagach, fokusni o'sha tomondagi monitorga ko'chiradi |
| `Super + Shift + Arrow` | O'sha tomondagi monitordagi oyna bilan almashadi |
| `Super + Alt + Arrow` | Oynani o'sha tomondagi monitordagi guruhga ko'chiradi |
| `Super + Shift + Ctrl + Arrow` | Oynani o'sha tomondagi monitorga, u ko'rsatayotgan ish maydoniga ko'chiradi |
| `Super + Shift + Alt + Arrow` | Ish maydonini o'sha tomondagi monitorga ko'chiradi, agar bo'sh bo'lsa, uning raqamini saqlab qoladi |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Joylashuvdan qat'i nazar, fokusni keyingi yoki oldingi monitorga ko'chiradi |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Siz turgan monitorda qoladi |

Agar bir nechta ekranning joylashuvida sizga yordam beradigan TUI ni xohlasangiz, [Hyprmon](https://github.com/erans/hyprmon/) ni ham ko'rib chiqishingiz mumkin.

### Yorqinlikni boshqarish

Monitor yorqinligi yorqinlikni oshirish/pasaytirish uchun ajratilgan funksiya tugmalari bilan boshqariladi. Agar bularni bosayotganda shift ni bosib tursangiz, maksimal yoki minimal yorqinlikka o'tasiz. Tugmalar siz fokusda turgan displeyni boshqaradi, shuning uchun DDC/CI orqali gaplashadigan tashqi monitorlar noutbuk ekrani bilan bir xil tarzda sozlanadi.

### Apple displeylari

Agar Apple displeyidan foydalanayotgan bo'lsangiz, Apple displeyiga fokusda turganingizda odatdagi klaviatura yorqinlik tugmalari ham avtomatik ravishda ishlaydi. Bu `asdcontrol` buyrug'i orqali amalga oshiriladi.

E'tibor bering, agar Apple 6K XDR displeyidan foydalanayotgan bo'lsangiz, `hyprctl monitors` ro'yxatingizda xayoliy ekranni ko'rishingiz mumkin. Buni `~/.config/hypr/monitors.lua` da `hl.monitor({ output = "DP-2", disabled = true })` kabi narsa bilan o'chirishingiz mumkin.

Intel mashinalarida Apple displeylariga odatdagi Thunderbolt kabeli yordamida ulanishingiz kerak. Thunderbolt bo'lmagan boshqa mashinalarda buni ishlashi uchun odatda [DP + USB-A -> USB-C kabelidan](https://www.amazon.com/dp/B0BNX7MS6N) foydalanishingizga to'g'ri keladi.
