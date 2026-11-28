# Темы

В Omarchy входят двадцать три красивые темы. Выбрать одну из них можно через _Внешний вид > Тема_ в меню Omarchy (`Super + Space`) или сразу перейти к выбору темы с помощью `Super + Ctrl + T`.

Каждая тема оформляет рабочий стол, терминал, neovim, экран активности (btop), ваш браузер (Chrome, Chromium, Edge или Brave) и всю оболочку Omarchy: верхнюю панель, меню, уведомления, OSD и экран блокировки. (Для Obsidian тему Omarchy нужно вручную выбрать через _Внешний вид > Темы_ внутри приложения).

У тем есть набор фоновых изображений, между которыми можно переключаться с помощью `Super + Ctrl + W`.

Ещё больше тем можно найти на [странице дополнительных тем](https://omarchy.org/themes/) или даже [сделать свою собственную тему](43-making-your-own-theme.md).

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

Значки в панели запуска приложений и в доке рисуются в цветах вашей темы, поэтому меняются вместе с ней. Они берутся из набора значков, который выбирается отдельно от темы в разделе _Внешний вид > Значки_ по предпросмотру каждого набора — точно так же, как выбирается тема:

- _Papercraft_ — набор по умолчанию: всё, что установлено, нарисовано в одном стиле. Приложения, узнаваемые по своему логотипу, например Chrome, HEY или YouTube, сохраняют свою форму и принимают цвета темы.
- _Arcade_ рисует те же приложения в виде 8-битного пиксель-арта, как на старой игровой консоли.
- _Original_ показывает каждое приложение со значком, который дал ему его создатель.

Набор значков, сделанный кем-то другим, можно установить через _Установка > Стиль > Значки_ (или командой `omarchy icons install <git url>`), а удалить — через _Удаление > Значки_. Пункт _Обновление > Дополнительные значки_ загружает последнюю версию установленных у вас наборов.

Чтобы сделать собственный набор, поместите значки в `~/.config/omarchy/icons/<name>/` — по одному файлу на приложение, с именем по строке `Icon=` из `.desktop`-файла приложения. Файл с окончанием `.svg` показывается как есть. Файл с окончанием `.svg.tpl` рисуется в цветах темы: укажите `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` или `{{ icon_shadow }}` там, где должен быть цвет. Набор по умолчанию в `/usr/share/omarchy/icons/papercraft/` — хорошая отправная точка. Добавьте `preview.png`, чтобы ваш набор показывался в окне выбора; без него Omarchy составит предпросмотр из ваших значков. Чтобы изменить один значок из набора по умолчанию, поместите свою версию в `~/.config/omarchy/icons/papercraft/`.

### Загрузка и вход

Экран, который запрашивает пароль от диска при запуске компьютера, и экран входа тоже следуют теме. Каждый раз при смене темы они принимают её цвета фона, текста, акцента и красный цвет, поэтому отдельного оформления разблокировки выбирать не нужно. На компьютерах Mac с Apple Silicon экран пароля от диска сохраняет стандартное оформление Omarchy при любой теме.
