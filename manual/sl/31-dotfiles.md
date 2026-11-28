# Dotfiles

Omarchy se v prvi vrsti konfigurira prek tako imenovanih datotek dotfiles, ki se nahajajo v `~/.config`. Te veljajo za vaše datoteke za vaše spremembe. Datoteke, ki se nahajajo v `/usr/share/omarchy`, pripadajo samemu sistemu Omarchy in se z njimi ne bi smeli ukvarjati. Če morate kaj spremeniti v `/usr/share/omarchy`, morate namesto tega prepisati vrednost v `~/.config`.

Ključne konfiguracije lahko urejate naravnost iz menija Omarchy (`Super + Space`), na primer _Setup > Keyboard > Keybindings_, _Setup > Input_ in _Setup > Config > [file]_. Kadar to storite na ta način, se bo vsak proces, ki ga je treba po urejanju konfiguracije znova zagnati, po zaprtju urejevalnika znova zagnal samodejno (privzeto Neovim — `:wq`, ne pozabite! — vendar lahko to spremenite prek _Setup > Defaults > Editor_).

Tukaj je seznam ključnih datotek v `~/.config` in tega, kaj nadzorujejo:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Glavna konfiguracija za Hyprland. Naloži privzete nastavitve Omarchy in vaše spodnje datoteke za prepis. [Več o konfiguracijah Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Vaše lastne tipkovne bližnjice in prepisi privzetih. |
| `~/.config/hypr/monitors.lua` | Nastavitve zaslonov, ki jih plošča za zaslone ne pokriva, kot so vrtenje, dodatni načini ali izklopljen zaslon. |
| `~/.config/hypr/input.lua` | Nadzira razporeditev tipkovnice, nastavitve miške in sledilne ploščice. |
| `~/.config/hypr/looknfeel.lua` | Nadzira razmake, robove, animacije in preostali videz. |
| `~/.config/hypr/autostart.lua` | Nadzira dodatne procese, ki se zaženejo skupaj s sejo. |
| `~/.config/omarchy/shell.json` | Nadzira lupino Omarchy: položaj vrstice, postavitev in gradnike ter časovne nastavitve ohranjevalnika zaslona, zaklepanja in nedejavnosti. |
| `~/.config/foot/foot.ini` | Nadzira vaš terminal (foot je privzeti). |
| `~/.XCompose` | Določa vaše emojije za hitri dostop in samodejno dopolnjevanje imena/e-pošte. Po spremembah obvezno zaženite `omarchy-restart-xcompose`. |

Če na koncu naredite veliko sprememb za prilagoditev lastne nastavitve, je dobro narediti varnostno kopijo vseh teh datotek dotfiles. [Stow je odličen način za to](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Zagon lastnih aplikacij ob začetku seje

Če želite, da se nekaj zažene ob vsaki prijavi — demon za sinhronizacijo, aplikacija za klepet, vaš lastni skript — to vstavite v `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Tako se ukaz zažene kot del seje, zato se ob odjavi pravilno pospravi.

### Izvajanje skriptov ob sistemskih dogodkih

Omarchy ob nekaj priložnostih sproži hooke, nanje pa lahko obesite svoje lastne skripte. Nahajajo se v `~/.config/omarchy/hooks/<event>.d/`, po en imenik za vsak dogodek, in vsaka datoteka tam, ki se ne konča s `.sample`, se ob dogodku zažene z bash:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Takoj po zagonu namizja |
| `post-update` | Proti koncu `omarchy update`, po paketih, migracijah in ponovnih zagonih storitev, preden se posodobijo orodja mise |
| `pre-refresh-pacman` | Potem ko `omarchy refresh pacman` znova sinhronizira konfiguracijo paketov, preden posodobi pakete; preklop kanala ga zažene med istim korakom osvežitve |
| `theme-set` | Po spremembi teme (ime teme v `$1`) |
| `font-set` | Po spremembi pisave (ime pisave v `$1`) |
| `battery-low` | Ko je baterija skoraj prazna (odstotek v `$1`) |

Hook `pre-refresh-pacman` je mesto, kamor sodijo repozitoriji po meri ali vrstice `IgnorePkg`, saj se zažene pred transakcijo paketov. Oba se izvajata kot vaš uporabnik. `post-update` se izvaja, dokler je pooblastilo sudo za `omarchy update` še sveže, zato hook, ki uporablja `sudo`, ne bo znova zahteval vašega gesla; `pre-refresh-pacman` se zažene takoj potem, ko je `omarchy refresh pacman` sam uporabil sudo.

Vsak od teh imenikov že vsebuje datoteko `.sample`, ki prikazuje obliko hooka — odstranite `.sample` iz imena, da ga uveljavite. Za namestitev skripta, ki ste ga napisali drugje, uporabite `omarchy hook install post-boot ~/my-hook`, ki ga kopira tja in naredi izvedljivega.

### Dodajanje lastnih vnosov v meni

Meni Omarchy (`Super + Space`) lahko razširite z lastnimi vrsticami z urejanjem `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Vnosi so opredeljeni s pikčastim id-jem in ta id jih umešča v drevo, zato se `personal` prikaže v korenskem meniju, `personal.notes` pa znotraj njega:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Če znova uporabite obstoječi id, to vrstico prepišete, namesto da bi dodali novo. Datoteka je dobavljena z vsemi razpoložljivimi polji, dokumentiranimi kot komentarji.

### Dodajanje lastnih izvozov lupine, funkcij in aliasov

Omarchy je dobavljen s kupom ergonomskih aliasov in koristnih funkcij, vendar je zelo pogosto, da želite dodati svoje. Aliase, funkcije in izvoze morate dodati v `~/.bashrc`. Ta datoteka ob posodobitvah ne bo prepisana. Če želite spremeniti katero koli privzeto nastavitev Omarchy, jo lahko tudi varno dodate tukaj.

### Nastavljanje okoljskih spremenljivk za namizje

Izvozi seje namizja sodijo v `~/.config/uwsm/env.d/`. Te datoteke se zaženejo, preden se zažene vaše namizje, zato vas napaka v lupini lahko vrne na prijavni zaslon. Med urejanjem imejte odprt delujoč terminal. Če želite prepis onemogočiti, ga premaknite iz `env.d`. Če sprememba prepreči prijavo, glejte [obnovitev prijave](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen).

### Spreminjanje notranjih datotek Omarchy

Poglejte, to je vaš računalnik. Z njim lahko počnete, kar želite, vendar vam odsvetujem neposredno spreminjanje datotek v `/usr/share/omarchy`. Pripadajo paketu pacman za Omarchy, zato bodo vaše spremembe ob naslednji posodobitvi preprosto prepisane. Bolje je, da namesto tega v mapi `~/.config/*` preprosto prepišete vse privzete vrednosti, ki vam niso všeč.

Na ta način lahko spremenite skoraj vse, na primer privzete tipkovne bližnjice. Preprosto uredite `~/.config/hypr/bindings.lua`, da, recimo, zamenjate [Obsidian](https://obsidian.md/) z [Joplin](https://joplinapp.org/) (namestite z `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` odstrani obstoječo vezavo, preden doda njeno zamenjavo. Sprejme iste argumente kot `o.bind`, vključno s pomočniki za zagon in možnostmi vezave. Uporabite `o.bind` za dodajanje vezave ali `hl.unbind` za odstranitev vezave brez zamenjave.

Če vztrajate pri hekanju notranjih datotek Omarchy, preklopite na kanal dev prek _Update > Channel > Dev_. To poveže Omarchy s kopijo izvorne kode git v `~/omarchy`, ki jo lahko spreminjate po mili volji. Tukaj vam nihče ne bo govoril, kaj smete početi!

### Ponastavitev vseh sprememb

Če na koncu naredite zmešnjavo s konfiguracijami, jih lahko kadar koli vrnete na privzete prek _Update > Config_ v meniju Omarchy. Ali tako, da zaženete `omarchy reinstall configs` in ponastavite vse.
