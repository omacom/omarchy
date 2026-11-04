# Perjungikliai, neveiklumas ir ekrano užsklanda

Daugelis dalykų, kuriuos kasdien keičiate, iš tikrųjų nėra nustatymas. Tai režimas, kurį valandai įjungiate ir vėl išjungiate: naktinė šviesa, kai dirbate vėlai, netrukdymo režimas, kai pristatote, budėjimas, kai ką nors žiūrite. Omarchy juos vadina perjungikliais, ir jie visi veikia vienodai — spartusis klavišas, meniu įrašas ir komanda, visi pasiekiantys tą patį jungiklį.

### Perjungiklių meniu

`Super + Ctrl + O` tiesiogiai atveria _Trigger > Toggle_, arba galite ten nueiti iš Omarchy meniu (`Super + Space`). Viskas tame sąraše yra jungiklis, kurį galite perjungti negalvodami, kur saugoma jo būsena. Jungikliai, skirti darbalaukio išvaizdai, yra šalia, skiltyje _Appearance_.

Iš terminalo tie patys jungikliai pasiekiami kaip `omarchy toggle <thing>`. Paleiskite `omarchy toggle` vieną, kad pamatytumėte visą grupę.

| Perjungiklis | Spartusis klavišas | Komanda |
| ------ | ------ | ------- |
| Naktinė šviesa | — | `omarchy toggle nightlight` |
| Nutildyti pranešimus | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Budėjimas (be užrakinimo dėl neveiklumo) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Strigčių fiksavimas | — | `omarchy toggle crash-capture` |
| Ekrano užsklanda | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) temos sinchronizavimas | — | `omarchy toggle theme sync` |
| Meniu juosta | `Super + Shift + Space` | `omarchy toggle bar` |
| Jutiklinis kilimėlis | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Jutiklinis ekranas | — | `omarchy toggle touchscreen` |
| Pristabdymas | — | `omarchy toggle suspend` |
| Hibridinis GPU | — | `omarchy toggle hybrid gpu` |

Jutiklinio kilimėlio, jutiklinio ekrano ir hibridinio GPU jungikliai yra skiltyje _Trigger > Hardware_ (`Super + Ctrl + H`), o ne skiltyje Toggle, nes jie rodomi tik tada, kai iš tikrųjų turite tą aparatinę įrangą. Jutiklinio kilimėlio ir jutiklinio ekrano jungikliai išlieka po Hyprland perkrovimo — išjungto įrenginio pavadinimas įrašomas į mažą būsenos failą, kurį Hyprland perskaito paleisdamas, kad vėl jį išjungtų.

_Appearance_ skiltyje yra meniu juosta ir animacijos, taip pat keli dalykai, kurie nėra `omarchy toggle` komandos, bet elgiasi taip pat: akumuliatoriaus įkrovos procentai juostoje, numatytasis darbo sričių išdėstymas ir skiltyje _Windows_ — langų tarpai (`Super + Shift + Backspace`) bei 1 lango kvadratinis kraštinių santykis (`Super + Ctrl + Backspace`).

Kai Hyprland neturi GPU, su kuriuo galėtų piešti, ir vietoj to vaizdą atkuria naudodamas CPU (llvmpipe), kaip Mac kompiuteriuose, kurių GPU dar nepalaikomas, daugumoje virtualių mašinų arba kai nepavyksta įkelti grafikos tvarkyklės, Omarchy tai sesijai išjungia animacijas, suliejimą ir šešėlius ir vieną kartą apie tai praneša pranešimu. _Appearance > Animations On_ juos sugrąžina, ir Omarchy tai prisimena ir vėlesnėms sesijoms.

Dauguma jų tėra žymos failas kataloge `~/.local/state/omarchy/toggles/`. Jei scenarijuje norite pagal jį šakotis, `omarchy-toggle-enabled` pateikia išėjimo kodą, užuot vertęs jus jo ieškoti:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Žymos pavadintos pagal išjungtą būseną — `screensaver-off`, `suspend-off`, `bar-off` — todėl jų buvimas reiškia, kad funkcija išjungta.

### Indikatoriai juostoje

Kai režimas įjungtas, viršutinės juostos viduryje šalia laikrodžio matote mažą glifą. Tai indikatorių valdiklis, ir jis rodo diktavimą, ekrano įrašymą, laukiančius priminimus, naktinę šviesą, netrukdymo režimą ir budėjimą.

Neaktyvūs indikatoriai paslėpti. Užveskite pelę bet kurioje juostos vietoje ir jie pritemdytai pasirodys, todėl galėsite spustelėti vieną ir jį įjungti nežinodami jo sparčiojo klavišo. Spustelėjus aktyvų indikatorių, jis vėl išjungiamas. Jei verčiau norite juos visus matyti visą laiką, nustatykite `alwaysShow` į `true` įraše `omarchy.indicators`, esančiame `~/.config/omarchy/shell.json` — žr. [viršutinę juostą](05-the-top-bar.md), kur paaiškinta, kaip konfigūruojami juostos valdikliai.

### Naktinė šviesa

