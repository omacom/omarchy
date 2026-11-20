# Perjungikliai, tuščioji eiga ir ekrano užsklanda

Daugelis dalykų, kuriuos keičiate kasdien, iš tikrųjų nėra nustatymas. Tai režimas, kurį įjungiate valandai ir vėl išjungiate: naktinė šviesa, kai dirbate vėlai, netrukdymo režimas, kai pristatote, budrumas, kai ką nors žiūrite. Omarchy juos vadina perjungikliais, ir visi jie veikia vienodai — spartusis klavišas, meniu įrašas ir komanda, visi pasiekiantys tą patį jungiklį.

### Perjungiklių meniu

`Super + Ctrl + O` tiesiogiai atveria _Paleidiklis > Perjungiklis_, arba galite ten nueiti iš Omarchy meniu (`Super + Space`). Viskas tame sąraše yra jungiklis, kurį galite perjungti negalvodami, kur yra jo būsena. Jungikliai, skirti tam, kaip atrodo darbalaukis, yra šalia jo, po _Išvaizda_.

Iš terminalo tie patys jungikliai yra `omarchy toggle <thing>`. Paleiskite `omarchy toggle` vieną, kad pamatytumėte visą grupę.

| Perjungiklis | Spartusis klavišas | Komanda |
| ------ | ------ | ------- |
| Naktinė šviesa | — | `omarchy toggle nightlight` |
| Nutildyti pranešimus | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Likti budriam (be tuščiosios eigos užrakto) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Strigčių fiksavimas | — | `omarchy toggle crash-capture` |
| Ekrano užsklanda | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) temos sinchronizavimas | — | `omarchy toggle theme sync` |
| Meniu juosta | `Super + Shift + Space` | `omarchy toggle bar` |
| Jutiklinis kilimėlis | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Jutiklinis ekranas | — | `omarchy device touchscreen` |
| Pristabdymas | — | `omarchy toggle suspend` |
| Hibridinė GPU | — | `omarchy toggle hybrid gpu` |

Jutiklinio kilimėlio, jutiklinio ekrano ir hibridinės GPU jungikliai yra po _Paleidiklis > Aparatinė įranga_ (`Super + Ctrl + H`), o ne po Perjungiklis, nes jie rodomi tik tada, kai iš tikrųjų turite tą aparatinę įrangą. Jutiklinio kilimėlio ir jutiklinio ekrano jungikliai išlieka po Hyprland perkrovimo — išjungto įrenginio pavadinimas įrašomas į mažą būsenos failą, kurį Hyprland nuskaito paleidžiantis, kad vėl jį išjungtų.

_Išvaizda_ saugo meniu juostą ir animacijas, be to, kelis dalykus, kurie nėra `omarchy toggle` komandos, bet elgiasi taip pat: akumuliatoriaus įkrovos procentą juostoje, numatytąjį darbo sričių išdėstymą ir, po _Langai_, langų tarpus (`Super + Shift + Backspace`) bei 1 lango kvadrato kraštinių santykį (`Super + Ctrl + Backspace`).

Kai Hyprland neturi GPU, su kuriuo galėtų piešti, ir vietoj to atvaizduoja naudodamas CPU (llvmpipe), kaip Mac kompiuteriuose, kurių GPU dar nepalaikoma, daugumoje virtualių mašinų arba kai nepavyksta įkelti grafikos tvarkyklės, Omarchy tai sesijai išjungia animacijas, suliejimą ir šešėlius ir vieną kartą apie tai praneša pranešimu. _Išvaizda > Animacijos įjungtos_ juos grąžina, ir Omarchy tai prisimena ir vėlesnėms sesijoms.

Dauguma jų tėra žymos failas po `~/.local/state/omarchy/toggles/`. Jei norite scenarijuje patikrinti vieną iš jų, `omarchy-toggle-enabled` pateikia išėjimo kodą, užuot vertęs jus jo ieškoti:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Žymos pavadintos pagal išjungtą būseną — `screensaver-off`, `suspend-off`, `bar-off` — todėl jų buvimas reiškia, kad funkcija išjungta.

### Indikatoriai juostoje

Kai režimas įjungtas, viršutinės juostos viduryje šalia laikrodžio gaunate mažą glifą. Tai indikatorių valdiklis, ir jis rodo diktavimą, ekrano įrašymą, laukiančius priminimus, naktinę šviesą, netrukdymo režimą ir budrumą.

Neaktyvūs indikatoriai paslėpti. Užveskite žymeklį bet kur ant juostos ir jie blankiai pasirodys, todėl galite spustelėti vieną, kad jį įjungtumėte, nežinodami jo sparčiojo klavišo. Spustelėjus aktyvų, jis vėl išjungiamas. Jei verčiau norėtumėte juos visus matyti visą laiką, nustatykite `alwaysShow` į `true` įraše `omarchy.indicators` faile `~/.config/omarchy/shell.json` — žr. [viršutinė juosta](05-the-top-bar.md), kaip konfigūruojami juostos valdikliai.

### Naktinė šviesa

Naktinė šviesa sušildo ekraną iki 4000K, o perjungus ją dar kartą grąžinama 6500K. Perjunkite ją iš perjungiklių meniu (`Super + Ctrl + O`) arba su `omarchy toggle nightlight`. Ją valdo hyprsunset, kurį perjungiklis paleidžia už jus, jei jis dar neveikia.

