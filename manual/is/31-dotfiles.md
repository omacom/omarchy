# Punktaskrár

Omarchy er aðallega stillt í gegnum svokallaðar punktaskrár sem búa í `~/.config`. Þær teljast þínar skrár fyrir þínar breytingar. Skrárnar sem búa í `/usr/share/omarchy` tilheyra Omarchy sjálfu og þú ættir ekki að vera að fikta í þeim. Ef þú þarft að breyta einhverju í `/usr/share/omarchy` ættir þú í staðinn að yfirskrifa gildið í `~/.config`.

Lykilstillingunum má breyta beint úr Omarchy-valmyndinni (`Super + Space`), eins og _Uppsetning > Lyklaborð > Lyklabindingar_, _Uppsetning > Inntak_ og _Uppsetning > Stillingar > [file]_. Þegar þú gerir það á þennan hátt endurræsist sjálfkrafa öll ferli sem þurfa endurræsingu eftir breytingar á stillingum þegar þú lokar ritlinum (Neovim sjálfgefið — `:wq`, mundu það! — en þú getur breytt því í gegnum _Uppsetning > Sjálfgefið > Ritill_).

Hér er listi yfir lykilskrárnar í `~/.config` og hvað þær stjórna:

| Skrá | Tilgangur |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Aðalstilling Hyprland. Hleður inn sjálfgefnum Omarchy-stillingum ásamt yfirskriftarskránum þínum hér að neðan. [Frekari upplýsingar um Hyprland-stillingar](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Þínar eigin lyklabindingar og yfirskriftir á sjálfgefnu gildunum. |
| `~/.config/hypr/monitors.lua` | Skjástillingar sem skjáborðið nær ekki yfir, eins og snúningur, fleiri hamir eða að halda skjá slökktum. |
| `~/.config/hypr/input.lua` | Stjórnar lyklaborðsuppsetningu þinni, mús og snertifleti. |
| `~/.config/hypr/looknfeel.lua` | Stjórnar bilum, römmum, hreyfimyndum og öðru útliti. |
| `~/.config/hypr/autostart.lua` | Stjórnar viðbótarferlum sem ræst eru með lotunni. |
| `~/.config/omarchy/shell.json` | Stjórnar Omarchy-skelinni: staðsetningu slár, uppröðun og búnaði, auk skjávara, læsingar og tímastillinga fyrir aðgerðarleysi. |
| `~/.config/foot/foot.ini` | Stjórnar útstöðinni þinni (foot er sjálfgefið). |
| `~/.XCompose` | Skilgreinir emoji með flýtiaðgangi og sjálfvirka útfyllingu á nafni/netfangi. Gakktu úr skugga um að keyra `omarchy-restart-xcompose` eftir að þú gerir breytingar. |

Ef þú endar með að gera margar breytingar til að fínstilla þína eigin uppsetningu er góð hugmynd að taka öryggisafrit af öllum þessum punktaskrám. [Stow er frábær leið til að gera það](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Að ræsa þín eigin forrit með lotunni

Ef þú vilt að eitthvað keyri í hvert sinn sem þú skráir þig inn — samstillingarþjónn, spjallforrit, þitt eigið forskrift — settu það í `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Það ræsir skipunina sem hluta af lotunni, svo henni er hreinsað upp á réttan hátt þegar þú skráir þig út aftur.

### Að keyra forskriftir við kerfisatburði

Omarchy kveikir á krókum á nokkrum augnablikum og þú getur hengt þín eigin forskrift á þá. Þeir búa í `~/.config/omarchy/hooks/<event>.d/`, ein mappa fyrir hvern atburð, og hver skrá þar inni sem endar ekki á `.sample` keyrir með bash þegar atburðurinn á sér stað:

| Atburður | Hvenær hann keyrir |
| ----- | ------------ |
| `post-boot` | Strax eftir að skjáborðið hefur ræst |
| `post-update` | Undir lok `omarchy update`, eftir pakka, færslur og endurræsingar á þjónustum, áður en mise-tól eru uppfærð |
| `pre-refresh-pacman` | Eftir að `omarchy refresh pacman` hefur endursamstillt pakkastillingarnar, áður en það uppfærir pakka; rásaskipti keyra hann í sama skrefi við endurhleðslu |
| `theme-set` | Eftir þemabreytingu (þemanafn í `$1`) |
| `font-set` | Eftir leturbreytingu (leturheiti í `$1`) |
| `battery-low` | Þegar rafhlaðan verður lág (prósenta í `$1`) |

Krókurinn `pre-refresh-pacman` er þar sem sérsniðnar pakkageymslur eða `IgnorePkg`-línur eiga heima, þar sem hann keyrir fyrir pakkafærsluna. Báðir keyra sem notandinn þinn. `post-update` keyrir á meðan sudo-heimild `omarchy update` er enn fersk, svo krókur sem notar `sudo` mun ekki biðja um lykilorðið þitt aftur; `pre-refresh-pacman` keyrir strax eftir að `omarchy refresh pacman` hefur sjálft notað sudo.

Hver af þessum möppum geymir þegar `.sample`-skrá sem sýnir lögun króks — fjarlægðu `.sample` úr nafninu til að taka hana í notkun. Til að setja upp forskrift sem þú hefur skrifað annars staðar skaltu nota `omarchy hook install post-boot ~/my-hook`, sem afritar hana inn og gerir hana keyranlega.

### Að bæta við þínum eigin valmyndarfærslum

Hægt er að útvíkka Omarchy-valmyndina (`Super + Space`) með þínum eigin röðum með því að breyta `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Færslur hafa lykil sem er punktaskipt auðkenni, og auðkennið er það sem staðsetur þær í trénu, svo `personal` birtist á rótarvalmyndinni og `personal.notes` birtist inni í henni:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Ef þú endurnýtir fyrirliggjandi auðkenni yfirskrifar þú þá röð í stað þess að bæta við nýrri. Skráin fylgir með öll tiltæk svið skjalfest sem athugasemdir.

### Að bæta við þínum eigin skeljarútflutningum, föllum og samheitum

Omarchy fylgir með fullt af þægilegum samheitum og hjálplegum föllum, en það er mjög algengt að vilja bæta við sínum eigin. Þú ættir að bæta bæði samheitum, föllum og útflutningum við í `~/.bashrc`. Þessi skrá verður ekki yfirskrifuð við uppfærslur. Ef þú vilt breyta einhverjum af sjálfgefnum stillingum Omarchy getur þú líka bætt þeim við hér á öruggan hátt.

### Að stilla umhverfisbreytur fyrir skjáborðið

Útflutningar fyrir skjáborðslotu eiga heima í `~/.config/uwsm/env.d/`. Þessar skrár keyra áður en skjáborðið þitt ræsist, svo villa í skel getur sent þig aftur á innskráningarskjáinn. Haltu virkri útstöð opinni á meðan þú breytir þeim. Til að slökkva á yfirskrift skaltu færa hana úr `env.d`. Sjá [endurheimt innskráningar](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) ef breyting kemur í veg fyrir innskráningu.

### Að breyta innri Omarchy-skrám

Hlustaðu, þetta er þín tölva. Þú getur gert hvað sem þú vilt við hana, en ég myndi ráða frá því að breyta skránum í `/usr/share/omarchy` beint. Þær tilheyra Omarchy pacman-pakkanum, svo breytingar þínar verða einfaldlega yfirskrifaðar við næstu uppfærslu. Betra er að yfirskrifa bara öll sjálfgefnu gildi sem þér líkar ekki í `~/.config/*` möppunni í staðinn.

Þú getur breytt nánast öllu á þann hátt, eins og sjálfgefnum lyklabindingum. Breyttu bara `~/.config/hypr/bindings.lua` til að, segjum, skipta út [Obsidian](https://obsidian.md/) fyrir [Joplin](https://joplinapp.org/) (settu upp með `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` fjarlægir fyrirliggjandi bindingu áður en það bætir við staðgenglinum hennar. Það tekur sömu röksemdir og `o.bind`, þar á meðal ræsihjálpartól og valkosti fyrir bindingar. Notaðu `o.bind` til að bæta við bindingu, eða `hl.unbind` til að fjarlægja eina án þess að skipta henni út.

Ef þú stendur fast á því að hakka í innri Omarchy-skrárnar skaltu skipta yfir á dev-rásina í gegnum _Uppfærsla > Rás > Dev_. Það tengir Omarchy við git-útgáfu af frumkóðanum í `~/omarchy`, sem þér er frjálst að breyta eins og þér sýnist. Það er enginn hér sem ætlar að segja þér hvað þú átt að gera!

### Að endurstilla allar breytingar

Ef þú endar með að klúðra stillingunum getur þú alltaf fært þær aftur í sjálfgefnar stillingar í gegnum _Uppfærsla > Stillingar_ í Omarchy-valmyndinni. Eða með því að keyra `omarchy reinstall configs` til að endurstilla allt.
