# Izrada vlastite teme

Vlastite teme možete dodati u `~/.config/omarchy/themes`. Samo kopirajte jednu od postojećih kao osnovu (pogledajte u `/usr/share/omarchy/themes`), zatim je prilagodite po svojoj želji. Dokle god je vaša tema unutar te mape, bit će uključena u izbornik za odabir teme.

Glavna datoteka koju morate prilagoditi jest `colors.toml`. Ona definira skup boja koji se zatim koristi za generiranje konfiguracija za terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian i cijelu Omarchy ljusku (gornju traku, izbornik, obavijesti, OSD i zaključani zaslon).

Možete upotrijebiti i priloženu aplikaciju Aether za izradu nove teme pomoću lijepog GUI sučelja za igranje bojama i pretraživanje pozadina. Samo je pokrenite iz mreže aplikacija na `Super + Alt + Space`.

### Što instalirana tema može sadržavati

Tema koju sami napišete u `~/.config/omarchy/themes` može sadržavati što god želite — to je vaše računalo i vaša datoteka, a Omarchy primjenjuje sve to.

Tema koju instalirate iz tuđeg repozitorija pomoću `omarchy theme install` zadržava sve što je boja i gubi ono nekoliko datoteka koje bi pokretale kod na vašem računalu: svaku `.lua` datoteku, konfiguracije terminala (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) i `vscode.json`. `hyprland.lua` teme jest Lua koju vaš kompozitor pokreće pri prijavi, konfiguracija terminala imenuje program koji vaš terminal pokreće, a `vscode.json` imenuje VSCode proširenje koje se instalira. Instaliranje nečije teme trebalo bi promijeniti kako vaša radna površina izgleda, nikad što pokreće.

Sve ostalo i dalje radi točno onako kako je autor teme napisao — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, pozadine i pregledi sve se zadržava. Samo ono što je odbačeno ponovno se generira iz `colors.toml` na vašem računalu.

Omarchy ih razlikuje prema tome ima li tema vlastiti git repozitorij unutar sebe, što je ono što `omarchy theme install` ostavlja za sobom kad klonira. Tako tema koju ste napisali ostaje vaša, a ona koju ste povukli s interneta ostaje samo boje.

### Svijetli način

Ako izrađujete temu sa svijetlim načinom, postavite `mode = "light"` na vrh svoje `colors.toml`. Tada će se automatski upariti sa svijetlim načinom za sve aplikacije. (Stari način ispuštanja prazne datoteke pod nazivom `light.mode` u korijen vaše teme također i dalje radi.)

### Boje ikona

Ako želite uskladiti boje ikona upravitelja datoteka s vašom temom, dodajte datoteku pod nazivom `icons.theme` s nazivom skupa ikona koji želite koristiti. Prema zadanim postavkama, opcije su: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Slika za otključavanje

Teme isporučene sa slikama `unlock.png` i `preview-unlock.png` bit će navedene pod _Izgled > Otključavanje_. Vaš `unlock.png` po mogućnosti bi trebao biti prozirni png. A sliku pregleda možete izraditi pomoću `omarchy plymouth preview`.

### Postavljanje teme aplikacijama koje Omarchy ne pokriva

Ako koristite aplikaciju koja nije na tom popisu, možete naučiti Omarchy da joj sam postavi temu pomoću predloška. Umetnite datoteku u `~/.config/omarchy/themed/` nazvanu prema konfiguraciji koju generira plus ekstenzija `.tpl` i napišite konfiguraciju s `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` do `{{ color15 }}` i ostatkom palete kao rezerviranim mjestima. Svaki put kad promijenite temu, datoteka se ponovno generira s bojama te teme.

U toj se mapi nalazi potpuno komentirana `alacritty.toml.tpl.sample` koju možete kopirati — navodi svaku varijablu koju možete koristiti, plus modifikatore `_strip` i `_rgb` za aplikacije koje žele svoje boje bez `#` ili kao decimalni RGB. Vaši predlošci imaju prednost pred Omarchyjevim vlastitima, pa ovo možete koristiti i za nadjačavanje načina na koji se postavlja tema ugrađenoj aplikaciji.

### Distribucija vaše teme

Ako želite distribuirati svoju temu kako bi je drugi mogli koristiti, morate je staviti na javni git poslužitelj, poput GitHuba. Tada je ljudi mogu instalirati pomoću _Instaliraj > Stil > Tema_ u izborniku Omarchy koristeći taj URL. Preporučuje se da slijedite konvenciju imenovanja `omarchy-[themename]-theme`, jer će se tema nakon instalacije ispravno prikazati kao samo `[themename]` u izborniku za odabir teme.

Taj preostali `[themename]` postaje naziv direktorija teme, pa mora biti onaj koji Omarchy može sigurno prosljeđivati: mora počinjati slovom, znamenkom ili donjom crticom, a ostatak može sadržavati slova, znamenke, `.`, `_`, `+` i `-`. Velika se slova za vas pretvaraju u mala, ali sve ostalo — razmak, navodnik, znak koji nije engleski — odbija se u vrijeme instalacije umjesto da se pretvori u naziv direktorija. Tako se `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` i `omarchy-c++-theme` svi instaliraju bez problema.

Zapamtite da se, nakon što se instalira iz repozitorija, svaka `.lua`, konfiguracija terminala ili `vscode.json` koju isporučuje odbacuje, pa nemojte graditi temu oko njih.

Svoju temu možete dodati na [stranicu s dodatnim temama](https://omarchy.org/themes/) slanjem pull requesta u [repozitorij omarchy-site](https://github.com/omacom-io/omarchy-site).