Pagal numatytuosius nustatymus hyprsunset jūsų ekranui apskritai nieko nedaro. `~/.config/hypr/hyprsunset.conf` pateikiamas su tapatybės profiliu būtent tam, kad ekranas liktų nepaliestas, kol nepaprašysite šilumos. Jei verčiau norėtumėte, kad ji persijungtų pagal laikrodį, pakeiskite jį laiko profiliu:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Tada paleiskite hyprsunset prisijungiant, pridėdami `o.launch_on_start("hyprsunset")` į `~/.config/hypr/autostart.lua`. Perjungiklio naudojama 4000K/6500K pora yra fiksuota, todėl konfigūracijos failas yra vieta, į kurią einate, jei norite kitos temperatūros.

### Netrukdyti

`Super + Ctrl + Alt + ,` nutildo pranešimus. Kol jis įjungtas, jokie iššokantys pranešimai nepasirodo, o perbrauktas varpelio indikatorius juostoje primena, kodėl darbalaukis nutilo.

Tačiau niekas neprarandama. Nutildyti pranešimai sulaikomi: paskutinius kelis vėl parodykite ekrane su `Super + Shift + Alt + ,`. Likusią dalį žr. skyriuje [pranešimai](10-notices.md).

Dviejų rūšių pranešimai vis tiek prasiskverbia: patys Omarchy patvirtinimo iššokantys pranešimai apie tai, ką ką tik padarėte („Theme changed“, „Screenshot saved“), ir kritiniai įspėjimai, siunčiami iš komandinės eilutės. Pokalbių programos, kurios viską žymi kaip kritinius, kad priverstinai prasibrautų prieš jus, neatitinka reikalavimų.

### Tuščioji eiga

Omarchy apvalkalas valdo tuščiosios eigos elgseną, o laikai yra aukščiausio lygio `idle` blokas faile `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Abu skaičiai yra sekundės, skaičiuojamos nuo momento, kai tapote neaktyvūs — ne vienas nuo kito. Taigi su numatytaisiais nustatymais ekrano užsklanda pasirodo po dviejų su puse minutės, o užrakinimo ekranas perima po penkių minučių, nesvarbu, ar ekrano užsklanda veikė, ar ne. Įrašykite failą ir apvalkalas iš karto perima naujus laikus.

Jei atmesite ekrano užsklandą iki užrakinimo termino, tai laikoma aktyvumu ir laukiantis užrakinimas atšaukiamas. Nebūsite užrakinti vien todėl, kad žvilgtelėjote į savo kompiuterį.

Norėdami visiškai sustabdyti užrakinimą esant tuščiajai eigai, `Super + Ctrl + I` — arba `omarchy toggle idle` — įjungia budrumą, o juostoje pasirodo kavos puodelio indikatorius. Tai tas, kurį reikia paspausti prieš ilgą pristatymą arba kompiliavimą, kurį norite stebėti. Paspauskite jį dar kartą, kad grįžtumėte į įprastą režimą. `omarchy toggle idle status` atspausdina dabartinę būseną kaip JSON, jei jums jos reikia iš scenarijaus.

Tai susiję su užrakinimu ir ekrano užsklanda, o ne su energija. Pristabdymas ir užmigdymas turi atskirą sąranką: [sistemos miegas](36-system-sleep.md).

### Ekrano užsklanda

Omarchy ekrano užsklanda yra ASCII menas, leidžiamas per atsitiktinius teksto efektus, po vieną egzempliorių kiekvienam monitoriui. Bet koks klavišas ar pelės judesys ją uždaro.

Galite ją paleisti pagal poreikį iš _Sistema > Ekrano užsklanda_ (`Super + Esc`), o tai priverstinai ją parodo, net jei išjungėte tuščiosios eigos ekrano užsklandą. Pagal numatytuosius nustatymus joks spartusis klavišas jai nepriskirtas.

`omarchy toggle screensaver` yra tai, kas išjungia tuščiosios eigos užsklandą, jei verčiau norėtumėte eiti tiesiai nuo darbo prie užrakinimo. Bet koks klavišas, spustelėjimas, slinkimas ar pelės judesys ją uždaro.

Jos piešiamą logotipą galite keisti po _Išvaizda > Prekės ženklas > Ekrano užsklanda_. Įkelkite png arba svg ir Omarchy pavers jį į ASCII. Žr. [prekės ženklas](41-branding.md).

### Užrakinimo ekranas

`Super + Ctrl + L` užrakina kompiuterį. Tai paleidžia užrakinimo ekraną iš Omarchy apvalkalo, užtemdo ekraną, atstato klaviatūros išdėstymą į pirmąjį, kad neįvestumėte slaptažodžio netinkama abėcėle, ir — jei ją turite veikiančią — pakeliui užrakina 1Password.

Užrakinimo ekranas priima slaptažodį, ir jis priims ir piršto atspaudą, kai jį susikursite. Tai ir kiti autentifikavimo būdai aptariami skyriuje [aparatinės įrangos autentifikavimas](37-hardware-authentication.md).
