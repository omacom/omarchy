# Preklopi, nedejavnost in ohranjevalnik

Veliko tega, kar spreminjate iz dneva v dan, v resnici ni nastavitev. To je način, ki ga za eno uro vklopite in nato spet izklopite: nočna svetloba, medtem ko delate pozno, ne moti, medtem ko predstavljate, ostanek budnosti, medtem ko nekaj gledate. Omarchy jim pravi preklopi in vsi delujejo enako — bližnjica, vnos v meni in ukaz, vsi zadenejo isto stikalo.

### Meni za preklop

`Super + Ctrl + O` neposredno odpre _Trigger > Toggle_ ali pa lahko do tja pridete iz menija Omarchy (`Super + Space`). Vse na tem seznamu je stikalo, ki ga lahko preklopite, ne da bi razmišljali o tem, kje stanje živi. Stikala za to, kako namizje izgleda, sedijo poleg njega, pod _Trigger > Appearance_.

Iz terminala so ista stikala `omarchy toggle <thing>`. Samostojno zaženite `omarchy toggle`, da vidite celotno skupino.

| Preklop | Bližnjica | Ukaz |
| ------ | ------ | ------- |
| Nočna svetloba | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Utišaj obvestila | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Ostani buden (brez zaklepanja v nedejavnosti) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Zajem sesutij | — | `omarchy toggle crash-capture` |
| Ohranjevalnik | — | `omarchy toggle screensaver` |
| Sinh. teme [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Menijska vrstica | `Super + Shift + Space` | `omarchy toggle bar` |
| Sledilna ploščica | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Zaslon na dotik | — | `omarchy toggle touchscreen` |
| Spanje | — | `omarchy toggle suspend` |
| Hibridni GPU | — | `omarchy toggle hybrid gpu` |

Stikala sledilne ploščice, zaslona na dotik in hibridnega GPU-ja živijo pod _Trigger > Hardware_ (`Super + Ctrl + H`) in ne pod Preklopi, saj se prikažejo le, ko dejansko imate to strojno opremo. Tista za sledilno ploščico in zaslon na dotik preživita vnovično nalaganje Hyprlanda — ime onemogočene naprave se shrani v majhno datoteko stanja, ki jo Hyprland bere ob zagonu, da jo znova onemogoči.

_Trigger > Appearance_ hrani menijsko vrstico in animacije, plus nekaj stvari, ki niso ukazi `omarchy toggle`, a se obnašajo enako: odstotek baterije v vrstici, privzeta postavitev delovnega prostora, razmiki oken (`Super + Shift + Backspace`) in razmerje kvadrata 1 okna (`Super + Ctrl + Backspace`).

Večina od teh je le datoteka z zastavico pod `~/.local/state/omarchy/toggles/`. Če želite v skriptu razvejati glede na eno, vam `omarchy-toggle-enabled` da izhodno kodo, namesto da bi vas silil iskati:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Zastavice so poimenovane po izklopljenem stanju — `screensaver-off`, `suspend-off`, `bar-off` — tako da njihova prisotnost pomeni, da je funkcija onemogočena.

### Kazalniki v vrstici

Ko je način vklopljen, dobite majhen glif na sredini menijske vrstice poleg ure. To je gradnik kazalnikov in nosi narekovanje, snemanje zaslona, čakajoče opomnike, nočno svetlobo, ne moti in ostanek budnosti.

Nedejavni kazalniki so skriti. Z miško se premaknite okoli njih in zbledijo zatemnjeni, tako da enega kliknete, da ga vklopite, ne da bi poznali njegovo bližnjico. Klik aktivnega ga izklopi. Če želite vse ves čas, nastavite `alwaysShow` na `true` na vnos `omarchy.indicators` v `~/.config/omarchy/shell.json` — glejte [menijska vrstica](05-the-top-bar.md) za to, kako se gradniki vrstice konfigurirajo.

### Nočna svetloba

`Super + Ctrl + N` zaslon segreje na 4000 K, vnovičen pritisk ga vrne na 6500 K. Poganja ga hyprsunset, ki ga preklop zažene namesto vas, če že ne teče.

Privzeto hyprsunset z vašim zaslonom ne naredi popolnoma ničesar. `~/.config/hypr/hyprsunset.conf` je dobavljen z identitetnim profilom natanko zato, da zaslon ostane nedotaknjen, dokler ne zaprosite za toplino. Če želite, da preklaplja po uri, ga zamenjajte s časovnim profilom:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Nato hyprsunset zaženite ob prijavi tako, da v `~/.config/hypr/autostart.lua` dodate `o.launch_on_start("hyprsunset")`. Par 4000 K/6500 K, ki ga uporablja preklop, je fiksiran, tako da je konfiguracijska datoteka kraj, kamor greste, če želite drugačno temperaturo.

### Ne moti

`Super + Ctrl + ,` utiša obvestila. Medtem ko je vključeno, se ne pojavljajo slastne objave, kazalnik prečrtanega zvonca pa sedi v vrstici, da vas spomni, zakaj je namizje utihnilo.

Nič pa ni izgubljeno. Utišano obvestilo se zapiše naravnost v zgodovino obvestil, kar je natanko zapis, ki ga želite, ko se vrnete in se sprašujete, kaj ste zamudili. Odprete ga s `Super + Shift + Alt + ,`. Za preostanek zgodbe o obvestilih glejte [obvestila](10-notices.md).

Dve vrsti sporočil še vedno prideta skozi: potrditvene objave samega Omarchyja za nekaj, kar ste pravkar naredili (»Theme changed«, »Screenshot saved«), in kritična opozorila, poslana iz ukazne vrstice. Klepetalnice, ki vse označijo kot kritično, da bi se vsilile pred vas, se ne uvrstijo.

### Nedejavnost

Lupina Omarchy je lastnik vedenja v nedejavnosti, timingi pa so blok `idle` na zgornji ravni v `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Obe številki sta sekunde, štete od trenutka, ko ste postali nedejavni — ne ena od druge. Tako se s privzetimi nastavitvami ohranjevalnik pojavijo po dveh minutah in pol, zaklenjeni zaslon pa prevzame pri petih minutah, ne glede na to, ali je ohranjevalnik tekel. Datoteko shranite in lupina nove timingse prevzame takoj.

Če ohranjevalnik odpustite pred rokom zaklepanja, to šteje kot dejavnost in čakajoče zaklepanje se prekliče. Ne boste zaklenjeni za pogled na računalnik.

Da zaklepanje v nedejavnosti v celoti ustavite, `Super + Ctrl + I` — ali `omarchy toggle idle` — vklopi ostanek budnosti in kazalnik skodelice kave se pojavi v vrstici. To je tisto, kar pritisnete pred dolgo predstavitvijo ali gradnjo, ki jo želite opazovati. Znova pritisnite, da se vrnete k običajnemu. `omarchy toggle idle status` izpiše trenutno stanje kot JSON, če ga potrebujete iz skripta.

To gre za zaklepanje in ohranjevalnik, ne za napajanje. Spanje in mirovanje imata lastno ureditev v [spanju sistema](36-system-sleep.md).

### Ohranjevalnik

Ohranjevalnik Omarchyja je umetnost ASCII, ki teče prek naključnih učinkov besedila, en primerek na zaslon. Vsak pritisk tipke ali premik miške ga zapusti.

Zaženete ga lahko na zahtevo iz _System > Screensaver_ (`Super + Esc`), kar ga vsili, tudi če ste ohranjevalnik v nedejavnosti izklopili. Privzeto nanj ni vezana nobena bližnjica.

`omarchy toggle screensaver` je tisto, kar izklopi tistega v nedejavnosti, če raje greste naravnost iz dela v zaklenjeno stanje. Potrebuje terminal, ki ga zna konfigurirati — Alacritty, Foot, Ghostty ali Kitty — in vam bo to povedal, če je vaš privzeti terminal nekaj drugega.

Logotip, ki ga riše, je vaš, da ga spremenite, pod _Style > Screensaver_. Naložite png ali svg in Omarchy ga pretvori v ASCII. Glejte [blagovno znamko](41-branding.md).

### Zaklenjeni zaslon

`Super + Ctrl + L` zaklene računalnik. To zažene zaklenjeni zaslon iz lupine Omarchy, zatmni prikaz, ponastavi razpored tipkovnice na prvega, tako da gesla ne tipkate v napačni abecedi, in — če ga imate zagnanega — na poti ven zaklene 1Password.

Zaklenjeni zaslon sprejme geslo, sprejel pa bo tudi prstni odtis, ko ga nastavite. To in drugi načini preverjanja pristnosti so obravnavani v [preverjanju pristnosti s strojno opremo](37-hardware-authentication.md).
