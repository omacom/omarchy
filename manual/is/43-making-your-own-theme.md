# Að búa til þitt eigið þema

Þú getur bætt þínum eigin þemum við `~/.config/omarchy/themes`. Afritaðu bara eitt af þeim sem fyrir eru sem grunn (þú finnur þau í `/usr/share/omarchy/themes`) og stilltu það svo eftir þínum óskum. Svo lengi sem þemað þitt er inni í þeirri möppu verður það með í valmyndinni fyrir þemu.

Aðalskráin sem þú þarft að stilla er `colors.toml`. Hún skilgreinir litasettið sem síðan er notað til að búa til stillingar fyrir skjáherminn (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian og alla Omarchy-skelina (efstu stikuna, valmyndina, tilkynningar, OSD og læsiskjáinn).

Þú getur líka notað innifalda forritið Aether til að búa til nýtt þema með yndislegu GUI-viðmóti til að leika þér með liti og leita að bakgrunnsmyndum. Ræstu það bara úr forritayfirlitinu með `Super + Alt + Space`.

### Hvað uppsett þema getur innihaldið

Þema sem þú skrifar sjálfur í `~/.config/omarchy/themes` getur innihaldið hvað sem þú vilt — þetta er þín vél og þín skrá, og Omarchy notar allt saman.

Þema sem þú setur upp úr repo einhvers annars með `omarchy theme install` heldur öllu sem er litur, en missir þær fáu skrár sem myndu keyra kóða á vélinni þinni: allar `.lua`-skrár, stillingar skjáhermis (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) og `vscode.json`. `hyprland.lua` þema er Lua sem samsettirinn þinn keyrir við innskráningu, stilling skjáhermis nefnir forritið sem skjáhermirinn þinn ræsir og `vscode.json` nefnir VSCode-viðbót sem á að setja upp. Að setja upp þema einhvers ætti að breyta því hvernig skjáborðið þitt lítur út, aldrei því hvað það keyrir.

Allt annað virkar áfram nákvæmlega eins og höfundur þemans skrifaði það — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, bakgrunnsmyndirnar og forskoðanirnar haldast allar. Aðeins það sem var fjarlægt er endurgert úr `colors.toml` á vélinni þinni.

Omarchy greinir þetta tvennt í sundur eftir því hvort þemað hefur sitt eigið git-repo inni í sér, sem er það sem `omarchy theme install` skilur eftir sig þegar það klónar. Þannig helst þema sem þú skrifaðir þitt, og þema sem þú sóttir af internetinu helst litir.

### Ljós stilling

Ef þú ert að búa til þema með ljósri stillingu skaltu setja `mode = "light"` efst í `colors.toml` þína. Þá verður það sjálfkrafa parað við ljósa stillingu fyrir öll forritin. (Gamla aðferðin, að skilja eftir tóma skrá sem heitir `light.mode` í rót þemans þíns, virkar líka enn.)

### Litir táknmynda

Ef þú vilt láta táknmyndir skráastjórans passa við litina í þemanu þínu skaltu bæta við skrá sem heitir `icons.theme` með heiti táknmyndasettsins sem þú vilt nota. Sjálfgefið eru valkostirnir: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Mynd fyrir aflæsingu

Þemu sem fylgja `unlock.png` og `preview-unlock.png` myndir verða skráð undir _Útlit > Aflæsing_. `unlock.png` þín ætti helst að vera gegnsæ png-mynd. Og þú getur búið til forskoðunarmyndina með `omarchy plymouth preview`.

### Að þema forrit sem Omarchy nær ekki til

Ef þú notar forrit sem er ekki á þeim lista geturðu kennt Omarchy að þema það sjálfur með sniðmáti. Settu skrá í `~/.config/omarchy/themed/` sem er nefnd eftir stillingunni sem hún býr til, auk endingarinnar `.tpl`, og skrifaðu stillinguna með `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` til `{{ color15 }}` og restinni af litapallettunni sem staðgenglum. Í hvert skipti sem þú skiptir um þema er skráin endurgerð með litum þess þema.

Það er ítarlega útskýrð `alacritty.toml.tpl.sample` í þeirri möppu til að afrita úr — hún telur upp allar breytur sem þú getur notað, auk breytivísanna `_strip` og `_rgb` fyrir forrit sem vilja litina sína án `#` eða sem aukastafatölur fyrir RGB. Sniðmátin þín hafa forgang fram yfir þau sem Omarchy á sjálft, svo þú getur líka notað þetta til að hnekkja því hvernig innbyggt forrit er þemað.

### Að dreifa þemanu þínu

Ef þú vilt dreifa þemanu þínu svo aðrir geti notað það þarftu að setja það á opinberan git-þjón, eins og GitHub. Þá geta aðrir sett það upp í gegnum _Setja upp > Stíll > Þema_ í Omarchy-valmyndinni með því að nota þá URL-slóð. Mælt er með að þú fylgir nafnakerfinu `omarchy-[themename]-theme`, því þá birtist þemað rétt sem bara `[themename]` í valmyndinni fyrir þemu eftir uppsetningu.

Þetta eftirstandandi `[themename]` verður heiti möppunnar fyrir þemað, svo það verður að vera eitthvað sem Omarchy getur meðhöndlað á öruggan hátt: það verður að byrja á bókstaf, tölustaf eða undirstriki, og restin má innihalda bókstafi, tölustafi, `.`, `_`, `+` og `-`. Hástafir eru lágstafaðir fyrir þig, en allt annað — bil, gæsalöpp, stafur sem er ekki enskur — er hafnað við uppsetningu í stað þess að vera breytt í möppuheiti. Þannig að `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` og `omarchy-c++-theme` setjast öll upp án vandræða.

Mundu að þegar það hefur verið sett upp úr repo er öllum `.lua`-skrám, stillingum skjáhermis eða `vscode.json` sem því fylgja fleygt, svo ekki byggja þemað í kringum þær.

Þú getur fengið þemað þitt bætt við [síðuna með aukaþemum](https://omarchy.org/themes/) með því að senda pull request í [omarchy-site repo-ið](https://github.com/omacom-io/omarchy-site).
