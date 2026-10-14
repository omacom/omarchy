# Izrada vlastite teme

Vlastite teme možete dodati u `~/.config/omarchy/themes`. Samo kopirajte jednu od postojećih kao osnovu (potražite u `/usr/share/omarchy/themes`), a zatim je prilagodite do mile volje. Sve dok je vaša tema unutar te mape, bit će uključena u izbornik za odabir teme.

Glavna datoteka koju morate prilagoditi je `colors.toml`. Ona definira skup boja koji se zatim koristi za generiranje konfiguracija za terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian i cijelu Omarchy ljusku (gornja traka, izbornik, obavijesti, OSD i zaslon za zaključavanje).

Možete koristiti i uključenu aplikaciju Aether za izradu nove teme pomoću lijepog GUI sučelja za igranje bojama i traženje pozadina. Samo je pokrenite iz rešetke aplikacija na `Super + Alt + Space`.

### Što instalirana tema može sadržavati

Tema koju sami napišete u `~/.config/omarchy/themes` može sadržavati što god želite — to je vaše računalo i vaša datoteka, a Omarchy primjenjuje sve to.

Tema koju instalirate iz tuđeg repozitorija s `omarchy theme install` zadržava sve što je boja, a gubi šačicu datoteka koje bi pokretale kod na vašem računalu: bilo koju `.lua` datoteku, konfiguracije terminala (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) i `vscode.json`. `hyprland.lua` teme je Lua koju vaš skladatelj pokreće pri prijavi, konfiguracija terminala imenuje program koji vaš terminal pokreće, a `vscode.json` imenuje VSCode proširenje za instalaciju. Instalacija tuđe teme trebala bi promijeniti kako vaša radna površina izgleda, nikada što pokreće.

Sve ostalo i dalje radi točno kako je autor teme napisao — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, pozadine i pregledi svi se zadržavaju. Samo ono što je odbačeno ponovno se generira iz `colors.toml` na vašem računalu.

Omarchy razlikuje to dvoje prema tome ima li tema vlastiti git repozitorij unutar sebe, što `omarchy theme install` ostavlja za sobom kad klonira. Pa tema koju ste napisali ostaje vaša, a ona koju ste povukli s interneta ostaje boja.

### Svijetli način

Ako izrađujete temu svijetlog načina, postavite `mode = "light"` na vrh svoje `colors.toml`. Zatim će automatski biti uparena sa svijetlim načinom za sve aplikacije. (Stari način ubacivanja prazne datoteke zvane `light.mode` u korijen vaše teme također i dalje radi.)

### Boje ikona

Ako želite uskladiti boje ikona upravitelja datoteka sa svojom temom, dodajte datoteku zvanu `icons.theme` s imenom skupa ikona koji želite koristiti. Prema zadanim postavkama opcije su: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Slika za otključavanje

Teme isporučene sa slikama `unlock.png` i `preview-unlock.png` bit će navedene pod _Stil > Unlock_. Vaš `unlock.png` po mogućnosti bi trebao biti prozirni png. A sliku pregleda možete izraditi pomoću `omarchy plymouth preview`.

### Tematiziranje aplikacija koje Omarchy ne pokriva

Ako koristite aplikaciju koja nije na tom popisu, možete sami naučiti Omarchy da je tematizira predloškom. Ubacite datoteku u `~/.config/omarchy/themed/` nazvanu prema konfiguraciji koju generira plus ekstenzija `.tpl` i napišite konfiguraciju s `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` do `{{ color15 }}` i ostatkom palete kao rezervirana mjesta. Svaki put kad promijenite temu, datoteka se ponovno generira s bojama te teme.

U toj mapi nalazi se potpuno komentirani `alacritty.toml.tpl.sample` iz kojeg možete kopirati — navodi svaku varijablu koju možete koristiti, plus modifikatore `_strip` i `_rgb` za aplikacije koje žele svoje boje bez `#` ili kao decimalni RGB. Vaši predlošci imaju prednost pred Omarchyjevima, pa to možete koristiti i za nadjačavanje načina na koji se ugrađena aplikacija tematizira.

### Distribucija vaše teme

Ako želite distribuirati svoju temu kako bi je drugi mogli koristiti, morate je staviti na javni git poslužitelj, poput GitHuba. Zatim je ljudi mogu instalirati pomoću _Instaliraj > Style > Theme_ u Omarchy izborniku pomoću tog URL-a. Preporučuje se da slijedite konvenciju imenovanja `omarchy-[themename]-theme`, jer će se tema nakon instalacije ispravno prikazati samo kao `[themename]` u izborniku za odabir teme.

Taj preostali `[themename]` postaje ime direktorija teme, pa mora biti onaj koji Omarchy može sigurno prenositi: mora započeti slovom, znamenkom ili podvlakom, a ostatak može sadržavati slova, znamenke, `.`, `_`, `+` i `-`. Velika slova pretvaraju se u mala za vas, ali sve drugo — razmak, navodnik, znak koji nije engleski — odbija se pri instalaciji umjesto da se pretvori u ime direktorija. Pa se `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` i `omarchy-c++-theme` svi uredno instaliraju.

Imajte na umu da se, nakon što se instalira iz repozitorija, bilo koji `.lua`, konfiguracija terminala ili `vscode.json` koji isporučuje odbacuje, pa nemojte temu graditi oko njih.

Svoju temu možete dodati na [stranicu s dodatnim temama](https://omarchy.org/themes/) slanjem pull requesta u [repozitorij omarchy-site](https://github.com/omacom-io/omarchy-site).
