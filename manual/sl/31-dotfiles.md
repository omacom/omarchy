# Dotfiles

Omarchy se v prvi vrsti konfigurira prek tako imenovanih datotek dotfiles, ki živijo v `~/.config`. Te veljajo za vaše datoteke za vaše spremembe. Datoteke v `/usr/share/omarchy` pripadajo samemu Omarchyju in se z njimi ne bi smeli igrati. Če morate kaj spremeniti v `/usr/share/omarchy`, bi morali namesto tega prepisati vrednost v `~/.config`.

Ključne konfiguracije je mogoče urejati naravnost iz menija Omarchy (`Super + Space`), kot so _Nastavitve > Zasloni_, _Nastavitve > Bližnjice_, _Nastavitve > Vnos_ in _Nastavitve > Config > [file]_. Ko to počnete na ta način, se bo vsak proces, ki ga je treba po urejanju konfiguracije znova zagnati, samodejno zagnal, ko zaprete urejevalnik (privzeto Neovim — `:wq`, zapomnite si! — vendar to lahko spremenite prek _Nastavitve > Privzeto > Urejevalnik_).

Tu je seznam ključnih datotek v `~/.config` in kaj nadzirajo:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Glavna konfiguracija Hyprland. Naloži privzete vrednosti Omarchy in vaše datoteke za prepis spodaj. [Več o konfiguracijah Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Vaše lastne bližnjice in prepisi privzetih vrednosti. |
| `~/.config/hypr/monitors.lua` | Nadzira vaše zaslone, ločljivost in položaj. |
| `~/.config/hypr/input.lua` | Nadzira razporeditev tipkovnice, miško in nastavitve sledilne ploščice. |
| `~/.config/hypr/looknfeel.lua` | Nadzira razmike, robove, animacije in preostanek videza. |
| `~/.config/hypr/autostart.lua` | Nadzira dodatne procese, zagnane s sejo. |
| `~/.config/omarchy/shell.json` | Nadzira lupino Omarchy: položaj vrstice, postavitev in pripomočke ter čase ohranjevalnika, zaklepa in nedejavnosti. |
| `~/.config/foot/foot.ini` | Nadzira vaš terminal (privzeti je foot). |
| `~/.XCompose` | Določa vaše emojije za hiter dostop in samodopolnjevanje imena/e-pošte. Po spremembah zaženite `omarchy-restart-xcompose`. |

Če naredite veliko sprememb za prilagoditev svoje namestitve, je dobra ideja varnostno kopirati vse te dotfiles. [Stow je odličen način za to](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Zagon lastnih aplikacij s sejo

Če želite, da kaj teče ob vsaki prijavi — demon za sinhronizacijo, aplikacija za klepet, vaš lastni skript — to postavite v `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

To zažene ukaz kot del seje, tako da se ob ponovni odjavi pravilno počisti.

### Zagon skriptov ob sistemskih dogodkih

Omarchy ob peščici trenutkov sproži kavlje, nanje pa lahko obesite lastne skripte. Živijo v `~/.config/omarchy/hooks/<event>.d/`, ena mapa na dogodek, in vsaka izvedljiva datoteka v njej se zažene, ko se dogodek zgodi:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Takoj po zagonu namizja |
| `post-update` | Proti koncu `omarchy update`, po paketih, migracijah in vnovičnem zagonu storitev, pred posodobitvijo orodij mise |
| `pre-refresh-pacman` | Po tem, ko `omarchy refresh pacman` znova sinhronizira konfiguracijo paketov, pred posodobitvijo paketov; preklop kanala ga zažene med istim korakom osveževanja |
| `theme-set` | Po spremembi teme (ime teme v `$1`) |
| `font-set` | Po spremembi pisave (ime pisave v `$1`) |
| `battery-low` | Ko je baterija skoraj prazna (odstotek v `$1`) |

Kavelj `pre-refresh-pacman` je mesto, kamor spadajo repozitoriji po meri ali vrstice `IgnorePkg`, saj teče pred transakcijo paketov. Oba kavlja, povezana s posodobitvami, tečeta kot vaš uporabnik, potem ko Omarchy počisti svoje predpomnjeno dovoljenje sudo, tako da kavelj, ki uporablja `sudo`, potrebuje lastno dovoljenje in vas lahko vpraša za geslo.

Vsaka od teh map že vsebuje datoteko `.sample`, ki prikazuje obliko kavlja — z imena odstranite `.sample`, da ga spravite v delo. Če želite namestiti skript, ki ste ga napisali drugje, uporabite `omarchy hook install post-boot ~/my-hook`, kar ga kopira in naredi izvedljivega.

### Dodajanje lastnih vnosov v meni

Meni Omarchy (`Super + Space`) je mogoče razširiti z lastnimi vrsticami z urejanjem `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Vnosi so ključirani po pikčastem id-ju in id je tisti, ki jih umesti v drevo, tako da se `personal` pojavi v korenskem meniju, `personal.notes` pa znotraj njega:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Ponovna uporaba obstoječega id-ja prepiše to vrstico, namesto da bi dodala novo. Datoteka dobavlja vsa razpoložljiva polja, dokumentirana kot komentarji.

### Dodajanje lastnih izvozov lupine, funkcij in vzdevkov

Omarchy dobavlja kup ergonomskih vzdevkov in koristnih funkcij, vendar je zelo pogosto, da želite dodati svoje. Vzdevke, funkcije in izvoze dodajte v `~/.bashrc`. Ta datoteka ob posodobitvah ne bo prepisana. Če želite spremeniti katere od privzetih vrednosti Omarchy, jih lahko varno dodate tudi tukaj.

### Spreminjanje notranjih datotek Omarchy

Glejte, to je vaš računalnik. Z njim lahko počnete, kar hočete, vendar bi odsvetoval neposredno spreminjanje datotek v `/usr/share/omarchy`. Pripadajo paketu pacman Omarchy, tako da bodo vaše spremembe ob naslednji posodobitvi preprosto prepisane. Bolje je, da vse privzete vrednosti, ki vam niso všeč, prepišete v mapi `~/.config/*`.

Na ta način lahko spremenite skoraj vse, kot privzete bližnjice. Samo uredite `~/.config/hypr/bindings.lua`, da recimo [Obsidian](https://obsidian.md/) zamenjate z [Joplin](https://joplinapp.org/) (namestite z `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` odstrani obstoječo vezavo, preden doda zamenjavo. Sprejme iste argumente kot `o.bind`, vključno s pomočniki za zagon in možnostmi vezave. Uporabite `o.bind`, da dodate vezavo, ali `hl.unbind`, da eno odstranite brez zamenjave.

Če vztrajate pri krpanju notranjih datotek Omarchy, preklopite na kanal dev prek _Posodobi > Kanal > Dev_. To Omarchy poveže s kopijo izvorne kode git v `~/omarchy`, ki jo lahko po mili volji spreminjate. Nikogar ni tukaj, da vam pove, kaj storiti!

### Ponastavitev vseh sprememb

Če zmešavate konfiguracije, jih lahko kadar koli povrnete na privzete vrednosti prek _Posodobi > Config_ v meniju Omarchy. Ali z zagonom `omarchy reinstall configs`, da ponastavite vse.
