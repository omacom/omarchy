# Izdelava lastne teme

Svoje teme lahko dodate v `~/.config/omarchy/themes`. Preprosto kopirajte eno od obstoječih tem kot osnovo (poiščite jih v `/usr/share/omarchy/themes`), nato pa jo prilagodite po svojih željah. Dokler je vaša tema v tej mapi, bo vključena v meni za izbiro teme.

Glavna datoteka, ki jo morate prilagoditi, je `colors.toml`. Ta določa nabor barv, ki se nato uporabi za ustvarjanje konfiguracij za terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian in celotno lupino Omarchy (zgornja vrstica, meni, obvestila, OSD in zaklenjeni zaslon).

Novo temo lahko ustvarite tudi s priloženo aplikacijo Aether, ki ponuja prijeten grafični vmesnik za igranje z barvami in iskanje ozadij. Preprosto jo zaženite iz mreže aplikacij s `Super + Alt + Space`.

### Kaj lahko vsebuje nameščena tema

Tema, ki jo napišete sami v `~/.config/omarchy/themes`, lahko vsebuje, kar koli želite — to je vaš računalnik in vaša datoteka, Omarchy pa uporabi vse.

Tema, ki jo namestite iz tujega repozitorija z `omarchy theme install`, obdrži vse, kar je barva, in izgubi peščico datotek, ki bi na vašem računalniku zagnale kodo: katero koli datoteko `.lua`, konfiguracije terminala (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) in `vscode.json`. `hyprland.lua` teme je Lua, ki jo vaš sestavljalnik oken zažene ob prijavi, konfiguracija terminala imenuje program, ki ga vaš terminal zažene, `vscode.json` pa imenuje razširitev za VSCode, ki naj se namesti. Namestitev tuje teme naj spremeni videz vašega namizja, nikoli pa tega, kaj se na njem izvaja.

Vse drugo še vedno deluje točno tako, kot je zapisal avtor teme — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, ozadja in predogledi se vsi ohranijo. Samo to, kar je bilo opuščeno, se na vašem računalniku znova ustvari iz `colors.toml`.

Omarchy ju razlikuje po tem, ali ima tema v sebi svoj repozitorij git, kar `omarchy theme install` pusti za seboj, ko klonira. Tako tema, ki ste jo napisali, ostane vaša, tista, ki ste jo potegnili z interneta, pa ostane samo pri barvah.

### Svetli način

Če izdelujete temo s svetlim načinom, na vrh svoje datoteke `colors.toml` nastavite `mode = "light"`. Nato bo samodejno povezana s svetlim načinom za vse aplikacije. (Stari način, pri katerem v koren teme odložite prazno datoteko z imenom `light.mode`, še vedno deluje.)

### Slika za odklepanje

Teme, ki vsebujejo sliki `unlock.png` in `preview-unlock.png`, bodo navedene pod _Videz > Odklepanje_. Vaša `unlock.png` naj bo po možnosti prozoren png. Predogledno sliko pa lahko ustvarite z `omarchy plymouth preview`.

### Teme za aplikacije, ki jih Omarchy ne pokriva

Če uporabljate aplikacijo, ki je ni na tem seznamu, lahko Omarchy sami naučite, kako zanjo uporabiti temo, s predlogo. V `~/.config/omarchy/themed/` odložite datoteko, poimenovano po konfiguraciji, ki jo ustvari, s pripono `.tpl`, in konfiguracijo zapišite z ogradami `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` do `{{ color15 }}` in preostalo paleto. Ob vsaki zamenjavi teme se datoteka znova ustvari z barvami te teme.

V tej mapi je v celoti komentirana datoteka `alacritty.toml.tpl.sample`, ki jo lahko kopirate — navaja vse spremenljivke, ki jih lahko uporabite, ter modifikatorja `_strip` in `_rgb` za aplikacije, ki želijo svoje barve brez `#` ali kot decimalne RGB. Vaše predloge imajo prednost pred Omarchyjevimi, zato lahko s tem tudi prepišete, kako se tema uporabi za vgrajeno aplikacijo.

### Deljenje vaše teme

Če želite svojo temo deliti, da jo lahko uporabljajo tudi drugi, jo morate objaviti na javnem strežniku git, kot je GitHub. Nato jo lahko ljudje namestijo z _Namesti > Slog > Tema_ v meniju Omarchy z uporabo tega URL-ja. Priporočljivo je, da upoštevate dogovor o poimenovanju `omarchy-[themename]-theme`, saj se bo tema po namestitvi v meniju za izbiro teme pravilno prikazala samo kot `[themename]`.

Ta preostali `[themename]` postane ime imenika teme, zato mora biti takšno, ki ga lahko Omarchy varno posreduje naprej: začeti se mora s črko, števko ali podčrtajem, preostanek pa lahko vsebuje črke, števke, `.`, `_`, `+` in `-`. Velike črke se namesto vas pretvorijo v male, vse drugo — presledek, narekovaj, neangleški znak — pa se ob namestitvi zavrne, namesto da bi se pretvorilo v ime imenika. Tako se `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` in `omarchy-c++-theme` vse namestijo brez težav.

Ne pozabite, da se ob namestitvi iz repozitorija vse datoteke `.lua`, konfiguracije terminala ali `vscode.json`, ki jih vsebuje, opustijo, zato teme ne gradite okoli njih.

Svojo temo lahko dodate na [stran z dodatnimi temami](https://omarchy.org/themes/) tako, da pošljete pull request v [repozitorij omarchy-site](https://github.com/omacom-io/omarchy-site).
