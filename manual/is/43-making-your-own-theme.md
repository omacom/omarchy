# Að búa til þitt eigið þema

Þú getur bætt þínum eigin þemum við í `~/.config/omarchy/themes`. Afritaðu bara eitt af núverandi þemum sem grunn (horfðu í `/usr/share/omarchy/themes`) og lagfærðu svo að vild þinni. Svo framarlega sem þemað þitt er inni í þeirri möppu verður það innifalið í þemavalsvalmyndinni.

Aðalskráin sem þú þarft að lagfæra er `colors.toml`. Hún skilgreinir litasettið sem er svo notað til að búa til stillingar fyrir terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian og alla Omarchy-skelina (valmyndastiku, valmynd, tilkynningar, OSD og læsiskjá).

Þú getur líka notað innifalið Aether-forrit til að búa til nýtt þema með yndislegu grafísku viðmóti til að leika þér með liti og leita að bakgrunnum. Ræstu það bara úr forritastikunni með `Super + Alt + Space`.

### Hvað uppsett þema getur innihaldið

Þema sem þú skrifar sjálfur í `~/.config/omarchy/themes` getur innihaldið hvað sem þér lystir — þetta er þín vél og þín skrá, og Omarchy beitir öllu.

Þema sem þú setur upp úr geymslu einhvers annars með `omarchy theme install` heldur öllu sem er litur og tapar þeim fáu skrám sem myndu keyra kóða á vélinni þinni: sérhver `.lua` skrá, terminal-stillingarnar (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) og `vscode.json`. `hyprland.lua` þema er Lua sem samsetjarinn þinn keyrir við innskráningu, terminal-stilling nefnir forritið sem terminal þinn ræsir, og `vscode.json` nefnir VSCode-viðbót til að setja upp. Að setja upp þema einhvers annars ætti að breyta því hvernig skjáborðið þitt lítur út, aldrei því hvað það keyrir.

Allt annað virkar enn nákvæmlega eins og höfundur þemans skrifaði það — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, bakgrunnarnir og forskoðanirnar eru öll geymd. Aðeins það sem var fellt út er endurgerð úr `colors.toml` á vélinni þinni.

Omarchy aðgreinir þau tvö eftir því hvort þemað hefur sína eigin git-geymslu inni í sér, sem er það sem `omarchy theme install` skilur eftir þegar það klónar. Svo þema sem þú skrifaðir helst þitt, og það sem þú drógst af internetinu helst litir.

### Ljós hamur

Ef þú ert að búa til ljóst þema skaltu stilla `mode = "light"` efst í `colors.toml` þinni. Þá verður það sjálfkrafa parað við ljósan ham fyrir öll forritin. (Gamla leiðin að setja tóma skrá sem heitir `light.mode` í rót þemans virkar líka enn.)

### Táknlitir

Ef þú vilt litasamræma tákn skráastjórans við þemað þitt skaltu bæta við skrá sem heitir `icons.theme` með nafni táknasetsins sem þú vilt nota. Sjálfgefið eru valkostirnir: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Aflæsingarmynd

Þemu sem fylgja `unlock.png` og `preview-unlock.png` myndir verða talin upp undir _Stíll > Opna_. `unlock.png` þín ætti helst að vera gagnsæ png. Og þú getur búið til forskoðunarmyndina með `omarchy plymouth preview`.

### Að þemaa forrit sem Omarchy nær ekki yfir

Ef þú notar forrit sem er ekki á þeim lista geturðu kennt Omarchy að þemaa það sjálfur með sniðmáti. Settu skrá í `~/.config/omarchy/themed/` nefnda eftir stillingunni sem hún býr til auk `.tpl` endingar, og skrifaðu stillinguna með `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` til `{{ color15 }}` og afgangi litaspjaldsins sem staðgenglum. Í hvert sinn sem þú skiptir um þemu er skráin endurgerð með litum þess þema.

Það er fullkomlega athugasemdaríkt `alacritty.toml.tpl.sample` í þeirri möppu til að afrita af — hún telur upp sérhverja breytu sem þú getur notað, auk `_strip` og `_rgb` breytileiðréttinganna fyrir forrit sem vilja liti sína án `#` eða sem tugabrots RGB. Sniðmát þín hafa forgang fram yfir Omarchy sjálfs, svo þú getur líka notað þetta til að yfirskrifa hvernig innbyggt forrit er þemaað.

### Að dreifa þemanu þínu

Ef þú vilt dreifa þemanu þínu svo aðrir geti notað það þarftu að setja það á opinberan git-þjón, eins og GitHub. Þá geta aðrir sett það upp með _Setja upp > Stíll > Þema_ í Omarchy-valmyndinni með þeirri slóð. Mælt er með að þú fylgir nefningarvenjunni `omarchy-[themename]-theme`, þar sem þemað birtist rétt sem bara `[themename]` í þemavalsvalmyndinni eftir uppsetningu.

Það sem stendur eftir, `[themename]`, verður möppunafn þemans, svo það þarf að vera eitt sem Omarchy getur afhent á öruggan hátt: það verður að byrja á staf, tölustaf eða undirstriki, og afgangurinn má innihalda stafi, tölustafi, `.`, `_`, `+` og `-`. Hástafir eru lækkaðir fyrir þig, en öllu öðru — bili, gæsalöppum, óenskum staf — er hafnað við uppsetningu frekar en að verða að möppunafni. Svo `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` og `omarchy-c++-theme` setjast öll upp fínt.

Mundu að þegar það er sett upp úr geymslu er sérhver `.lua`, terminal-stilling eða `vscode.json` sem það flytur með sér felld út, svo byggðu ekki þemað í kringum þau.

Þú getur fengið þemað þitt bætt við [aukaþemasíðuna](https://omarchy.org/themes/) með því að senda pull request í [omarchy-site geymsluna](https://github.com/omacom-io/omarchy-site).
