# Monitorlar

Omarchy sukut bo'yicha 2x imkoniyatli retina sinfidagi displeyda ishlayapsiz deb hisoblaydi. Yaxshi, tiniq dasturchi shriftlari uchun sizga shu kerak. Deyarli barcha yuqori aniqlikdagi ekranli yangi premium noutbuklar aynan shunga optimallashtirilgan. 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) yoki 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) da ishlashni xohlaganingizda ham shu kerak bo'ladi.

Ammo PPI 218 yoki undan yuqori bo'lgan displeydan foydalanmayotgan bo'lsangiz, monitor sozlamalarini o'zgartirishni xohlaysiz. Masalan, agar 27" yoki 32" 4K ga ega bo'lsangiz, yuqori paneldagi monitor panelidan unga kasrli masshtab tanlashingiz yoki `~/.config/hypr/monitors.lua` ni ochib, har bir monitor uchun sukut bo'yicha qiymatni o'sha kombinatsiya uchun tavsiya etilgandek o'zgartirishingiz mumkin:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Agar 1080p yoki 1440p displeydan foydalanayotgan bo'lsangiz, ehtimol shunchaki 1x masshtabdan foydalanishni xohlaysiz, GTK va X11 ilovalari uchun ham xuddi shunday, shuning uchun quyidagidan foydalanishingiz mumkin:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` ga kiritilgan o'zgarishlar o'zgarishdan keyin ishga tushirilgan ilovalarga qo'llaniladi (va GTK faqat butun sonlarni qabul qiladi, shuning uchun uni monitor masshtabingizga eng yaqin butun sonda saqlang). Shuning uchun o'zgarishdan keyin o'lchami kattalashib qolgan oynalaringizni yopganingizga ishonch hosil qiling (yoki barcha oynalarni `Ctrl + Alt + Del` bilan yoping!).

Shuningdek, `Super + /` yordamida yuqori tomonga va `Super + Alt + /` yordamida past tomonga o'tib, asosiy monitor masshtab nisbatlarini (1x, 1.25x, 1.6x, 2x, 3x, 4x) tez aylanib chiqishingiz yoki yuqori paneldagi monitor panelidan bittasini tanlashingiz mumkin. Bular faqat fokusdagi monitorni o'zgartiradi, shuning uchun noutbuk ekrani va tashqi displey har biri o'z masshtabiga ega bo'lishi mumkin. Panel shuningdek har bir monitorning aniqligini ham o'rnatadi. Tanlovlaringiz o'sha jismoniy monitor uchun `~/.local/state/omarchy/monitors/settings` da saqlanadi, shuning uchun ular qayta yuklashdan keyin ham saqlanib qoladi va monitor keyingi safar qaysi port yoki dokka ulangan bo'lsa ham uni kuzatib boradi. Ular Omarchy hech qachon tahrirlamaydigan `~/.config/hypr/monitors.lua` dagi ayni monitor uchun har qanday qoidadan ustun turadi. `GDK_SCALE` barcha ekranlar uchun bitta qiymat bo'lgani sababli, tanlangan masshtab uni eng past masshtabli monitordan o'rnatadi, shuning uchun X11 ilovalari boshqa ekranda haddan tashqari katta chiqish o'rniga zichroq ekranda biroz kichikroq chiqadi.

### Matnni kattalashtirish yoki kichiklashtirish

Monitor masshtabi hamma narsaning hajmini o'zgartiradi. Agar siz faqat kattaroq yoki kichikroq _matn_ ni xohlasangiz, buning uchun bitta tugma mavjud:

```
omarchy display text size 14
```

U 9 dan 20 gacha bo'lgan piksel o'lchamini qabul qiladi va Omarchy qobig'i, GTK ilovalari va terminalingizni birgalikda siljitadi, shuning uchun butun ish stoli mutanosib bo'lib qoladi. Qayerda ekaningizni ko'rish uchun uni argumentsiz ishga tushiring va sukut bo'yicha qiymatga qaytish uchun `omarchy display text size reset` dan foydalaning. Foot yagona orqada qoluvchi: uning konfiguratsiyasini qayta yuklash imkoniyati yo'q, shuning uchun ishlayotgan terminallar yangi terminal ochmaguningizcha eski o'lchamni saqlab qoladi.

### Noutbuk displeylarini kengaytirish va aks ettirish

Tashqi ekranni noutbukingizga ulaganingizda, displey avtomatik ravishda kengaytiriladi. Ammo Omarchy menyusida _Trigger > Hardware_ dan foydalanib yoki `Super + Ctrl + Alt + Delete` yordamida buni o'rniga aks ettirish rejimiga o'zgartirishingiz mumkin. Bu ayniqsa tashqi ekran proyektor bo'lsa va ishlayotganingizda biror narsani ko'rsatmoqchi bo'lsangiz yordam beradi.

Kengaytirayotganingizda, noutbuk qopqog'ini yopish ichki ekranni avtomatik ravishda o'chiradi. Qopqoqni ochish uni qayta yoqadi. Buni Omarchy menyusida _Trigger > Hardware_ yordamida yoki `Super + Ctrl + Delete` yordamida qo'lda ham boshqarishingiz mumkin.

### Bir nechta ekranni tartibga solish

Hyprland bir nechta ekran bilan ajoyib ishlaydi. Yuqori paneldagi monitor paneli ularni joylashgan joyida chizadi: birini boshqasining yoniga sudrab olib boring, shunda u o'sha yerga ko'chadi va tartib har bir monitorning boshqa sozlamalari bilan birga saqlanadi. Panel qamrab olmaydigan har qanday narsa uchun, ularni qanday joylashtirish haqida [Hyprland monitor hujjatlari](https://wiki.hypr.land/Configuring/Basics/Monitors/) da batafsil o'qing. Omarchy da bular `~/.config/hypr/monitors.lua` ga `hl.monitor` yozuvlari sifatida kiritiladi — fayl muayyan monitorni aniqlik, joylashuv va burilish bo'yicha mahkamlash uchun izohlangan misollar bilan birga keladi.

Har bir monitor o'zining 1 dan 10 gacha ish maydonlariga ega, shuning uchun `Super + 1` har doim siz turgan monitorning birinchi ish maydonini anglatadi. Parda ortida Hyprland ish maydonlarini hali ham barcha monitorlar bo'ylab raqamlaydi: noutbuk ekraningiz (yoki birinchi monitor) 1–10 ni, keyingi monitor 11–20 ni va hokazoni oladi va har bir monitor har safar ulaganingizda o'z blokini saqlab qoladi. Agar muayyan monitor uchun [ish maydoni qoidalari](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) yoki oyna qoidalarini yozsangiz, o'sha raqamlardan foydalaning, shuning uchun 12-ish maydoni ikkinchi monitoringizning ikkinchi ish maydoni hisoblanadi. `~/.local/state/omarchy/monitors/workspaces` har bir monitor qaysi blokka ega ekanligini sanab o'tadi.

Strelka tugmalari joylashuvingizda umumiy chekkaga ega monitorlar o'rtasida ishlaydi. Faqat burchakda tegib turadigan yoki orasida bo'shliq bo'lgan ekranlar qo'shni emas, shuning uchun ular o'rtasida o'tish uchun `Ctrl + Alt + Tab` dan foydalaning.

| Klavishalar birikmasi | Monitorlar orasida |
| --- | --- |
| `Super + Arrow` | Shu tomonda u yo'nalishda boshqa oyna qolmaganda fokusni o'sha tomondagi monitorga ko'chiradi |
| `Super + Shift + Arrow` | O'sha tomondagi monitordagi oyna bilan o'rin almashadi |
| `Super + Alt + Arrow` | Oynani o'sha tomondagi monitordagi guruhga ko'chiradi |
| `Super + Shift + Ctrl + Arrow` | Oynani o'sha tomondagi monitorga, u ko'rsatayotgan ish maydoniga ko'chiradi |
| `Super + Shift + Alt + Arrow` | Ish maydonini o'sha tomondagi monitorga ko'chiradi, agar bo'sh bo'lsa raqamini saqlab qoladi |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Joylashuv qanday bo'lishidan qat'i nazar, fokusni keyingi yoki oldingi monitorga ko'chiradi |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Siz turgan monitorda qoladi |

Agar bir nechta ekranlarni joylashtirishda yordam beradigan TUI ni xohlasangiz, [Hyprmon](https://github.com/erans/hyprmon/) ni ham ko'rib chiqishingiz mumkin.

### Yorqinlikni boshqarish

Monitor yorqinligi maxsus yorqinlikni oshirish/pasaytirish funksiya tugmalari bilan boshqariladi. Agar ushbu tugmalarni bosganingizda shift ni bosib tursangiz, maksimal yoki minimal yorqinlikka o'tasiz. Tugmalar fokusdagi displeyni boshqaradi, shuning uchun DDC/CI orqali gaplasha oladigan tashqi monitorlar noutbuk ekrani bilan bir xil tarzda sozlanadi.

### Apple displeylari

Agar Apple displeyidan foydalanayotgan bo'lsangiz, oddiy klaviatura yorqinlik tugmalari ham, agar Apple displeyida fokusda bo'lsangiz, avtomatik ravishda ishlaydi. Bu `asdcontrol` buyrug'i orqali amalga oshiriladi.

E'tibor bering, agar Apple 6K XDR displeyidan foydalanayotgan bo'lsangiz, `hyprctl monitors` ro'yxatingizda xayoliy ekranni ko'rishingiz mumkin. Buni `~/.config/hypr/monitors.lua` da `hl.monitor({ output = "DP-2", disabled = true })` kabi biror narsa bilan o'chirib qo'yishingiz mumkin.

Intel mashinalarida Apple displeylariga oddiy Thunderbolt kabeli yordamida ulanishingiz kerak. Thunderbolt bo'lmagan boshqa mashinalarda, uni ishlashi uchun odatda [DP + USB-A -> USB-C kabeli](https://www.amazon.com/dp/B0BNX7MS6N) dan foydalanishingizga to'g'ri keladi.
