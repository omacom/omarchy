# Mavzular

Omarchy yigirma ikkita chiroyli mavzu bilan birga keladi. Ular orasidan Omarchy Menu (`Super + Space`) ichidagi _Appearance > Theme_ orqali tanlashingiz yoki `Super + Ctrl + T` yordamida to'g'ridan-to'g'ri mavzu tanlagichga o'tishingiz mumkin.

Har bir mavzu ish stolini, terminalni, neovim, faollik ekranini (btop), Chromium va butun Omarchy qobig'ini uslubaydi: yuqori panel, menyu, bildirishnomalar, OSD va qulf ekranini. (Obsidian uchun Omarchy mavzusini ilova ichidagi _Appearance > Themes_ orqali qo'lda tanlashingiz kerak).

Mavzularda fon rasmlari to'plami mavjud bo'lib, ular orasidan `Super + Ctrl + W` yordamida tanlashingiz mumkin.

Yanada ko'proq mavzularni [qo'shimcha mavzular sahifasida](https://omarchy.org/themes/) topishingiz yoki hatto [o'z mavzuingizni yaratishingiz](43-making-your-own-theme.md) ham mumkin.

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

### Ilova ikonalari

Ilova ishga tushirgichi va dokdagi ikonalar mavzuingiz ranglarida chiziladi, shuning uchun ular u bilan birga o'zgaradi. Ular ikona to'plamidan keladi, uni mavzudan alohida _Appearance > Icons_ ostida, har bir to'plamning oldindan ko'rishlaridan, xuddi mavzu tanlaganingizdek tanlaysiz:

- _Papercraft_ — standart to'plam: o'rnatilgan hamma narsa bitta uslubda chizilgan. Chrome, HEY yoki YouTube kabi logotipi bilan taniladigan ilovalar shaklini saqlab qoladi va mavzu ranglarini oladi.
- _Arcade_ o'sha ilovalarni eski o'yin konsoli chizgandek 8-bitli piksel art sifatida chizadi.
- _Original_ har bir ilovani uning yaratuvchisi bergan ikona bilan ko'rsatadi.

Boshqa birov yaratgan ikona to'plamini _Install > Style > Icons_ (yoki `omarchy icons install <git url>`) bilan o'rnatishingiz va uni _Remove > Icons_ ostida yana olib tashlashingiz mumkin. _Update > Extra Icons_ siz o'rnatgan to'plamlarning eng so'nggi versiyasini olib keladi.

O'zingiznikini yaratish uchun ikonalaringizni `~/.config/omarchy/icons/<name>/` ichiga qo'ying, har bir ilova uchun bitta fayldan, ilovaning `.desktop` faylidagi `Icon=` qatori nomi bilan nomlang. `.svg` bilan tugaydigan fayl qanday bo'lsa, shunday ko'rsatiladi. `.svg.tpl` bilan tugaydigan fayl mavzu ranglarida chiziladi: rang ketadigan joyga `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` yoki `{{ icon_shadow }}` deb yozing. `/usr/share/omarchy/icons/papercraft/` ichidagi standart to'plam boshlash uchun yaxshi joy. To'plamingizni tanlagichda ko'rsatish uchun `preview.png` qo'shing; usiz Omarchy ikonalaringizdan oldindan ko'rish chizadi. Standart to'plamning bitta ikonasini o'zgartirish uchun o'z versiyangizni `~/.config/omarchy/icons/papercraft/` ichiga qo'ying.

### Qulf ochish ekranlari

Mavzular yuklanishdagi shifrni ochish jarayoni uchun ishlatiladigan maxsus qulf ochish dizayniga ham ega bo'lishi mumkin. Ulardan birini _Appearance > Unlock_ ostida tanlashingiz mumkin. Ular shunday ko'rinadi:

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
