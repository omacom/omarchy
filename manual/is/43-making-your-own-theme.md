# Að búa til þitt eigið þema

Þú getur bætt þínum eigin þemum við `~/.config/omarchy/themes`. Afritaðu bara eitt af þeim sem fyrir eru sem grunn (þau eru í `/usr/share/omarchy/themes`), og stilltu síðan eftir þínu höfði. Svo lengi sem þemað þitt er inni í þeirri möppu verður það með í valmyndinni fyrir þemu.

Aðalskráin sem þú þarft að stilla er `colors.toml`. Hún skilgreinir litasettið sem síðan er notað til að búa til stillingar fyrir terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt apps, baklýsingu lyklaborðsins, innsláttaraðferðina, valgluggann fyrir skjádeilingu, tákn forrita, nokkur gervigreindartól (Claude, Pi, Hermes, T3 Code, Herdr), og alla Omarchy-skelina (efstu stikuna, valmyndina, tilkynningar, OSD og læsiskjáinn).

Þú getur líka notað meðfylgjandi Aether-forritið til að búa til nýtt þema með fallegu GUI-viðmóti til að leika þér með liti og leita að bakgrunnum. Ræstu það bara úr forritayfirlitinu með `Super + Alt + Space`.

### Það sem uppsett þema getur innihaldið

Þema sem þú skrifar sjálfur í `~/.config/omarchy/themes` getur innihaldið hvað sem þú vilt — þetta er þín vél og þín skrá, og Omarchy notar allt saman.

Þema sem þú setur upp úr repo einhvers annars með `omarchy theme install` heldur öllu sem er litur, og missir þær fáu skrár sem myndu keyra kóða á vélinni þinni: allar `.lua`-skrár, terminal-stillingarnar (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), og `vscode.json`. `hyprland.lua` þema er Lua sem samsetningarforritið þitt keyrir við innskráningu, terminal-stilling nefnir forritið sem terminalinn þinn ræsir, og `vscode.json` nefnir VSCode-viðbót sem á að setja upp. Að setja upp þema einhvers annars á að breyta því hvernig skjáborðið þitt lítur út, aldrei því hvað það keyrir.

Allt annað virkar áfram nákvæmlega eins og höfundur þemans skrifaði það — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, bakgrunnarnir og forskoðanirnar haldast öll. Aðeins það sem var fellt út er endurgert úr `colors.toml` á vélinni þinni.

Omarchy greinir þetta tvennt í sundur eftir því hvort þemað hefur sitt eigið git-repo inni í sér, sem er það sem `omarchy theme install` skilur eftir sig þegar það klónar. Þannig að þema sem þú skrifaðir helst þitt, og þema sem þú sóttir af internetinu helst litir.

### Ljós stilling

Ef þú ert að búa til þema með ljósri stillingu skaltu setja `mode = "light"` efst í `colors.toml` þinn. Þá verður það sjálfkrafa parað við ljósa stillingu fyrir öll forritin. (Gamla aðferðin, að sleppa tómri skrá sem heitir `light.mode` í rót þemans þíns, virkar líka enn.)

### Mynd fyrir aflæsingu

Þemu sem fylgja `unlock.png` og `preview-unlock.png` myndir verða skráð undir _Appearance > Unlock_. `unlock.png` þín ætti helst að vera gegnsæ png. Og þú getur búið til forskoðanarmyndina með `omarchy plymouth preview`.

### Að setja þema á forrit sem Omarchy nær ekki yfir

Ef þú notar forrit sem er ekki á þeim lista geturðu kennt Omarchy að setja þema á það sjálfur með sniðmáti. Slepptu skrá í `~/.config/omarchy/themed/` sem heitir eftir stillingunni sem hún býr til auk `.tpl`-endingar, og skrifaðu stillinguna með `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` til `{{ color15 }}`, og restinni af litavalinu sem staðgenglum. Í hvert skipti sem þú skiptir um þema er skráin endurgerð með litum þess þema.

Það er fullkomlega útskýrð `alacritty.toml.tpl.sample` í þeirri möppu til að afrita úr — hún listar allar breytur sem þú getur notað, auk `_strip` og `_rgb` breytanna fyrir forrit sem vilja liti sína án `#` eða sem tugabrota RGB. Sniðmátin þín hafa forgang fram yfir þau sem Omarchy hefur sjálft, svo þú getur líka notað þetta til að hnekkja því hvernig innbyggt forrit fær þema.

### Að dreifa þemanu þínu

Ef þú vilt dreifa þemanu þínu svo aðrir geti notað það þarftu að setja það á opinberan git-þjón, eins og GitHub. Þá getur fólk sett það upp með _Install > Style > Theme_ í Omarchy-valmyndinni með því URL-i. Mælt er með að þú fylgir nafnakerfinu `omarchy-[themename]-theme`, þar sem þemað mun birtast rétt sem bara `[themename]` í valmyndinni fyrir þemu eftir uppsetningu.

Sá `[themename]` sem eftir stendur verður möppuheiti þemans, svo það verður að vera eitt sem Omarchy getur fært á milli á öruggan hátt: það verður að byrja á bókstaf, tölustaf eða undirstriki, og restin má innihalda bókstafi, tölustafi, `.`, `_`, `+` og `-`. Hástafir eru lækkaðir í lágstafi fyrir þig, en öllu öðru — bili, gæsalöpp, staf sem er ekki enskur — er hafnað við uppsetningu frekar en að því sé breytt í möppuheiti. Þannig að `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` og `omarchy-c++-theme` setjast öll upp án vandræða.

Mundu að um leið og það er sett upp úr repo er öllum `.lua`, terminal-stillingum eða `vscode.json` sem það sendir með fellt út, svo ekki byggja þemað í kringum þau.

Þú getur látið bæta þemanu þínu við [síðuna með aukaþemum](https://omarchy.org/themes/) með því að senda pull request til [omarchy-site repoisins](https://github.com/omacom-io/omarchy-site).
