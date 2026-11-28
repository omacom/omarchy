# Izrada vlastite teme

Svoje teme možete dodati u `~/.config/omarchy/themes`. Samo kopirajte jednu od postojećih kao osnovu (pogledajte u `/usr/share/omarchy/themes`), pa je uredite po svom ukusu. Dok je god vaša tema unutar te mape, bit će uključena u izbornik za odabir tema.

Glavna datoteka koju morate urediti je `colors.toml`. Ona definira skup boja koji se zatim koristi za generiranje konfiguracija za terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt apps, pozadinsko osvjetljenje tipkovnice, način unosa, odabir dijeljenja zaslona, ikone aplikacija, nekoliko AI alata (Claude, Pi, Hermes, T3 Code, Herdr) i cijelu Omarchy ljusku (gornju traku, izbornik, obavijesti, OSD i zaključani zaslon).

Za izradu nove teme možete koristiti i priloženu aplikaciju Aether s ljupkim GUI sučeljem za igranje bojama i pretraživanje pozadina. Samo je pokrenite iz mreže aplikacija putem `Super + Alt + Space`.

### Što instalirana tema može sadržavati

Tema koju sami napišete u `~/.config/omarchy/themes` može sadržavati što god želite — to je vaš stroj i vaša datoteka, a Omarchy primjenjuje sve to.

Tema koju instalirate iz tuđeg repozitorija naredbom `omarchy theme install` zadržava sve što je boja i gubi nekolicinu datoteka koje bi pokretale kod na vašem stroju: svaku `.lua` datoteku, konfiguracije terminala (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) i `vscode.json`. `hyprland.lua` teme je Lua koju vaš kompozitor pokreće pri prijavi, konfiguracija terminala navodi program koji vaš terminal pokreće, a `vscode.json` navodi VSCode proširenje koje treba instalirati. Instaliranje tuđe teme trebalo bi promijeniti kako vaša radna površina izgleda, a nikada što se na njoj pokreće.

Sve ostalo i dalje radi točno onako kako je autor teme napisao — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, pozadine i pregledi svi se zadržavaju. Samo ono što je odbačeno ponovno se generira iz `colors.toml` na vašem stroju.

Omarchy razlikuje to dvoje prema tome ima li tema vlastiti git repozitorij unutar sebe, što je ono što `omarchy theme install` ostavlja za sobom kad klonira. Tako tema koju ste napisali ostaje vaša, a ona koju ste povukli s interneta ostaje samo boje.

### Svijetli način

Ako izrađujete temu sa svijetlim načinom, postavite `mode = "light"` na vrh svog `colors.toml`. Tada će se automatski upariti sa svijetlim načinom za sve aplikacije. (Stari način ispuštanja prazne datoteke nazvane `light.mode` u korijen vaše teme i dalje radi.)

### Slika za otključavanje

Teme isporučene sa slikama `unlock.png` i `preview-unlock.png` bit će navedene pod _Appearance > Unlock_. Vaš `unlock.png` po mogućnosti bi trebao biti prozirni png. A sliku za pregled možete izraditi pomoću `omarchy plymouth preview`.

### Tematiziranje aplikacija koje Omarchy ne pokriva

Ako koristite aplikaciju koja nije na tom popisu, Omarchy možete sami naučiti kako da je tematizira pomoću predloška. Ispustite datoteku u `~/.config/omarchy/themed/` nazvanu prema konfiguraciji koju generira plus ekstenziju `.tpl` i napišite konfiguraciju s `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` do `{{ color15 }}` i ostatkom palete kao rezerviranim mjestima. Svaki put kad promijenite temu, datoteka se ponovno generira bojama te teme.

U toj mapi nalazi se potpuno komentirana datoteka `alacritty.toml.tpl.sample` koju možete kopirati — navodi svaku varijablu koju možete koristiti, plus modifikatore `_strip` i `_rgb` za aplikacije koje žele svoje boje bez `#` ili kao decimalni RGB. Vaši predlošci imaju prednost nad Omarchyjevim vlastitim, pa ovo možete koristiti i za nadjačavanje načina na koji se tematizira ugrađena aplikacija.

### Distribucija vaše teme

Ako želite distribuirati svoju temu kako bi je drugi mogli koristiti, morate je postaviti na javni git poslužitelj, poput GitHub. Zatim je ljudi mogu instalirati pomoću _Install > Style > Theme_ u Omarchy izborniku koristeći taj URL. Preporučuje se da slijedite konvenciju imenovanja `omarchy-[themename]-theme`, jer će se tema nakon instalacije u izborniku za odabir tema ispravno prikazati samo kao `[themename]`.

Taj preostali `[themename]` postaje naziv direktorija teme, pa mora biti onaj koji Omarchy može sigurno prenositi: mora započeti slovom, znamenkom ili donjom crtom, a ostatak može sadržavati slova, znamenke, `.`, `_`, `+` i `-`. Velika slova pretvaraju se u mala za vas, ali sve ostalo — razmak, navodnik, neengleski znak — odbija se u vrijeme instalacije umjesto da se pretvori u naziv direktorija. Tako se `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` i `omarchy-c++-theme` svi instaliraju bez problema.

Zapamtite da se, jednom kad je instalirana iz repozitorija, svaka `.lua`, konfiguracija terminala ili `vscode.json` koju isporučuje odbacuje, pa nemojte graditi temu oko toga.

Svoju temu možete dodati na [stranicu s dodatnim temama](https://omarchy.org/themes/) slanjem pull requesta u [omarchy-site repozitorij](https://github.com/omacom-io/omarchy-site).
