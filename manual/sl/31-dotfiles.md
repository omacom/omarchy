# Dotfiles

Omarchy se v glavnem konfigurira prek tako imenovanih datotek dotfiles, ki so v `~/.config`. Te veljajo za vaše datoteke za vaše spremembe. Datoteke, ki so v `/usr/share/omarchy`, pripadajo samemu sistemu Omarchy in z njimi se ne bi smeli ukvarjati. Če morate kaj spremeniti v `/usr/share/omarchy`, namesto tega prepišite vrednost v `~/.config`.

Ključne konfiguracije lahko urejate neposredno iz menija Omarchy (`Super + Space`), na primer _Nastavitve > Tipkovnica > Bližnjice na tipkovnici_, _Nastavitve > Vnos_ in _Nastavitve > Konfiguracija > [file]_. Ko to naredite na ta način, se bo vsak proces, ki ga je treba po urejanju konfiguracije znova zagnati, samodejno znova zagnal, ko zaprete urejevalnik (privzeto Neovim — `:wq`, ne pozabite! — vendar lahko to spremenite prek _Nastavitve > Privzeto > Urejevalnik_).

Tukaj je seznam ključnih datotek v `~/.config` in kaj nadzirajo:

| Datoteka                  | Namen              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Glavna konfiguracija za Hyprland. Naloži privzete nastavitve Omarchy in vaše spodnje datoteke s prepisi. [Več o konfiguracijah Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Vaše lastne bližnjice na tipkovnici in prepisi privzetih. |
| `~/.config/hypr/monitors.lua` | Nastavitve monitorja, ki jih plošča za monitor ne pokriva, na primer vrtenje, dodatni načini ali puščanje monitorja izklopljenega. |
| `~/.config/hypr/input.lua` | Nadzira postavitev tipkovnice ter nastavitve miške in sledilne ploščice. |
| `~/.config/hypr/looknfeel.lua` | Nadzira vrzeli, robove, animacije in preostali videz. |
| `~/.config/hypr/autostart.lua` | Nadzira dodatne procese, ki se zaženejo s sejo. |
| `~/.config/omarchy/shell.json` | Nadzira lupino Omarchy: položaj vrstice, postavitev in gradnike ter časovne nastavitve ohranjevalnika zaslona, zaklepanja in nedejavnosti. |
| `~/.config/foot/foot.ini` | Nadzira vaš terminal (foot je privzeti). |
| `~/.XCompose` | Določa vaše emoji za hitri dostop ter samodokončanje imena/e-pošte. Po spremembah obvezno zaženite `omarchy-restart-xcompose`. |

Če boste na koncu naredili veliko sprememb za prilagoditev svoje namestitve, je dobro narediti varnostno kopijo vseh teh datotek dotfiles. [Stow je odličen način za to](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Zagon lastnih aplikacij s sejo

Če želite, da se kaj zažene ob vsaki prijavi — demon za sinhronizacijo, aplikacija za klepet, vaš lastni skript — to vstavite v `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

To zažene ukaz kot del seje, zato se ob ponovni odjavi pravilno pospravi.

### Zagon skriptov ob sistemskih dogodkih

Omarchy ob nekaj trenutkih sproži hooke in nanje lahko obesite svoje skripte. So v `~/.config/omarchy/hooks/<event>.d/`, en imenik za vsak dogodek, in vsaka izvedljiva datoteka v njem se zažene, ko se dogodek zgodi:

| Dogodek | Kdaj se zažene |
| ----- | ------------ |
| `post-boot` | Takoj po zagonu namizja |
| `post-update` | Proti koncu `omarchy update`, po paketih, migracijah in ponovnih zagonih storitev, preden se posodobijo orodja mise |
| `pre-refresh-pacman` | Ko `omarchy refresh pacman` znova sinhronizira konfiguracijo paketov, preden posodobi pakete; preklop kanala ga zažene med istim korakom osvežitve |
| `theme-set` | Po spremembi teme (ime teme v `$1`) |
| `font-set` | Po spremembi pisave (ime pisave v `$1`) |
| `battery-low` | Ko je baterija skoraj prazna (odstotek v `$1`) |

Hook `pre-refresh-pacman` je mesto, kamor spadajo repozitoriji po meri ali vrstice `IgnorePkg`, saj se zažene pred transakcijo paketov. Oba hooka, povezana s posodobitvijo, se zaženeta kot vaš uporabnik, potem ko Omarchy počisti svojo predpomnjeno pooblastitev sudo, zato hook, ki uporablja `sudo`, potrebuje lastno pooblastitev in vas lahko vpraša za geslo.

V vsakem od teh imenikov je že datoteka `.sample`, ki prikazuje obliko hooka — odstranite `.sample` iz imena, da ga uporabite. Če želite namestiti skript, ki ste ga napisali drugje, uporabite `omarchy hook install post-boot ~/my-hook`, ki ga kopira tja in naredi izvedljivega.

### Dodajanje lastnih vnosov v meni

Meni Omarchy (`Super + Space`) lahko razširite z lastnimi vrsticami z urejanjem `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Vnosi imajo ključ v obliki pikčastega id-ja in id je tisti, ki jih umesti v drevo, tako da se `personal` prikaže v korenskem meniju in `personal.notes` znotraj njega:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Če znova uporabite obstoječi id, boste to vrstico prepisali, namesto da bi dodali novo. Datoteka je dobavljena z vsemi razpoložljivimi polji, dokumentiranimi kot komentarji.

### Dodajanje lastnih izvozov lupine, funkcij in aliasov

Omarchy je dobavljen s kupom ergonomskih aliasov in uporabnih funkcij, vendar je zelo pogosto, da želite dodati svoje. Tako aliase, funkcije kot izvoze dodajte v `~/.bashrc`. Ta datoteka ob posodobitvah ne bo prepisana. Če želite spremeniti katero od privzetih nastavitev Omarchy, jih lahko varno dodate tudi tukaj.

### Nastavitev okoljskih spremenljivk za namizje

Izvozi seje namizja spadajo v `~/.config/uwsm/env.d/`. Te datoteke se zaženejo, preden se zažene vaše namizje, zato vas lahko napaka lupine vrne na prijavni zaslon. Med urejanjem imejte odprt delujoč terminal. Če želite onemogočiti prepis, ga premaknite iz `env.d`. Glejte [obnovitev prijave](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), če sprememba prepreči prijavo.

### Spreminjanje notranjih datotek Omarchy

Poglejte, to je vaš računalnik. Z njim lahko počnete, kar želite, vendar vam odsvetujem neposredno spreminjanje datotek v `/usr/share/omarchy`. Pripadajo paketu pacman Omarchy, zato bodo vaše spremembe ob naslednji posodobitvi preprosto prepisane. Bolje je, da namesto tega v mapi `~/.config/*` preprosto prepišete vse privzete vrednosti, ki vam niso všeč.

Na ta način lahko spremenite skoraj vse, na primer privzete bližnjice na tipkovnici. Preprosto uredite `~/.config/hypr/bindings.lua`, da na primer zamenjate [Obsidian](https://obsidian.md/) z [Joplin](https://joplinapp.org/) (namestite z `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` odstrani obstoječo bližnjico, preden doda njeno zamenjavo. Sprejme enake argumente kot `o.bind`, vključno s pomočniki za zagon in možnostmi bližnjice. Uporabite `o.bind`, če želite dodati bližnjico, ali `hl.unbind`, če želite eno odstraniti, ne da bi jo zamenjali.

Če vztrajate pri hekanju notranjih datotek Omarchy, preklopite na razvojni kanal prek _Posodobitev > Kanal > Dev_. To poveže Omarchy z git izvodom izvorne kode v `~/omarchy`, ki ga lahko spreminjate po mili volji. Tukaj vam nihče ne bo govoril, kaj morate početi!

### Ponastavitev vseh sprememb

Če boste na koncu naredili zmešnjavo s konfiguracijami, jih lahko vedno vrnete na privzete prek _Posodobitev > Konfiguracija_ v meniju Omarchy. Ali tako, da zaženete `omarchy reinstall configs`, da ponastavite vse.
