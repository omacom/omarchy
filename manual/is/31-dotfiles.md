# Dotfiles

Omarchy er aðallega stillt í gegnum svokallaðar dotfiles-skrár sem búa í `~/.config`. Þær teljast þínar skrár fyrir þínar breytingar. Skrárnar sem búa í `/usr/share/omarchy` tilheyra Omarchy sjálfu og þú ættir ekki að vera að fikta í þeim. Ef þú þarft að breyta einhverju í `/usr/share/omarchy` ættir þú í staðinn að yfirskrifa gildið í `~/.config`.

Lykilstillingarnar er hægt að breyta beint úr Omarchy-valmyndinni (`Super + Space`), eins og _Setup > Keyboard > Keybindings_, _Setup > Input_ og _Setup > Config > [file]_. Þegar þú gerir það þannig verður hvert ferli sem þarf að endurræsa eftir breytingar á stillingum sjálfkrafa endurræst eftir að þú hættir í ritlinum (Neovim sjálfgefið — `:wq`, mundu það! — en þú getur breytt því í gegnum _Setup > Defaults > Editor_).

Hér er listi yfir lykilskrárnar í `~/.config` og hvað þær stjórna:

| Skrá                  | Tilgangur              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Aðalstillingaskrá Hyprland. Hleður inn sjálfgefnum stillingum Omarchy auk yfirskrifskránna þinna hér að neðan. [Frekari upplýsingar um Hyprland-stillingar](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Þínar eigin lyklabindingar og yfirskrif á sjálfgefnum gildum. |
| `~/.config/hypr/monitors.lua` | Skjástillingar sem skjáspjaldið nær ekki yfir, eins og snúningur, aukahamir eða að halda skjá slökktum. |
| `~/.config/hypr/input.lua` | Stjórnar lyklaborðsuppsetningu þinni, mús og snertifleti. |
| `~/.config/hypr/looknfeel.lua` | Stjórnar bilum, römmum, hreyfimyndum og öðru útliti. |
| `~/.config/hypr/autostart.lua` | Stjórnar aukaförlum sem ræst eru með setunni. |
| `~/.config/omarchy/shell.json` | Stjórnar Omarchy-skelinni: staðsetningu stikunnar, uppsetningu og viðmótshlutum, auk tímasetninga fyrir skjávörn, læsingu og aðgerðaleysi. |
| `~/.config/foot/foot.ini` | Stjórnar útstöðinni þinni (foot er sjálfgefið). |
| `~/.XCompose` | Skilgreinir flýtíaðgang þinn að emoji-táknum og sjálfvirka útfyllingu á nafni/netfangi. Vertu viss um að keyra `omarchy-restart-xcompose` eftir að þú gerir breytingar. |

Ef þú endar á að gera margar breytingar til að fínstilla þína eigin uppsetningu er góð hugmynd að taka afrit af öllum þessum dotfiles-skrám. [Stow er frábær leið til þess](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Að ræsa þín eigin forrit með setunni

Ef þú vilt að eitthvað keyri í hvert sinn sem þú skráir þig inn — samstillingarþjónn, spjallforrit, þitt eigið forskrift — settu það í `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Það ræsir skipunina sem hluta af setunni, þannig að rétt er hreinsað til þegar þú skráir þig út aftur.

### Að keyra forskriftir við kerfisatburði

Omarchy kveikir á krókum á nokkrum augnablikum og þú getur hengt þínar eigin forskriftir á þá. Þeir búa í `~/.config/omarchy/hooks/<event>.d/`, ein mappa fyrir hvern atburð, og hver keyranleg skrá þar inni keyrir þegar atburðurinn á sér stað:

| Atburður | Hvenær hann keyrir |
| ----- | ------------ |
| `post-boot` | Strax eftir að skjáborðið hefur ræst |
| `post-update` | Undir lok `omarchy update`, eftir pakka, færslur og endurræsingar á þjónustum, áður en mise-tól eru uppfærð |
| `pre-refresh-pacman` | Eftir að `omarchy refresh pacman` endursamstillir pakkastillingarnar, áður en það uppfærir pakka; rásaskipti keyra hann í sama endurnýjunarskrefi |
| `theme-set` | Eftir þemabreytingu (nafn þemans í `$1`) |
| `font-set` | Eftir leturbreytingu (nafn letursins í `$1`) |
| `battery-low` | Þegar rafhlaðan verður lág (prósenta í `$1`) |

`pre-refresh-pacman`-krókurinn er þar sem sérsniðnar pakkageymslur eða `IgnorePkg`-línur eiga heima, þar sem hann keyrir fyrir pakkafærsluna. Báðir uppfærslutengdu krókarnir keyra sem notandinn þinn eftir að Omarchy hreinsar vistaða sudo-heimild sína, þannig að krókur sem notar `sudo` þarf sína eigin heimild og gæti beðið þig um lykilorðið þitt.

Hver þessara mappa geymir þegar `.sample`-skrá sem sýnir snið króks — fjarlægðu `.sample` úr nafninu til að taka hann í notkun. Til að setja upp forskrift sem þú hefur skrifað annars staðar skaltu nota `omarchy hook install post-boot ~/my-hook`, sem afritar hana inn og gerir hana keyranlega.

### Að bæta við þínum eigin valmyndarfærslum

Hægt er að útvíkka Omarchy-valmyndina (`Super + Space`) með þínum eigin röðum með því að breyta `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Færslur eru lyklaðar með punktakenndum auðkennum og auðkennið er það sem setur þær í tréð, þannig að `personal` birtist í rótarvalmyndinni og `personal.notes` birtist inni í henni:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Endurtaktu fyrirliggjandi auðkenni og þú yfirskrifar þá röð í stað þess að bæta við nýrri. Skráin fylgir með öll tiltæk svæði skjalfest sem athugasemdir.

### Að bæta við þínum eigin útflutningum, föllum og samheitum í skelinni

Omarchy fylgir fullt af þægilegum samheitum og gagnlegum föllum, en það er mjög algengt að vilja bæta við sínum eigin. Þú ættir að bæta bæði samheitum, föllum og útflutningum við í `~/.bashrc`. Þessi skrá verður ekki yfirskrifuð við uppfærslur. Ef þú vilt breyta einhverjum sjálfgefnum gildum Omarchy geturðu líka örugglega bætt þeim við hér.

### Að stilla umhverfisbreytur fyrir skjáborðið

Útflutningar fyrir skjáborðssetuna eiga heima í `~/.config/uwsm/env.d/`. Þessar skrár keyra áður en skjáborðið þitt ræsist, þannig að villa í skelinni getur sent þig aftur á innskráningarskjáinn. Hafðu virka útstöð opna á meðan þú breytir þeim. Til að slökkva á yfirskrifi skaltu færa það út úr `env.d`. Sjá [endurheimt innskráningar](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) ef breyting kemur í veg fyrir innskráningu.

### Að breyta innri skrám Omarchy

Heyrðu, þetta er þín tölva. Þú getur gert hvað sem þú vilt við hana, en ég myndi ráðleggja gegn því að gera breytingar beint á skrárnar í `/usr/share/omarchy`. Þær tilheyra Omarchy pacman-pakkanum, þannig að breytingarnar þínar verða einfaldlega yfirskrifaðar við næstu uppfærslu. Þér er betra að yfirskrifa bara öll sjálfgefin gildi sem þér líkar ekki í `~/.config/*`-möppunni í staðinn.

Þú getur breytt nánast öllu þannig, eins og sjálfgefnum lyklabindingum. Breyttu bara `~/.config/hypr/bindings.lua` til að, segjum, skipta út [Obsidian](https://obsidian.md/) fyrir [Joplin](https://joplinapp.org/) (settu upp með `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` fjarlægir fyrirliggjandi bindingu áður en það bætir við staðgenglinum. Það tekur sömu viðföng og `o.bind`, þar á meðal ræsihjálparföll og valkosti fyrir bindingar. Notaðu `o.bind` til að bæta við bindingu, eða `hl.unbind` til að fjarlægja eina án þess að skipta henni út.

Ef þú stendur fast á því að fikta í innri skrám Omarchy skaltu skipta yfir á dev-rásina í gegnum _Update > Channel > Dev_. Það tengir Omarchy við git-úttekt á frumkóðanum í `~/omarchy`, sem þér er frjálst að breyta eftir hjartans lyst. Enginn hér ætlar að segja þér fyrir verkum!

### Að endurstilla allar breytingar

Ef þú endar á að klúðra stillingunum geturðu alltaf fært þær aftur í sjálfgefin gildi í gegnum _Update > Config_ í Omarchy-valmyndinni. Eða með því að keyra `omarchy reinstall configs` til að endurstilla allt.
