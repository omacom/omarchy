# Темы

Omarchy поставляется с двадцатью двумя красивыми темами. Выбрать тему можно через _Внешний вид > Тема_ в меню Omarchy (`Super + Space`) или сразу перейти к выбору темы с помощью `Super + Ctrl + T`.

Каждая тема оформляет рабочий стол, терминал, neovim, экран активности (btop), Chromium и всю оболочку Omarchy: верхнюю панель, меню, уведомления, OSD и экран блокировки. (Для Obsidian тему Omarchy нужно вручную выбрать через _Внешний вид > Темы_ внутри приложения).

У тем есть набор фоновых изображений, между которыми можно переключаться с помощью `Super + Ctrl + W`.

Ещё больше тем можно найти на [странице дополнительных тем](https://omarchy.org/themes/) или даже [создать свою собственную тему](43-making-your-own-theme.md).

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

### Значки приложений

Значки в средстве запуска приложений и в доке нарисованы в цветах вашей темы, поэтому они меняются вместе с ней. Они берутся из набора значков, который вы выбираете отдельно от темы в разделе _Внешний вид > Значки_, по предпросмотрам каждого набора, точно так же, как выбираете тему:

- _Papercraft_ используется по умолчанию: всё, что установлено, нарисовано в одном стиле. Приложения, узнаваемые по своему логотипу, такие как Chrome, HEY или YouTube, сохраняют его форму и принимают цвета темы.
- _Arcade_ рисует те же приложения в виде 8-битной пиксельной графики, как на старой игровой консоли.
- _Original_ показывает каждое приложение со значком, который дал ему его создатель.

Вы можете установить набор значков, созданный кем-то другим, через _Установка > Стиль > Значки_ (или `omarchy icons install <git url>`), и снова удалить его через _Удаление > Значки_. _Обновление > Дополнительные значки_ загружает последнюю версию установленных у вас наборов.

Чтобы создать свой собственный набор, поместите значки в `~/.config/omarchy/icons/<name>/`, по одному файлу на приложение, названному в соответствии со строкой `Icon=` в `.desktop`-файле приложения. Файл с расширением `.svg` показывается как есть. Файл с расширением `.svg.tpl` рисуется в цветах темы: напишите `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` или `{{ icon_shadow }}` там, где должен быть цвет. Набор по умолчанию в `/usr/share/omarchy/icons/papercraft/` — хорошая отправная точка. Добавьте `preview.png`, чтобы показать ваш набор в окне выбора; без него Omarchy нарисует предпросмотр из ваших значков. Чтобы изменить один значок из набора по умолчанию, поместите свою версию в `~/.config/omarchy/icons/papercraft/`.

### Экраны разблокировки

У тем также может быть собственный дизайн разблокировки, который используется в процессе расшифровки при загрузке. Выбрать один из них можно в разделе _Внешний вид > Разблокировка_. Выглядят они так:

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
