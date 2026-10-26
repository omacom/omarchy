# Ustvarjanje lastne teme

Svoje teme lahko dodate v `~/.config/omarchy/themes`. Preprosto kopirajte eno od obstoječih kot osnovo (poiščite jih v `/usr/share/omarchy/themes`), nato pa jo prilagodite po svojih željah. Dokler je vaša tema v tej mapi, bo vključena v meni za izbiro teme.

Glavna datoteka, ki jo morate prilagoditi, je `colors.toml`. Ta določa nabor barv, ki se nato uporablja za ustvarjanje konfiguracij za terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian in celotno lupino Omarchy (vrhnja vrstica, meni, obvestila, OSD in zaklenjeni zaslon).

Za ustvarjanje nove teme lahko uporabite tudi priloženo aplikacijo Aether, ki ponuja lep grafični vmesnik za igranje z barvami in iskanje ozadij. Preprosto jo zaženite iz mreže aplikacij s `Super + Alt + Space`.

### Kaj lahko vsebuje nameščena tema

Tema, ki jo sami napišete v `~/.config/omarchy/themes`, lahko vsebuje karkoli želite — to je vaš računalnik in vaša datoteka, Omarchy pa uporabi vse to.

Tema, ki jo namestite iz tujega repoja z `omarchy theme install`, obdrži vse, kar je barvno, in izgubi peščico datotek, ki bi na vašem računalniku zagnale kodo: katero koli datoteko `.lua`, konfiguracije terminala (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) in `vscode.json`. Temina datoteka `hyprland.lua` je Lua, ki jo vaš skladatelj zažene ob prijavi, konfiguracija terminala navede program, ki ga vaš terminal zažene, `vscode.json` pa navede razširitev VSCode, ki jo je treba namestiti. Namestitev tuje teme naj spremeni videz vašega namizja, nikoli pa tega, kaj se na njem izvaja.

Vse ostalo še vedno deluje natanko tako, kot je zapisal avtor teme — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, ozadja in predogledi se ohranijo. Samo tisto, kar je bilo zavrženo, se na vašem računalniku znova ustvari iz `colors.toml`.

Omarchy obe vrsti loči po tem, ali ima tema v sebi lasten repo git, kar za seboj pusti `omarchy theme install`, ko ga klonira. Tako tema, ki ste jo napisali sami, ostane vaša, tista, ki ste jo prenesli z interneta, pa ostane le pri barvah.

### Svetli način

Če ustvarjate temo s svetlim načinom, nastavite `mode = "light"` na vrhu svoje datoteke `colors.toml`. Nato se bo samodejno povezala s svetlim načinom za vse aplikacije. (Stari način, pri katerem v koren teme odložite prazno datoteko z imenom `light.mode`, še vedno deluje.)

### Barve ikon

Če želite barve ikon upravljalnika datotek uskladiti s svojo temo, dodajte datoteko z imenom `icons.theme`, ki vsebuje ime nabora ikon, ki ga želite uporabiti. Privzeto so možnosti: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Slika za odklepanje

Teme, dobavljene s slikama `unlock.png` in `preview-unlock.png`, bodo navedene pod _Videz > Odklepanje_. Vaša `unlock.png` naj bo po možnosti prozoren png. Predogledno sliko pa lahko ustvarite z `omarchy plymouth preview`.

### Tematizacija aplikacij, ki jih Omarchy ne pokriva

Če uporabljate aplikacijo, ki ni na tem seznamu, lahko Omarchy s predlogo sami naučite, da jo tematizira. V `~/.config/omarchy/themed/` odložite datoteko, poimenovano po konfiguraciji, ki jo ustvari, s pripono `.tpl`, in konfiguracijo zapišite z ogradami `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` do `{{ color15 }}` ter preostankom palete. Vsakič, ko zamenjate temo, se datoteka znova ustvari z barvami te teme.

V tej mapi je popolnoma komentirana datoteka `alacritty.toml.tpl.sample`, ki jo lahko kopirate — navaja vsako spremenljivko, ki jo lahko uporabite, ter modifikatorja `_strip` in `_rgb` za aplikacije, ki želijo barve brez `#` ali kot decimalni RGB. Vaše predloge imajo prednost pred predlogami Omarchy, zato lahko to uporabite tudi za preglasitev načina tematizacije vgrajene aplikacije.

### Distribucija vaše teme

Če želite svojo temo distribuirati, da jo lahko uporabljajo drugi, jo morate postaviti na javni strežnik git, kot je GitHub. Nato jo lahko ljudje namestijo prek _Namestitev > Slog > Tema_ v meniju Omarchy z uporabo tega URL-ja. Priporočljivo je, da upoštevate konvencijo poimenovanja `omarchy-[themename]-theme`, saj se bo tema po namestitvi v meniju za izbiro teme pravilno prikazala le kot `[themename]`.

Ta preostali `[themename]` postane ime imenika teme, zato mora biti tak, da ga Omarchy lahko varno posreduje naprej: začeti se mora s črko, števko ali podčrtajem, preostanek pa lahko vsebuje črke, števke, `.`, `_`, `+` in `-`. Velike črke se za vas pretvorijo v male, vse drugo — presledek, narekovaj, neangleški znak — pa se ob namestitvi zavrne, namesto da bi se pretvorilo v ime imenika. Tako se `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` in `omarchy-c++-theme` vse namestijo brez težav.

Ne pozabite, da se po namestitvi iz repoja zavrže vsaka datoteka `.lua`, konfiguracija terminala ali `vscode.json`, ki jo tema vsebuje, zato teme ne gradite okoli teh.

Svojo temo lahko dodate na [stran z dodatnimi temami](https://omarchy.org/themes/), tako da pošljete pull request v [repozitorij omarchy-site](https://github.com/omacom-io/omarchy-site).
