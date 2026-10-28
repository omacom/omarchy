# Preklopi, nedejavnost in ohranjevalnik zaslona

Veliko tega, kar spreminjaš iz dneva v dan, v resnici ni nastavitev. Je način, ki ga vklopiš za eno uro in nato spet izklopiš: nočna svetloba, ko delaš pozno v noč, ne moti, ko predstavljaš, ostani buden, ko nekaj gledaš. Omarchy jim pravi preklopi in vsi delujejo na enak način — bližnjica, vnos v meniju in ukaz, vsi zadenejo isto stikalo.

### Meni preklopov

`Super + Ctrl + O` neposredno odpre _Trigger > Toggle_, lahko pa prideš tja tudi iz menija Omarchy (`Super + Space`). Vse na tem seznamu je stikalo, ki ga lahko preklopiš, ne da bi razmišljal, kje živi stanje. Stikala za videz namizja so tik zraven, pod _Appearance_.

Iz terminala so ista stikala `omarchy toggle <thing>`. Zaženi samo `omarchy toggle`, da vidiš celotno skupino.

| Preklop | Bližnjica | Ukaz |
| ------ | ------ | ------- |
| Nočna svetloba | — | `omarchy toggle nightlight` |
| Utišaj obvestila | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Ostani buden (brez zaklepanja ob nedejavnosti) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Zajemanje zrušitev | — | `omarchy toggle crash-capture` |
| Ohranjevalnik zaslona | — | `omarchy toggle screensaver` |
| Sinhronizacija teme [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Menijska vrstica | `Super + Shift + Space` | `omarchy toggle bar` |
| Sledilna ploščica | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Zaslon na dotik | — | `omarchy toggle touchscreen` |
| Začasna zaustavitev | — | `omarchy toggle suspend` |
| Hibridni GPU | — | `omarchy toggle hybrid gpu` |

Preklopi za sledilno ploščico, zaslon na dotik in hibridni GPU so pod _Trigger > Hardware_ (`Super + Ctrl + H`) in ne pod Toggle, saj se prikažejo samo, kadar dejansko imaš to strojno opremo. Preklopa za sledilno ploščico in zaslon na dotik preživita ponovno nalaganje Hyprland — ime onemogočene naprave se shrani v majhno datoteko stanja, ki jo Hyprland ob zagonu prebere, da jo znova onemogoči.

_Appearance_ vsebuje menijsko vrstico in animacije ter nekaj stvari, ki niso ukazi `omarchy toggle`, a se obnašajo enako: odstotek baterije v vrstici, privzeto postavitev delovnih površin in pod _Windows_ razmike med okni (`Super + Shift + Backspace`) ter kvadratno razmerje stranic za 1 okno (`Super + Ctrl + Backspace`).

Večina teh je preprosto datoteka z zastavico pod `~/.local/state/omarchy/toggles/`. Če želiš v skripti vejo izbrati glede na eno od njih, ti `omarchy-toggle-enabled` da izhodno kodo, namesto da bi moral iti iskat:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Zastavice so poimenovane po izklopljenem stanju — `screensaver-off`, `suspend-off`, `bar-off` — zato njihova prisotnost pomeni, da je funkcija onemogočena.

### Indikatorji v vrstici

Kadar je način vklopljen, dobiš majhen glif na sredini zgornje vrstice poleg ure. To je pripomoček za indikatorje in nosi narekovanje, snemanje zaslona, čakajoče opomnike, nočno svetlobo, ne moti in ostani buden.

Neaktivni indikatorji so skriti. Z miško se pomakni kamorkoli na vrstico in pojavili se bodo zatemnjeni, tako da lahko enega klikneš in ga vklopiš, ne da bi poznal njegovo bližnjico. Klik na aktivnega ga znova izklopi. Če jih raje vidiš vse ves čas, nastavi `alwaysShow` na `true` pri vnosu `omarchy.indicators` v `~/.config/omarchy/shell.json` — glej [zgornjo vrstico](05-the-top-bar.md) za to, kako se konfigurirajo pripomočki v vrstici.

### Nočna svetloba

Nočna svetloba ogreje zaslon na 4000K, ponovni preklop pa ga vrne na 6500K. Preklopiš jo iz menija preklopov (`Super + Ctrl + O`) ali z `omarchy toggle nightlight`. Poganja jo hyprsunset, ki ga preklop zažene zate, če še ne teče.

Privzeto hyprsunset tvojemu zaslonu sploh nič ne naredi. `~/.config/hypr/hyprsunset.conf` ima profil identitete prav zato, da zaslon ostane nedotaknjen, dokler ne zahtevaš topline. Če raje želiš, da preklaplja po uri, to zamenjaj s časovnim profilom:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Nato zaženi hyprsunset ob prijavi tako, da dodaš `o.launch_on_start("hyprsunset")` v `~/.config/hypr/autostart.lua`. Par 4000K/6500K, ki ga uporablja preklop, je fiksen, zato je konfiguracijska datoteka kraj, kamor greš, če želiš drugačno temperaturo.

### Ne moti

`Super + Ctrl + Alt + ,` utiša obvestila. Dokler je vklopljeno, se ne prikazujejo nobeni pojavni napisi, prečrtan zvonec v vrstici pa te opominja, zakaj je namizje utihnilo.

Nič pa se ne izgubi. Utišana obvestila se zadržijo: zadnjih nekaj vrneš na zaslon s `Super + Shift + Alt + ,`. Glej [obvestila](10-notices.md) za ostalo.

Dve vrsti sporočil vseeno prideta skozi: Omarchyjeva lastna potrditvena pojavna sporočila za nekaj, kar si pravkar naredil (»Theme changed«, »Screenshot saved«), in kritična opozorila, poslana iz ukazne vrstice. Klepetalne aplikacije, ki vse označijo kot kritično, da se na silo postavijo predte, se ne štejejo.

### Nedejavnost

Vedenje ob nedejavnosti je v lasti lupine Omarchy, časovne nastavitve pa so blok `idle` na najvišji ravni v `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Obe številki sta sekundi, šteti od trenutka, ko si postal nedejaven — ne ena od druge. Tako se s privzetima nastavitvama ohranjevalnik zaslona prikaže po dveh minutah in pol, zaklenjeni zaslon pa prevzame pri petih minutah, ne glede na to, ali se je ohranjevalnik zagnal ali ne. Shrani datoteko in lupina nove časovne nastavitve prevzame takoj.

Če ohranjevalnik zaslona zavrneš pred rokom za zaklepanje, to šteje kot dejavnost in čakajoče zaklepanje se prekliče. Ne boš zaklenjen ven, ker si pogledal svoj stroj.

Če želiš zaklepanje ob nedejavnosti popolnoma ustaviti, `Super + Ctrl + I` — ali `omarchy toggle idle` — vklopi ostani buden in v vrstici se prikaže indikator skodelice kave. To je tisti, ki ga pritisneš pred dolgo predstavitvijo ali gradnjo, ki jo želiš spremljati. Pritisni ga znova, da se vrneš v normalno stanje. `omarchy toggle idle status` izpiše trenutno stanje kot JSON, če ga potrebuješ iz skripte.

Tu gre za zaklepanje in ohranjevalnik zaslona, ne za napajanje. Začasna zaustavitev in hibernacija imata svojo nastavitev v [spanju sistema](36-system-sleep.md).

### Ohranjevalnik zaslona

Omarchyjev ohranjevalnik zaslona je umetnost ASCII, ki teče skozi naključne besedilne učinke, en primerek na monitor. Vsaka tipka ali premik miške ga zapusti.

Na zahtevo ga lahko zaženeš iz _System > Screensaver_ (`Super + Esc`), kar ga vsili navzgor, tudi če si ohranjevalnik ob nedejavnosti izklopil. Privzeto nanj ni vezana nobena bližnjica.

`omarchy toggle screensaver` je tisto, kar izklopi tistega ob nedejavnosti, če raje greš naravnost iz dela v zaklenjeno stanje. Potrebuje terminal, ki ga zna konfigurirati — Alacritty, Foot, Ghostty ali Kitty — in ti bo to povedal, če je tvoj privzeti terminal kaj drugega.

Logotip, ki ga riše, lahko spremeniš pod _Appearance > Branding > Screensaver_. Naloži png ali svg in Omarchy ga pretvori v ASCII. Glej [blagovno znamko](41-branding.md).

### Zaklenjeni zaslon

`Super + Ctrl + L` zaklene stroj. To zažene zaklenjeni zaslon iz lupine Omarchy, zatemni zaslon, ponastavi postavitev tipkovnice na prvo, da gesla ne tipkaš v napačni abecedi, in — če ga imaš zagnanega — na poti ven zaklene 1Password.

Zaklenjeni zaslon sprejme geslo, sprejel pa bo tudi prstni odtis, ko ga nastaviš. To in druge načine avtentikacije obravnava [strojna avtentikacija](37-hardware-authentication.md).
