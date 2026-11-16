# Izrada vlastite teme

Vlastite teme možete dodati u `~/.config/omarchy/themes`. Samo kopirajte jednu od postojećih kao osnovu (pogledajte u `/usr/share/omarchy/themes`), pa je prilagodite po želji. Sve dok je vaša tema u toj mapi, bit će uključena u izbornik za odabir teme.

Glavna datoteka koju morate prilagoditi jest `colors.toml`. Ona definira skup boja koji se zatim koristi za generiranje konfiguracija za terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian i cijelu Omarchy ljusku (gornju traku, izbornik, obavijesti, OSD i zaključani zaslon).

Novu temu možete izraditi i pomoću priložene aplikacije Aether, kroz lijepo GUI sučelje za igranje bojama i pretraživanje pozadina. Samo je pokrenite iz mreže aplikacija pomoću `Super + Alt + Space`.

### Što instalirana tema smije sadržavati

Tema koju sami napišete u `~/.config/omarchy/themes` smije sadržavati što god želite — to je vaš stroj i vaša datoteka, a Omarchy primjenjuje sve to.

Tema koju instalirate iz tuđeg repozitorija pomoću `omarchy theme install` zadržava sve što je boja, a gubi onih nekoliko datoteka koje bi pokretale kod na vašem stroju: svaku `.lua` datoteku, konfiguracije terminala (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) i `vscode.json`. `hyprland.lua` neke teme jest Lua koju vaš kompozitor pokreće pri prijavi, konfiguracija terminala imenuje program koji vaš terminal pokreće, a `vscode.json` imenuje VSCode proširenje koje treba instalirati. Instaliranje nečije teme smije promijeniti kako vaša radna površina izgleda, nikad što ona pokreće.

Sve ostalo i dalje radi točno onako kako je autor teme napisao — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, pozadine i pregledi — sve se zadržava. Samo ono što je odbačeno ponovno se generira iz `colors.toml` na vašem stroju.

Omarchy to dvoje razlikuje po tome ima li tema vlastiti git repozitorij u sebi, što je ono što `omarchy theme install` ostavlja iza sebe kad klonira. Tako tema koju ste napisali ostaje vaša, a ona koju ste povukli s interneta ostaje samo bojama.

### Svijetli način rada

Ako radite temu sa svijetlim načinom rada, postavite `mode = "light"` na vrh svoje datoteke `colors.toml`. Tada će se automatski upariti sa svijetlim načinom rada za sve aplikacije. (Stari način, ubacivanje prazne datoteke pod nazivom `light.mode` u korijen vaše teme, također i dalje radi.)

### Slika za otključavanje

Teme isporučene sa slikama `unlock.png` i `preview-unlock.png` bit će navedene pod _Izgled > Otključavanje_. Vaš `unlock.png` po mogućnosti bi trebao biti prozirni png. A sliku za pregled možete izraditi pomoću `omarchy plymouth preview`.

### Primjena teme na aplikacije koje Omarchy ne pokriva

Ako koristite aplikaciju koja nije na tom popisu, Omarchy možete sami naučiti da joj primijeni temu pomoću predloška. Ubacite datoteku u `~/.config/omarchy/themed/` nazvanu prema konfiguraciji koju generira plus ekstenzija `.tpl` i napišite konfiguraciju s `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` do `{{ color15 }}` i ostatkom palete kao zamjenskim oznakama. Svaki put kad promijenite temu, datoteka se ponovno generira s bojama te teme.

U toj mapi postoji potpuno komentirana datoteka `alacritty.toml.tpl.sample` koju možete kopirati — navodi svaku varijablu koju možete upotrijebiti, plus modifikatore `_strip` i `_rgb` za aplikacije koje žele svoje boje bez znaka `#` ili kao decimalni RGB. Vaši predlošci imaju prednost pred Omarchyjevima, pa ovo možete upotrijebiti i za nadjačavanje načina na koji se tema primjenjuje na ugrađenu aplikaciju.

### Distribucija vaše teme

Ako želite distribuirati svoju temu da je i drugi mogu koristiti, morate je postaviti na javni git poslužitelj, poput GitHuba. Tada je ljudi mogu instalirati pomoću _Instaliraj > Stil > Tema_ u Omarchy izborniku koristeći taj URL. Preporučuje se da slijedite konvenciju imenovanja `omarchy-[themename]-theme`, jer će se tema nakon instalacije u izborniku za odabir teme ispravno prikazivati samo kao `[themename]`.

Taj preostali `[themename]` postaje naziv direktorija teme, pa mora biti onaj kojim Omarchy može sigurno rukovati: mora počinjati slovom, znamenkom ili donjom crtom, a ostatak smije sadržavati slova, znamenke, `.`, `_`, `+` i `-`. Velika slova pretvaraju se u mala umjesto vas, ali sve ostalo — razmak, navodnik, znak koji nije engleski — odbija se u trenutku instalacije umjesto da se pretvori u naziv direktorija. Tako se `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` i `omarchy-c++-theme` sve instaliraju bez problema.

Imajte na umu da se nakon instalacije iz repozitorija odbacuje svaka `.lua` datoteka, konfiguracija terminala ili `vscode.json` koju tema isporučuje, pa nemojte temu graditi oko njih.

Vašu temu možete dodati na [stranicu s dodatnim temama](https://omarchy.org/themes/) slanjem pull requesta u [repozitorij omarchy-site](https://github.com/omacom-io/omarchy-site).
