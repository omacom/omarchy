# Теми

Omarchy постачається з двадцятьма трьома прекрасними темами. Вибирати між ними можна через _Зовнішній вигляд > Тема_ в меню Omarchy (`Super + Space`) або перейти безпосередньо до вибору теми за допомогою `Super + Ctrl + T`.

Кожна тема оформлює робочий стіл, термінал, neovim, екран активності (btop), ваш браузер (Chrome, Chromium, Edge або Brave) і всю оболонку Omarchy: верхню панель, меню, сповіщення, OSD та екран блокування. (Для Obsidian тему Omarchy потрібно вибрати вручну через _Зовнішній вигляд > Теми_ всередині застосунку).

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

### Значки застосунків

Значки в засобі запуску застосунків і в доку намальовано в кольорах вашої теми, тож вони змінюються разом із нею. Вони походять із набору значків, який ви вибираєте окремо від теми в розділі _Зовнішній вигляд > Значки_ за попередніми переглядами кожного набору, так само, як вибираєте тему:

- _Papercraft_ — типовий набір: усе, що постачається встановленим, намальовано в одному стилі. Застосунки, впізнавані за логотипом, як-от Chrome, HEY або YouTube, зберігають його форму й набувають кольорів теми.
- _Arcade_ малює ті самі застосунки як 8-бітний піксель-арт, як це зробила б стара ігрова консоль.
- _Original_ показує кожен застосунок зі значком, який дав йому його творець.

Встановити набір значків, створений кимось іншим, можна через _Встановлення > Стиль > Значки_ (або `omarchy icons install <git url>`), а видалити його знову — через _Видалення > Значки_. _Оновлення > Додаткові значки_ отримує найновішу версію встановлених вами наборів.

Щоб створити власний набір, покладіть свої значки до `~/.config/omarchy/icons/<name>/`, по одному файлу на застосунок, названому відповідно до рядка `Icon=` у файлі `.desktop` застосунку. Файл, що закінчується на `.svg`, показується як є. Файл, що закінчується на `.svg.tpl`, малюється в кольорах теми: пишіть `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` або `{{ icon_shadow }}` там, де має бути колір. Типовий набір у `/usr/share/omarchy/icons/papercraft/` — хороше місце, з якого варто почати. Додайте `preview.png`, щоб показати свій набір у засобі вибору; без нього Omarchy намалює попередній перегляд із ваших значків. Щоб змінити один значок типового набору, покладіть свою версію до `~/.config/omarchy/icons/papercraft/`.

### Завантаження та вхід

Екран, який запитує пароль до диска під час запуску комп'ютера, та екран входу також дотримуються теми. Щоразу, коли ви перемикаєте теми, вони переймають її кольори тла, тексту, акценту та червоний, тож окремого оформлення розблокування вибирати не потрібно. На комп'ютерах Mac з Apple Silicon екран пароля до диска зберігає типовий вигляд Omarchy незалежно від теми.
