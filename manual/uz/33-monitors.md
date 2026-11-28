# Monitorlar

Omarchy sukut bo‘yicha siz 2x imkoniyatiga ega retina sinfidagi displeyda ishlayapsiz deb hisoblaydi. O‘sha yoqimli, tiniq dasturchi shriftlarini olish uchun aynan shu kerak. Deyarli barcha yangi, yuqori aniqlikdagi ekranli premium noutbuklar aynan shunga optimallashtirilgan. Buni 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) yoki 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) da ishlatishni xohlaysiz.

Ammo agar siz PPI ko‘rsatkichi 218 yoki undan yuqori bo‘lgan displeydan foydalanmayotgan bo‘lsangiz, monitor sozlamalarini o‘zgartirishni xohlaysiz. Masalan, sizda 27" yoki 32" 4K bo‘lsa, yuqori paneldagi monitor panelidan unga kasrli masshtab tanlashingiz yoki `~/.config/hypr/monitors.lua` ni ochib, o‘sha kombinatsiya uchun tavsiyaga o‘tish orqali har bir monitor uchun sukut bo‘yicha qiymatni belgilashingiz mumkin:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Agar siz 1080p yoki 1440p displeydan foydalanayotgan bo‘lsangiz, ehtimol shunchaki 1x masshtabdan foydalanishni xohlaysiz, GTK va X11 ilovalari uchun ham xuddi shunday, shuning uchun quyidagidan foydalanishingiz mumkin:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` ga kiritilgan o‘zgarishlar o‘zgarishdan keyin ishga tushirilgan ilovalarga ta’sir qiladi (va GTK faqat butun sonlarni qabul qiladi, shuning uchun uni monitor masshtabingizga eng yaqin butun sonda saqlang). Shuning uchun o‘zgarishdan keyin juda katta bo‘lib qolgan oynalaringizni yopganingizga ishonch hosil qiling (yoki barcha oynalarni `Ctrl + Alt + Del` bilan yoping!).

Shuningdek, asosiy monitor masshtab nisbatlari (1x, 1.25x, 1.6x, 2x, 3x, 4x) orasida `Super + /` yordamida yuqoriga va `Super + Alt + /` yordamida pastga tez o‘tishingiz yoki yuqori paneldagi monitor panelidan birini tanlashingiz mumkin. Bular faqat siz fokusda turgan monitorni o‘zgartiradi, shuning uchun noutbuk ekrani va tashqi displey har biri o‘z masshtabiga ega bo‘lishi mumkin. Panel shuningdek har bir monitorning ruxsatini, yangilanish tezligini va aylanishini ham belgilaydi. Sizning tanlovlaringiz o‘sha jismoniy monitor uchun `~/.local/state/omarchy/monitors/settings` da saqlanadi, shuning uchun ular qayta yuklashdan keyin ham saqlanib qoladi va monitor keyingi safar qaysi port yoki dokka ulangan bo‘lsa, unga ergashadi. Ular `~/.config/hypr/monitors.lua` dagi ayni monitor uchun har qanday qoidadan ustun turadi, Omarchy esa uni hech qachon tahrirlamaydi. Agar monitorlaringizni to‘liq o‘sha faylda belgilashni afzal ko‘rsangiz, unga `omarchy_monitor_panel_settings = false` ni qo‘shing, shunda panelning o‘zgarishlari faqat Hyprland qayta yuklangunigacha amal qiladi. `GDK_SCALE` barcha ekranlar uchun bitta qiymat bo‘lgani sababli, tanlangan masshtab uni eng past masshtabli monitordan belgilaydi, shuning uchun X11 ilovalari boshqa ekranda juda katta bo‘lib ketgandan ko‘ra, zichroq ekranda biroz kichikroq chiqadi.

### Matnni kattalashtirish yoki kichiklashtirish

Monitor masshtabi hamma narsaning o‘lchamini o‘zgartiradi. Agar siz xohlagan narsa faqat kattaroq yoki kichikroq _matn_ bo‘lsa, buning uchun bitta sozlash tugmasi bor:

```
omarchy display text size 14
```

Bu 9 dan 20 gacha bo‘lgan piksel o‘lchamini qabul qiladi va Omarchy qobig‘ini, GTK ilovalarini va terminalingizni birgalikda harakatlantiradi, shuning uchun butun ish stoli mutanosib bo‘lib qoladi. Qayerda turganingizni ko‘rish uchun uni argumentsiz ishga tushiring, sukut bo‘yicha qiymatga qaytish uchun esa `omarchy display text size reset` ni ishga tushiring. Foot yagona orqada qoluvchi: uning konfiguratsiyani qayta yuklash usuli yo‘q, shuning uchun ishlayotgan terminallar yangi terminal ochmaguningizcha eski o‘lchamini saqlab qoladi.

### Noutbuk displeylarini kengaytirish va aks ettirish

Tashqi ekranni noutbukingizga ulaganingizda, displey avtomatik ravishda kengaytiriladi. Ammo buni yuqori paneldagi monitor panelidagi _Extend_ | _Mirror_, Omarchy menyusidagi _Trigger > Hardware_ yoki `Super + Ctrl + Alt + Delete` yordamida o‘rniga aks ettirishga o‘zgartirishingiz mumkin. Bu ayniqsa o‘sha tashqi ekran proyektor bo‘lsa va ishlayotganingizda biror narsani ko‘rsatmoqchi bo‘lsangiz foydali.

Kengaytirayotganingizda, noutbuk qopqog‘ini yopish ichki ekranni avtomatik ravishda o‘chiradi. Qopqoqni ochish uni qayta yoqadi. Buni Omarchy menyusidagi _Trigger > Hardware_ yoki `Super + Ctrl + Delete` yordamida qo‘lda ham boshqarishingiz mumkin.

Noutbuk elektr tarmog‘iga ulangan paytda, qopqoqni yopish uni hech qachon uyquga yubormaydi, shuning uchun dokka ulangan noutbuk tashqi ekran qisqa vaqt uzilib qolsa ham uyg‘oq qoladi. Hech qanday tashqi ekran ulanmagan bo‘lsa, elektr tarmog‘ida qopqoqni yopish uni shunchaki qulflaydi. Batareyada qopqoqni yopish odatdagidek to‘xtatib turadi.

### Bir nechta ekranni joylashtirish

Hyprland bir nechta ekran bilan ajoyib ishlaydi. Yuqori paneldagi monitor paneli ularni turgan joyida chizadi: birini boshqasining yoniga sudrab olib boring va uni o‘sha yerga ko‘chiring, joylashuv esa har bir monitorning boshqa sozlamalari bilan birga saqlanadi. Panel qamrab olmaydigan har qanday narsa uchun ularni qanday joylashtirish haqida [Hyprland monitor hujjatlarida](https://wiki.hypr.land/Configuring/Basics/Monitors/) ko‘proq o‘qing. Omarchy da bular `~/.config/hypr/monitors.lua` ga `hl.monitor` yozuvlari sifatida kiradi — fayl monitorni o‘chiq saqlash, panel taklif qilmaydigan rejimlar, 10-bit rang va o‘zgaruvchan yangilanish tezligi uchun izohlangan misollar bilan birga keladi.

Har bir monitorning o‘zining 1 dan 10 gacha ish joylari bor, shuning uchun `Super + 1` har doim siz turgan monitorning birinchi ish joyini bildiradi. Sahna ortida Hyprland ish joylarini baribir barcha monitorlar bo‘ylab raqamlaydi: noutbuk ekraningiz (yoki birinchi monitoringiz) 1–10 ni oladi, keyingi monitor 11–20 ni oladi va hokazo, har bir monitor esa uni har safar ulaganingizda o‘z blokini saqlab qoladi. Agar ma’lum bir monitor uchun [ish joyi qoidalari](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) yoki oyna qoidalarini yozsangiz, o‘sha raqamlardan foydalaning, shunda 12-ish joyi ikkinchi monitoringizning ikkinchi ish joyi bo‘ladi. `~/.local/state/omarchy/monitors/workspaces` har bir monitor qaysi blokka egaligini ro‘yxatga oladi.

Strelka tugmalari joylashuvingizda umumiy qirrani bo‘lishadigan monitorlar orasida ishlaydi. Faqat burchakda tegib turadigan yoki orasida bo‘shliq bo‘lgan ekranlar qo‘shni emas, shuning uchun ular orasiga o‘tish uchun `Ctrl + Alt + Tab` dan foydalaning.

| Tugmalar birikmasi | Monitorlar orasida |
| --- | --- |
| `Super + Arrow` | O‘sha yo‘nalishda oyna qolmagach, fokusni o‘sha tomondagi monitor­ga ko‘chiradi |
| `Super + Shift + Arrow` | O‘sha tomondagi monitordagi oyna bilan almashadi |
| `Super + Alt + Arrow` | Oynani o‘sha tomondagi monitordagi guruhga ko‘chiradi |
| `Super + Shift + Ctrl + Arrow` | Oynani o‘sha tomondagi monitorga, u ko‘rsatayotgan ish joyiga ko‘chiradi |
| `Super + Shift + Alt + Arrow` | Ish joyini o‘sha tomondagi monitorga ko‘chiradi, agar bo‘sh bo‘lsa raqamini saqlab qoladi |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Joylashuv qanday bo‘lishidan qat’i nazar, fokusni keyingi yoki oldingi monitorga ko‘chiradi |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Siz turgan monitorda qoladi |

Agar sizga bir nechta ekranlarni joylashtirishda yordam beradigan TUI kerak bo‘lsa, [Hyprmon](https://github.com/erans/hyprmon/) ni ham ko‘rib chiqishingiz mumkin.

### Yorqinlikni boshqarish

Monitor yorqinligi yorqinlikni oshirish/pasaytirish uchun ajratilgan funksiya tugmalari bilan boshqariladi. Agar bularni bosayotganda shift ni bosib tursangiz, maksimal yoki minimal yorqinlikka o‘tasiz. Tugmalar siz fokusda turgan displeyni boshqaradi, shuning uchun DDC/CI orqali gaplashadigan tashqi monitorlar noutbuk ekrani bilan bir xil tarzda sozlanadi.

### Apple Displays

Agar siz Apple displeyidan foydalanayotgan bo‘lsangiz, oddiy klaviatura yorqinlik tugmalari ham avtomatik ravishda ishlaydi, agar siz Apple displeyida fokusda bo‘lsangiz. Bu `asdcontrol` buyrug‘i orqali amalga oshiriladi.

E’tibor bering, agar siz Apple 6K XDR displeyidan foydalanayotgan bo‘lsangiz, `hyprctl monitors` ro‘yxatingizda xayoliy ekranni ko‘rishingiz mumkin. Buni `~/.config/hypr/monitors.lua` dagi `hl.monitor({ output = "DP-2", disabled = true })` kabi biror narsa bilan o‘chirishingiz mumkin.

Intel mashinalarida Apple displeylariga oddiy Thunderbolt kabeli yordamida ulanishingiz kerak. Thunderbolt bo‘lmagan boshqa mashinalarda buni ishlashi uchun odatda [DP + USB-A -> USB-C kabelidan](https://www.amazon.com/dp/B0BNX7MS6N) foydalanishingizga to‘g‘ri keladi.
