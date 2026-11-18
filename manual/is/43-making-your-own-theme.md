# Að búa til þitt eigið þema

Þú getur bætt þínum eigin þemum við í `~/.config/omarchy/themes`. Afritaðu bara eitt af þeim sem fyrir eru sem grunn (líttu í `/usr/share/omarchy/themes`) og lagaðu það síðan að vild. Svo lengi sem þemað þitt er inni í þeirri möppu verður það með í valmyndinni fyrir þemu.

Aðalskráin sem þú þarft að laga er `colors.toml`. Hún skilgreinir litasettið sem síðan er notað til að búa til stillingar fyrir útstöðina (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian og alla Omarchy-skelina (efstu stikuna, valmyndina, tilkynningar, OSD og læsiskjáinn).

Þú getur líka notað meðfylgjandi Aether-forritið til að búa til nýtt þema með fallegu GUI-viðmóti til að leika þér með liti og leita að bakgrunnum. Ræstu það bara úr forritayfirlitinu með `Super + Alt + Space`.

### Hvað uppsett þema getur innihaldið

Þema sem þú skrifar sjálfur í `~/.config/omarchy/themes` getur innihaldið hvað sem þú vilt — þetta er þín vél og þín skrá, og Omarchy notar allt saman.

Þema sem þú setur upp úr repo-i einhvers annars með `omarchy theme install` heldur öllu sem er litur og missir þann handfylli af skrám sem myndu keyra kóða á vélinni þinni: allar `.lua`-skrár, stillingar útstöðvarinnar (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) og `vscode.json`. `hyprland.lua` þema er Lua sem samsettirinn þinn keyrir við innskráningu, stilling útstöðvar nefnir forritið sem útstöðin þín ræsir og `vscode.json` nefnir VSCode-viðbót sem á að setja upp. Að setja upp þema einhvers ætti að breyta því hvernig skjáborðið þitt lítur út, aldrei því sem það keyrir.

Allt annað virkar áfram nákvæmlega eins og höfundur þemans skrifaði það — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, bakgrunnarnir og forskoðanirnar varðveitast öll. Aðeins það sem var fjarlægt er endurgert úr `colors.toml` á vélinni þinni.

Omarchy greinir þetta tvennt í sundur eftir því hvort þemað hefur sitt eigið git-repo inni í sér, sem er það sem `omarchy theme install` skilur eftir sig þegar það klónar. Svo þema sem þú skrifaðir helst þitt, og eitt sem þú sóttir af netinu helst litir.

### Ljós hamur

Ef þú ert að búa til þema í ljósum ham skaltu setja `mode = "light"` efst í `colors.toml` þinn. Þá verður það sjálfkrafa parað við ljósan ham fyrir öll forritin. (Gamla aðferðin, að setja tóma skrá sem heitir `light.mode` í rót þemans þíns, virkar líka enn.)

### Mynd fyrir aflæsingu

Þemu sem fylgja `unlock.png`- og `preview-unlock.png`-myndir verða skráð undir _Útlit > Aflæsa_. `unlock.png` þín ætti helst að vera gegnsæ png-mynd. Og þú getur búið til forskoðunarmyndina með `omarchy plymouth preview`.

### Að þemastilla forrit sem Omarchy nær ekki yfir

Ef þú notar forrit sem er ekki á þeim lista geturðu kennt Omarchy að þemastilla það sjálfur með sniðmáti. Settu skrá í `~/.config/omarchy/themed/` sem er nefnd eftir stillingunni sem hún býr til auk `.tpl`-endingar, og skrifaðu stillinguna með `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` til `{{ color15 }}` og restinni af litavalinu sem staðgenglum. Í hvert skipti sem þú skiptir um þema er skráin endurgerð með litum þess þema.

Þar í möppunni er fullkomlega útskýrð `alacritty.toml.tpl.sample` til að afrita úr — hún telur upp allar breytur sem þú getur notað, auk `_strip`- og `_rgb`-breytanna fyrir forrit sem vilja liti sína án `#` eða sem tugakerfis-RGB. Sniðmátin þín hafa forgang fram yfir þau sem Omarchy á sjálft, svo þú getur líka notað þetta til að hnekkja því hvernig innbyggt forrit er þemastillt.

### Að dreifa þemanu þínu

Ef þú vilt dreifa þemanu þínu svo aðrir geti notað það þarftu að setja það á opinberan git-þjón, eins og GitHub. Þá getur fólk sett það upp með _Setja upp > Stíll > Þema_ í Omarchy-valmyndinni með því að nota þá URL-slóð. Mælt er með því að þú fylgir nafnavenjunni `omarchy-[themename]-theme`, þar sem þemað mun þá birtast rétt sem bara `[themename]` í valmyndinni fyrir þemu eftir uppsetningu.

Sá hluti sem eftir stendur, `[themename]`, verður nafn möppunnar fyrir þemað, svo það þarf að vera nafn sem Omarchy getur meðhöndlað á öruggan hátt: það verður að byrja á bókstaf, tölustaf eða undirstriki, og restin má innihalda bókstafi, tölustafi, `.`, `_`, `+` og `-`. Hástöfum er breytt í lágstafi fyrir þig, en öllu öðru — bili, gæsalöpp, staf sem er ekki enskur — er hafnað við uppsetningu frekar en að því sé breytt í möppunafn. Svo `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` og `omarchy-c++-theme` setjast öll upp án vandræða.

Mundu að þegar það er sett upp úr repo-i er öllum `.lua`-skrám, stillingum útstöðvar eða `vscode.json` sem því fylgir sleppt, svo ekki byggja þemað í kringum þær.

Þú getur látið bæta þemanu þínu við á [síðuna með aukaþemum](https://omarchy.org/themes/) með því að senda pull request í [omarchy-site repo-ið](https://github.com/omacom-io/omarchy-site).
