# Vörumerking

Omarchy gerir þér kleift að setja merki fyrirtækisins þíns eða persónulega mynd bæði fyrir aflæsingu við ræsingu, skjáhvíluna og Um-skjáinn.

### Aflæsing við ræsingu

Þú getur notað `omarchy plymouth preview` til að sjá hvernig sérsniðið merki þitt og litirnir þínir myndu líta út. Það tekur við bakgrunnslit, textalit, png-merki og slóð fyrir forskoðunarmyndina:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Notaðu síðan uppsetninguna með `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, sem gefur SDDM-innskráningarskjánum líka sömu liti og merki. Ef þú vilt taka þetta til baka geturðu notað `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Skjáhvíla

Þú getur breytt merkinu sem notað er fyrir skjáhvíluna undir _Útlit > Vörumerking > Skjáhvíla_. Þetta er ASCII-merki, svo þú getur breytt textanum beint, en þú getur líka gefið því png- eða svg-mynd og við breytum henni í ASCII. Það lítur ansi vel út.

 ![branding-screensaver](images/branding-screensaver.webp)

Það eru þrír valkostir í þeirri valmynd:

- **Breyta texta** opnar `~/.config/omarchy/branding/screensaver.txt` í ritlinum þínum. Sláðu inn eða límdu það sem þú vilt — ASCII-list, nafnið þitt, dónalegt orð. Vistaðu og hættu, og skjáhvílan fer strax í gang svo þú getir séð hana.
- **Setja frá mynd** opnar skráarveljara fyrir png eða svg, breytir því í ASCII og sýnir þér útkomuna. Merki með skýra útlínu virka miklu betur en ljósmyndir.
- **Endurheimta sjálfgefið** setur Omarchy-merkið aftur.

### Um-skjárinn

Sömu þrír valkostirnir eru undir _Útlit > Vörumerking > Um_ fyrir _Um_-skjáinn sem þú færð úr Omarchy-valmyndinni, og þeir virka alveg eins — skráin er `~/.config/omarchy/branding/about.txt`, og Um-glugginn birtist eftir hverja breytingu. Listin fyrir Um er breytt í minni stærð en sú fyrir skjáhvíluna, þar sem hún þarf að passa í glugga í stað þess að fylla skjáinn þinn.

Meðan glugginn er opinn hallast rönd af björtu hvítu ljósi yfir listina á nokkurra sekúndna fresti og skilur hana síðan eftir kyrr aftur. Þín eigin list fær það líka, svo lengi sem sérhver stafur í henni er einn dálk á breidd — allt sem _Setja frá mynd_ býr til er það. List sem er byggð úr emoji eða tvíbreiðum stöfum helst kyrr í staðinn, og það sama gerir skjárinn ef þú geymir þína eigin fastfetch-stillingu: kyrrt merki í þeim tilvikum þýðir að hreyfimyndin heldur sig frá frekar en að hún mistakist, þar sem það að renna glampa yfir þau myndi koma restinni af línunni á rangan stað.

 ![branding-about](images/branding-about.webp)

### Að breyta myndum sjálfur

Báðir _Setja frá mynd_-valkostirnir kalla bara á `omarchy transcode ascii`, sem þú getur keyrt beint ef þú vilt hafa stjórn á breytingunni:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Það tekur `--width` og `--height` í dálkum og röðum útstöðvar, `--mode` sem annaðhvort `braille` (sjálfgefið, og miklu fínna) eða `block`, `--threshold` prósentu til að ákveða hvaða dílar teljast hluti af merkinu, og `--invert` fyrir þegar merkið þitt er ljóst á dökkum bakgrunni. Ef breyting kemur út sem klessa er þröskuldurinn yfirleitt takkinn sem á að snúa.

### Orð í stað merkis

`omarchy ascii` teiknar texta í Delta Corps Priest 1, FIGlet-leturgerðinni sem Omarchy-orðmerkið sjálft er teiknað í, svo skjáhvíla getur sagt eitthvað frekar en að sýna mynd:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Það tekur textann sem viðföng, eða les hann úr pípu þegar enginn er gefinn. Leturgerðin inniheldur aðeins stafi og bil — hún var teiknuð án tölustafa eða greinarmerkja — svo öllu öðru er sleppt og það er tilgreint á stderr frekar en að því sé kyngt í þögn.
