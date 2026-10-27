# Perjungikliai, neveikla ir ekrano užsklanda

Daug ką kasdien keičiate iš tikrųjų ne nustatymas. Tai režimas, kurį įjungiate valandai ir vėl išjungiate: naktinė šviesa, kai dirbate vėlai, netrukdymo režimas, kai pristatote, budrumas, kai ką nors žiūrite. Omarchy tai vadina perjungikliais ir visi jie veikia vienodai — spartusis klavišas, meniu įrašas ir komanda veikia tą patį jungiklį.

### Perjungiklių meniu

`Super + Ctrl + O` tiesiogiai atidaro _Paleidiklis > Perjungiklis_, arba ten galite nueiti iš Omarchy meniu (`Super + Space`). Viskas tame sąraše yra jungiklis, kurį galite perjungti negalvodami, kur saugoma būsena. Jungikliai, skirti darbalaukio išvaizdai, yra šalia, skiltyje _Išvaizda_.

Iš terminalo tie patys jungikliai yra `omarchy toggle <thing>`. Paleiskite `omarchy toggle` atskirai, kad pamatytumėte visą grupę.

| Perjungiklis | Spartusis klavišas | Komanda |
| ------ | ------ | ------- |
| Naktinė šviesa | — | `omarchy toggle nightlight` |
| Nutildyti pranešimus | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Būti budriam (be užrakinimo dėl neveiklos) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Strigčių fiksavimas | — | `omarchy toggle crash-capture` |
| Ekrano užsklanda | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) temos sinchronizavimas | — | `omarchy toggle theme sync` |
| Meniu juosta | `Super + Shift + Space` | `omarchy toggle bar` |
| Jutiklinis kilimėlis | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Jutiklinis ekranas | — | `omarchy toggle touchscreen` |
| Sustabdymas | — | `omarchy toggle suspend` |
| Hibridinis GPU | — | `omarchy toggle hybrid gpu` |

Jutiklinio kilimėlio, jutiklinio ekrano ir hibridinio GPU jungikliai yra skiltyje _Paleidiklis > Aparatinė įranga_ (`Super + Ctrl + H`), o ne skiltyje Perjungiklis, nes jie rodomi tik tada, kai iš tikrųjų turite tą aparatinę įrangą. Jutiklinio kilimėlio ir jutiklinio ekrano jungikliai išlieka po Hyprland perkrovimo — išjungto įrenginio pavadinimas išsaugomas mažame būsenos faile, kurį Hyprland perskaito paleidžiant, kad vėl jį išjungtų.

_Išvaizda_ saugo meniu juostą ir animacijas, taip pat keletą dalykų, kurie nėra `omarchy toggle` komandos, bet elgiasi taip pat: akumuliatoriaus procentą juostoje, numatytąjį darbo sričių išdėstymą ir skiltyje _Langai_ — langų tarpus (`Super + Shift + Backspace`) ir 1 lango kvadrato formatą (`Super + Ctrl + Backspace`).

Dauguma jų tėra žymos failas kataloge `~/.local/state/omarchy/toggles/`. Jei norite scenarijuje pagal jį šakotis, `omarchy-toggle-enabled` pateikia išėjimo kodą, užuot vertęs jus jo ieškoti:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Žymos pavadintos pagal išjungtą būseną — `screensaver-off`, `suspend-off`, `bar-off` — todėl jų buvimas reiškia, kad funkcija išjungta.

### Indikatoriai juostoje

Kai režimas įjungtas, viršutinės juostos viduryje šalia laikrodžio gaunate mažą glifą. Tai indikatorių valdiklis, kuriame yra diktavimas, ekrano įrašymas, laukiantys priminimai, naktinė šviesa, netrukdymo režimas ir budrumas.

Neaktyvūs indikatoriai paslėpti. Užveskite pelę bet kurioje juostos vietoje ir jie pritemdytai pasirodys, todėl galėsite spustelėti vieną, kad jį įjungtumėte, nežinodami jo sparčiojo klavišo. Spustelėjus aktyvų, jis vėl išjungiamas. Jei verčiau norite juos visus matyti visą laiką, nustatykite `alwaysShow` į `true` įraše `omarchy.indicators` faile `~/.config/omarchy/shell.json` — žr. [viršutinę juostą](05-the-top-bar.md), kaip konfigūruojami juostos valdikliai.

### Naktinė šviesa

Naktinė šviesa sušildo ekraną iki 4000K, o perjungus ją dar kartą grąžinama 6500K. Perjunkite ją iš perjungiklių meniu (`Super + Ctrl + O`) arba su `omarchy toggle nightlight`. Ją valdo hyprsunset, kurį perjungiklis paleidžia už jus, jei jis dar neveikia.

