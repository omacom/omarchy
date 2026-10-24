# Izdelava lastne teme

Lastne teme lahko dodate v `~/.config/omarchy/themes`. Preprosto kopirajte eno od obstoječih kot osnovo (poglejte v `/usr/share/omarchy/themes`), nato jo prilagodite do svojega veselja. Dokler je vaša tema znotraj te mape, bo vključena v meni za izbiro teme.

Glavna datoteka, ki jo morate prilagoditi, je `colors.toml`. Ta določa nabor barv, ki se nato uporabi za ustvarjanje konfiguracij za terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian in celotno lupino Omarchy (vrstico, meni, obvestila, OSD in zaklepanje zaslona).

Uporabite lahko tudi vključeno aplikacijo Aether, da ustvarite novo temo prek ljubkega grafičnega vmesnika za igranje z barvami in iskanje ozadij. Preprosto jo zaženite iz mreže aplikacij na `Super + Alt + Space`.

### Kaj lahko vsebuje nameščena tema

Tema, ki jo napišete sami v `~/.config/omarchy/themes`, lahko vsebuje kar koli želite — to je vaš računalnik in vaša datoteka, Omarchy pa uporabi vse.

Tema, ki jo namestite iz repozitorija nekoga drugega z `omarchy theme install`, obdrži vse, kar je barva, izgubi pa peščico datotek, ki bi na vašem računalniku zagnale kodo: vsako datoteko `.lua`, konfiguracije terminala (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) in `vscode.json`. Temina `hyprland.lua` je Lua, ki jo vaš sestavljalnik zažene ob prijavi, konfiguracija terminala poimenuje program, ki ga vaš terminal zažene, `vscode.json` pa poimenuje razširitev VSCode za namestitev. Namestitev teme nekoga drugega naj spremeni videz vašega namizja, nikoli pa ne, kaj ta izvaja.

Vse drugo še vedno deluje natanko tako, kot je napisal avtor teme — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, ozadja in predogledi so vsi ohranjeni. Samo tisto, kar je bilo izpuščeno, se na vašem računalniku znova ustvari iz `colors.toml`.

Omarchy loči obojega po tem, ali ima tema v sebi svoj lastni git repo, kar `omarchy theme install` pusti za sabo, ko klonira. Tako tema, ki ste jo napisali, ostane vaša, tema, ki ste jo potegnili z interneta, pa ostane barve.

### Svetli način

Če izdelujete temo za svetli način, nastavite `mode = "light"` na vrhu vaše `colors.toml`. Nato bo samodejno združena s svetlim načinom za vse aplikacije. (Deluje tudi stari način spuščanja prazne datoteke z imenom `light.mode` v koren vaše teme.)

### Barve ikon

Če želite barvno uskladiti ikone upravitelja datotek z vašo temo, dodajte datoteko z imenom `icons.theme` z imenom nabora ikon, ki ga želite uporabiti. Privzeto so možnosti: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Slika za odklepanje

Teme, dobavljene s slikama `unlock.png` in `preview-unlock.png`, bodo navedene pod _Slog > Odkleni_. Vaša `unlock.png` naj bo po možnosti prosojna png. Sliko predogleda lahko ustvarite z `omarchy plymouth preview`.

### Tematiziranje aplikacij, ki jih Omarchy ne pokriva

Če uporabljate aplikacijo, ki je ni na tem seznamu, lahko Omarchy sami naučite, da jo tematizira, s predlogo. V `~/.config/omarchy/themed/` spustite datoteko, poimenovano po konfiguraciji, ki jo ustvari, plus pripono `.tpl`, in konfiguracijo napišite z `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` do `{{ color15 }}` in preostankom palete kot nadomestnimi oznakami. Vsakič, ko preklopite temo, se datoteka znova ustvari z barvami te teme.

V tej mapi je popolnoma zakomentirana `alacritty.toml.tpl.sample`, iz katere lahko kopirate — navaja vsako spremenljivko, ki jo lahko uporabite, plus modifikatorja `_strip` in `_rgb` za aplikacije, ki svoje barve želijo brez `#` ali kot decimalni RGB. Vaše predloge imajo prednost pred predlogami Omarchyja, tako da lahko to uporabite tudi za preglasitev načina, kako se tematizira vgrajena aplikacija.

### Distribucija vaše teme

Če želite distribuirati svojo temo, da jo lahko drugi uporabijo, jo morate postaviti na javni git strežnik, kot je GitHub. Nato jo ljudje lahko namestijo prek _Namesti > Slog > Tema_ v meniju Omarchy z uporabo tega URL-ja. Priporočljivo je, da sledite dogovoru o poimenovanju `omarchy-[themename]-theme`, saj se bo tema po namestitvi pravilno prikazala kot samo `[themename]` v meniju za izbiro teme.

Ta preostali `[themename]` postane ime imenika teme, zato mora biti tak, da ga Omarchy lahko varno prenaša: začeti se mora s črko, števko ali podčrtajem, preostanek pa lahko vsebuje črke, števke, `.`, `_`, `+` in `-`. Velike črke se za vas pretvorijo v male, vse drugo — presledek, narekovaj, neangleški znak — pa se ob namestitvi zavrne, namesto da bi postalo ime imenika. Tako se `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` in `omarchy-c++-theme` vse namestijo brez težav.

Ne pozabite, da je po namestitvi iz repozitorija vsaka `.lua`, konfiguracija terminala ali `vscode.json`, ki jo prinaša, izpuščena, zato teme ne gradite okoli teh.

Svojo temo lahko dodate na [stran z dodatnimi temami](https://omarchy.org/themes/) tako, da pošljete zahtevek za vlečenje v [repozitorij omarchy-site](https://github.com/omacom-io/omarchy-site).
