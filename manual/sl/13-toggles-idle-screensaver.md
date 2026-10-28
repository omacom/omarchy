# Preklopi, nedejavnost in ohranjevalnik zaslona

Veliko tega, kar spreminjaš iz dneva v dan, v resnici ni nastavitev. Je način, ki ga vklopiš za eno uro in nato spet izklopiš: nočna svetloba, ko delaš pozno, ne moti, ko predstavljaš, ostani buden, ko nekaj gledaš. Omarchy jim pravi preklopi in vsi delujejo na enak način — bližnjica, vnos v meniju in ukaz, vsi zadenejo isto stikalo.

### Meni preklopov

`Super + Ctrl + O` neposredno odpre _Trigger > Toggle_, ali pa tja prideš iz menija Omarchy (`Super + Space`). Vse na tem seznamu je stikalo, ki ga lahko preklopiš, ne da bi razmišljal, kje živi stanje. Stikala za videz namizja so zraven, pod _Appearance_.

Iz terminala so ista stikala `omarchy toggle <thing>`. Zaženi samo `omarchy toggle`, da vidiš celotno skupino.

| Preklop | Bližnjica | Ukaz |
| ------ | ------ | ------- |
| Nočna svetloba | — | `omarchy toggle nightlight` |
| Utišaj obvestila | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Ostani buden (brez zaklepanja ob nedejavnosti) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Zajem ob zrušitvi | — | `omarchy toggle crash-capture` |
| Ohranjevalnik zaslona | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) sinhronizacija teme | — | `omarchy toggle theme sync` |
| Menijska vrstica | `Super + Shift + Space` | `omarchy toggle bar` |
| Sledilna ploščica | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Zaslon na dotik | — | `omarchy toggle touchscreen` |
| Začasna zaustavitev | — | `omarchy toggle suspend` |
| Hibridni GPU | — | `omarchy toggle hybrid gpu` |

Preklopi za sledilno ploščico, zaslon na dotik in hibridni GPU živijo pod _Trigger > Hardware_ (`Super + Ctrl + H`) in ne pod Toggle, saj se prikažejo le, ko to strojno opremo dejansko imaš. Preklopa za sledilno ploščico in zaslon na dotik preživita ponovno nalaganje Hyprlanda — ime onemogočene naprave se shrani v majhno datoteko stanja, ki jo Hyprland prebere ob zagonu in napravo znova onemogoči.

_Appearance_ vsebuje menijsko vrstico in animacije ter nekaj stvari, ki niso ukazi `omarchy toggle`, a se obnašajo enako: odstotek baterije v vrstici, privzeto postavitev delovnih površin in pod _Windows_ vrzeli med okni (`Super + Shift + Backspace`) ter kvadratno razmerje stranic za 1 okno (`Super + Ctrl + Backspace`).

Večina teh je le datoteka z zastavico pod `~/.local/state/omarchy/toggles/`. Če želiš nanjo vejati v skripti, ti `omarchy-toggle-enabled` da izhodno kodo, namesto da bi moral iskati sam:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Zastavice so poimenovane po izklopljenem stanju — `screensaver-off`, `suspend-off`, `bar-off` — zato njihova prisotnost pomeni, da je funkcija onemogočena.

### Kazalniki v vrstici

Ko je način vklopljen, dobiš majhen glif na sredini zgornje vrstice ob uri. To je gradnik kazalnikov in nosi narekovanje, snemanje zaslona, čakajoče opomnike, nočno svetlobo, ne moti in ostani buden.

Neaktivni kazalniki so skriti. Zadrži kazalec kjer koli na vrstici in zbledelo se prikažejo, tako da lahko enega klikneš in ga vklopiš, ne da bi poznal njegovo bližnjico. Klik na aktivnega ga spet izklopi. Če jih želiš videti vse ves čas, nastavi `alwaysShow` na `true` pri vnosu `omarchy.indicators` v `~/.config/omarchy/shell.json` — glej [zgornjo vrstico](05-the-top-bar.md) za to, kako se gradniki vrstice nastavijo.

### Nočna svetloba

Nočna svetloba segreje zaslon na 4000K, ponovni preklop pa ga vrne na 6500K. Preklopi jo iz menija preklopov (`Super + Ctrl + O`) ali z `omarchy toggle nightlight`. Poganja jo hyprsunset, ki ga preklop zažene zate, če še ne teče.

