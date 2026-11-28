# Temos

Omarchy pateikiama su dvidešimt trimis gražiomis temomis. Galite rinktis iš jų per _Išvaizda > Tema_ Omarchy meniu (`Super + Space`) arba pereiti tiesiai prie temų pasirinkimo naudodami `Super + Ctrl + T`.

Kiekviena tema suformuoja darbalaukio, terminalo, neovim, aktyvumo ekrano (btop), jūsų naršyklės (Chrome, Chromium, Edge arba Brave) ir visos Omarchy aplinkos stilių: viršutinę juostą, meniu, pranešimus, OSD ir užrakinimo ekraną. (Obsidian programoje Omarchy temą turite rankiniu būdu pasirinkti programoje per _Išvaizda > Temos_). 

Temos turi foninių vaizdų rinkinį, iš kurio galite rinktis naudodami `Super + Ctrl + W`.

Dar daugiau temų galite rasti [papildomų temų puslapyje](https://omarchy.org/themes/) arba net [sukurti savo temą](43-making-your-own-theme.md).

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

### Programų piktogramos

Programų paleidimo priemonėje ir doke esančios piktogramos nupieštos jūsų temos spalvomis, todėl jos keičiasi kartu su ja. Jos gaunamos iš piktogramų rinkinio, kurį pasirenkate atskirai nuo temos skiltyje _Išvaizda > Piktogramos_, iš kiekvieno rinkinio peržiūrų, taip pat, kaip renkatės temą:

- _Papercraft_ yra numatytasis: viskas, kas įdiegta, nupiešta vienu stiliumi. Programos, atpažįstamos iš savo logotipo, pavyzdžiui, Chrome, HEY ar YouTube, išlaiko jo formą ir įgauna temos spalvas.
- _Arcade_ tas pačias programas piešia kaip 8 bitų pikselių grafiką, kaip būtų dariusi sena žaidimų konsolė.
- _Original_ kiekvieną programą rodo su piktograma, kurią jai suteikė jos kūrėjas.

Kito sukurta piktogramų rinkinį galite įdiegti per _Įdiegti > Stilius > Piktogramos_ (arba `omarchy icons install <git url>`), o vėl jį pašalinti skiltyje _Pašalinti > Piktogramos_. _Atnaujinti > Papildomos piktogramos_ atsiunčia naujausią jūsų įdiegtų rinkinių versiją.

Norėdami sukurti savąjį, įkelkite savo piktogramas į `~/.config/omarchy/icons/<name>/`, po vieną failą kiekvienai programai, pavadintą pagal programos `.desktop` failo eilutę `Icon=`. Failas, besibaigiantis `.svg`, rodomas toks, koks yra. Failas, besibaigiantis `.svg.tpl`, nupiešiamas temos spalvomis: rašykite `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` arba `{{ icon_shadow }}` ten, kur turi būti spalva. Numatytasis rinkinys `/usr/share/omarchy/icons/papercraft/` yra gera vieta, nuo kurios galima pradėti. Pridėkite `preview.png`, kad jūsų rinkinys būtų rodomas pasirinkimo priemonėje; be jo Omarchy nupieš peržiūrą iš jūsų piktogramų. Norėdami pakeisti vieną numatytojo rinkinio piktogramą, įkelkite savo versiją į `~/.config/omarchy/icons/papercraft/`.

### Paleidimas ir prisijungimas

Ekranas, kuriame paleidžiant kompiuterį prašoma jūsų disko slaptažodžio, ir prisijungimo ekranas taip pat paklūsta temai. Kaskart perjungus temas, jie perima jos fono, teksto, akcento ir raudoną spalvas, todėl nėra jokio atskiro atrakinimo dizaino, kurį reikėtų rinktis. Apple Silicon Mac kompiuteriuose disko slaptažodžio ekranas išlaiko numatytąją Omarchy išvaizdą, kad ir kokia būtų tema.