Naktinė šviesa sušildo ekraną iki 4000K, o perjungus ją dar kartą, grąžinama 6500K. Perjunkite ją iš perjungiklių meniu (`Super + Ctrl + O`) arba komanda `omarchy toggle nightlight`. Ją valdo hyprsunset, kurį perjungiklis paleidžia už jus, jei jis dar neveikia.

Pagal numatytuosius nustatymus hyprsunset jūsų ekranui iš viso nieko nedaro. `~/.config/hypr/hyprsunset.conf` pateikiamas su tapatybės profiliu būtent tam, kad ekranas liktų nepaliestas, kol nepaprašysite šilumos. Jei verčiau norite, kad jis persijungtų pagal laikrodį, pakeiskite jį laiko profiliu:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Tada paleiskite hyprsunset prisijungdami, pridėdami `o.launch_on_start("hyprsunset")` į `~/.config/hypr/autostart.lua`. Perjungiklio naudojama 4000K/6500K pora yra fiksuota, todėl, jei norite kitokios temperatūros, jums reikia konfigūracijos failo.

### Netrukdyti

`Super + Ctrl + Alt + ,` nutildo pranešimus. Kol jis įjungtas, neiškyla jokie pranešimai, o juostoje esantis perbraukto varpelio indikatorius primena, kodėl darbalaukis nutilo.

Tačiau niekas nedingsta. Nutildyti pranešimai sulaikomi: paskutinius kelis vėl parodykite ekrane paspaudę `Super + Shift + Alt + ,`. Daugiau žr. [pranešimuose](10-notices.md).

Dviejų rūšių pranešimai vis tiek prasiskverbia: patys Omarchy patvirtinimo pranešimai apie tai, ką ką tik padarėte ("Theme changed", "Screenshot saved"), ir kritiniai įspėjimai, siųsti iš komandinės eilutės. Pokalbių programos, kurios viską žymi kaip kritinius pranešimus, kad priverstinai atsidurtų priešais jus, neatitinka kriterijų.

### Neveiklumas

Neveiklumo elgseną valdo Omarchy apvalkalas, o laikai nurodyti aukščiausio lygio `idle` bloke faile `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Abu skaičiai yra sekundės, skaičiuojamos nuo momento, kai tapote neaktyvūs — o ne vienas nuo kito. Taigi su numatytaisiais nustatymais ekrano užsklanda pasirodo po dviejų su puse minutės, o užrakinimo ekranas perima valdymą po penkių minučių, nesvarbu, ar ekrano užsklanda veikė. Įrašykite failą ir apvalkalas iš karto perims naujus laikus.

Jei atmesite ekrano užsklandą iki užrakinimo termino, tai laikoma aktyvumu ir laukiantis užrakinimas atšaukiamas. Nebūsite užrakinti vien už tai, kad žvilgtelėjote į savo kompiuterį.

Norėdami visiškai sustabdyti užrakinimą dėl neveiklumo, paspauskite `Super + Ctrl + I` — arba paleiskite `omarchy toggle idle` — taip įjungsite budėjimą, o juostoje atsiras kavos puodelio indikatorius. Būtent jį paspauskite prieš ilgą pristatymą arba prieš kompiliavimą, kurį norite stebėti. Paspauskite dar kartą, kad grįžtumėte į įprastą režimą. `omarchy toggle idle status` atspausdina dabartinę būseną JSON formatu, jei jos reikia iš scenarijaus.

Tai susiję su užrakinimu ir ekrano užsklanda, o ne su maitinimu. Pristabdymas ir užmigdymas turi savo sąranką skyriuje [sistemos miegas](36-system-sleep.md).

### Ekrano užsklanda

Omarchy ekrano užsklanda yra ASCII menas, leidžiamas per atsitiktinius teksto efektus, po vieną egzempliorių kiekvienam monitoriui. Bet koks klavišas ar pelės judesys ją uždaro.

Ją galite paleisti pagal poreikį iš _System > Screensaver_ (`Super + Esc`) — tai priverstinai ją parodo, net jei neveiklumo ekrano užsklandą išjungėte. Pagal numatytuosius nustatymus jai nepriskirtas joks spartusis klavišas.

`omarchy toggle screensaver` išjungia neveiklumo ekrano užsklandą, jei verčiau norite iš karto nuo darbo pereiti prie užrakinto ekrano. Bet koks klavišas, spustelėjimas, slinkimas ar pelės judesys ją uždaro.

Jos piešiamą logotipą galite keisti skiltyje _Appearance > Branding > Screensaver_. Įkelkite png arba svg ir Omarchy jį konvertuos į ASCII. Žr. [firminį stilių](41-branding.md).

### Užrakinimo ekranas

`Super + Ctrl + L` užrakina kompiuterį. Tai paleidžia užrakinimo ekraną iš Omarchy apvalkalo, užtemdo ekraną, atstato klaviatūros išdėstymą į pirmąjį, kad nerašytumėte slaptažodžio netinkama abėcėle, ir — jei ją turite veikiančią — išeidamas užrakina 1Password.

Užrakinimo ekranas priima slaptažodį, o kai jį nustatysite, priims ir piršto atspaudą. Tai ir kiti autentifikavimo būdai aprašyti skyriuje [aparatinis autentifikavimas](37-hardware-authentication.md).
