# Preklopi, nedejavnost in ohranjevalnik zaslona

Veliko tega, kar spreminjaš iz dneva v dan, v resnici ni nastavitev. Je način, ki ga vklopiš za eno uro in nato spet izklopiš: nočna svetloba, ko delaš pozno, ne moti, ko predstavljaš, ostani buden, ko nekaj gledaš. Omarchy jim pravi preklopi in vsi delujejo na enak način — bližnjica, vnos v meniju in ukaz, vsi zadenejo isto stikalo.

### Meni preklopov

`Super + Ctrl + O` neposredno odpre _Sprožilec > Preklop_, ali pa se tja sprehodiš iz menija Omarchy (`Super + Space`). Vse na tem seznamu je stikalo, ki ga lahko preklopiš, ne da bi razmišljal, kje živi stanje. Stikala za videz namizja sedijo zraven, pod _Videz_.

Iz terminala so ista stikala `omarchy toggle <thing>`. Zaženi samo `omarchy toggle`, da vidiš celotno skupino.

| Preklop | Bližnjica | Ukaz |
| ------ | ------ | ------- |
| Nočna svetloba | — | `omarchy toggle nightlight` |
| Utišanje obvestil | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Ostani buden (brez zaklepanja ob nedejavnosti) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Zajem zrušitve | — | `omarchy toggle crash-capture` |
| Ohranjevalnik zaslona | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) sinhronizacija teme | — | `omarchy toggle theme sync` |
| Vrstica menija | `Super + Shift + Space` | `omarchy toggle bar` |
| Namizje na cel zaslon (brez vrstice, brez vrzeli) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animacije, zameglitev in sence | — | `omarchy toggle animations` |
| Sledilna ploščica | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Zaslon na dotik | — | `omarchy device touchscreen` |
| Začasna zaustavitev | — | `omarchy toggle suspend` |
| Hibridni GPU | — | `omarchy device gpu hybrid` |

Stikala za sledilno ploščico, zaslon na dotik in hibridni GPU živijo pod _Sprožilec > Strojna oprema_ (`Super + Ctrl + H`) in ne pod Preklop, saj se pokažejo le, ko to strojno opremo dejansko imaš. Preklopa za sledilno ploščico in zaslon na dotik preživita ponovno nalaganje Hyprland — ime onemogočene naprave se shrani v majhno datoteko stanja, ki jo Hyprland prebere ob zagonu, da jo znova onemogoči.

_Videz_ hrani vrstico menija in animacije ter nekaj stvari, ki niso ukazi `omarchy toggle`, a se obnašajo enako: odstotek baterije v vrstici, privzeto postavitev delovnih prostorov in pod _Okna_, vrzeli med okni (`Super + Shift + Backspace`) ter kvadratno razmerje 1 okna (`Super + Ctrl + Backspace`).

Ko Hyprland nima GPU za risanje in namesto tega upodablja s CPU (llvmpipe), kot na Macih, katerih GPU še ni podprt, v večini virtualnih strojev ali ko se grafični gonilnik ne naloži, Omarchy za to sejo izklopi animacije, zameglitev in sence in ti to enkrat pove z obvestilom. _Videz > Animacije vključene_ jih prikliče nazaj in Omarchy si to zapomni tudi za kasnejše seje.

Večina teh je le datoteka zastavice pod `~/.local/state/omarchy/toggles/`. Če se želiš v skripti vejiti na eno od njih, ti `omarchy-toggle-enabled` da izhodno kodo, namesto da bi moral iti iskat:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Zastavice so poimenovane po izklopljenem stanju — `screensaver-off`, `suspend-off`, `bar-off` — zato njihova prisotnost pomeni, da je funkcija onemogočena.

### Kazalniki v vrstici

Ko je način vklopljen, dobiš majhen glif na sredini zgornje vrstice ob uri. To je gradnik kazalnikov in nosi snemanje zaslona, čakajoče opomnike, nočno svetlobo, ne moti in ostani buden ter opozorila, ko je vklopljeno sudo brez gesla ali ko je nekdo povezan z oddaljeno sejo.

Neaktivni kazalniki so skriti. Z miško se pomakni kamorkoli nad vrstico in pojavili se bodo zatemnjeni, tako da lahko klikneš enega in ga vklopiš, ne da bi poznal njegovo bližnjico. Klik na aktivnega ga znova izklopi. Če jih raje vidiš vse ves čas, nastavi `alwaysShow` na `true` pri vnosu `omarchy.indicators` v `~/.config/omarchy/shell.json` — glej [zgornjo vrstico](05-the-top-bar.md) za to, kako se gradniki vrstice konfigurirajo.

### Nočna svetloba

