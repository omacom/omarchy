# Punktaskrár

Omarchy er fyrst og fremst stillt í gegnum svokallaðar punktaskrár sem búa í `~/.config`. Þær teljast þínar skrár fyrir þínar breytingar. Skrárnar sem búa í `/usr/share/omarchy` tilheyra Omarchy sjálfu, og þú ættir ekki að vera að fikta í þeim. Ef þú þarft að breyta einhverju í `/usr/share/omarchy` ættir þú í staðinn að yfirskrifa gildið í `~/.config`.

Helstu stillingarnar er hægt að breyta beint úr Omarchy-valmyndinni (`Super + Space`), eins og _Setup > Keybindings_, _Setup > Input_ og _Setup > Config > [file]_. Þegar þú gerir það á þennan hátt endurræsist öll ferli sem þurfa endurræsingu eftir breytingar á stillingum sjálfkrafa þegar þú hættir í ritlinum (Neovim er sjálfgefið — `:wq`, mundu það! — en þú getur breytt því í gegnum _Setup > Defaults > Editor_).

Hér er listi yfir helstu skrárnar í `~/.config` og hvað þær stjórna:

| Skrá | Tilgangur |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Aðalstillingarskrá Hyprland. Hleður inn sjálfgefnum Omarchy-stillingum auk yfirskrifunarskránna þinna hér að neðan. [Frekari upplýsingar um Hyprland-stillingar](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Þínar eigin lyklabindingar og yfirskrifanir á sjálfgefnu gildunum. |
| `~/.config/hypr/monitors.lua` | Stillingar skjás sem skjáborðið nær ekki yfir, eins og snúningur, fleiri hamir eða að halda skjá slökktum. |
| `~/.config/hypr/input.lua` | Stjórnar lyklaborðsuppsetningu þinni, mús og snertifleti. |
| `~/.config/hypr/looknfeel.lua` | Stjórnar bilum, römmum, hreyfimyndum og öllu öðru útliti. |
| `~/.config/hypr/autostart.lua` | Stjórnar aukaferlum sem ræst eru með setunni. |
| `~/.config/omarchy/shell.json` | Stjórnar Omarchy-skelinni: staðsetningu stiku, uppsetningu og græjum, auk skjáhlífar, læsingar og tímastillinga aðgerðarleysis. |
| `~/.config/foot/foot.ini` | Stjórnar útstöðinni þinni (foot er sjálfgefið). |
| `~/.XCompose` | Skilgreinir snöggvirkan emoji-aðgang þinn og sjálfvirka útfyllingu á nafni/netfangi. Vertu viss um að keyra `omarchy-restart-xcompose` eftir að þú gerir breytingar. |

Ef þú endar með að gera margar breytingar til að fínstilla þína eigin uppsetningu er góð hugmynd að taka öryggisafrit af öllum þessum punktaskrám. [Stow er frábær leið til þess](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Að ræsa þín eigin forrit með setunni

Ef þú vilt að eitthvað keyri í hvert skipti sem þú skráir þig inn — samstillingarþjónn, spjallforrit, þín eigin forskrift — settu það í `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Það ræsir skipunina sem hluta af setunni, svo hún er hreinsuð upp á réttan hátt þegar þú skráir þig út aftur.

### Að keyra forskriftir við kerfisatburði

Omarchy kveikir á krókum á nokkrum augnablikum, og þú getur hengt þínar eigin forskriftir á þá. Þeir búa í `~/.config/omarchy/hooks/<event>.d/`, ein mappa fyrir hvern atburð, og hver keyranleg skrá þar inni keyrir þegar atburðurinn gerist:

| Atburður | Hvenær hann keyrir |
| ----- | ------------ |
| `post-boot` | Strax eftir að skjáborðið hefur ræst |
| `post-update` | Undir lok `omarchy update`, eftir pakka, færslur og endurræsingar þjónustu, áður en mise-tól eru uppfærð |
| `pre-refresh-pacman` | Eftir að `omarchy refresh pacman` endursamstillir pakkastillingarnar, áður en það uppfærir pakka; rásaskipti keyra það á sama endurnýjunarskrefi |
| `theme-set` | Eftir þemabreytingu (þemanafn í `$1`) |
| `font-set` | Eftir leturbreytingu (leturheiti í `$1`) |
| `battery-low` | Þegar rafhlaðan verður lág (prósenta í `$1`) |

Krókurinn `pre-refresh-pacman` er þar sem sérsniðin hugbúnaðarsöfn eða `IgnorePkg`-línur eiga heima, þar sem hann keyrir fyrir pakkafærsluna. Báðir uppfærslutengdir krókar keyra sem notandinn þinn eftir að Omarchy hreinsar skyndiminnta sudo-heimild sína, svo krókur sem notar `sudo` þarf sína eigin heimild og gæti beðið þig um lykilorðið þitt.

Hver þessara mappa geymir þegar `.sample`-skrá sem sýnir lögun króks — fjarlægðu `.sample` úr nafninu til að taka hann í notkun. Til að setja upp forskrift sem þú hefur skrifað annars staðar skaltu nota `omarchy hook install post-boot ~/my-hook`, sem afritar hana inn og gerir hana keyranlega.

### Að bæta við þínum eigin valmyndarfærslum

Hægt er að útvíkka Omarchy-valmyndina (`Super + Space`) með þínum eigin röðum með því að breyta `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Færslur fá lykil sem er punktað auðkenni, og það er auðkennið sem staðsetur þær í trénu, svo `personal` birtist á rótarvalmyndinni og `personal.notes` birtist inni í henni:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Endurnýttu fyrirliggjandi auðkenni og þú yfirskrifar þá röð í stað þess að bæta við nýrri. Skráin fylgir með öll tiltæk svæði skjalfest sem athugasemdir.

### Að bæta við þínum eigin skeljarútflutningum, föllum og samheitum

Omarchy fylgir með fullt af þægilegum samheitum og hjálplegum föllum, en það er mjög algengt að vilja bæta við sínum eigin. Þú ættir að bæta bæði samheitum, föllum og útflutningum við í `~/.bashrc`. Þessi skrá verður ekki yfirskrifuð við uppfærslur. Ef þú vilt breyta einhverjum sjálfgefnum Omarchy-stillingum geturðu líka bætt þeim örugglega við hér.

### Að breyta innri Omarchy-skrám

Heyrðu, þetta er þín tölva. Þú getur gert hvað sem þú vilt við hana, en ég myndi ráðleggja þér að gera ekki breytingar á skránum í `/usr/share/omarchy` beint. Þær tilheyra Omarchy pacman-pakkanum, svo breytingarnar þínar verða einfaldlega yfirskrifaðar við næstu uppfærslu. Þér er betra að yfirskrifa bara öll sjálfgefin gildi sem þú vilt ekki í möppunni `~/.config/*` í staðinn.

Þú getur breytt nánast öllu á þennan hátt, eins og sjálfgefnum lyklabindingum. Breyttu bara `~/.config/hypr/bindings.lua` til að, segjum, skipta út [Obsidian](https://obsidian.md/) fyrir [Joplin](https://joplinapp.org/) (settu upp með `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` fjarlægir fyrirliggjandi bindingu áður en það bætir við staðgenglinum. Það tekur sömu röksemdir og `o.bind`, þar með talda ræsingarhjálpara og bindingarvalkosti. Notaðu `o.bind` til að bæta við bindingu, eða `hl.unbind` til að fjarlægja eina án þess að skipta henni út.

Ef þú þráast við að hakka í innri Omarchy-skrárnar skaltu skipta yfir á dev-rásina í gegnum _Update > Channel > Dev_. Það tengir Omarchy við git-úttekt á frumkóðanum í `~/omarchy`, sem þér er frjálst að breyta eins og hjartað girnist. Það er enginn hér til að segja þér hvað þú átt að gera!

### Að endurstilla allar breytingar

Ef þú endar með að klúðra stillingunum geturðu alltaf snúið þeim aftur í sjálfgefin gildi í gegnum _Update > Config_ í Omarchy-valmyndinni. Eða með því að keyra `omarchy reinstall configs` til að endurstilla allt.
