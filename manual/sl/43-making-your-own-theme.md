# Ustvarjanje lastne teme

Svoje teme lahko dodate v `~/.config/omarchy/themes`. Preprosto kopirajte eno od obstoječih kot osnovo (poglejte v `/usr/share/omarchy/themes`), nato pa jo prilagodite po svojih željah. Dokler je vaša tema v tej mapi, bo vključena v meni za izbiro teme.

Glavna datoteka, ki jo morate prilagoditi, je `colors.toml`. Ta določa nabor barv, ki se nato uporabi za ustvarjanje konfiguracij za terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, aplikacije Qt, osvetlitev tipkovnice, način vnosa, izbirnik za deljenje zaslona, ikone aplikacij, več orodij AI (Claude, Pi, Hermes, T3 Code, Herdr) in celotno lupino Omarchy (zgornja vrstica, meni, obvestila, OSD in zaklenjeni zaslon).

Uporabite lahko tudi priloženo aplikacijo Aether, da ustvarite novo temo z lepim grafičnim vmesnikom GUI za igranje z barvami in iskanje ozadij. Preprosto jo zaženite iz mreže aplikacij s `Super + Alt + Space`.

### Kaj lahko vsebuje nameščena tema

Tema, ki jo sami napišete v `~/.config/omarchy/themes`, lahko vsebuje, kar koli želite — to je vaš računalnik in vaša datoteka, Omarchy pa uporabi vse.

Tema, ki jo namestite iz repozitorija nekoga drugega z `omarchy theme install`, obdrži vse, kar je barva, in izgubi tistih nekaj datotek, ki bi na vašem računalniku zagnale kodo: katero koli datoteko `.lua`, konfiguracije terminala (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) in `vscode.json`. `hyprland.lua` teme je Lua, ki jo vaš sestavljalnik zažene ob prijavi, konfiguracija terminala imenuje program, ki ga zažene vaš terminal, `vscode.json` pa imenuje razširitev za VSCode, ki jo je treba namestiti. Namestitev tuje teme naj spremeni videz vašega namizja, nikoli pa tega, kaj se na njem izvaja.

Vse ostalo še vedno deluje točno tako, kot je zapisal avtor teme — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, ozadja in predogledi so vsi ohranjeni. Samo tisto, kar je bilo zavrženo, se na vašem računalniku znova ustvari iz `colors.toml`.

Omarchy obe vrsti loči po tem, ali ima tema v sebi svoj repozitorij git, kar za seboj pusti `omarchy theme install`, ko ga klonira. Tako tema, ki ste jo napisali, ostane vaša, tista, ki ste jo potegnili z interneta, pa ostanejo barve.

### Svetli način

Če ustvarjate temo s svetlim načinom, nastavite `mode = "light"` na vrhu datoteke `colors.toml`. Nato bo samodejno povezana s svetlim načinom za vse aplikacije. (Stari način, pri katerem v koren teme odložite prazno datoteko z imenom `light.mode`, še vedno deluje.)

### Zagonski in prijavni zaslon

Zaslon, ki ob zagonu zahteva geslo za pogon, in prijavni zaslon narišeta logotip Omarchy v barvi `accent` vaše teme na njenem `background`, polje za geslo je v njenem `foreground`, `red` pa se uporabi za napačno geslo. Zanju ni treba priložiti ničesar dodatnega: Omarchy ne uporablja več teminih datotek `unlock.png` ali `preview-unlock.png`. Na računalnikih Mac z Apple Silicon ostane zaslon za geslo za pogon v privzetem videzu Omarchy, ne glede na temo.

### Oblikovanje aplikacij, ki jih Omarchy ne pokriva

Če uporabljate aplikacijo, ki je ni na tem seznamu, lahko Omarchy sami naučite, kako jo tematsko oblikuje, s predlogo. Odložite datoteko v `~/.config/omarchy/themed/`, imenovano po konfiguraciji, ki jo ustvari, s pripono `.tpl`, in konfiguracijo zapišite z ogradi `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` do `{{ color15 }}` in preostalo paleto. Vsakič, ko zamenjate temo, se datoteka znova ustvari z barvami te teme.

V tej mapi je v celoti komentirana datoteka `alacritty.toml.tpl.sample`, iz katere lahko kopirate — navaja vse spremenljivke, ki jih lahko uporabite, ter modifikatorja `_strip` in `_rgb` za aplikacije, ki želijo svoje barve brez `#` ali kot decimalne RGB. Vaše predloge imajo prednost pred Omarchyjevimi, zato lahko s tem tudi preglasite, kako se oblikuje vgrajena aplikacija.

### Distribucija vaše teme

Če želite svojo temo distribuirati, da jo lahko uporabljajo tudi drugi, jo morate objaviti na javnem strežniku git, kot je GitHub. Nato jo lahko ljudje namestijo prek _Install > Style > Theme_ v meniju Omarchy z uporabo tega URL-ja. Priporočljivo je, da upoštevate dogovor o poimenovanju `omarchy-[themename]-theme`, saj se bo tema po namestitvi v meniju za izbiro teme pravilno prikazala samo kot `[themename]`.

Ta preostali `[themename]` postane ime imenika teme, zato mora biti tak, da ga lahko Omarchy varno posreduje: začeti se mora s črko, števko ali podčrtajem, preostali del pa lahko vsebuje črke, števke, `.`, `_`, `+` in `-`. Velike črke se za vas pretvorijo v male, vse drugo — presledek, narekovaj, neangleški znak — pa se ob namestitvi zavrne, namesto da bi se pretvorilo v ime imenika. Tako se `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` in `omarchy-c++-theme` vsi namestijo brez težav.

Ne pozabite, da se ob namestitvi iz repozitorija vse priložene datoteke `.lua`, konfiguracije terminala ali `vscode.json` zavržejo, zato teme ne gradite okoli njih.

Svojo temo lahko dodate na [stran z dodatnimi temami](https://omarchy.org/themes/), tako da pošljete zahtevek za združitev v [repozitorij omarchy-site](https://github.com/omacom-io/omarchy-site).
