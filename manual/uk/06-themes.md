# Теми

Omarchy постачається з двадцятьма двома красивими темами. Ви можете вибирати між ними через _Оформлення > Тема_ в Omarchy Menu (`Super + Space`) або перейти безпосередньо до засобу вибору теми за допомогою `Super + Ctrl + T`.

Кожна тема оформлює робочий стіл, термінал, neovim, екран активності (btop), Chromium і всю оболонку Omarchy: верхню панель, меню, сповіщення, OSD та екран блокування. (Для Obsidian ви повинні вручну вибрати тему Omarchy через _Оформлення > Теми_ всередині застосунку).

Теми мають набір фонових зображень, між якими ви можете вибирати за допомогою `Super + Ctrl + W`.

Ще більше тем ви можете знайти на [сторінці додаткових тем](https://omarchy.org/themes/) або навіть [створити власну тему](43-making-your-own-theme.md).

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

### Піктограми застосунків

Піктограми в засобі запуску застосунків і в доці намальовані в кольорах вашої теми, тож вони змінюються разом із нею. Вони походять із набору піктограм, який ви вибираєте окремо від теми в розділі _Оформлення > Піктограми_, за попередніми переглядами кожного набору, так само, як ви вибираєте тему:

- _Papercraft_ — стандартний: усе, що встановлено, намальовано в одному стилі. Застосунки, впізнавані за своїм логотипом, як-от Chrome, HEY або YouTube, зберігають його форму й набувають кольорів теми.
- _Arcade_ малює ті самі застосунки як 8-бітний піксель-арт, як це зробила б стара ігрова консоль.
- _Original_ показує кожен застосунок із піктограмою, яку йому дав його творець.

Ви можете встановити набір піктограм, створений кимось іншим, через _Встановлення > Стиль > Піктограми_ (або `omarchy icons install <git url>`), і знову видалити його в розділі _Видалення > Піктограми_. _Оновлення > Додаткові піктограми_ завантажує найновішу версію встановлених вами наборів.

Щоб створити власний набір, покладіть свої піктограми в `~/.config/omarchy/icons/<name>/`, по одному файлу на застосунок, названому відповідно до рядка `Icon=` у файлі `.desktop` застосунку. Файл із закінченням `.svg` показується як є. Файл із закінченням `.svg.tpl` малюється в кольорах теми: напишіть `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` або `{{ icon_shadow }}` там, де має бути колір. Стандартний набір у `/usr/share/omarchy/icons/papercraft/` — хороше місце, з якого можна почати. Додайте `preview.png`, щоб показати ваш набір у засобі вибору; без нього Omarchy намалює попередній перегляд із ваших піктограм. Щоб змінити одну піктограму стандартного набору, покладіть свою версію в `~/.config/omarchy/icons/papercraft/`.

### Розблокування

Теми також можуть мати власний дизайн розблокування, який використовується для процесу розшифрування під час завантаження. Ви можете вибрати один із них у розділі _Оформлення > Розблокування_. Вони виглядають так:

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
