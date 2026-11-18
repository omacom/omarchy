# Temos

Omarchy pateikiama su dvidešimt dviem gražiomis temomis. Galite rinktis iš jų per _Išvaizda > Tema_ Omarchy meniu (`Super + Space`) arba pereiti tiesiai prie temų pasirinkimo naudodami `Super + Ctrl + T`.

Kiekviena tema stilizuoja darbalaukį, terminalą, neovim, veiklos ekraną (btop), Chromium ir visą Omarchy aplinką: viršutinę juostą, meniu, pranešimus, OSD ir užrakinimo ekraną. (Obsidian programoje Omarchy temą turite rankiniu būdu pasirinkti per _Išvaizda > Temos_ pačioje programoje).

Temos turi foninių paveikslėlių rinkinį, iš kurio galite rinktis naudodami `Super + Ctrl + W`.

Dar daugiau temų rasite [papildomų temų puslapyje](https://omarchy.org/themes/) arba netgi galite [sukurti savo temą](43-making-your-own-theme.md).

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

### Programų piktogramos

Programų paleidimo priemonėje ir doke esančios piktogramos piešiamos jūsų temos spalvomis, todėl keičiasi kartu su ja. Jos yra iš piktogramų rinkinio, kurį pasirenkate atskirai nuo temos per _Išvaizda > Piktogramos_, iš kiekvieno rinkinio peržiūrų, taip pat, kaip renkatės temą:

- _Papercraft_ yra numatytasis: viskas, kas įdiegta, nupiešta vienu stiliumi. Programos, atpažįstamos iš savo logotipo, pavyzdžiui, Chrome, HEY ar YouTube, išlaiko savo formą ir įgauna temos spalvas.
- _Arcade_ tas pačias programas piešia kaip 8 bitų pikselių grafiką, kaip tai darytų sena žaidimų konsolė.
- _Original_ kiekvieną programą rodo su piktograma, kurią jai suteikė jos kūrėjas.

Kito sukurta piktogramų rinkinį galite įdiegti per _Įdiegti > Stilius > Piktogramos_ (arba `omarchy icons install <git url>`), o pašalinti vėl per _Pašalinti > Piktogramos_. _Atnaujinti > Papildomos piktogramos_ atsisiunčia naujausią jūsų įdiegtų rinkinių versiją.

Norėdami sukurti savo, įkelkite savo piktogramas į `~/.config/omarchy/icons/<name>/`, po vieną failą kiekvienai programai, pavadintą pagal programos `.desktop` failo `Icon=` eilutę. Failas, besibaigiantis `.svg`, rodomas toks, koks yra. Failas, besibaigiantis `.svg.tpl`, piešiamas temos spalvomis: rašykite `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` arba `{{ icon_shadow }}` ten, kur turi būti spalva. Numatytasis rinkinys `/usr/share/omarchy/icons/papercraft/` yra gera vieta pradėti. Pridėkite `preview.png`, kad jūsų rinkinys būtų rodomas pasirinkimo priemonėje; be jo Omarchy nupieš peržiūrą iš jūsų piktogramų. Norėdami pakeisti vieną numatytojo rinkinio piktogramą, įkelkite savo versiją į `~/.config/omarchy/icons/papercraft/`.

### Atrakinimo ekranai

Temos taip pat gali turėti pasirinktinį atrakinimo dizainą, kuris naudojamas įkrovos iššifravimo procesui. Vieną iš jų galite pasirinkti per _Išvaizda > Atrakinimas_. Jie atrodo taip:

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
