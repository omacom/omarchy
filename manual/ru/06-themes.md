# Темы

В Omarchy входит двадцать три красивые темы. Выбрать их можно через _Внешний вид > Тема_ в меню Omarchy (`Super + Space`) или сразу открыть выбор темы сочетанием `Super + Ctrl + T`.

Каждая тема оформляет рабочий стол, терминал, neovim, экран активности (btop), ваш браузер (Chrome, Chromium, Edge или Brave) и всю оболочку Omarchy: верхнюю панель, меню, уведомления, OSD и экран блокировки. (Для Obsidian тему Omarchy нужно выбрать вручную через _Внешний вид > Темы_ внутри приложения).

У тем есть набор фоновых изображений, между которыми можно выбирать сочетанием `Super + Ctrl + W`.

Ещё больше тем можно найти на [странице с дополнительными темами](https://omarchy.org/themes/) или даже [создать свою тему](43-making-your-own-theme.md).

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

### Значки приложений

Значки в средстве запуска приложений и в доке рисуются в цветах вашей темы, поэтому меняются вместе с ней. Они берутся из набора значков, который выбирается отдельно от темы в разделе _Внешний вид > Значки_, по предпросмотрам каждого набора, так же, как выбирается тема:

- _Papercraft_ — по умолчанию: всё, что установлено, нарисовано в одном стиле. Приложения, узнаваемые по своему логотипу, такие как Chrome, HEY или YouTube, сохраняют свою форму и принимают цвета темы.
- _Arcade_ рисует те же приложения как 8-битную пиксельную графику, как это сделала бы старая игровая консоль.
- _Original_ показывает каждое приложение со значком, который ему дал его создатель.

Набор значков, сделанный кем-то другим, можно установить через _Установка > Стиль > Значки_ (или командой `omarchy icons install <git url>`), а удалить его — в разделе _Удаление > Значки_. _Обновление > Дополнительные значки_ загружает последнюю версию установленных у вас наборов.

Чтобы сделать свой набор, поместите свои значки в `~/.config/omarchy/icons/<name>/`, по одному файлу на приложение, с именем по строке `Icon=` из `.desktop`-файла приложения. Файл с окончанием `.svg` показывается как есть. Файл с окончанием `.svg.tpl` рисуется в цветах темы: напишите `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` или `{{ icon_shadow }}` там, где должен быть цвет. Хорошей отправной точкой будет набор по умолчанию в `/usr/share/omarchy/icons/papercraft/`. Добавьте `preview.png`, чтобы показать свой набор в окне выбора; без него Omarchy составит предпросмотр из ваших значков. Чтобы изменить один значок из набора по умолчанию, поместите свою версию в `~/.config/omarchy/icons/papercraft/`.

### Оформление разблокировки

У тем также может быть собственное оформление разблокировки, которое используется в процессе расшифровки при загрузке. Выбрать одно из них можно в разделе _Внешний вид > Разблокировка_. Выглядят они вот так:

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
