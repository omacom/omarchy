# Теме

Omarchy долази са двадесет две прелепе теме. Можете да бирате између њих преко _Изглед > Тема_ у Omarchy менију (`Super + Space`) или да одете директно на бирач тема користећи `Super + Ctrl + T`.

Свака тема стилизује радну површину, терминал, neovim, екран активности (btop), Chromium и целу Omarchy шкољку: горњу траку, мени, обавештења, OSD и екран за закључавање. (За Obsidian морате ручно да изаберете Omarchy тему преко _Изглед > Теме_ унутар апликације).

Теме имају скуп позадинских слика између којих можете да бирате користећи `Super + Ctrl + W`.

Још више тема можете пронаћи на [страници са додатним темама](https://omarchy.org/themes/) или чак [да направите сопствену тему](43-making-your-own-theme.md).

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

### Иконе апликација

Иконе у покретачу апликација и на доку нацртане су у бојама ваше теме, па се мењају заједно са њом. Потичу из скупа икона, који бирате одвојено од теме под _Изглед > Иконе_, из прегледа сваког скупа, на исти начин на који бирате тему:

- _Papercraft_ је подразумевани: све што долази инсталирано, нацртано у једном стилу. Апликације познате по свом логотипу, као што су Chrome, HEY или YouTube, задржавају свој облик и попримају боје теме.
- _Arcade_ црта исте апликације као 8-битну пиксел уметност, као што би то радила стара играчка конзола.
- _Original_ приказује сваку апликацију са иконом коју јој је дао њен творац.

Можете да инсталирате скуп икона који је неко други направио помоћу _Инсталирање > Стил > Иконе_ (или `omarchy icons install <git url>`), и да га поново уклоните под _Уклањање > Иконе_. _Ажурирање > Додатне иконе_ преузима најновију верзију скупова које сте инсталирали.

Да бисте направили сопствени, ставите своје иконе у `~/.config/omarchy/icons/<name>/`, по један фајл за сваку апликацију, именован према линији `Icon=` у `.desktop` фајлу апликације. Фајл који се завршава на `.svg` приказује се онакав какав јесте. Фајл који се завршава на `.svg.tpl` црта се у бојама теме: напишите `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` или `{{ icon_shadow }}` где иде боја. Подразумевани скуп у `/usr/share/omarchy/icons/papercraft/` добро је место за почетак. Додајте `preview.png` да бисте приказали свој скуп у бирачу; без њега, Omarchy црта преглед од ваших икона. Да бисте променили једну икону подразумеваног скупа, ставите своју верзију у `~/.config/omarchy/icons/papercraft/`.

### Откључавања

Теме такође могу имати прилагођени дизајн откључавања, који се користи за процес дешифровања при покретању система. Један од њих можете да изаберете под _Изглед > Откључавање_. Изгледају овако:

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
