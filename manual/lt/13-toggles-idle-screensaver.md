# Perjungikliai, tuščioji eiga ir ekrano užsklanda

Daug kas, ką keiti kasdien, iš tikrųjų nėra nustatymas. Tai režimas, kurį įjungi valandai ir vėl išjungi: naktinė šviesa, kai dirbi vėlai, netrukdymo režimas, kai pristatai, budėjimo režimas, kai ką nors žiūri. Omarchy juos vadina perjungikliais, ir jie visi veikia vienodai — spartusis klavišas, meniu įrašas ir komanda, visi kreipiasi į tą patį jungiklį.

### Perjungiklių meniu

`Super + Ctrl + O` tiesiogiai atveria _Trigger > Toggle_, arba gali ten nueiti iš Omarchy meniu (`Super + Space`). Viskas tame sąraše yra jungiklis, kurį gali perjungti negalvodamas, kur saugoma būsena. Jungikliai, kaip atrodo darbalaukis, yra šalia, skiltyje _Appearance_.

Iš terminalo tie patys jungikliai yra `omarchy toggle <thing>`. Paleisk `omarchy toggle` patį savaime, kad pamatytum visą grupę.

| Perjungiklis | Spartusis klavišas | Komanda |
| ------ | ------ | ------- |
| Naktinė šviesa | — | `omarchy toggle nightlight` |
| Nutildyti pranešimus | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Likti budriam (be užrakinimo dėl tuščiosios eigos) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Strigčių fiksavimas | — | `omarchy toggle crash-capture` |
| Ekrano užsklanda | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) temos sinchronizavimas | — | `omarchy toggle theme sync` |
| Meniu juosta | `Super + Shift + Space` | `omarchy toggle bar` |
| Viso ekrano darbalaukis (be juostos, be tarpų) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animacijos, suliejimas ir šešėliai | — | `omarchy toggle animations` |
| Jutiklinė aikštelė | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Jutiklinis ekranas | — | `omarchy device touchscreen` |
| Sustabdymas | — | `omarchy toggle suspend` |
| Hibridinis GPU | — | `omarchy device gpu hybrid` |

Jutiklinės aikštelės, jutiklinio ekrano ir hibridinio GPU jungikliai yra skiltyje _Trigger > Hardware_ (`Super + Ctrl + H`), o ne skiltyje Toggle, nes jie rodomi tik tada, kai iš tikrųjų turi tą aparatinę įrangą. Jutiklinės aikštelės ir jutiklinio ekrano jungikliai išlieka po Hyprland perkrovimo — išjungto įrenginio pavadinimas įrašomas į mažą būsenos failą, kurį Hyprland perskaito paleidžiant, kad vėl jį išjungtų.

_Appearance_ saugo meniu juostą ir animacijas, taip pat kelis dalykus, kurie nėra `omarchy toggle` komandos, bet elgiasi taip pat: akumuliatoriaus procentus juostoje, numatytąjį darbo sričių išdėstymą ir skiltyje _Windows_ — langų tarpus (`Super + Shift + Backspace`) bei 1 lango kvadratinį kraštinių santykį (`Super + Ctrl + Backspace`).

Kai Hyprland neturi GPU, su kuriuo galėtų piešti, ir vietoj to atvaizduoja naudodamas CPU (llvmpipe), kaip Mac kompiuteriuose, kurių GPU dar nepalaikomas, daugumoje virtualių mašinų arba kai nepavyksta įkelti grafikos tvarkyklės, Omarchy tai sesijai išjungia animacijas, suliejimą ir šešėlius ir vieną kartą apie tai praneša pranešimu. _Appearance > Animations On_ juos sugrąžina, ir Omarchy tai prisimena ir vėlesnėms sesijoms.

Dauguma jų tėra žymos failas kataloge `~/.local/state/omarchy/toggles/`. Jei scenarijuje nori pagal jį šakotis, `omarchy-toggle-enabled` pateikia išėjimo kodą, užuot vertęs tavęs jo ieškoti:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Žymos pavadintos pagal išjungtą būseną — `screensaver-off`, `suspend-off`, `bar-off` — todėl jų buvimas reiškia, kad funkcija išjungta.

### Indikatoriai juostoje

Kai režimas įjungtas, viršutinės juostos viduryje šalia laikrodžio gauni mažą glifą. Tai indikatorių valdiklis, ir jame yra ekrano įrašymas, laukiantys priminimai, naktinė šviesa, netrukdymo režimas ir budėjimo režimas, taip pat įspėjimai, kol įjungtas sudo be slaptažodžio arba kas nors prisijungęs prie nuotolinės sesijos.

Neaktyvūs indikatoriai paslėpti. Užvesk pelę bet kur ant juostos ir jie blankiai pasirodys, kad galėtum spustelėti vieną ir jį įjungti nežinodamas jo sparčiojo klavišo. Spustelėjus aktyvų, jis vėl išjungiamas. Jei verčiau norėtum juos visus matyti visą laiką, nustatyk `alwaysShow` į `true` įraše `omarchy.indicators` faile `~/.config/omarchy/shell.json` — žr. [viršutinę juostą](05-the-top-bar.md), kaip konfigūruojami juostos valdikliai.

### Naktinė šviesa

