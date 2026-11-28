# Теми

Omarchy постачається з двадцятьма трьома красивими темами. Вибрати одну з них можна через _Зовнішній вигляд > Тема_ в меню Omarchy (`Super + Space`) або одразу перейти до вибору теми за допомогою `Super + Ctrl + T`.

Кожна тема оформлює стільницю, термінал, neovim, екран активності (btop), ваш браузер (Chrome, Chromium, Edge або Brave) і всю оболонку Omarchy: верхню панель, меню, сповіщення, OSD та екран блокування. (Для Obsidian тему Omarchy потрібно вибрати вручну через _Зовнішній вигляд > Теми_ всередині програми).

Теми мають набір фонових зображень, між якими можна вибирати за допомогою `Super + Ctrl + W`.

Ще більше тем можна знайти на [сторінці додаткових тем](https://omarchy.org/themes/) або навіть [створити власну тему](43-making-your-own-theme.md).

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

### Значки програм

Значки в засобі запуску програм і в доку намальовано в кольорах вашої теми, тож вони змінюються разом із нею. Вони походять із набору значків, який ви вибираєте окремо від теми в розділі _Зовнішній вигляд > Значки_ з попередніх переглядів кожного набору, так само, як ви вибираєте тему:

- _Papercraft_ — стандартний набір: усе встановлене намальовано в одному стилі. Програми, впізнавані за своїм логотипом, як-от Chrome, HEY або YouTube, зберігають його форму й набувають кольорів теми.
- _Arcade_ малює ті самі програми як 8-бітне піксельне мистецтво, як це зробила б стара ігрова консоль.
- _Original_ показує кожну програму зі значком, який дав їй її творець.

Ви можете встановити набір значків, створений кимось іншим, через _Встановити > Стиль > Значки_ (або `omarchy icons install <git url>`), а знову видалити його в розділі _Видалити > Значки_. _Оновити > Додаткові значки_ завантажує найновішу версію встановлених вами наборів.

Щоб створити власний набір, розмістіть свої значки в `~/.config/omarchy/icons/<name>/`, по одному файлу для кожної програми, названому за рядком `Icon=` файлу `.desktop` цієї програми. Файл, що закінчується на `.svg`, показується як є. Файл, що закінчується на `.svg.tpl`, малюється в кольорах теми: напишіть `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` або `{{ icon_shadow }}` там, де має стояти колір. Стандартний набір у `/usr/share/omarchy/icons/papercraft/` — гарна відправна точка. Додайте `preview.png`, щоб ваш набір показувався у засобі вибору; без нього Omarchy намалює попередній перегляд із ваших значків. Щоб змінити один значок стандартного набору, розмістіть свою версію в `~/.config/omarchy/icons/papercraft/`.

### Розблокування

Теми також можуть мати власне оформлення розблокування, яке використовується для процесу розшифрування під час завантаження. Ви можете вибрати одне з них у розділі _Зовнішній вигляд > Розблокування_. Вони виглядають так:

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

 ![last-horizon](../themes/last-horizon/preview-unlock.png)
_Last Horizon_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![lupine](../themes/lupine/preview-unlock.png)
_Lupine_

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

 ![solitude](../themes/solitude/preview-unlock.png)
_Solitude_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
