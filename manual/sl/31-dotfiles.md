# Dotfiles

Omarchy se v glavnem nastavlja prek tako imenovanih datotek dotfiles, ki živijo v `~/.config`. Te veljajo za vaše datoteke za vaše spremembe. Datoteke, ki živijo v `/usr/share/omarchy`, pripadajo samemu sistemu Omarchy in z njimi se ne bi smeli ukvarjati. Če morate kaj spremeniti v `/usr/share/omarchy`, raje prepišite vrednost v `~/.config`.

Ključne nastavitve lahko urejate naravnost v meniju Omarchy (`Super + Space`), na primer _Setup > Keybindings_, _Setup > Input_ in _Setup > Config > [file]_. Kadar to storite na ta način, se bo vsak proces, ki ga je treba po urejanju nastavitev znova zagnati, po zaprtju urejevalnika znova zagnal samodejno (privzeto Neovim — `:wq`, zapomnite si! — lahko pa to spremenite prek _Setup > Defaults > Editor_).

Tukaj je seznam ključnih datotek v `~/.config` in kaj nadzirajo:

| Datoteka                  | Namen              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Glavna nastavitev za Hyprland. Naloži privzete nastavitve Omarchy in vaše datoteke s prepisom spodaj. [Več o nastavitvah za Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Vaše lastne bližnjice na tipkovnici in prepisi privzetih. |
| `~/.config/hypr/monitors.lua` | Nastavitve monitorja, ki jih plošča za monitor ne pokriva, kot so rotacija, dodatni načini ali izklopljen monitor. |
| `~/.config/hypr/input.lua` | Nadzira postavitev tipkovnice, miško in nastavitve sledilne ploščice. |
| `~/.config/hypr/looknfeel.lua` | Nadzira razmike, robove, animacije in preostanek videza. |
| `~/.config/hypr/autostart.lua` | Nadzira dodatne procese, zagnane s sejo. |
| `~/.config/omarchy/shell.json` | Nadzira lupino Omarchy: položaj vrstice, postavitev in gradnike ter časovne nastavitve ohranjevalnika zaslona, zaklepanja in nedejavnosti. |
| `~/.config/foot/foot.ini` | Nadzira vaš terminal (foot je privzeti). |
| `~/.XCompose` | Določa vaš hitri dostop do emodžijev in samodokončanje imena/e-pošte. Po spremembah obvezno zaženite `omarchy-restart-xcompose`. |

Če boste na koncu naredili veliko sprememb za prilagoditev lastne nastavitve, je dobro narediti varnostno kopijo vseh teh datotek dotfiles. [Stow je odličen način za to](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Zagon lastnih aplikacij ob seji

Če želite, da se kaj zažene ob vsaki prijavi — demon za sinhronizacijo, aplikacija za klepet, vaš lastni skript — to dajte v `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

To zažene ukaz kot del seje, zato se ob odjavi znova pravilno pospravi.

### Zagon skriptov ob sistemskih dogodkih

Omarchy sproži hooke ob nekaj trenutkih, nanje pa lahko obesite lastne skripte. Živijo v `~/.config/omarchy/hooks/<event>.d/`, en imenik na dogodek, in vsaka izvršljiva datoteka v njem se zažene, ko se dogodek zgodi:

| Dogodek | Kdaj se zažene |
| ----- | ------------ |
| `post-boot` | Takoj po zagonu namizja |
| `post-update` | Proti koncu `omarchy update`, po paketih, migracijah in ponovnih zagonih storitev, preden se posodobijo orodja mise |
| `pre-refresh-pacman` | Potem ko `omarchy refresh pacman` znova sinhronizira nastavitev paketov, preden posodobi pakete; preklop kanala ga zažene med istim korakom osvežitve |
| `theme-set` | Po spremembi teme (ime teme v `$1`) |
| `font-set` | Po spremembi pisave (ime pisave v `$1`) |
| `battery-low` | Ko je baterija skoraj prazna (odstotek v `$1`) |

Hook `pre-refresh-pacman` je tisti, kamor spadajo repozitoriji po meri ali vrstice `IgnorePkg`, saj se zažene pred transakcijo paketov. Oba hooka, povezana s posodobitvijo, se zaženeta kot vaš uporabnik, potem ko Omarchy počisti svoje predpomnjeno pooblastilo sudo, zato hook, ki uporablja `sudo`, potrebuje lastno pooblastilo in vas lahko vpraša za geslo.

Vsak od teh imenikov že vsebuje datoteko `.sample`, ki prikazuje obliko hooka — odstranite `.sample` iz imena, da ga spravite v delo. Če želite namestiti skript, ki ste ga napisali drugje, uporabite `omarchy hook install post-boot ~/my-hook`, ki ga kopira noter in ga naredi izvršljivega.

### Dodajanje lastnih vnosov v meni

Meni Omarchy (`Super + Space`) lahko razširite z lastnimi vrsticami z urejanjem `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Vnosi imajo za ključ id s pikami, id pa je tisto, kar jih umesti v drevo, tako da se `personal` pokaže v korenskem meniju, `personal.notes` pa znotraj njega:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Če znova uporabite obstoječi id, boste to vrstico prepisali, namesto da bi dodali novo. Datoteka je dobavljena z vsemi razpoložljivimi polji, dokumentiranimi kot komentarji.

### Dodajanje lastnih izvozov lupine, funkcij in aliasov

Omarchy je dobavljen s kupom ergonomskih aliasov in koristnih funkcij, zelo pogosto pa si želite dodati lastne. Tako aliase, funkcije kot izvoze dodajte v `~/.bashrc`. Ta datoteka ob posodobitvah ne bo prepisana. Če želite spremeniti katero od privzetih nastavitev Omarchy, jih lahko prav tako varno dodate tukaj.

### Spreminjanje notranjih datotek Omarchy

Glejte, to je vaš računalnik. Z njim lahko počnete, kar hočete, vendar vam odsvetujem neposredno spreminjanje datotek v `/usr/share/omarchy`. Pripadajo paketu pacman za Omarchy, zato bodo vaše spremembe ob naslednji posodobitvi preprosto prepisane. Bolje bo, če namesto tega prepišete privzete vrednosti, ki vam niso všeč, v mapi `~/.config/*`.

Na ta način lahko spremenite skoraj vse, na primer privzete bližnjice na tipkovnici. Preprosto uredite `~/.config/hypr/bindings.lua`, da, recimo, zamenjate [Obsidian](https://obsidian.md/) z [Joplin](https://joplinapp.org/) (namestite z `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` odstrani obstoječo vezavo, preden doda njeno zamenjavo. Sprejme iste argumente kot `o.bind`, vključno s pomočniki za zagon in možnostmi vezave. Uporabite `o.bind`, da dodate vezavo, ali `hl.unbind`, da eno odstranite, ne da bi jo zamenjali.

Če vztrajate pri hekanju notranjih datotek Omarchy, preklopite na razvojni kanal prek _Update > Channel > Dev_. To poveže Omarchy z git izvodom izvorne kode v `~/omarchy`, ki ga lahko spreminjate po mili volji. Tukaj vam nihče ne bo govoril, kaj morate početi!

### Ponastavitev vseh sprememb

Če na koncu naredite zmešnjavo z nastavitvami, jih lahko vedno povrnete na privzete prek _Update > Config_ v meniju Omarchy. Ali z zagonom `omarchy reinstall configs`, da ponastavite vse.
