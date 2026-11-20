# Izdelava lastne teme

Svoje teme lahko dodate v `~/.config/omarchy/themes`. Preprosto kopirajte eno od obstoječih tem kot osnovo (poiščite jih v `/usr/share/omarchy/themes`) in jo nato prilagodite po svojih željah. Dokler je vaša tema v tej mapi, bo vključena v meni za izbiro teme.

Glavna datoteka, ki jo morate prilagoditi, je `colors.toml`. Ta določa nabor barv, ki se nato uporabi za ustvarjanje konfiguracij za terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, aplikacije Qt, osvetlitev ozadja tipkovnice, način vnosa, izbirnik za deljenje zaslona, ikone aplikacij, več orodij AI (Claude, Pi, Hermes, T3 Code, Herdr) in celotno lupino Omarchy (zgornja vrstica, meni, obvestila, OSD in zaklenjeni zaslon).

Za ustvarjanje nove teme lahko uporabite tudi priloženo aplikacijo Aether s prijetnim grafičnim vmesnikom, v katerem se lahko poigrate z barvami in poiščete ozadja. Preprosto jo zaženite iz mreže aplikacij s `Super + Alt + Space`.

### Kaj lahko vsebuje nameščena tema

Tema, ki jo napišete sami v `~/.config/omarchy/themes`, lahko vsebuje, kar koli želite — to je vaš računalnik in vaša datoteka, Omarchy pa uporabi vse.

Tema, ki jo namestite iz repozitorija nekoga drugega z `omarchy theme install`, obdrži vse, kar zadeva barve, in izgubi tistih nekaj datotek, ki bi na vašem računalniku zagnale kodo: katero koli datoteko `.lua`, konfiguracije terminala (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) in `vscode.json`. Datoteka `hyprland.lua` teme je Lua, ki jo vaš compositor zažene ob prijavi, konfiguracija terminala navede program, ki ga vaš terminal zažene, `vscode.json` pa navede razširitev za VSCode, ki naj se namesti. Namestitev tuje teme naj spremeni videz vašega namizja, nikoli pa tega, kaj se na njem izvaja.

Vse ostalo še vedno deluje točno tako, kot je zapisal avtor teme — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, ozadja in predogledi so vsi ohranjeni. Samo tisto, kar je bilo zavrženo, se na vašem računalniku znova ustvari iz `colors.toml`.

Omarchy obe vrsti loči po tem, ali ima tema v sebi svoj repozitorij git, kar `omarchy theme install` pusti za seboj, ko klonira. Tako tema, ki ste jo napisali sami, ostane vaša, tista, ki ste jo prenesli z interneta, pa ostane zgolj barve.

### Svetli način

Če izdelujete temo s svetlim načinom, na vrh datoteke `colors.toml` nastavite `mode = "light"`. Nato bo samodejno povezana s svetlim načinom za vse aplikacije. (Stari način, pri katerem v koren teme odložite prazno datoteko z imenom `light.mode`, še vedno deluje.)

### Slika za odklepanje

Teme, ki so opremljene s slikama `unlock.png` in `preview-unlock.png`, bodo navedene pod _Videz > Odklepanje_. Vaša slika `unlock.png` naj bo po možnosti prozoren png. Predogledno sliko lahko ustvarite z `omarchy plymouth preview`.

### Oblikovanje tem za aplikacije, ki jih Omarchy ne pokriva

Če uporabljate aplikacijo, ki je ni na tem seznamu, lahko Omarchy sami naučite, kako zanjo uporabiti temo, s predlogo. V `~/.config/omarchy/themed/` odložite datoteko, poimenovano po konfiguraciji, ki jo ustvari, s končnico `.tpl`, in konfiguracijo zapišite z `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` do `{{ color15 }}` ter preostankom palete kot nadomestnimi oznakami. Vsakič, ko zamenjate temo, se datoteka znova ustvari z barvami te teme.

V tej mapi je v celoti komentirana datoteka `alacritty.toml.tpl.sample`, ki jo lahko kopirate — navaja vse spremenljivke, ki jih lahko uporabite, ter modifikatorja `_strip` in `_rgb` za aplikacije, ki želijo svoje barve brez `#` ali kot decimalne vrednosti RGB. Vaše predloge imajo prednost pred predlogami Omarchy, zato lahko s tem tudi preglasite, kako se tema uporabi za vgrajeno aplikacijo.

### Distribucija vaše teme

Če želite svojo temo distribuirati, da jo bodo lahko uporabljali tudi drugi, jo morate objaviti na javnem strežniku git, kot je GitHub. Nato jo lahko ljudje namestijo v meniju Omarchy prek _Namesti > Slog > Tema_ z uporabo tega URL-ja. Priporočljivo je, da upoštevate poimenovalno konvencijo `omarchy-[themename]-theme`, saj bo tema po namestitvi v meniju za izbiro teme pravilno prikazana samo kot `[themename]`.

Ta preostali `[themename]` postane ime imenika teme, zato mora biti takšno, ki ga lahko Omarchy varno posreduje naprej: začeti se mora s črko, števko ali podčrtajem, preostali del pa lahko vsebuje črke, števke, `.`, `_`, `+` in `-`. Velike črke se za vas pretvorijo v male, vse drugo — presledek, narekovaj, neangleški znak — pa je ob namestitvi zavrnjeno, namesto da bi postalo ime imenika. Tako se `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` in `omarchy-c++-theme` vsi namestijo brez težav.

Ne pozabite, da je po namestitvi iz repozitorija vsaka datoteka `.lua`, konfiguracija terminala ali `vscode.json`, ki jo tema vsebuje, zavržena, zato teme ne gradite okoli teh datotek.

Svojo temo lahko dodate na [stran z dodatnimi temami](https://omarchy.org/themes/), tako da pošljete pull request v [repozitorij omarchy-site](https://github.com/omacom-io/omarchy-site).
