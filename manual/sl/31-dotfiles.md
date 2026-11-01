# Dotfiles

Omarchy se v glavnem konfigurira prek tako imenovanih datotek dotfiles, ki živijo v `~/.config`. Te veljajo za vaše datoteke za vaše spremembe. Datoteke, ki živijo v `/usr/share/omarchy`, pripadajo samemu Omarchyju, in z njimi se ne bi smeli ukvarjati. Če morate karkoli spremeniti v `/usr/share/omarchy`, bi morali namesto tega prepisati vrednost v `~/.config`.

Ključne konfiguracije lahko urejate neposredno iz menija Omarchy (`Super + Space`), na primer _Setup > Keybindings_, _Setup > Input_ in _Setup > Config > [file]_. Ko to naredite na ta način, se bo vsak proces, ki ga je treba po urejanju konfiguracije znova zagnati, samodejno znova zagnal, ko zaprete urejevalnik (privzeto Neovim — `:wq`, ne pozabite! — lahko pa to spremenite prek _Setup > Defaults > Editor_).

Tukaj je seznam ključnih datotek v `~/.config` in kaj nadzorujejo:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Glavna konfiguracija Hyprlanda. Naloži privzete nastavitve Omarchyja ter vaše spodnje datoteke s prepisi. [Več o konfiguracijah Hyprlanda](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Vaše lastne bližnjice na tipkovnici in prepisi privzetih. |
| `~/.config/hypr/monitors.lua` | Nastavitve monitorja, ki jih plošča za monitor ne pokriva, na primer vrtenje, dodatni načini ali izklopljen monitor. |
| `~/.config/hypr/input.lua` | Nadzoruje postavitev tipkovnice, miško in nastavitve sledilne ploščice. |
| `~/.config/hypr/looknfeel.lua` | Nadzoruje reže, obrobe, animacije in preostali videz. |
| `~/.config/hypr/autostart.lua` | Nadzoruje dodatne procese, ki se zaženejo s sejo. |
| `~/.config/omarchy/shell.json` | Nadzoruje lupino Omarchy: položaj vrstice, postavitev in gradnike ter časovne nastavitve ohranjevalnika zaslona, zaklepanja in nedejavnosti. |
| `~/.config/foot/foot.ini` | Nadzoruje vaš terminal (foot je privzeti). |
| `~/.XCompose` | Določa vaše emodžije za hitri dostop in samodejno dokončanje imena/e-pošte. Po spremembah obvezno zaženite `omarchy-restart-xcompose`. |

Če boste na koncu naredili veliko sprememb, da prilagodite svojo nastavitev, je dobro narediti varnostno kopijo vseh teh datotek dotfiles. [Stow je odličen način za to](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Zagon svojih aplikacij s sejo

Če želite, da se nekaj zažene ob vsaki prijavi — demon za sinhronizacijo, aplikacija za klepet, vaš lastni skript — to vstavite v `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

To zažene ukaz kot del seje, zato se ob ponovni odjavi pravilno počisti.

### Izvajanje skriptov ob sistemskih dogodkih

Omarchy ob nekaj trenutkih sproži hooke, nanje pa lahko obesite svoje skripte. Živijo v `~/.config/omarchy/hooks/<event>.d/`, en imenik na dogodek, vsaka izvedljiva datoteka v njem pa se zažene, ko se dogodek zgodi:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Takoj po zagonu namizja |
| `post-update` | Proti koncu `omarchy update`, po paketih, migracijah in ponovnih zagonih storitev, preden se posodobijo orodja mise |
| `pre-refresh-pacman` | Ko `omarchy refresh pacman` znova sinhronizira konfiguracijo paketov, preden posodobi pakete; preklop kanala ga zažene med istim korakom osvežitve |
| `theme-set` | Po spremembi teme (ime teme v `$1`) |
| `font-set` | Po spremembi pisave (ime pisave v `$1`) |
| `battery-low` | Ko je baterija skoraj prazna (odstotek v `$1`) |

Hook `pre-refresh-pacman` je mesto, kamor spadajo skladišča po meri ali vrstice `IgnorePkg`, saj se zažene pred transakcijo paketov. Oba hooka, povezana s posodobitvami, se zaženeta kot vaš uporabnik, potem ko Omarchy počisti svojo predpomnjeno avtorizacijo sudo, zato hook, ki uporablja `sudo`, potrebuje lastno avtorizacijo in vas bo morda vprašal za geslo.

Vsak od teh imenikov že vsebuje datoteko `.sample`, ki prikazuje obliko hooka — odstranite `.sample` iz imena, da ga uporabite. Če želite namestiti skript, ki ste ga napisali drugje, uporabite `omarchy hook install post-boot ~/my-hook`, ki ga kopira noter in ga naredi izvedljivega.

### Dodajanje lastnih vnosov v meni

Meni Omarchy (`Super + Space`) lahko razširite z lastnimi vrsticami z urejanjem `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Vnosi so vezani na pikčasti id, id pa je tisto, kar jih umesti v drevo, zato se `personal` prikaže v korenskem meniju, `personal.notes` pa znotraj njega:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Če znova uporabite obstoječi id, boste to vrstico prepisali, namesto da bi dodali novo. Datoteka vsebuje vsa razpoložljiva polja, dokumentirana kot komentarji.

### Dodajanje lastnih izvozov lupine, funkcij in aliasov

Omarchy je opremljen s kupom ergonomskih aliasov in priročnih funkcij, a zelo pogosto želite dodati svoje. Tako aliase, funkcije kot izvoze bi morali dodati v `~/.bashrc`. Ta datoteka ob posodobitvah ne bo prepisana. Če želite spremeniti katero od privzetih nastavitev Omarchyja, jih lahko varno dodate tudi tukaj.

### Nastavitev okoljskih spremenljivk za namizje

Izvozi namizne seje spadajo v `~/.config/uwsm/env.d/`. Te datoteke se zaženejo pred zagonom namizja, zato vas lahko napaka lupine vrne na prijavni zaslon. Med urejanjem imejte odprt delujoč terminal. Če želite onemogočiti prepis, ga premaknite iz `env.d`. Če sprememba prepreči prijavo, glejte [obnovitev prijave](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen).

### Spreminjanje notranjih datotek Omarchyja

Glejte, to je vaš računalnik. Z njim lahko počnete, kar želite, a odsvetujem neposredno spreminjanje datotek v `/usr/share/omarchy`. Pripadajo paketu pacman Omarchyja, zato bodo vaše spremembe ob naslednji posodobitvi preprosto prepisane. Bolje bo, če namesto tega kakršne koli privzete vrednosti, ki vam niso všeč, prepišete v mapi `~/.config/*`.

Na ta način lahko spremenite skoraj vse, na primer privzete bližnjice na tipkovnici. Samo uredite `~/.config/hypr/bindings.lua`, da, recimo, zamenjate [Obsidian](https://obsidian.md/) z [Joplin](https://joplinapp.org/) (namestite z `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` odstrani obstoječo vezavo, preden doda njeno zamenjavo. Sprejme iste argumente kot `o.bind`, vključno s pomočniki za zagon in možnostmi vezave. Uporabite `o.bind`, da dodate vezavo, ali `hl.unbind`, da eno odstranite, ne da bi jo zamenjali.

Če vztrajate pri hekanju notranjih datotek Omarchyja, preklopite na razvojni kanal prek _Update > Channel > Dev_. To poveže Omarchy z git izvodom izvorne kode v `~/omarchy`, ki ga lahko spreminjate po mili volji. Tukaj vam nihče ne bo govoril, kaj morate početi!

### Ponastavitev sprememb

Če na koncu naredite zmešnjavo v konfiguracijah, jih lahko vedno vrnete na privzete vrednosti prek _Update > Config_ v meniju Omarchy. Ali z zagonom `omarchy reinstall configs`, da ponastavite vse.
