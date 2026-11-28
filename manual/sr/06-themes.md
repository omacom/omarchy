# Теме

Omarchy долази са двадесет три прелепе теме. Можете бирати између њих преко _Изглед > Тема_ у Omarchy менију (`Super + Space`) или прескочити право до бирача тема користећи `Super + Ctrl + T`.

Свака тема стилизује радну површину, терминал, neovim, екран активности (btop), ваш прегледач (Chrome, Chromium, Edge или Brave) и целокупну Omarchy љуску: горњу траку, мени, обавештења, OSD и екран за закључавање. (За Obsidian морате ручно изабрати Omarchy тему преко _Изглед > Теме_ унутар апликације).

Теме имају скуп позадинских слика између којих можете бирати користећи `Super + Ctrl + W`.

Можете пронаћи још више тема на [страници са додатним темама](https://omarchy.org/themes/) или чак [направити сопствену тему](43-making-your-own-theme.md).

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

### Иконе апликација

Иконе у покретачу апликација и на доку нацртане су у бојама ваше теме, па се мењају заједно са њом. Оне потичу из скупа икона, који бирате одвојено од теме под _Изглед > Иконе_, на основу прегледа сваког скупа, на исти начин на који бирате тему:

- _Papercraft_ је подразумевани: све што долази инсталирано, нацртано у једном стилу. Апликације познате по свом логотипу, као што су Chrome, HEY или YouTube, задржавају његов облик и преузимају боје теме.
- _Arcade_ црта исте апликације као 8-bit уметност од пиксела, као што би то радила стара играћа конзола.
- _Original_ приказује сваку апликацију са иконом коју јој је дао њен творац.

Скуп икона који је направио неко други можете инсталирати помоћу _Инсталирај > Стил > Иконе_ (или `omarchy icons install <git url>`), а поново га уклонити под _Уклони > Иконе_. _Ажурирај > Додатне иконе_ преузима најновију верзију скупова које сте инсталирали.

Да бисте направили сопствени, ставите своје иконе у `~/.config/omarchy/icons/<name>/`, по једну датотеку за сваку апликацију, названу према линији `Icon=` у датотеци `.desktop` те апликације. Датотека која се завршава на `.svg` приказује се таква каква јесте. Датотека која се завршава на `.svg.tpl` црта се у бојама теме: напишите `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` или `{{ icon_shadow }}` тамо где иде боја. Подразумевани скуп у `/usr/share/omarchy/icons/papercraft/` добро је место од којег можете почети. Додајте `preview.png` да бисте свој скуп приказали у бирачу; без њега, Omarchy црта преглед на основу ваших икона. Да бисте променили једну икону подразумеваног скупа, ставите своју верзију у `~/.config/omarchy/icons/papercraft/`.

### Покретање система и пријава

Екран који тражи лозинку вашег диска када се рачунар покрене и екран за пријаву такође прате тему. Сваки пут када промените тему, они преузимају њену позадину, текст, акценат и црвене боје, тако да не постоји посебан дизајн откључавања који треба одабрати. На Apple Silicon Mac рачунарима екран за лозинку диска задржава Omarchy подразумевани изглед, каква год да је тема.
