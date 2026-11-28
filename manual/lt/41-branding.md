# Prekės ženklas

Omarchy leidžia nustatyti įmonės logotipą arba asmeninį paveikslėlį tiek įkrovos atrakinimui, tiek ekrano užsklandai, tiek ekranui „Apie“.

### Įkrovos atrakinimas

Galite naudoti `omarchy plymouth preview`, kad pamatytumėte, kaip atrodytų jūsų pasirinktinis logotipas ir spalvos. Jis priima fono spalvą, teksto spalvą, logotipo png ir peržiūros paveikslėlio kelią:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Tuomet pritaikykite sąranką su `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, kuri taip pat suteiks SDDM prisijungimo ekranui tas pačias spalvas ir logotipą. Jei norite grąžinti ankstesnę būseną, galite naudoti `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Ekrano užsklanda

Ekrano užsklandai naudojamą logotipą galite pakeisti skiltyje _Išvaizda > Prekės ženklas > Ekrano užsklanda_. Tai ASCII logotipas, todėl galite tiesiogiai redaguoti tekstą, bet taip pat galite pateikti jam png arba svg paveikslėlį, ir mes jį konvertuosime į ASCII. Atrodo gana šauniai.

 ![branding-screensaver](images/branding-screensaver.webp)

Tame meniu yra trys įrašai:

- **Redaguoti tekstą** atidaro `~/.config/omarchy/branding/screensaver.txt` jūsų redaktoriuje. Įveskite arba įklijuokite ką tik norite — ASCII piešinį, savo vardą, nepadorų žodį. Išsaugokite ir uždarykite, ir ekrano užsklanda iš karto įsijungs, kad galėtumėte ją pamatyti.
- **Nustatyti iš paveikslėlio** atidaro failų parinkiklį png arba svg failui, konvertuoja jį į ASCII ir parodo jums rezultatą. Logotipai su aiškiu siluetu veikia kur kas geriau nei nuotraukos.
- **Atkurti numatytąjį** grąžina Omarchy logotipą.

### Ekranas „Apie“

Tie patys trys variantai yra skiltyje _Išvaizda > Prekės ženklas > Apie_ ir skirti ekranui _Apie_, kurį gaunate iš Omarchy meniu, ir jie veikia identiškai — failas yra `~/.config/omarchy/branding/about.txt`, o langas „Apie“ iššoka po kiekvieno pakeitimo. Piešinys ekranui „Apie“ konvertuojamas į mažesnį dydį nei ekrano užsklandos, nes jis turi tilpti į langą, o ne užpildyti jūsų ekraną.

Kol langas atidarytas, ryškios baltos šviesos juosta kas kelias sekundes nuslysta per piešinį ir tuomet vėl palieka jį ramų. Jūsų pačių piešinys ją taip pat gauna, jei kiekvienas jo simbolis yra vieno stulpelio pločio — toks yra viskas, ką sukuria _Nustatyti iš paveikslėlio_. Piešinys, sukurtas iš emoji arba dvigubo pločio simbolių, vietoj to lieka ramus, ir taip pat elgiasi ekranas, jei turite savo fastfetch konfigūraciją: nejudantis logotipas tais atvejais yra animacija, kuri pasitraukia iš kelio, o ne sugenda, nes nuslinkus blyksniui per juos likusi eilutės dalis atsidurtų netinkamoje vietoje.

 ![branding-about](images/branding-about.webp)

### Paveikslėlių konvertavimas savarankiškai

Abu _Nustatyti iš paveikslėlio_ variantai tiesiog iškviečia `omarchy transcode ascii`, kurį galite paleisti tiesiogiai, jei norite valdyti konvertavimą:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Jis priima `--width` ir `--height` terminalo stulpeliais ir eilutėmis, `--mode` — arba `braille` (numatytąjį ir daug smulkesnį), arba `block`, `--threshold` procentais, skirtą nuspręsti, kurie pikseliai laikomi logotipo dalimi, ir `--invert`, skirtą atvejui, kai jūsų logotipas yra šviesus tamsiame fone. Jei konvertuotas rezultatas atrodo kaip dėmė, slenkstis paprastai yra tas reguliatorius, kurį reikia pasukti.

### Žodžiai vietoj logotipo

`omarchy ascii` piešia tekstą šriftu Delta Corps Priest 1 — FIGlet šriftu, kuriuo nupieštas pats Omarchy žodinis ženklas, — todėl ekrano užsklanda gali ką nors pasakyti, o ne rodyti paveikslėlį:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Jis priima tekstą kaip argumentus arba skaito jį iš srauto, kai argumentų nepateikiama. Šriftas turi tik raides ir tarpus — jis buvo nupieštas be skaitmenų ir skyrybos ženklų, — todėl visa kita yra atmetama ir įvardijama stderr, o ne tyliai praryjama.
