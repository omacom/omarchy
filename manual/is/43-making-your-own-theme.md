# Að búa til þitt eigið þema

Þú getur bætt þínum eigin þemum við `~/.config/omarchy/themes`. Afritaðu bara eitt af þeim sem fyrir eru sem grunn (þau eru í `/usr/share/omarchy/themes`), breyttu því síðan eftir þínu höfði. Svo lengi sem þemað þitt er inni í þeirri möppu verður það með í valmynd þema.

Aðalskráin sem þú þarft að breyta er `colors.toml`. Hún skilgreinir litasettið sem síðan er notað til að búa til stillingar fyrir útstöðina (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt-forrit, baklýsingu lyklaborðsins, innsláttaraðferðina, veljarann fyrir skjádeilingu, tákn forrita, nokkur gervigreindartól (Claude, Pi, Hermes, T3 Code, Herdr) og alla Omarchy-skelina (efstu stikuna, valmyndina, tilkynningar, OSD og læsiskjáinn).

Þú getur líka notað meðfylgjandi Aether-forritið til að búa til nýtt þema með fallegu GUI-viðmóti til að leika þér með liti og leita að bakgrunnum. Ræstu það bara úr forritayfirlitinu með `Super + Alt + Space`.

### Hvað uppsett þema má innihalda

Þema sem þú skrifar sjálfur í `~/.config/omarchy/themes` getur innihaldið hvað sem þú vilt — þetta er þín vél og þín skrá, og Omarchy notar allt saman.

Þema sem þú setur upp úr safni einhvers annars með `omarchy theme install` heldur öllu sem er litur, og missir þær fáu skrár sem myndu keyra kóða á vélinni þinni: allar `.lua`-skrár, stillingar útstöðvar (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) og `vscode.json`. `hyprland.lua` þema er Lua sem gluggastjórinn þinn keyrir við innskráningu, stilling útstöðvar nefnir forritið sem útstöðin þín ræsir og `vscode.json` nefnir VSCode-viðbót sem á að setja upp. Að setja upp þema einhvers annars á að breyta því hvernig skjáborðið þitt lítur út, aldrei því hvað það keyrir.

Allt annað virkar áfram nákvæmlega eins og höfundur þemans skrifaði það — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, bakgrunnarnir og forskoðanirnar haldast öll. Aðeins það sem var fellt út er endurgert úr `colors.toml` á vélinni þinni.

Omarchy greinir þetta tvennt í sundur eftir því hvort þemað hefur sitt eigið git-safn inni í sér, sem er það sem `omarchy theme install` skilur eftir þegar það klónar. Svo þema sem þú skrifaðir helst þitt, og þema sem þú sóttir á internetinu helst litir.

### Ljós hamur

Ef þú ert að búa til þema í ljósum ham, settu `mode = "light"` efst í `colors.toml` þína. Þá verður það sjálfkrafa parað við ljósan ham fyrir öll forritin. (Gamla leiðin, að skilja eftir tóma skrá sem heitir `light.mode` í rót þemans þíns, virkar líka enn.)

### Ræsi- og innskráningarskjáir

Skjárinn sem biður um lykilorð drifsins við ræsingu, og innskráningarskjárinn, teikna Omarchy-merkið í `accent`-lit þemans þíns á `background` þess, með lykilorðareitinn í `foreground` þess og `red` fyrir rangt lykilorð. Það er ekkert auka sem þarf að fylgja með fyrir þá: Omarchy notar ekki lengur `unlock.png` eða `preview-unlock.png` þema. Á Apple Silicon Mac-tölvum heldur skjárinn fyrir lykilorð drifsins sjálfgefnu útliti Omarchy, sama hvaða þema er notað.

### Að þemabreyta forritum sem Omarchy nær ekki yfir

Ef þú notar forrit sem er ekki á þeim lista geturðu kennt Omarchy að þemabreyta því sjálfur með sniðmáti. Settu skrá í `~/.config/omarchy/themed/` sem er nefnd eftir stillingunni sem hún býr til auk endingarinnar `.tpl`, og skrifaðu stillinguna með `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` til `{{ color15 }}` og restinni af litapallettunni sem staðgenglum. Í hvert skipti sem þú skiptir um þema er skráin endurgerð með litum þess þema.

Það er að fullu útskýrð `alacritty.toml.tpl.sample` í þeirri möppu til að afrita — hún telur upp allar breytur sem þú getur notað, auk breytanna `_strip` og `_rgb` fyrir forrit sem vilja liti sína án `#` eða sem tugakerfis-RGB. Sniðmátin þín hafa forgang fram yfir þau sem fylgja Omarchy, svo þú getur líka notað þetta til að hnekkja því hvernig innbyggt forrit fær þema.

### Að dreifa þemanu þínu

Ef þú vilt dreifa þemanu þínu svo aðrir geti notað það þarftu að setja það á opinberan git-þjón, eins og GitHub. Þá geta aðrir sett það upp í gegnum _Install > Style > Theme_ í Omarchy-valmyndinni með því að nota þá slóð. Mælt er með að þú fylgir nafnavenjunni `omarchy-[themename]-theme`, því þemað mun þá birtast rétt sem bara `[themename]` í valmynd þema eftir uppsetningu.

Það sem eftir stendur, `[themename]`, verður nafn möppu þemans, svo það þarf að vera nafn sem Omarchy getur meðhöndlað á öruggan hátt: það verður að byrja á bókstaf, tölustaf eða undirstriki, og restin má innihalda bókstafi, tölustafi, `.`, `_`, `+` og `-`. Hástafir eru lágstafaðir fyrir þig, en allt annað — bil, gæsalöpp, stafur sem er ekki úr ensku — er hafnað við uppsetningu frekar en að verða að möppunafni. Svo `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` og `omarchy-c++-theme` setjast öll upp án vandræða.

Mundu að um leið og það er sett upp úr safni er öllum `.lua`-skrám, stillingum útstöðvar eða `vscode.json` sem það inniheldur fellt út, svo byggðu ekki þemað í kringum þær.

Þú getur látið bæta þemanu þínu við [síðuna með aukaþemum](https://omarchy.org/themes/) með því að senda pull request í [omarchy-site-safnið](https://github.com/omacom-io/omarchy-site).
