# Vörumerking

Omarchy gerir þér kleift að setja merki fyrirtækis þíns eða persónulega mynd bæði fyrir opnun við ræsingu, skjáhvíluna og Um-skjáinn.

### Opnun við ræsingu

Þú getur notað `omarchy plymouth preview` til að sjá hvernig sérsniðið merki þitt og litir myndu líta út. Það tekur bakgrunnslit, textalit, logo png og slóð fyrir forskoðunarmyndina:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Beittu svo uppsetningunni með `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, sem mun líka gefa SDDM-innskráningarskjánum sömu liti og merki. Ef þú vilt afturkalla það getur þú notað `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Skjáhvíla

Þú getur breytt merkinu sem notað er fyrir skjáhvíluna undir _Útlit > Vörumerking > Skjáhvíla_. Það er ASCII-merki, svo þú getur breytt textanum beint, en þú getur líka gefið því png- eða svg-mynd og við breytum því í ASCII. Það lítur nokkuð vel út.

 ![branding-screensaver](images/branding-screensaver.webp)

Í þeirri valmynd eru þrír færslur:

- **Breyta texta** opnar `~/.config/omarchy/branding/screensaver.txt` í ritlinum þínum. Skrifaðu eða límdu hvað sem þú vilt — ASCII-list, nafnið þitt, ruddalegt orð. Vistaðu og lokaðu, og skjáhvílan fer strax í gang svo þú getir séð það.
- **Setja frá mynd** opnar skráavel fyrir png eða svg, breytir því í ASCII og sýnir þér útkomuna. Merki með skýra útlínu virka miklu betur en ljósmyndir.
- **Endurheimta sjálfgefið** setur Omarchy-merkið aftur á.

### Um-skjárinn

Sömu þrír valkostir eru undir _Útlit > Vörumerking > Um_ fyrir _Um_-skjáinn sem þú færð úr Omarchy-valmyndinni, og þeir virka eins — skráin er `~/.config/omarchy/branding/about.txt`, og Um-glugginn sprettur upp eftir hverja breytingu. Um-listinni er breytt í minni stærð en list skjáhvílunnar, þar sem hún þarf að passa í glugga frekar en að fylla skjáinn þinn.

Meðan glugginn er opinn hallast grænn ljómi yfir listina á nokkurra sekúndna fresti og skilur hana svo eftir kyrr aftur. Þín eigin list fær hann líka, svo lengi sem hvert tákn í henni er einn dálkur á breidd — allt sem _Setja frá mynd_ býr til er það. List sem er byggð úr emoji eða tvíbreiðum táknum helst þess í stað kyrr, og það gerir skjárinn líka ef þú geymir þína eigin fastfetch-stillingu: kyrrt merki í þeim tilvikum er hreyfimyndin að halda sig til hlés frekar en að mistakast, þar sem að renna ljóma yfir þau myndi láta afganginn af línunni lenda á röngum stað.

 ![branding-about](images/branding-about.webp)

### Að breyta myndum sjálfur

Báðir _Setja frá mynd_-valkostirnir kalla bara á `omarchy transcode ascii`, sem þú getur keyrt beint ef þú vilt stjórn á umbreytingunni:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Það tekur `--width` og `--height` í dálkum og röðum útstöðvar, `--mode` sem annaðhvort `braille` (sjálfgefið, og miklu fínna) eða `block`, `--threshold` prósentu til að ákveða hvaða pixlar teljast hluti af merkinu, og `--invert` fyrir þegar merkið þitt er ljóst á dökkum bakgrunni. Ef umbreyting kemur út sem klessa er þröskuldurinn yfirleitt hnappurinn sem á að snúa.

### Orð í stað merkis

`omarchy ascii` teiknar texta í Delta Corps Priest 1, FIGlet-leturgerðinni sem Omarchy-orðmerkið sjálft er teiknað í, svo skjáhvíla getur sagt eitthvað frekar en að sýna mynd:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Það tekur textann sem færibreytur, eða les hann úr pípu þegar enginn er gefinn. Letrið ber aðeins bókstafi og bil — það var teiknað án tölustafa eða greinarmerkja — svo öllu öðru er sleppt og það nefnt á stderr frekar en að vera þaggað niður í kyrrþey.
