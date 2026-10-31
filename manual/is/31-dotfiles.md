# Dotfiles

Omarchy er aðallega stillt í gegnum svokallaðar dotfiles-skrár sem búa í `~/.config`. Þær teljast þínar skrár fyrir þínar breytingar. Skrárnar sem búa í `/usr/share/omarchy` tilheyra Omarchy sjálfu, og þú ættir ekki að vera að fikta í þeim. Ef þú þarft að breyta einhverju í `/usr/share/omarchy` ættir þú í staðinn að yfirskrifa gildið í `~/.config`.

Helstu stillingarnar má breyta beint úr Omarchy valmyndinni (`Super + Space`), eins og _Setup > Keybindings_, _Setup > Input_ og _Setup > Config > [file]_. Þegar þú gerir það á þennan hátt mun öll ferli sem þurfa endurræsingu eftir breytingar á stillingum endurræsast sjálfkrafa eftir að þú hættir í ritlinum (Neovim sjálfgefið — `:wq`, mundu það! — en þú getur breytt því í gegnum _Setup > Defaults > Editor_).

Hér er listi yfir helstu skrárnar í `~/.config` og hvað þær stjórna:

| Skrá | Tilgangur |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Aðalstillingaskrá Hyprland. Hleður inn sjálfgefnum stillingum Omarchy auk yfirskrifunarskránna þinna hér að neðan. [Frekari upplýsingar um Hyprland stillingar](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Þínar eigin lyklabindingar og yfirskrifanir á sjálfgefnu gildunum. |
| `~/.config/hypr/monitors.lua` | Skjáastillingar sem skjástjórnborðið nær ekki yfir, eins og snúningur, aukahamir eða að hafa skjá slökktan. |
| `~/.config/hypr/input.lua` | Stjórnar lyklaborðsuppsetningu þinni, mús og snertiflata. |
| `~/.config/hypr/looknfeel.lua` | Stjórnar bilum, römmum, hreyfimyndum og öllu öðru útliti. |
| `~/.config/hypr/autostart.lua` | Stjórnar aukaferlum sem ræst eru með setunni. |
| `~/.config/omarchy/shell.json` | Stjórnar Omarchy skelinni: staðsetningu stiku, uppsetningu og græjum, auk tíma fyrir skjávörn, læsingu og aðgerðaleysi. |
| `~/.config/foot/foot.ini` | Stjórnar útstöðinni þinni (foot er sjálfgefið). |
| `~/.XCompose` | Skilgreinir flýtiaðgang þinn að emoji og sjálfvirka útfyllingu á nafni/netfangi. Gakktu úr skugga um að keyra `omarchy-restart-xcompose` eftir að þú gerir breytingar. |

Ef þú endar með að gera margar breytingar til að fínstilla þína eigin uppsetningu er góð hugmynd að taka öryggisafrit af öllum þessum dotfiles-skrám. [Stow er frábær leið til að gera það](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Að ræsa þín eigin forrit með setunni

Ef þú vilt að eitthvað keyri í hvert skipti sem þú skráir þig inn — samstillingarþjónn, spjallforrit, þitt eigið skript — settu það í `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Það ræsir skipunina sem hluta af setunni, svo hún er hreinsuð rétt upp þegar þú skráir þig út aftur.

### Að keyra skriptur við kerfisatburði

Omarchy kveikir á krókum á nokkrum augnablikum, og þú getur hengt þín eigin skript við þá. Þeir búa í `~/.config/omarchy/hooks/<event>.d/`, ein mappa fyrir hvern atburð, og hver keyranleg skrá þar inni keyrir þegar atburðurinn gerist:

| Atburður | Hvenær hann keyrir |
| ----- | ------------ |
| `post-boot` | Strax eftir að skjáborðið hefur ræst |
| `post-update` | Undir lok `omarchy update`, eftir pakka, flutninga og endurræsingar á þjónustum, áður en mise verkfæri eru uppfærð |
| `pre-refresh-pacman` | Eftir að `omarchy refresh pacman` endursamstillir pakkastillingarnar, áður en það uppfærir pakka; skipti um rás keyrir hann í sama endurnýjunarskrefi |
| `theme-set` | Eftir breytingu á þema (nafn þema í `$1`) |
| `font-set` | Eftir breytingu á letri (nafn leturs í `$1`) |
| `battery-low` | Þegar rafhlaðan verður lág (prósenta í `$1`) |

`pre-refresh-pacman` krókurinn er þar sem sérsniðin hugbúnaðarsöfn eða `IgnorePkg` línur eiga heima, þar sem hann keyrir fyrir pakkaviðskiptin. Báðir uppfærslutengdu krókarnir keyra sem notandinn þinn eftir að Omarchy hreinsar vistaða sudo heimild sína, svo krókur sem notar `sudo` þarf sína eigin heimild og gæti beðið þig um lykilorðið þitt.

Hver af þessum möppum geymir þegar `.sample` skrá sem sýnir lögun króks — slepptu `.sample` úr nafninu til að taka hann í notkun. Til að setja upp skript sem þú hefur skrifað annars staðar skaltu nota `omarchy hook install post-boot ~/my-hook`, sem afritar það inn og gerir það keyranlegt.

### Að bæta við þínum eigin valmyndarfærslum

Hægt er að útvíkka Omarchy valmyndina (`Super + Space`) með þínum eigin röðum með því að breyta `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Færslur eru lyklaðar með punktakenndru auðkenni, og auðkennið er það sem staðsetur þær í trénu, svo `personal` birtist á rótarvalmyndinni og `personal.notes` birtist inni í henni:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Ef þú endurnýtir fyrirliggjandi auðkenni yfirskrifar þú þá röð í stað þess að bæta við nýrri. Skráin kemur með öllum tiltækum reitum skjalfestum sem athugasemdir.

### Að bæta við þínum eigin skeljarútflutningum, föllum og samheitum

Omarchy kemur með fullt af þægilegum samheitum og hjálpsömum föllum, en það er mjög algengt að vilja bæta við sínum eigin. Þú ættir að bæta bæði samheitum, föllum og útflutningum við í `~/.bashrc`. Þessi skrá verður ekki yfirskrifuð við uppfærslur. Ef þú vilt breyta einhverjum sjálfgefnum stillingum Omarchy getur þú líka bætt þeim örugglega við hér.

### Að stilla umhverfisbreytur fyrir skjáborðið

Útflutningar fyrir skjáborðssetu eiga heima í `~/.config/uwsm/env.d/`. Þessar skrár keyra áður en skjáborðið þitt ræsist, svo skeljarvilla getur sent þig aftur á innskráningarskjáinn. Hafðu virka útstöð opna á meðan þú breytir þeim. Til að slökkva á yfirskrifun skaltu færa hana út úr `env.d`. Sjá [endurheimt innskráningar](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) ef breyting kemur í veg fyrir innskráningu.

### Að breyta innri Omarchy skrám

Heyrðu, þetta er þín tölva. Þú getur gert hvað sem þú vilt við hana, en ég myndi ráðleggja þér að breyta ekki skrám í `/usr/share/omarchy` beint. Þær tilheyra Omarchy pacman pakkanum, svo breytingar þínar verða einfaldlega yfirskrifaðar við næstu uppfærslu. Þér er betra að yfirskrifa bara öll sjálfgefin gildi sem þér líkar ekki í `~/.config/*` möppunni í staðinn.

Þú getur breytt nánast öllu á þann hátt, eins og sjálfgefnum lyklabindingum. Breyttu bara `~/.config/hypr/bindings.lua` til að, segjum, skipta [Obsidian](https://obsidian.md/) út fyrir [Joplin](https://joplinapp.org/) (settu upp með `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` fjarlægir fyrirliggjandi bindingu áður en það bætir við staðgenglinum. Það tekur sömu viðföng og `o.bind`, þar á meðal ræsihjálparföll og valkosti fyrir bindingu. Notaðu `o.bind` til að bæta við bindingu, eða `hl.unbind` til að fjarlægja eina án þess að skipta henni út.

Ef þú krefst þess að hakka í innri Omarchy skrárnar skaltu skipta yfir á þróunarrásina í gegnum _Update > Channel > Dev_. Það tengir Omarchy við git afrit af frumkóðanum í `~/omarchy`, sem þér er frjálst að breyta eins og þér sýnist. Enginn hérna ætlar að segja þér fyrir verkum!

### Að endurstilla allar breytingar

Ef þú endar með að klúðra stillingunum getur þú alltaf fært þær aftur í sjálfgefin gildi í gegnum _Update > Config_ í Omarchy valmyndinni. Eða með því að keyra `omarchy reinstall configs` til að endurstilla allt.
