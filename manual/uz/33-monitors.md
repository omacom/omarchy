# Monitorlar

Omarchy sukut bo'yicha sizda 2x imkoniyatiga ega retina darajasidagi displey ishlatilmoqda deb hisoblaydi. O'sha yoqimli, tiniq dasturchi shriftlarini olish uchun sizga aynan shu kerak. Bu deyarli barcha yangi yuqori aniqlikdagi ekranli premium noutbuklar optimallashtirilgan narsadir. Siz buni 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) yoki 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) da ishlatishni xohlaysiz.

Ammo agar siz PPI 218 yoki undan yuqori bo'lgan displeydan foydalanmayotgan bo'lsangiz, monitor sozlamalarini o'zgartirishni xohlaysiz. Masalan, agar sizda 27" yoki 32" 4K bo'lsa, `~/.config/hypr/monitors.lua` faylini ochib (Omarchy menyusidagi _Setup > Monitors_ orqali) va shu kombinatsiya uchun tavsiyaga o'tib, kasrli masshtablashdan foydalanishingiz mumkin:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Agar siz 1080p yoki 1440p displeydan foydalanayotgan bo'lsangiz, ehtimol shunchaki 1x masshtablashdan foydalanishni xohlaysiz, shuning uchun quyidagidan foydalanishingiz mumkin:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` ga kiritilgan o'zgarishlar o'zgarishdan keyin ishga tushirilgan ilovalarga qo'llaniladi (va GTK faqat butun sonlarni qabul qiladi, shuning uchun uni monitor masshtabingizga eng yaqin butun son sifatida saqlang). Shuning uchun o'zgarishdan keyin o'lchami kattalashib qolgan oynalaringizni yopganingizga ishonch hosil qiling (yoki barcha oynalarni `Ctrl + Alt + Del` bilan yoping!).

Siz shuningdek `Super + /` yordamida yuqoriga va `Super + Alt + /` yordamida pastga o'tib, asosiy monitor masshtablash nisbatlarini (1x, 1.25x, 1.6x, 2x, 3x, 4x) tezda ketma-ket almashtirishingiz yoki yuqori paneldagi monitor panelidan birini tanlashingiz mumkin. Bular faqat siz fokuslagan monitorni o'zgartiradi, shuning uchun noutbuk ekrani va tashqi displeyning har biri o'z masshtabiga ega bo'lishi mumkin. Tanlov `~/.config/hypr/monitors.lua` fayliga o'sha monitor uchun `hl.monitor` qoidasi sifatida saqlanadi, shuning uchun u qayta yuklashdan keyin ham saqlanib qoladi va o'z qoidasiga ega bo'lmagan har bir monitor uchun masshtab bo'lib qoladigan `omarchy_monitor_scale` dan ustun turadi.

### Matnni kattalashtirish yoki kichiklashtirish

Monitor masshtablash hamma narsaning o'lchamini o'zgartiradi. Agar siz xohlagan narsa faqat kattaroq yoki kichikroq _matn_ bo'lsa, buning uchun bitta sozlama mavjud:

```
omarchy display text size 14
```

U 9 dan 20 gacha bo'lgan piksel o'lchamini qabul qiladi va Omarchy qobig'i, GTK ilovalari va terminalingizni birgalikda siljitadi, shuning uchun butun ish stoli mutanosib bo'lib qoladi. Qayerda ekaningizni ko'rish uchun uni argumentsiz ishga tushiring va sukut bo'yicha holatga qaytish uchun `omarchy display text size reset` buyrug'ini bajaring. Foot yagona orqada qoluvchi: uning konfiguratsiyasini qayta yuklashning imkoni yo'q, shuning uchun ishlayotgan terminallar yangi terminal ochmaguningizcha eski o'lchamni saqlab qoladi.

### Noutbuk displeylarini kengaytirish va aks ettirish

Tashqi ekranni noutbukingizga ulaganingizda, displey avtomatik ravishda kengaytiriladi. Ammo buning o'rniga Omarchy menyusidagi _Trigger > Hardware_ yoki `Super + Ctrl + Alt + Delete` yordamida uni aks ettirishga o'zgartirishingiz mumkin. Bu ayniqsa o'sha tashqi ekran proyektor bo'lsa va siz ishlayotgan vaqtda nimanidir ko'rsatmoqchi bo'lsangiz foydali.

Kengaytirishdan foydalanayotganingizda, noutbuk qopqog'ini yopish ichki ekranni avtomatik ravishda o'chiradi. Qopqoqni ochish uni yana yoqadi. Buni Omarchy menyusidagi _Trigger > Hardware_ yoki `Super + Ctrl + Delete` yordamida qo'lda ham boshqarishingiz mumkin.

### Bir nechta ekranlarni joylashtirish

Hyprland bir nechta ekranlar bilan ajoyib ishlaydi. Ularni qanday joylashtirish haqida ko'proq [Hyprland monitor hujjatlarida](https://wiki.hypr.land/Configuring/Basics/Monitors/) o'qing. Omarchy da bular `~/.config/hypr/monitors.lua` faylida `hl.monitor` yozuvlari sifatida joylashadi — fayl muayyan monitorni aniqlik, joylashuv va burilishga biriktirish uchun izohlangan misollar bilan birga keladi.

Har bir monitorning o'zining 1 dan 10 gacha ish maydonlari mavjud, shuning uchun `Super + 1` har doim siz turgan monitorning birinchi ish maydonini anglatadi. Sahna ortida Hyprland hali ham ish maydonlarini barcha monitorlar bo'ylab raqamlaydi: noutbukingiz ekrani (yoki birinchi monitor) 1–10 ni, keyingi monitor 11–20 ni oladi va hokazo, va har bir monitor har safar ulaganingizda o'z blokini saqlab qoladi. Agar muayyan monitor uchun [ish maydoni qoidalarini](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) yoki oyna qoidalarini yozsangiz, o'sha raqamlardan foydalaning, shuning uchun 12-ish maydoni ikkinchi monitoringizning ikkinchi ish maydoni hisoblanadi. `~/.local/state/omarchy/monitor-workspaces` har bir monitorda qaysi blok borligini ro'yxatlaydi.

Strelka tugmalari joylashuvingizda umumiy chetga ega monitorlar o'rtasida ishlaydi. Faqat burchakda tegadigan yoki orasida bo'shliq bo'lgan ekranlar qo'shni emas, shuning uchun ular orasida harakatlanish uchun `Ctrl + Alt + Tab` dan foydalaning.

| Hotkey | Monitorlar orasida |
| --- | --- |
| `Super + Arrow` | O'sha yo'nalishda oyna qolmagach, fokusni o'sha tomondagi monitorga o'tkazadi |
| `Super + Shift + Arrow` | O'sha tomondagi monitordagi oyna bilan almashadi |
| `Super + Alt + Arrow` | Oynani o'sha tomondagi monitordagi guruhga ko'chiradi |
| `Super + Shift + Ctrl + Arrow` | Oynani o'sha tomondagi monitorga, u ko'rsatayotgan ish maydoniga ko'chiradi |
| `Super + Shift + Alt + Arrow` | Ish maydonini o'sha tomondagi monitorga ko'chiradi, agar bo'sh bo'lsa uning raqamini saqlab qoladi |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Joylashuv qanday bo'lishidan qat'i nazar, fokusni keyingi yoki oldingi monitorga o'tkazadi |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Siz turgan monitorda qoladi |

Agar bir nechta ekranlarni joylashtirishda sizga yordam beradigan TUI ni xohlasangiz, [Hyprmon](https://github.com/erans/hyprmon/) ga ham qarab ko'rishingiz mumkin.

### Yorqinlikni boshqarish

Monitor yorqinligi yorqinlikni oshirish/pasaytirish uchun maxsus funksiya tugmalari bilan boshqariladi. Agar ularni bosayotganda shift ni bosib tursangiz, maksimal yoki minimal yorqinlikka o'tasiz. Tugmalar siz fokuslagan displeyni boshqaradi, shuning uchun DDC/CI ni qo'llab-quvvatlaydigan tashqi monitorlar noutbuk ekrani bilan bir xil tarzda sozlanadi.

### Apple displeylari

Agar siz Apple displeyidan foydalanayotgan bo'lsangiz, agar siz Apple displeyiga fokuslagan bo'lsangiz, odatiy klaviatura yorqinlik tugmalari ham avtomatik ravishda ishlaydi. Bu `asdcontrol` buyrug'i orqali amalga oshiriladi.

E'tibor bering, agar siz Apple 6K XDR displeyidan foydalanayotgan bo'lsangiz, `hyprctl monitors` ro'yxatida xayoliy ekranni ko'rishingiz mumkin. Buni _Setup > Monitors_ orqali `hl.monitor({ output = "DP-2", disabled = true })` kabi narsa bilan o'chirishingiz mumkin.

Intel kompyuterlarida siz Apple displeylariga oddiy Thunderbolt kabeli yordamida ulanishingiz kerak. Thunderbolt bo'lmagan boshqa kompyuterlarda, uni ishlatish uchun odatda [DP + USB-A -> USB-C kabelidan](https://www.amazon.com/dp/B0BNX7MS6N) foydalanishingizga to'g'ri keladi.