Privzeto hyprsunset z tvojim zaslonom ne naredi popolnoma nič. `~/.config/hypr/hyprsunset.conf` je dobavljen s profilom identitete prav zato, da zaslon ostane nedotaknjen, dokler ne zahtevaš topline. Če želiš, da preklaplja po uri, to zamenjaj s časovnim profilom:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Nato zaženi hyprsunset ob prijavi tako, da dodaš `o.launch_on_start("hyprsunset")` v `~/.config/hypr/autostart.lua`. Par 4000K/6500K, ki ga uporablja preklop, je fiksen, zato greš v konfiguracijsko datoteko, če želiš drugačno temperaturo.

### Ne moti

`Super + Ctrl + Alt + ,` utiša obvestila. Medtem ko je vklopljeno, se ne prikazujejo pojavna obvestila, prečrtan zvonec v vrstici pa te opominja, zakaj je namizje utihnilo.

Nič ni izgubljeno. Utišana obvestila so zadržana: zadnjih nekaj vrni na zaslon s `Super + Shift + Alt + ,`. Za ostalo glej [obvestila](10-notices.md).

Dve vrsti sporočil vseeno prodreta: lastna potrditvena pojavna obvestila Omarchyja za nekaj, kar si pravkar naredil ("Theme changed", "Screenshot saved"), in kritična opozorila, poslana iz ukazne vrstice. Aplikacije za klepet, ki vse označijo kot kritično, da se ti na silo vrinejo v ospredje, se ne štejejo.

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

Obe številki sta sekundi, šteti od trenutka, ko si postal nedejaven — ne ena od druge. Zato se s privzetima nastavitvama ohranjevalnik zaslona prikaže po dveh minutah in pol, zaklenjeni zaslon pa prevzame pri petih minutah, ne glede na to, ali se je ohranjevalnik zagnal ali ne. Shrani datoteko in lupina nove časovne nastavitve prevzame takoj.

Če ohranjevalnik zaslona zapreš pred rokom za zaklepanje, to šteje kot dejavnost in čakajoče zaklepanje se prekliče. Ne bo te zaklenilo samo zato, ker si pogledal proti računalniku.

Da zaklepanje ob nedejavnosti popolnoma ustaviš, `Super + Ctrl + I` — ali `omarchy toggle idle` — vklopi ostani buden in v vrstici se prikaže kazalnik skodelice kave. Tega pritisni pred dolgo predstavitvijo ali gradnjo, ki jo želiš spremljati. Pritisni ga znova, da se vrneš v običajno stanje. `omarchy toggle idle status` izpiše trenutno stanje kot JSON, če ga potrebuješ iz skripte.

Gre za zaklepanje in ohranjevalnik zaslona, ne za napajanje. Začasna zaustavitev in mirovanje imata svojo nastavitev v [spanju sistema](36-system-sleep.md).

### Ohranjevalnik zaslona

Ohranjevalnik zaslona Omarchyja je ASCII umetnost, ki teče skozi naključne besedilne učinke, en primerek na monitor. Vsaka tipka ali premik miške ga zapre.

Na zahtevo ga lahko zaženeš iz _System > Screensaver_ (`Super + Esc`), kar ga prisilno prikaže, tudi če si ohranjevalnik ob nedejavnosti izklopil. Privzeto nanj ni vezane nobene bližnjice.

`omarchy toggle screensaver` je tisto, kar izklopi tistega ob nedejavnosti, če želiš iti naravnost od dela do zaklenjenega stanja. Vsaka tipka, klik, drsenje ali premik miške ga zapre.

Logotip, ki ga riše, lahko spremeniš pod _Appearance > Branding > Screensaver_. Naloži png ali svg in Omarchy ga pretvori v ASCII. Glej [celostno podobo](41-branding.md).

### Zaklenjeni zaslon

`Super + Ctrl + L` zaklene računalnik. To zažene zaklenjeni zaslon iz lupine Omarchy, izprazni zaslon, ponastavi postavitev tipkovnice na prvo, da gesla ne tipkaš v napačni abecedi, in — če ga imaš zagnanega — ob odhodu zaklene 1Password.

Zaklenjeni zaslon sprejme geslo, sprejel pa bo tudi prstni odtis, ko ga nastaviš. To in druge načine preverjanja pristnosti pokriva [strojno preverjanje pristnosti](37-hardware-authentication.md).
