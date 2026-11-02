# Perjungikliai, neveikla ir ekrano užsklanda

Daug ką, ką keičiate kasdien, iš tikrųjų sunku pavadinti nustatymu. Tai režimas, kurį įjungiate valandai ir vėl išjungiate: naktinė šviesa, kai dirbate vėlai, netrukdymo režimas, kai pristatote, budrumas, kai ką nors žiūrite. Omarchy juos vadina perjungikliais, ir visi jie veikia vienodai — spartusis klavišas, meniu įrašas ir komanda, visi veikiantys tą patį jungiklį.

### Perjungiklių meniu

`Super + Ctrl + O` tiesiogiai atidaro _Paleidiklis > Perjungiklis_, arba galite ten nueiti iš Omarchy meniu (`Super + Space`). Viskas tame sąraše yra jungiklis, kurį galite perjungti negalvodami, kur saugoma būsena. Jungikliai, skirti darbalaukio išvaizdai, yra šalia, skiltyje _Išvaizda_.

Iš terminalo tie patys jungikliai yra `omarchy toggle <thing>`. Paleiskite `omarchy toggle` patį savaime, kad pamatytumėte visą grupę.

| Perjungiklis | Spartusis klavišas | Komanda |
| ------ | ------ | ------- |
| Naktinė šviesa | — | `omarchy toggle nightlight` |
| Nutildyti pranešimus | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Likti budriam (be užrakinimo dėl neveiklos) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Strigčių fiksavimas | — | `omarchy toggle crash-capture` |
| Ekrano užsklanda | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) temos sinchronizavimas | — | `omarchy toggle theme sync` |
| Meniu juosta | `Super + Shift + Space` | `omarchy toggle bar` |
| Jutiklinis kilimėlis | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Jutiklinis ekranas | — | `omarchy toggle touchscreen` |
| Pristabdymas | — | `omarchy toggle suspend` |
| Hibridinis GPU | — | `omarchy toggle hybrid gpu` |

Jutiklinio kilimėlio, jutiklinio ekrano ir hibridinio GPU jungikliai yra skiltyje _Paleidiklis > Aparatūra_ (`Super + Ctrl + H`), o ne skiltyje Perjungiklis, nes jie rodomi tik tada, kai iš tikrųjų turite tą aparatūrą. Jutiklinio kilimėlio ir jutiklinio ekrano jungikliai išlieka po Hyprland perkrovimo — išjungto įrenginio pavadinimas išsaugomas mažame būsenos faile, kurį Hyprland perskaito paleidžiant, kad vėl jį išjungtų.

_Išvaizda_ saugo meniu juostą ir animacijas, taip pat kelis dalykus, kurie nėra `omarchy toggle` komandos, bet veikia taip pat: akumuliatoriaus procentą juostoje, numatytąjį darbo sričių išdėstymą ir skiltyje _Langai_ — langų tarpus (`Super + Shift + Backspace`) ir 1 lango kvadratinį kraštinių santykį (`Super + Ctrl + Backspace`).

Dauguma jų tėra žymos failas kataloge `~/.local/state/omarchy/toggles/`. Jei norite scenarijuje patikrinti vieną iš jų, `omarchy-toggle-enabled` pateikia išėjimo kodą, užuot vertęs jus jo ieškoti:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Žymos pavadintos pagal išjungtą būseną — `screensaver-off`, `suspend-off`, `bar-off` — todėl jų buvimas reiškia, kad funkcija išjungta.

### Indikatoriai juostoje

Kai režimas įjungtas, viršutinės juostos viduryje šalia laikrodžio matote mažą glifą. Tai indikatorių valdiklis, ir jis rodo diktavimą, ekrano įrašymą, laukiančius priminimus, naktinę šviesą, netrukdymo režimą ir budrumą.

Neaktyvūs indikatoriai paslėpti. Užveskite pelę bet kurioje juostos vietoje ir jie pritemdytai pasirodys, todėl galite spustelėti vieną, kad jį įjungtumėte, nežinodami jo sparčiojo klavišo. Spustelėjus aktyvų, jis vėl išjungiamas. Jei norite juos visus matyti visą laiką, nustatykite `alwaysShow` reikšmę `true` įraše `omarchy.indicators` faile `~/.config/omarchy/shell.json` — žr. [viršutinę juostą](05-the-top-bar.md) apie tai, kaip konfigūruojami juostos valdikliai.

### Naktinė šviesa

Naktinė šviesa pašildo ekraną iki 4000K, o perjungus ją dar kartą grąžina 6500K. Perjunkite ją iš perjungiklių meniu (`Super + Ctrl + O`) arba su `omarchy toggle nightlight`. Ją valdo hyprsunset, kurį perjungiklis paleidžia už jus, jei jis dar neveikia.

