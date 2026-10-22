# Dotfiles

Omarchy er aðallega stillt í gegnum svokölluð dotfiles sem búa í `~/.config`. Þau teljast þinar skrár fyrir þínar breytingar. Skrárnar sem búa í `/usr/share/omarchy` tilheyra Omarchy sjálfu, og þú ættir ekki að vera að fikta í þeim. Ef þú þarft að breyta nokkru í `/usr/share/omarchy` ættir þú að yfirskrifa gildið í `~/.config` í staðinn.

Lykilstillingarnar er hægt að breyta beint úr Omarchy-valmyndinni (`Super + Space`), eins og _Uppsetning > Skjár_, _Uppsetning > Flýtilyklar_, _Uppsetning > Inntak_ og _Uppsetning > Stillingar > [file]_. Þegar þú gerir það með þessum hætti mun hvaða ferli sem þarf að endurræsa eftir stillingarbreytingar sjálfkrafa verða endurræst eftir að þú hættir í ritlinum (Neovim sjálfgefið — `:wq`, mundu! — en þú getur breytt því í gegnum _Uppsetning > Sjálfgildi > Ritill_).

Hér er listi yfir lykilskrárnar í `~/.config` og hvað þær stjórna:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Aðalstillingar Hyprland. Hleður sjálfgildum Omarchy auk yfirskrifunarskráa þinna hér að neðan. [Frekari upplýsingar um Hyprland-stillingar](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Þínir eigin flýtilyklar og yfirskrifanir á sjálfgildunum. |
| `~/.config/hypr/monitors.lua` | Stjórnar skjám þínum, upplausn og staðsetningu. |
| `~/.config/hypr/input.lua` | Stjórnar lyklaborðskipan þinni, mús og snertifleti. |
| `~/.config/hypr/looknfeel.lua` | Stjórnar bilum, römmum, hreyfingum og restinni af útlitinu. |
| `~/.config/hypr/autostart.lua` | Stjórnar aukaverkum sem ræst eru með lotunni. |
| `~/.config/omarchy/shell.json` | Stjórnar Omarchy-shellinu: stöðu stiku, uppsetningu og græjum, auk skjáverja, læsingar og óvirkni-tímastillinga. |
| `~/.config/foot/foot.ini` | Stjórnar terminalinu þínu (foot er sjálfgildið). |
| `~/.XCompose` | Skilgreinir hraðan aðgang þinn að emoji og sjálfvirkri útfyllingu nafns/netfangs. Gakktu úr skugga um að keyra `omarchy-restart-xcompose` eftir breytingar. |

Ef þú gerir mikið af breytingum til að fínstilla þína eigin uppsetningu er góð hugmynd að taka afrit af öllum þessum dotfiles. [Stow er frábær leið til að gera það](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Að ræsa þín eigin forrit með lotunni

Ef þú vilt að eitthvað keyri í hvert skipti sem þú skráir þig inn — samstillingarþjónn, spjallforrit, þín eigin skrifta — skaltu setja það í `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Það ræsir skipunina sem hluta af lotunni, þannig að það er hreinsað rétt upp þegar þú skráir þig út aftur.

### Að keyra skriftur við kerfisatburði

Omarchy kveikir á krókum á nokkrum augnablikum, og þú getur hengt þínar eigin skriftur á þá. Þær búa í `~/.config/omarchy/hooks/<event>.d/`, ein mappa fyrir hvern atburð, og hver keyranleg skrá þar inni keyrir þegar atburðurinn gerist:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Rétt eftir að skjáborðið hefur ræst |
| `post-update` | Undir lok `omarchy update`, eftir pakka, flutninga og endurræsingar þjónustu, áður en mise-tól eru uppfærð |
| `pre-refresh-pacman` | Eftir að `omarchy refresh pacman` endursamstillir pakkastillinguna, áður en það uppfærir pakka; rásaskipti keyra það í sama endurhleðsluþrepi |
| `theme-set` | Eftir þemabreytingu (þemanafn í `$1`) |
| `font-set` | Eftir leturbreytingu (letursnafn í `$1`) |
| `battery-low` | Þegar rafhlaðan verður lág (prósenta í `$1`) |

Krókurinn `pre-refresh-pacman` er þar sem sérsniðnar geymslur eða `IgnorePkg`-línur eiga heima, þar sem hann keyrir fyrir pakkafærsluna. Báðir uppfærslutengdu krökunum keyra sem notandi þinn eftir að Omarchy hreinsar vistuðu sudo-heimild sína, þannig að krókur sem notar `sudo` þarf sína eigin heimild og gæti beðið um lykilorðið þitt.

Hvor þessara mappa inniheldur þegar `.sample`-skrá sem sýnir form króks — slepptu `.sample` af nafninu til að koma honum í vinnu. Til að setja upp skriftu sem þú hefur skrifað annars staðar skaltu nota `omarchy hook install post-boot ~/my-hook`, sem afritar hana inn og gerir hana keyranlega.

### Að bæta við þínum eigin valmyndarfærslum

Omarchy-valmyndina (`Super + Space`) er hægt að útvíkka með þínum eigin röðum með því að breyta `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Færslur eru lyklaðar með punktakenni, og kennið er það sem setur þær í tréð, þannig að `personal` birtist í rótarvalmyndinni og `personal.notes` birtist inni í henni:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Endurnotaðu núverandi kenni og þú yfirskrifar þá röð í stað þess að bæta við nýrri. Skráin kemur með öllum tiltækum reitum skráðum sem athugasemdir.

### Að bæta við þínum eigin shell-útflutningum, föllum og aliasum

Omarchy kemur með fullt af þægilegum aliasum og gagnlegum föllum, en það er mjög algengt að vilja bæta við sínum eigin. Þú ættir að bæta bæði aliasum, föllum og útflutningum við í `~/.bashrc`. Þessi skrá mun ekki verða yfirskrifuð við uppfærslur. Ef þú vilt breyta einhverjum af sjálfgildum Omarchy geturðu líka bætt þeim örugglega við hér.

### Að breyta innri Omarchy-skrám

Heyrðu, þetta er þín tölva. Þú getur gert það sem þú vilt við hana, en ég myndi ráðleggja gegn því að gera breytingar á skránum í `/usr/share/omarchy` beint. Þær tilheyra Omarchy pacman-pakkanum, þannig að breytingarnar þínar verða einfaldlega yfirskrifaðar við næstu uppfærslu. Þú ert betur settur með því að yfirskrifa bara öll sjálfgefnu gildi sem þér líkar ekki í möppunni `~/.config/*` í staðinn.

Þú getur breytt nánast öllu með þeim hætti, eins og sjálfgefnu flýtilyklunum. Breyttu bara `~/.config/hypr/bindings.lua` til að, segjum, skipta út [Obsidian](https://obsidian.md/) fyrir [Joplin](https://joplinapp.org/) (settu upp með `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` fjarlægir núverandi bindingu áður en það bætir við staðgengli sínum. Það tekur sömu viðföng og `o.bind`, þar á meðal ræsingarhjálparföll og bindingarkosti. Notaðu `o.bind` til að bæta við bindingu, eða `hl.unbind` til að fjarlægja eina án þess að skipta henni út.

Ef þú krefst þess að hakka í innri Omarchy-skrárnar skaltu skipta yfir á dev-rásina í gegnum _Uppfæra > Rás > Dev_. Það tengir Omarchy við git-afrit af frumkóðanum í `~/omarchy`, sem þú mátt breyta að vild. Það er enginn hér til að segja þér hvað þú átt að gera!

### Að endurstilla allar breytingar

Ef þú endar á að gera stillingarnar að drasli geturðu alltaf snúið þeim aftur í sjálfgildi í gegnum _Uppfæra > Stillingar_ í Omarchy-valmyndinni. Eða með því að keyra `omarchy reinstall configs` til að endurstilla allt.
