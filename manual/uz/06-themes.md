# Mavzular

Omarchy yigirma uchta go'zal mavzu bilan birga keladi. Ular orasidan Omarchy Menu (`Super + Space`) ichidagi _Tashqi ko'rinish > Mavzu_ orqali tanlashingiz yoki `Super + Ctrl + T` yordamida to'g'ridan-to'g'ri mavzu tanlagichga o'tishingiz mumkin.

Har bir mavzu ish stolini, terminalni, neovim'ni, faollik ekranini (btop), brauzeringizni (Chrome, Chromium, Edge yoki Brave) va butun Omarchy qobig'ini: yuqori panelni, menyuni, bildirishnomalarni, OSD'ni va qulf ekranini bezaydi. (Obsidian uchun Omarchy mavzusini ilova ichidagi _Tashqi ko'rinish > Mavzular_ orqali qo'lda tanlashingiz kerak).

Mavzularda fon rasmlari to'plami bor, ular orasidan `Super + Ctrl + W` yordamida tanlashingiz mumkin.

Yanada ko'proq mavzularni [qo'shimcha mavzular sahifasida](https://omarchy.org/themes/) topishingiz yoki hatto [o'z mavzuingizni yaratishingiz](43-making-your-own-theme.md) mumkin.

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### Ilova piktogrammalari

Ilova ishga tushirgichi va dokdagi piktogrammalar mavzuingiz ranglarida chiziladi, shuning uchun ular u bilan birga o'zgaradi. Ular piktogrammalar to'plamidan olinadi, uni mavzudan alohida _Tashqi ko'rinish > Piktogrammalar_ ostida, har bir to'plamning oldindan ko'rishlaridan, xuddi mavzu tanlagandek tanlaysiz:

- _Papercraft_ birlamchi hisoblanadi: o'rnatilgan barcha narsalar bitta uslubda chizilgan. Chrome, HEY yoki YouTube kabi logotipi bilan tanilgan ilovalar o'z shaklini saqlab qoladi va mavzu ranglarini oladi.
- _Arcade_ xuddi shu ilovalarni eski o'yin konsoli chizgandek 8-bitli piksel art ko'rinishida chizadi.
- _Original_ har bir ilovani uning yaratuvchisi bergan piktogramma bilan ko'rsatadi.

Birov yaratgan piktogrammalar to'plamini _O'rnatish > Uslub > Piktogrammalar_ (yoki `omarchy icons install <git url>`) bilan o'rnatishingiz va uni _Olib tashlash > Piktogrammalar_ ostida yana olib tashlashingiz mumkin. _Yangilash > Qo'shimcha piktogrammalar_ siz o'rnatgan to'plamlarning eng so'nggi versiyasini olib keladi.

O'zingiznikini yaratish uchun piktogrammalaringizni `~/.config/omarchy/icons/<name>/` ichiga qo'ying, har bir ilova uchun bitta fayl, ilovaning `.desktop` faylidagi `Icon=` qatori nomi bilan atalgan. `.svg` bilan tugaydigan fayl qanday bo'lsa, shunday ko'rsatiladi. `.svg.tpl` bilan tugaydigan fayl mavzu ranglarida chiziladi: rang qo'yiladigan joyga `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` yoki `{{ icon_shadow }}` deb yozing. `/usr/share/omarchy/icons/papercraft/` ichidagi birlamchi to'plam boshlash uchun yaxshi joy. To'plamingizni tanlagichda ko'rsatish uchun `preview.png` qo'shing; usiz Omarchy piktogrammalaringizdan oldindan ko'rish chizadi. Birlamchi to'plamning bitta piktogrammasini o'zgartirish uchun o'z versiyangizni `~/.config/omarchy/icons/papercraft/` ichiga qo'ying.

### Yuklanish va kirish

Kompyuter ishga tushganda disk parolingizni so'raydigan ekran va kirish ekrani ham mavzuga ergashadi. Har safar mavzuni almashtirganingizda, ular uning fonini, matnini, urg'u va qizil ranglarini oladi, shuning uchun tanlash uchun alohida qulfdan chiqarish dizayni yo'q. Apple Silicon Mac'larda disk paroli ekrani mavzu qanday bo'lishidan qat'i nazar Omarchy'ning birlamchi ko'rinishini saqlab qoladi.
