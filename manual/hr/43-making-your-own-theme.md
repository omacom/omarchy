# Izrada vlastite teme

Svoje vlastite teme možete dodati u `~/.config/omarchy/themes`. Samo kopirajte jednu od postojećih kao osnovu (pogledajte u `/usr/share/omarchy/themes`), a zatim je prilagodite po svom ukusu. Dokle god se vaša tema nalazi u toj mapi, bit će uključena u izbornik za odabir teme.

Glavna datoteka koju morate prilagoditi je `colors.toml`. Ona definira skup boja koji se zatim koristi za generiranje konfiguracija za terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt aplikacije, pozadinsko osvjetljenje tipkovnice, način unosa, odabir za dijeljenje zaslona, ikone aplikacija, nekoliko AI alata (Claude, Pi, Hermes, T3 Code, Herdr) i cijelu Omarchy ljusku (gornju traku, izbornik, obavijesti, OSD i zaslon zaključavanja).

Za izradu nove teme možete koristiti i uključenu aplikaciju Aether, pomoću ljupkog GUI sučelja za igranje s bojama i pretraživanje pozadina. Samo je pokrenite iz mreže aplikacija pomoću `Super + Alt + Space`.

### Što instalirana tema može sadržavati

Tema koju sami napišete u `~/.config/omarchy/themes` može sadržavati što god želite — to je vaše računalo i vaša datoteka, a Omarchy primjenjuje sve to.

Tema koju instalirate iz tuđeg repozitorija pomoću `omarchy theme install` zadržava sve što je boja, a gubi nekolicinu datoteka koje bi pokretale kod na vašem računalu: bilo koju `.lua` datoteku, konfiguracije terminala (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) i `vscode.json`. `hyprland.lua` neke teme je Lua koju vaš kompozitor pokreće pri prijavi, konfiguracija terminala imenuje program koji vaš terminal pokreće, a `vscode.json` imenuje VSCode proširenje koje treba instalirati. Instaliranje nečije teme trebalo bi promijeniti kako vaša radna površina izgleda, nikad što ona pokreće.

Sve ostalo i dalje radi točno onako kako je autor teme napisao — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, pozadine i pregledi, sve se zadržava. Samo ono što je odbačeno ponovno se generira iz `colors.toml` na vašem računalu.

Omarchy ih razlikuje po tome ima li tema u sebi vlastiti git repozitorij, što je ono što `omarchy theme install` ostavlja iza sebe kad klonira. Tako tema koju ste napisali ostaje vaša, a ona koju ste skinuli s interneta ostaje samo boje.

### Svijetli način rada

Ako izrađujete temu sa svijetlim načinom rada, postavite `mode = "light"` na vrh svog `colors.toml`. Tada će se automatski upariti sa svijetlim načinom rada za sve aplikacije. (Stari način, ostavljanje prazne datoteke nazvane `light.mode` u korijenu vaše teme, također i dalje radi.)

### Zaslon podizanja sustava i prijave

Zaslon koji pri podizanju sustava traži lozinku diska i zaslon prijave crtaju Omarchy logotip u `accent` boji vaše teme na njezinoj `background`, s poljem za lozinku u njezinoj `foreground` i `red` za pogrešnu lozinku. Za njih ne treba isporučiti ništa dodatno: Omarchy više ne koristi `unlock.png` ni `preview-unlock.png` teme. Na Apple Silicon Mac računalima zaslon za lozinku diska zadržava Omarchyjev zadani izgled bez obzira na temu.

### Tematiziranje aplikacija koje Omarchy ne pokriva

Ako koristite aplikaciju koja nije na tom popisu, možete sami naučiti Omarchy da je tematizira pomoću predloška. Umetnite datoteku u `~/.config/omarchy/themed/` nazvanu prema konfiguraciji koju generira plus ekstenziju `.tpl` i napišite konfiguraciju koristeći `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` do `{{ color15 }}` i ostatak palete kao rezervirana mjesta. Svaki put kad promijenite temu, datoteka se ponovno generira s bojama te teme.

U toj mapi nalazi se potpuno komentirana datoteka `alacritty.toml.tpl.sample` koju možete kopirati — ona navodi svaku varijablu koju možete koristiti, plus modifikatore `_strip` i `_rgb` za aplikacije koje žele svoje boje bez `#` ili kao decimalni RGB. Vaši predlošci imaju prednost pred Omarchyjevima, pa ovo možete koristiti i za nadjačavanje načina na koji se tematizira ugrađena aplikacija.

### Distribucija vaše teme

Ako želite distribuirati svoju temu kako bi je drugi mogli koristiti, morate je postaviti na javni git poslužitelj, poput GitHub. Tada je ljudi mogu instalirati pomoću _Install > Style > Theme_ u Omarchy izborniku, koristeći taj URL. Preporučuje se da slijedite konvenciju imenovanja `omarchy-[themename]-theme`, jer će se tema nakon instalacije ispravno prikazivati samo kao `[themename]` u izborniku za odabir teme.

Taj preostali `[themename]` postaje naziv direktorija teme, pa mora biti onakav kojim Omarchy može sigurno rukovati: mora počinjati slovom, znamenkom ili donjom crticom, a ostatak može sadržavati slova, znamenke, `.`, `_`, `+` i `-`. Velika slova se za vas pretvaraju u mala, ali sve ostalo — razmak, navodnik, neengleski znak — odbija se pri instalaciji umjesto da se pretvori u naziv direktorija. Tako se `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` i `omarchy-c++-theme` svi bez problema instaliraju.

Imajte na umu da se, jednom kad se instalira iz repozitorija, odbacuje svaka `.lua` datoteka, konfiguracija terminala ili `vscode.json` koju isporučuje, pa nemojte temu graditi oko njih.

Svoju temu možete dodati na [stranicu s dodatnim temama](https://omarchy.org/themes/) slanjem pull requesta u [repozitorij omarchy-site](https://github.com/omacom-io/omarchy-site).
