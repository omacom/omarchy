# Preklopi, nedejavnost in ohranjevalnik zaslona

Veliko tega, kar spreminjaš iz dneva v dan, pravzaprav ni nastavitev. Je način, ki ga vklopiš za eno uro in nato znova izklopiš: nočna svetloba, ko delaš pozno, ne moti, ko predstavljaš, ostani buden, ko nekaj gledaš. Omarchy jim pravi preklopi in vsi delujejo na enak način — bližnjica, vnos v meniju in ukaz, vsi zadenejo isto stikalo.

### Meni preklopov

`Super + Ctrl + O` neposredno odpre _Trigger > Toggle_ ali pa tja prideš iz menija Omarchy (`Super + Space`). Vse na tem seznamu je stikalo, ki ga lahko preklopiš, ne da bi razmišljal, kje živi stanje. Stikala za videz namizja so zraven, pod _Appearance_.

Iz terminala so ista stikala `omarchy toggle <thing>`. Zaženi samo `omarchy toggle`, da vidiš celotno skupino.

| Preklop | Bližnjica | Ukaz |
| ------ | ------ | ------- |
| Nočna svetloba | — | `omarchy toggle nightlight` |
| Utišanje obvestil | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Ostani buden (brez zaklepanja ob nedejavnosti) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Zajem ob sesutju | — | `omarchy toggle crash-capture` |
| Ohranjevalnik zaslona | — | `omarchy toggle screensaver` |
| Sinhronizacija teme [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Menijska vrstica | `Super + Shift + Space` | `omarchy toggle bar` |
| Sledilna ploščica | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Zaslon na dotik | — | `omarchy device touchscreen` |
| Zaustavitev | — | `omarchy toggle suspend` |
| Hibridni GPU | — | `omarchy toggle hybrid gpu` |

Preklopi za sledilno ploščico, zaslon na dotik in hibridni GPU so pod _Trigger > Hardware_ (`Super + Ctrl + H`) in ne pod Toggle, ker se prikažejo le, če to strojno opremo dejansko imaš. Preklopa za sledilno ploščico in zaslon na dotik preživita ponovno nalaganje Hyprlanda — ime onemogočene naprave se shrani v majhno datoteko stanja, ki jo Hyprland ob zagonu prebere in napravo znova onemogoči.

_Appearance_ vsebuje menijsko vrstico in animacije ter nekaj stvari, ki niso ukazi `omarchy toggle`, a se obnašajo enako: odstotek baterije v vrstici, privzeto postavitev delovnih prostorov in pod _Windows_ razmike med okni (`Super + Shift + Backspace`) ter kvadratno razmerje pri 1 oknu (`Super + Ctrl + Backspace`).

Kadar Hyprland nima GPU, s katerim bi risal, in namesto tega upodablja s CPU (llvmpipe), kot na Macih, katerih GPU še ni podprt, v večini VM ali kadar se grafični gonilnik ne naloži, Omarchy za to sejo izklopi animacije, zameglitev in sence ter ti to enkrat pove z obvestilom. _Appearance > Animations On_ jih vrne nazaj, Omarchy pa si to zapomni tudi za poznejše seje.

Večina teh je le datoteka z zastavico pod `~/.local/state/omarchy/toggles/`. Če želiš v skripti vejiti glede na enega od njih, ti `omarchy-toggle-enabled` da izhodno kodo, namesto da bi jo moral iskati sam:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Zastavice so poimenovane po izklopljenem stanju — `screensaver-off`, `suspend-off`, `bar-off` — zato njihova prisotnost pomeni, da je funkcija onemogočena.

### Indikatorji v vrstici

Ko je način vklopljen, dobiš majhen glif na sredini zgornje vrstice ob uri. To je gradnik indikatorjev in vsebuje narekovanje, snemanje zaslona, čakajoče opomnike, nočno svetlobo, ne moti in ostani buden.

Neaktivni indikatorji so skriti. Z miško se pomakni kamorkoli na vrstico in prikazali se bodo zatemnjeni, da lahko enega klikneš in ga vklopiš, ne da bi poznal njegovo bližnjico. Klik na aktivnega ga znova izklopi. Če želiš vse videti ves čas, nastavi `alwaysShow` na `true` pri vnosu `omarchy.indicators` v `~/.config/omarchy/shell.json` — glej [zgornjo vrstico](05-the-top-bar.md) za to, kako se gradniki vrstice konfigurirajo.

### Nočna svetloba

Nočna svetloba segreje zaslon na 4000K, ponovni preklop pa ga vrne na 6500K. Preklopiš jo iz menija preklopov (`Super + Ctrl + O`) ali z `omarchy toggle nightlight`. Poganja jo hyprsunset, ki ga preklop zažene zate, če še ne teče.

Privzeto hyprsunset tvojemu zaslonu ne naredi prav nič. `~/.config/hypr/hyprsunset.conf` je dobavljen z identitetnim profilom prav zato, da zaslon ostane nedotaknjen, dokler ne zahtevaš topline. Če želiš, da preklaplja po uri, ga zamenjaj s časovnim profilom:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Nato hyprsunset zaženi ob prijavi tako, da v `~/.config/hypr/autostart.lua` dodaš `o.launch_on_start("hyprsunset")`. Par 4000K/6500K, ki ga uporablja preklop, je fiksen, zato je konfiguracijska datoteka kraj, kamor greš, če želiš drugačno temperaturo.

### Ne moti

`Super + Ctrl + Alt + ,` utiša obvestila. Medtem ko je vklopljeno, se ne prikazujejo nobena pojavna obvestila, indikator prečrtanega zvonca v vrstici pa te opominja, zakaj je namizje utihnilo.

Nič ni izgubljenega. Utišana obvestila so zadržana: zadnjih nekaj jih vrneš na zaslon s `Super + Shift + Alt + ,`. Za ostalo glej [obvestila](10-notices.md).

Dve vrsti sporočil vseeno prodreta: Omarchyjeva lastna potrditvena pojavna obvestila za nekaj, kar si pravkar naredil ("Tema spremenjena", "Posnetek zaslona shranjen"), in kritična opozorila, poslana iz ukazne vrstice. Klepetalne aplikacije, ki vse označijo za kritično, da se na silo postavijo predte, ne štejejo.

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

Obe številki sta sekundi, šteti od trenutka, ko si postal nedejaven — ne ena od druge. S privzetimi nastavitvami se tako ohranjevalnik zaslona prikaže po dveh minutah in pol, zaklenjeni zaslon pa prevzame pri petih minutah, ne glede na to, ali je ohranjevalnik zaslona tekel ali ne. Shrani datoteko in lupina nove časovne nastavitve prevzame takoj.

Če ohranjevalnik zaslona zavrneš pred rokom za zaklepanje, to šteje kot dejavnost in čakajoče zaklepanje je preklicano. Ne bo te zaklenilo ven samo zato, ker si pogledal svoj računalnik.

Za popolno prenehanje zaklepanja ob nedejavnosti `Super + Ctrl + I` — ali `omarchy toggle idle` — vklopi ostani buden in v vrstici se prikaže indikator skodelice kave. Tega pritisni pred dolgo predstavitvijo ali gradnjo, ki jo želiš opazovati. Znova ga pritisni za vrnitev na običajno. `omarchy toggle idle status` izpiše trenutno stanje kot JSON, če ga potrebuješ iz skripte.

Tu gre za zaklepanje in ohranjevalnik zaslona, ne za napajanje. Zaustavitev in hibernacija imata svojo nastavitev v [spanju sistema](36-system-sleep.md).

### Ohranjevalnik zaslona

Omarchyjev ohranjevalnik zaslona je ASCII umetnost, ki teče skozi naključne besedilne učinke, en primerek na monitor. Katerakoli tipka ali premik miške ga zapre.

Zaženeš ga lahko na zahtevo iz _System > Screensaver_ (`Super + Esc`), kar ga prisilno prikaže, tudi če si ohranjevalnik zaslona ob nedejavnosti izklopil. Privzeto zanj ni vezane nobene bližnjice.

`omarchy toggle screensaver` izklopi tistega ob nedejavnosti, če greš raje naravnost od dela do zaklenjenosti. Zapre ga katerakoli tipka, klik, drsenje ali premik miške.

Logotip, ki ga riše, lahko spremeniš pod _Appearance > Branding > Screensaver_. Naloži png ali svg in Omarchy ga bo pretvoril v ASCII. Glej [znamko](41-branding.md).

### Zaklenjeni zaslon

`Super + Ctrl + L` zaklene računalnik. To zažene zaklenjeni zaslon iz lupine Omarchy, počrni zaslon, ponastavi postavitev tipkovnice na prvo, da gesla ne tipkaš v napačni abecedi, in — če ga imaš zagnanega — ob izhodu zaklene 1Password.

Zaklenjeni zaslon sprejme geslo, sprejel pa bo tudi prstni odtis, ko ga nastaviš. To in drugi načini preverjanja pristnosti so opisani v [preverjanju pristnosti s strojno opremo](37-hardware-authentication.md).
