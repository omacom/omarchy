# Prekės ženklas

Omarchy leidžia nustatyti savo įmonės logotipą arba asmeninį vaizdą tiek ekrano užsklandai, tiek „Apie“ ekranui.

### Ekrano užsklanda

Logotipą, naudojamą ekrano užsklandai, galite pakeisti skiltyje _Išvaizda > Prekės ženklas > Ekrano užsklanda_. Tai ASCII logotipas, todėl galite tiesiogiai redaguoti tekstą, bet taip pat galite pateikti png arba svg vaizdą, ir mes jį konvertuosime į ASCII. Atrodo gana šauniai.

 ![branding-screensaver](images/branding-screensaver.webp)

Tame meniu yra trys įrašai:

- **Redaguoti tekstą** atidaro `~/.config/omarchy/branding/screensaver.txt` jūsų redaktoriuje. Įveskite arba įklijuokite ką tik norite — ASCII piešinį, savo vardą, nepadorų žodį. Išsaugokite ir uždarykite, ir ekrano užsklanda iš karto įsijungs, kad galėtumėte ją pamatyti.
- **Nustatyti iš vaizdo** atidaro failų pasirinkimo langą png arba svg failui, konvertuoja jį į ASCII ir parodo jums rezultatą. Logotipai su aiškiu siluetu veikia kur kas geriau nei nuotraukos.
- **Atkurti numatytąjį** grąžina Omarchy logotipą.

### „Apie“ ekranas

Tos pačios trys parinktys yra skiltyje _Išvaizda > Prekės ženklas > Apie_ ir skirtos _Apie_ ekranui, kurį atidarote iš Omarchy meniu, ir jos veikia identiškai — failas yra `~/.config/omarchy/branding/about.txt`, o „Apie“ langas iššoka po kiekvieno pakeitimo. „Apie“ piešinys konvertuojamas į mažesnį dydį nei ekrano užsklandos, nes jis turi tilpti lange, o ne užpildyti visą jūsų ekraną.

Kol langas atidarytas, ryškios baltos šviesos juosta kas kelias sekundes nuslysta per piešinį ir tada vėl palieka jį ramiai stovėti. Jūsų pačių piešinys ją taip pat gauna, jei kiekvienas jo simbolis yra vieno stulpelio pločio — viskas, ką sukuria _Nustatyti iš vaizdo_, toks yra. Piešinys, sukurtas iš emoji arba dvigubo pločio simbolių, vietoj to lieka nejudantis, ir taip pat elgiasi ekranas, jei turite savo fastfetch konfigūraciją: nejudantis logotipas tais atvejais reiškia, kad animacija pasitraukia iš kelio, o ne kad ji sugedo, nes slystantis blyksnis per juos pastumtų likusią eilutės dalį į netinkamą vietą.

 ![branding-about](images/branding-about.webp)

### Vaizdų konvertavimas pačiam

Abi _Nustatyti iš vaizdo_ parinktys tiesiog iškviečia `omarchy transcode ascii`, kurią galite paleisti tiesiogiai, jei norite patys valdyti konvertavimą:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Ji priima `--width` ir `--height` terminalo stulpeliais ir eilutėmis, `--mode` reikšmę `braille` (numatytoji ir daug smulkesnė) arba `block`, `--threshold` procentinę reikšmę, pagal kurią sprendžiama, kurie pikseliai laikomi logotipo dalimi, ir `--invert`, kai jūsų logotipas yra šviesus tamsiame fone. Jei konvertavimas virsta dėme, dažniausiai reikia pasukti būtent slenksčio rankenėlę.

### Žodžiai vietoj logotipo

`omarchy ascii` piešia tekstą Delta Corps Priest 1 šriftu — FIGlet šriftu, kuriuo nupieštas ir pats Omarchy žodinis ženklas, — todėl ekrano užsklanda gali ką nors pasakyti, o ne rodyti paveikslėlį:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Ji priima tekstą kaip argumentus arba skaito jį iš konvejerio, kai argumentų nepateikiama. Šriftas turi tik raides ir tarpus — jis buvo nupieštas be skaitmenų ir skyrybos ženklų, — todėl visa kita yra atmetama ir įvardijama stderr, o ne tyliai praryjama.