Naktinė šviesa pašildo ekraną iki 4000K, o perjungus ją dar kartą, grąžinama 6500K. Perjunk ją iš perjungiklių meniu (`Super + Ctrl + O`) arba su `omarchy toggle nightlight`. Ją valdo hyprsunset, kurį perjungiklis paleidžia už tave, jei jis dar neveikia.

Pagal numatytuosius nustatymus hyprsunset tavo ekranui nedaro nieko. `~/.config/hypr/hyprsunset.conf` pateikiamas su tapatybės profiliu būtent tam, kad ekranas liktų nepaliestas, kol nepaprašysi šilumos. Jei verčiau norėtum, kad jis persijungtų pagal laikrodį, pakeisk jį laiko profiliu:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Tada paleisk hyprsunset prisijungus, pridėdamas `o.launch_on_start("hyprsunset")` į `~/.config/hypr/autostart.lua`. Perjungiklio naudojama 4000K/6500K pora yra fiksuota, todėl konfigūracijos failas yra ta vieta, kur eiti, jei nori kitokios temperatūros.

### Netrukdyti

`Super + Ctrl + Alt + ,` nutildo pranešimus. Kol jis įjungtas, neiššoka jokie pranešimai, o perbraukto varpelio indikatorius juostoje primena, kodėl darbalaukis nutylo.

Vis dėlto niekas neprarandama. Nutildyti pranešimai sulaikomi: paskutinius kelis vėl parodyk ekrane su `Super + Shift + Alt + ,`. Žr. [pranešimus](10-notices.md) dėl likusios dalies.

Triejų rūšių pranešimai vis tiek prasiskverbia: patys Omarchy patvirtinimo pranešimai apie tai, ką ką tik padarei ("Theme changed", "Screenshot saved"), kritiniai įspėjimai, siunčiami iš komandinės eilutės, ir patvirtinimo kodai. Pokalbių programėlės, kurios viską žymi kaip kritinius, kad priverstų save iškilti prieš tave, netinka.

### Tuščioji eiga

Omarchy apvalkalas valdo tuščiosios eigos elgseną, o trukmės yra aukščiausio lygio `idle` blokas faile `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Abu skaičiai yra sekundės, skaičiuojamos nuo momento, kai tapai neaktyvus — ne vienas nuo kito. Taigi su numatytosiomis reikšmėmis ekrano užsklanda pasirodo po dviejų su puse minutės, o užrakinimo ekranas perima po penkių minučių, nepriklausomai nuo to, ar ekrano užsklanda veikė. Įrašyk failą ir apvalkalas iš karto perims naujas trukmes.

Jei atmesi ekrano užsklandą prieš užrakinimo terminą, tai laikoma aktyvumu ir laukiantis užrakinimas atšaukiamas. Nebūsi užrakintas už tai, kad žvilgtelėjai į savo kompiuterį.

Norėdamas visiškai sustabdyti užrakinimą dėl tuščiosios eigos, `Super + Ctrl + I` — arba `omarchy toggle idle` — įjungia budėjimo režimą, ir juostoje pasirodo kavos puodelio indikatorius. Tai tas, kurį reikia paspausti prieš ilgą pristatymą ar kompiliavimą, kurį nori stebėti. Paspausk jį dar kartą, kad grįžtum į įprastą režimą. `omarchy toggle idle status` atspausdina dabartinę būseną kaip JSON, jei jos reikia iš scenarijaus.

Tai susiję su užrakinimu ir ekrano užsklanda, o ne su maitinimu. Sustabdymas ir užmigdymas turi savo sąranką skyriuje [sistemos miegas](36-system-sleep.md).

### Ekrano užsklanda

Omarchy ekrano užsklanda yra ASCII menas, leidžiamas per atsitiktinius teksto efektus, po vieną egzempliorių kiekvienam monitoriui. Bet koks klavišas ar pelės judesys iš jos išeina.

Gali ją paleisti pagal poreikį iš _System > Screensaver_ (`Super + Esc`), kas priverstinai ją parodo, net jei išjungei tuščiosios eigos ekrano užsklandą. Pagal numatytuosius nustatymus jai nepriskirtas joks spartusis klavišas.

`omarchy toggle screensaver` išjungia tuščiosios eigos užsklandą, jei verčiau norėtum eiti tiesiai nuo darbo prie užrakinto ekrano. Bet koks klavišas, spustelėjimas, slinkimas ar pelės judesys ją uždaro.

Jos piešiamą logotipą gali keisti skiltyje _Appearance > Branding > Screensaver_. Įkelk png arba svg ir Omarchy jį pavers į ASCII. Žr. [prekės ženklą](41-branding.md).

### Užrakinimo ekranas

`Super + Ctrl + L` užrakina kompiuterį. Tai paleidžia užrakinimo ekraną iš Omarchy apvalkalo, užtamsina ekraną, atstato klaviatūros išdėstymą į pirmąjį, kad nerašytum slaptažodžio netinkama abėcėle, ir — jei turi ją paleistą — pakeliui užrakina 1Password.

Užrakinimo ekranas priima slaptažodį, ir priims ir piršto atspaudą, kai jį būsi nustatęs. Tai ir kiti autentifikavimo būdai aptariami skyriuje [aparatinės įrangos autentifikavimas](37-hardware-authentication.md).