Pagal numatytuosius nustatymus hyprsunset jūsų ekranui iš viso nieko nedaro. `~/.config/hypr/hyprsunset.conf` pateikiamas su tapatybės profiliu būtent tam, kad ekranas liktų nepaliestas, kol nepaprašysite šilumos. Jei norite, kad jis persijungtų pagal laikrodį, pakeiskite jį laiko profiliu:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Tada paleiskite hyprsunset prisijungiant, pridėdami `o.launch_on_start("hyprsunset")` į `~/.config/hypr/autostart.lua`. Perjungiklio naudojama 4000K/6500K pora yra fiksuota, todėl konfigūracijos failas yra ta vieta, į kurią einate, jei norite kitokios temperatūros.

### Netrukdyti

`Super + Ctrl + Alt + ,` nutildo pranešimus. Kol jis įjungtas, neiškyla jokie pranešimai, o perbraukto varpelio indikatorius juostoje primena, kodėl darbalaukis nutilo.

Tačiau niekas neprarandama. Nutildyti pranešimai sulaikomi: paskutinius kelis vėl parodykite ekrane su `Super + Shift + Alt + ,`. Likusią dalį žr. [pranešimuose](10-notices.md).

Dviejų rūšių pranešimai vis tiek prasiskverbia: paties Omarchy patvirtinimo pranešimai apie tai, ką ką tik padarėte („Tema pakeista“, „Ekrano kopija išsaugota“), ir kritiniai įspėjimai, siunčiami iš komandinės eilutės. Pokalbių programėlės, kurios viską pažymi kaip kritiška, kad priverstinai atsidurtų prieš jūsų akis, nesiskaito.

### Neveikla

Omarchy apvalkalas valdo neveiklos elgesį, o laikai yra aukščiausio lygio `idle` blokas faile `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Abu skaičiai yra sekundės, skaičiuojamos nuo momento, kai tapote neaktyvūs — o ne vienas nuo kito. Taigi su numatytaisiais nustatymais ekrano užsklanda pasirodo po dviejų su puse minučių, o užrakinimo ekranas perima valdymą po penkių minučių, nesvarbu, ar ekrano užsklanda veikė. Išsaugokite failą ir apvalkalas iš karto perims naujus laikus.

Jei atmesite ekrano užsklandą iki užrakinimo termino, tai laikoma aktyvumu ir laukiantis užrakinimas atšaukiamas. Nebūsite užrakinti vien dėl to, kad žvilgtelėjote į savo kompiuterį.

Norėdami visiškai sustabdyti užrakinimą dėl neveiklos, `Super + Ctrl + I` — arba `omarchy toggle idle` — įjungia budrumo režimą, ir juostoje pasirodo kavos puodelio indikatorius. Tai tas, kurį reikia paspausti prieš ilgą pristatymą ar kompiliavimą, kurį norite stebėti. Paspauskite jį dar kartą, kad grįžtumėte į normalų režimą. `omarchy toggle idle status` išspausdina dabartinę būseną kaip JSON, jei jos reikia iš scenarijaus.

Tai susiję su užrakinimu ir ekrano užsklanda, o ne su energija. Pristabdymas ir hibernacija turi savo nustatymus [sistemos miege](36-system-sleep.md).

### Ekrano užsklanda

Omarchy ekrano užsklanda yra ASCII menas, veikiantis per atsitiktinius teksto efektus, po vieną egzempliorių kiekvienam monitoriui. Bet koks klavišas ar pelės judesys ją išjungia.

Galite ją paleisti pagal poreikį iš _Sistema > Ekrano užsklanda_ (`Super + Esc`), kuri priverstinai ją parodo, net jei išjungėte neveiklos ekrano užsklandą. Pagal numatytuosius nustatymus jai nepriskirtas joks spartusis klavišas.

`omarchy toggle screensaver` išjungia neveiklos ekrano užsklandą, jei norite pereiti tiesiai nuo darbo prie užrakinto ekrano. Bet koks klavišas, spustelėjimas, slinkimas ar pelės judesys ją uždaro.

Jos piešiamą logotipą galite keisti skiltyje _Išvaizda > Ženklodara > Ekrano užsklanda_. Įkelkite png arba svg ir Omarchy jį konvertuos į ASCII. Žr. [ženklodarą](41-branding.md).

### Užrakinimo ekranas

`Super + Ctrl + L` užrakina kompiuterį. Tai paleidžia užrakinimo ekraną iš Omarchy apvalkalo, užtamsina ekraną, atstato klaviatūros išdėstymą į pirmąjį, kad nerašytumėte slaptažodžio netinkama abėcėle, ir — jei turite jį veikiantį — pakeliui užrakina 1Password.

Užrakinimo ekranas priima slaptažodį, ir jis priims piršto atspaudą, kai jį nustatysite. Tai ir kiti tapatybės nustatymo būdai aptariami [aparatinio tapatybės nustatymo](37-hardware-authentication.md) skyriuje.