Pagal numatytuosius nustatymus hyprsunset nieko nedaro jūsų ekranui. `~/.config/hypr/hyprsunset.conf` pateikiamas su tapatybės profiliu būtent tam, kad ekranas liktų nepaliestas, kol paprašysite šilumos. Jei verčiau norite, kad jis persijungtų pagal laikrodį, pakeiskite tai laiko profiliu:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Tada paleiskite hyprsunset prisijungiant pridėdami `o.launch_on_start("hyprsunset")` į `~/.config/hypr/autostart.lua`. Perjungiklio naudojama 4000K/6500K pora yra fiksuota, todėl konfigūracijos failas yra ta vieta, kur eiti, jei norite kitokios temperatūros.

### Netrukdyti

`Super + Ctrl + Alt + ,` nutildo pranešimus. Kol jis įjungtas, neatsiranda jokių iškylančių pranešimų, o juostoje esantis perbraukto varpelio indikatorius primena, kodėl darbalaukis nutilo.

Tačiau niekas neprarandama. Nutildyti pranešimai sulaikomi: paskutinius kelis grąžinkite į ekraną su `Super + Shift + Alt + ,`. Likusią dalį žr. [pranešimuose](10-notices.md).

Dviejų rūšių pranešimai vis tiek prasiskverbia: paties Omarchy patvirtinimo iškylantys pranešimai apie tai, ką ką tik padarėte („Tema pakeista“, „Ekrano kopija išsaugota“), ir kritiniai įspėjimai, siunčiami iš komandinės eilutės. Pokalbių programos, kurios viską pažymi kaip kritinius dalykus, kad priverstų jus juos matyti, tam netinka.

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

Abu skaičiai yra sekundės, skaičiuojamos nuo momento, kai tapote neaktyvūs — o ne vienas nuo kito. Taigi su numatytaisiais nustatymais ekrano užsklanda pasirodo po dviejų su puse minutės, o užrakinimo ekranas perima valdymą po penkių minučių, nesvarbu, ar ekrano užsklanda veikė, ar ne. Išsaugokite failą ir apvalkalas iš karto perims naujus laikus.

Jei atmesite ekrano užsklandą prieš užrakinimo terminą, tai laikoma veikla ir laukiantis užrakinimas atšaukiamas. Nebūsite užrakinti už tai, kad žvilgtelėjote į savo kompiuterį.

Norėdami visiškai sustabdyti užrakinimą dėl neveiklos, `Super + Ctrl + I` — arba `omarchy toggle idle` — įjungia budrumą, o juostoje atsiranda kavos puodelio indikatorius. Tai tas, kurį reikia paspausti prieš ilgą pristatymą ar kūrimą, kurį norite stebėti. Paspauskite jį dar kartą, kad grįžtumėte į normalią būseną. `omarchy toggle idle status` išspausdina dabartinę būseną kaip JSON, jei jos reikia iš scenarijaus.

Tai susiję su užrakinimu ir ekrano užsklanda, o ne su maitinimu. Sustabdymas ir užmigdymas turi savo sąranką skyriuje [sistemos miegas](36-system-sleep.md).

### Ekrano užsklanda

Omarchy ekrano užsklanda yra ASCII menas, veikiantis per atsitiktinius teksto efektus, po vieną egzempliorių kiekvienam monitoriui. Bet koks klavišas ar pelės judesys iš jos išeina.

Galite ją paleisti pagal poreikį iš _Sistema > Ekrano užsklanda_ (`Super + Esc`), kuris priverstinai ją paleidžia, net jei išjungėte neveiklos ekrano užsklandą. Pagal numatytuosius nustatymus su ja nesusietas joks spartusis klavišas.

`omarchy toggle screensaver` išjungia neveiklos ekrano užsklandą, jei verčiau norite eiti tiesiai nuo darbo prie užrakinimo. Jai reikia terminalo, kurį ji moka konfigūruoti — Alacritty, Foot, Ghostty arba Kitty — ir ji jums tai pasakys, jei jūsų numatytasis terminalas yra kas nors kita.

Jos piešiamas logotipas yra jūsų keičiamas skiltyje _Išvaizda > Prekės ženklas > Ekrano užsklanda_. Įkelkite png arba svg ir Omarchy jį konvertuos į ASCII. Žr. [prekės ženklą](41-branding.md).

### Užrakinimo ekranas

`Super + Ctrl + L` užrakina kompiuterį. Tai paleidžia užrakinimo ekraną iš Omarchy apvalkalo, užtemdo ekraną, atstato klaviatūros išdėstymą į pirmąjį, kad nerašytumėte slaptažodžio netinkama abėcėle, ir — jei jį naudojate — išeidama užrakina 1Password.

Užrakinimo ekranas priima slaptažodį, o kai jį nustatysite, priims ir piršto atspaudą. Tai ir kiti tapatybės nustatymo būdai aprašyti skyriuje [aparatinės įrangos tapatybės nustatymas](37-hardware-authentication.md).
