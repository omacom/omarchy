# Prekės ženklas

Omarchy leidžia nustatyti įmonės logotipą arba asmeninį paveikslėlį paleidimo atrakinimo ekranui, ekrano užsklandai ir ekranui „Apie“.

### Paleidimo atrakinimas

Galite naudoti `omarchy plymouth preview`, kad pamatytumėte, kaip atrodytų jūsų pasirinktinis logotipas ir spalvos. Pateikiama fono spalva, teksto spalva, logotipo png ir peržiūros paveikslėlio kelias:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Tada pritaikykite sąranką su `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, kuri taip pat suteiks SDDM prisijungimo ekranui tas pačias spalvas ir logotipą. Jei norite grįžti prie ankstesnės būsenos, galite naudoti `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Ekrano užsklanda

Ekrano užsklandai naudojamą logotipą galite pakeisti skiltyje _Išvaizda > Prekės ženklas > Ekrano užsklanda_. Tai ASCII logotipas, todėl galite tiesiogiai redaguoti tekstą, bet taip pat galite pateikti jam png arba svg paveikslėlį, ir mes jį paversime ASCII. Atrodo gana šauniai.

 ![branding-screensaver](images/branding-screensaver.webp)

Tame meniu yra trys įrašai:

- **Teksto redagavimas** atidaro `~/.config/omarchy/branding/screensaver.txt` jūsų redaktoriuje. Įveskite arba įklijuokite, ką tik norite — ASCII piešinį, savo vardą, nepadorų žodį. Išsaugokite ir uždarykite, ir ekrano užsklanda iš karto įsijungs, kad galėtumėte ją pamatyti.
- **Nustatyti iš paveikslėlio** atidaro failų parinkiklį png arba svg failui, paverčia jį ASCII ir parodo jums rezultatą. Logotipai su aiškiu siluetu veikia daug geriau nei nuotraukos.
- **Atkurti numatytąjį** grąžina Omarchy logotipą.

### Ekranas „Apie“

Tos pačios trys parinktys yra skiltyje _Išvaizda > Prekės ženklas > Apie_, skirtos ekranui _Apie_, kurį gaunate iš Omarchy meniu, ir jos veikia identiškai — failas yra `~/.config/omarchy/branding/about.txt`, o langas „Apie“ iššoka po kiekvieno pakeitimo. Piešinys ekranui „Apie“ paverčiamas mažesniu dydžiu nei ekrano užsklandos, nes jis turi tilpti lange, o ne užpildyti visą jūsų ekraną.

Kol langas atidarytas, kas kelias sekundes per piešinį nuslysta žalias blyksnis ir tada vėl palieka jį ramų. Jūsų pačių piešinys jį taip pat gauna, jei kiekvienas jo simbolis yra vieno stulpelio pločio — toks yra viskas, ką sukuria _Nustatyti iš paveikslėlio_. Piešinys, sudarytas iš emoji arba dvigubo pločio simbolių, vietoj to lieka ramus, kaip ir ekranas, jei turite savo fastfetch konfigūraciją: nejudantis logotipas tais atvejais reiškia, kad animacija pasitraukia iš kelio, o ne kad ji sugedo, nes slystantis blyksnis per juos likusią eilutės dalį pastumtų į netinkamą vietą.

 ![branding-about](images/branding-about.webp)

### Paveikslėlių konvertavimas pačiam

Abi parinktys _Nustatyti iš paveikslėlio_ tiesiog kviečia `omarchy transcode ascii`, kurį galite paleisti tiesiogiai, jei norite valdyti konvertavimą:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Priimami `--width` ir `--height` terminalo stulpeliais ir eilutėmis, `--mode` su reikšme `braille` (numatytoji ir daug smulkesnė) arba `block`, `--threshold` procentais, pagal kuriuos nusprendžiama, kurie pikseliai laikomi logotipo dalimi, ir `--invert`, kai jūsų logotipas yra šviesus tamsiame fone. Jei konvertavimas pavirsta dėme, dažniausiai reikia pasukti būtent threshold rankenėlę.

### Žodžiai vietoj logotipo

`omarchy ascii` piešia tekstą šriftu Delta Corps Priest 1 — FIGlet šriftu, kuriuo nupieštas pats Omarchy žodinis ženklas, todėl ekrano užsklanda gali ką nors pasakyti, o ne rodyti paveikslėlį:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Tekstą jis priima kaip argumentus arba, kai jų nepateikiama, skaito jį iš konvejerio. Šriftas turi tik raides ir tarpus — jis buvo nupieštas be skaitmenų ar skyrybos ženklų — todėl visa kita atmetama ir įvardijama stderr, o ne tyliai praryjama.
