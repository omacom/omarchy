# Теми

Omarchy идва с двадесет и три красиви теми. Можете да избирате между тях чрез _Външен вид > Тема_ в Omarchy Menu (`Super + Space`) или да отидете директно до избора на тема с `Super + Ctrl + T`.

Всяка тема оформя работния плот, терминала, neovim, екрана за активност (btop), вашия браузър (Chrome, Chromium, Edge или Brave) и цялата обвивка на Omarchy: горната лента, менюто, известията, OSD и заключения екран. (За Obsidian трябва ръчно да изберете темата на Omarchy чрез _Външен вид > Теми_ вътре в приложението).

Темите имат набор от фонови изображения, между които можете да избирате с `Super + Ctrl + W`.

Можете да намерите още повече теми на [страницата с допълнителни теми](https://omarchy.org/themes/) или дори да [създадете своя собствена тема](43-making-your-own-theme.md).

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

### Икони на приложения

Иконите в стартера за приложения и в dock са нарисувани в цветовете на вашата тема, така че се променят заедно с нея. Те идват от набор от икони, който избирате отделно от темата под _Външен вид > Икони_, от визуализации на всеки набор, по същия начин, по който избирате тема:

- _Papercraft_ е по подразбиране: всичко, което идва инсталирано, нарисувано в един стил. Приложенията, познати по логото си, като Chrome, HEY или YouTube, запазват формата му и приемат цветовете на темата.
- _Arcade_ рисува същите приложения като 8-битова пикселна графика, както би направила стара игрова конзола.
- _Original_ показва всяко приложение с иконата, която производителят му е дал.

Можете да инсталирате набор от икони, направен от някой друг, с _Инсталиране > Стил > Икони_ (или `omarchy icons install <git url>`), и да го премахнете отново под _Премахване > Икони_. _Актуализация > Допълнителни икони_ изтегля най-новата версия на наборите, които сте инсталирали.

За да направите свои собствени, поставете иконите си в `~/.config/omarchy/icons/<name>/`, по един файл за приложение, именуван според реда `Icon=` от `.desktop` файла на приложението. Файл, завършващ на `.svg`, се показва такъв, какъвто е. Файл, завършващ на `.svg.tpl`, се рисува в цветовете на темата: напишете `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` или `{{ icon_shadow }}` там, където отива цвят. Наборът по подразбиране в `/usr/share/omarchy/icons/papercraft/` е добро място, от което да започнете. Добавете `preview.png`, за да покажете набора си в инструмента за избор; без такъв Omarchy рисува визуализация от вашите икони. За да промените една икона от набора по подразбиране, поставете вашата версия в `~/.config/omarchy/icons/papercraft/`.

### Стартиране и влизане

Екранът, който иска паролата за диска ви, когато компютърът стартира, и екранът за влизане също следват темата. Всеки път, когато сменяте тема, те приемат нейния фон, текст, акцент и червени цветове, така че няма отделен дизайн за отключване, който да избирате. На Apple Silicon Macs екранът за парола на диска запазва външния вид по подразбиране на Omarchy, каквато и да е темата.