Nočna svetloba segreje zaslon na 4000K, ponovni preklop pa ga vrne na 6500K. Preklopi jo iz menija preklopov (`Super + Ctrl + O`) ali z `omarchy toggle nightlight`. Poganja jo hyprsunset, ki ga preklop zažene zate, če še ne teče.

Privzeto hyprsunset tvojemu zaslonu sploh ne stori ničesar. `~/.config/hypr/hyprsunset.conf` je dobavljen z identitetnim profilom prav zato, da zaslon ostane nedotaknjen, dokler ne zahtevaš topline. Če raje preklaplja po uri, to zamenjaj s časovnim profilom:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Nato zaženi hyprsunset ob prijavi tako, da dodaš `o.launch_on_start("hyprsunset")` v `~/.config/hypr/autostart.lua`. Par 4000K/6500K, ki ga uporablja preklop, je fiksen, zato greš v konfiguracijsko datoteko, če želiš drugačno temperaturo.

### Ne moti

`Super + Ctrl + Alt + ,` utiša obvestila. Medtem ko je vklopljeno, se ne pojavljajo nobena pojavna obvestila, prečrtan zvonec kot kazalnik pa sedi v vrstici, da te opomni, zakaj je namizje utihnilo.

Nič pa ni izgubljeno. Utišana obvestila se zadržijo: zadnjih nekaj vrni na zaslon s `Super + Shift + Alt + ,`. Glej [obvestila](10-notices.md) za ostalo.

Tri vrste sporočil še vedno pridejo skozi: lastna potrditvena pojavna obvestila Omarchy za nekaj, kar si pravkar storil ("Tema spremenjena", "Posnetek zaslona shranjen"), kritična opozorila, poslana iz ukazne vrstice, in kode za preverjanje. Aplikacije za klepet, ki vse označijo kot kritično, da se ti na silo postavijo v ospredje, se ne kvalificirajo.

### Nedejavnost

Lupina Omarchy ima v lasti vedenje ob nedejavnosti, časovne nastavitve pa so blok `idle` na najvišji ravni v `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Obe številki sta sekundi, šteti od trenutka, ko si postal nedejaven — ne ena od druge. Torej se s privzetimi nastavitvami ohranjevalnik zaslona pojavi po dveh minutah in pol, zaklenjeni zaslon pa prevzame pri petih minutah, ne glede na to, ali se je ohranjevalnik zagnal ali ne. Shrani datoteko in lupina bo nove časovne nastavitve prevzela takoj.

Če ohranjevalnik opustiš pred rokom za zaklepanje, to šteje kot dejavnost in čakajoče zaklepanje se prekliče. Ne boš zaklenjen ven zato, ker si pogledal svoj stroj.

Če želiš zaklepanje ob nedejavnosti popolnoma ustaviti, `Super + Ctrl + I` — ali `omarchy toggle idle` — vklopi ostani buden in v vrstici se pojavi kazalnik skodelice kave. To je tisti, ki ga pritisni pred dolgo predstavitvijo ali gradnjo, ki jo želiš opazovati. Pritisni ga znova, da se vrneš v normalno stanje. `omarchy toggle idle status` izpiše trenutno stanje kot JSON, če ga potrebuješ iz skripte.

Tu gre za zaklepanje in ohranjevalnik zaslona, ne za napajanje. Začasna zaustavitev in hibernacija imata svojo nastavitev v [spanju sistema](36-system-sleep.md).

### Ohranjevalnik zaslona

Ohranjevalnik zaslona Omarchy je ASCII umetnost, ki teče skozi naključne besedilne učinke, en primerek na monitor. Vsaka tipka ali premik miške ga zapre.

Zagnati ga lahko na zahtevo iz _Sistem > Ohranjevalnik zaslona_ (`Super + Esc`), kar ga vsili navzgor, tudi če si nedejavni ohranjevalnik izklopil. Privzeto nanj ni vezane nobene bližnjice.

`omarchy toggle screensaver` je tisto, kar izklopi nedejavnega, če raje greš naravnost od dela do zaklenjenega. Vsaka tipka, klik, pomik ali premik miške ga zapre.

Logotip, ki ga riše, lahko spremeniš pod _Videz > Blagovna znamka > Ohranjevalnik zaslona_. Naloži png ali svg in Omarchy ga bo pretvoril v ASCII. Glej [blagovno znamko](41-branding.md).

### Zaklenjeni zaslon

`Super + Ctrl + L` zaklene stroj. To zažene zaklenjeni zaslon iz lupine Omarchy, zatemi zaslon, ponastavi postavitev tipkovnice na prvo, da gesla ne tipkaš v napačni abecedi, in — če ga imaš zagnanega — ob odhodu zaklene 1Password.

Zaklenjeni zaslon sprejme geslo, sprejel pa bo tudi prstni odtis, ko ga nastaviš. To in druge načine preverjanja pristnosti pokriva [strojno preverjanje pristnosti](37-hardware-authentication.md).
