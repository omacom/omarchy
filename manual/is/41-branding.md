# Merking

Omarchy leyfir þér að setja merki fyrirtækisins þíns eða eigin mynd bæði fyrir skjáhvílirinn og Um-skjáinn.

### Skjáhvílir

Þú getur breytt merkinu sem notað er fyrir skjáhvílirinn undir _Appearance > Branding > Screensaver_. Það er ASCII-merki, svo þú getur breytt textanum beint, en þú getur líka gefið því png- eða svg-mynd og við breytum henni í ASCII. Það lítur ansi vel út.

 ![branding-screensaver](images/branding-screensaver.webp)

Það eru þrír valkostir í þeirri valmynd:

- **Edit Text** opnar `~/.config/omarchy/branding/screensaver.txt` í ritlinum þínum. Sláðu inn eða límdu það sem þér dettur í hug — ASCII-list, nafnið þitt, dónalegt orð. Vistaðu og lokaðu, og skjáhvílirinn fer strax í gang svo þú getir séð það.
- **Set From Image** opnar skráarveljara fyrir png eða svg, breytir því í ASCII og sýnir þér niðurstöðuna. Merki með skýra útlínu virka miklu betur en ljósmyndir.
- **Restore Default** setur Omarchy-merkið aftur.

### Um-skjárinn

Sömu þrír valkostirnir eru undir _Appearance > Branding > About_ fyrir _About_-skjáinn sem þú færð úr Omarchy-valmyndinni, og þeir virka á sama hátt — skráin er `~/.config/omarchy/branding/about.txt`, og About-glugginn birtist eftir hverja breytingu. About-listin er breytt í minni stærð en sú fyrir skjáhvílirinn, þar sem hún þarf að passa í glugga í stað þess að fylla skjáinn þinn.

Á meðan glugginn er opinn hallar rönd af björtu hvítu ljósi yfir listina á nokkurra sekúndna fresti og skilur hana síðan eftir kyrrra aftur. Þín eigin list fær það líka, svo lengi sem hvert tákn í henni er einn dálkur á breidd — allt sem _Set From Image_ býr til er það. List sem er byggð úr emoji eða tvöfalt breiðum táknum helst kyrr í staðinn, og það sama gerir skjárinn ef þú geymir eigin fastfetch-stillingu: kyrrt merki í þeim tilvikum er hreyfingin að halda sig til hlés frekar en að mistakast, því að renna glampa yfir þau myndi láta afganginn af línunni lenda á röngum stað.

 ![branding-about](images/branding-about.webp)

### Að breyta myndum sjálfur

Báðir _Set From Image_-valkostirnir kalla bara á `omarchy transcode ascii`, sem þú getur keyrt beint ef þú vilt hafa stjórn á umbreytingunni:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Það tekur `--width` og `--height` í dálkum og röðum útstöðvarinnar, `--mode` sem annaðhvort `braille` (sjálfgefið, og miklu fínna) eða `block`, `--threshold`-prósentu til að ákveða hvaða pixlar teljist hluti af merkinu, og `--invert` fyrir þegar merkið þitt er ljóst á dökkum bakgrunni. Ef umbreyting kemur út sem klessa er þröskuldurinn yfirleitt stillingin sem á að snúa.

### Orð í stað merkis

`omarchy ascii` teiknar texta í Delta Corps Priest 1, FIGlet-leturgerðinni sem Omarchy-orðmerkið sjálft er teiknað í, svo skjáhvílir getur sagt eitthvað frekar en að sýna mynd:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Það tekur textann sem viðföng, eða les hann úr pípu þegar enginn er gefinn. Leturgerðin inniheldur aðeins stafi og bil — hún var teiknuð án tölustafa eða greinarmerkja — svo öllu öðru er sleppt og það nefnt á stderr frekar en að þegja yfir því.
