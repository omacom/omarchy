# Blagovna znamka

Omarchy vam omogoča, da za ohranjevalnik zaslona in zaslon O programu nastavite logotip svojega podjetja ali osebno sliko.

### Ohranjevalnik zaslona

Logotip, ki se uporablja za ohranjevalnik zaslona, lahko spremenite pod _Videz > Blagovna znamka > Ohranjevalnik zaslona_. Gre za logotip ASCII, zato lahko besedilo urejate neposredno, lahko pa mu podate tudi sliko png ali svg in pretvorili jo bomo v ASCII. Videti je precej kul.

 ![branding-screensaver](images/branding-screensaver.webp)

V tem meniju so trije vnosi:

- **Uredi besedilo** v vašem urejevalniku odpre `~/.config/omarchy/branding/screensaver.txt`. Vnesite ali prilepite, kar želite — umetnost ASCII, svoje ime, prostaško besedo. Shranite in zaprite, ohranjevalnik zaslona pa se takoj zažene, da si ga lahko ogledate.
- **Nastavi iz slike** odpre izbirnik datotek za png ali svg, sliko pretvori v ASCII in vam pokaže rezultat. Logotipi z jasno silhueto delujejo veliko bolje kot fotografije.
- **Obnovi privzeto** vrne logotip Omarchy.

### Zaslon O programu

Iste tri možnosti so pod _Videz > Blagovna znamka > O programu_ za zaslon _O programu_, ki ga dobite iz menija Omarchy, in delujejo enako — datoteka je `~/.config/omarchy/branding/about.txt`, okno O programu pa se po vsaki spremembi prikaže. Umetnost za O programu se pretvori v manjšo velikost kot tista za ohranjevalnik zaslona, saj se mora prilegati v okno in ne zapolniti vašega zaslona.

Medtem ko je okno odprto, se vsakih nekaj sekund čez umetnost nagne pas svetlo bele svetlobe, nato pa jo spet pusti nepremično. Tudi vaša lastna umetnost ga dobi, dokler je vsak znak v njej širok en stolpec — vse, kar ustvari _Nastavi iz slike_, je. Umetnost, sestavljena iz emodžijev ali znakov dvojne širine, namesto tega ostane nepremična, prav tako pa zaslon, če obdržite svojo lastno konfiguracijo fastfetch: nepremičen logotip v teh primerih pomeni, da se animacija umakne s poti, ne pa da je spodletela, saj bi drsenje leska čez nje preostanek vrstice postavilo na napačno mesto.

 ![branding-about](images/branding-about.webp)

### Pretvarjanje slik po svoje

Obe možnosti _Nastavi iz slike_ zgolj kličeta `omarchy transcode ascii`, ki ga lahko zaženete tudi neposredno, če želite nadzor nad pretvorbo:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Sprejme `--width` in `--height` v stolpcih in vrsticah terminala, `--mode` z vrednostjo `braille` (privzeto in veliko finejšo) ali `block`, odstotek `--threshold` za odločanje, kateri piksli štejejo kot del logotipa, in `--invert` za primere, ko je vaš logotip svetel na temnem ozadju. Če pretvorba izpade kot packa, je prag običajno tisti gumb, ki ga je treba zavrteti.

### Besede namesto logotipa

`omarchy ascii` izriše besedilo v pisavi Delta Corps Priest 1, pisavi FIGlet, v kateri je izrisana tudi sama besedna oznaka Omarchy, tako da lahko ohranjevalnik zaslona nekaj pove, namesto da prikaže sliko:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Besedilo sprejme kot argumente, če mu jih ne podate, pa ga prebere iz cevi. Pisava vsebuje samo črke in presledke — izrisana je bila brez številk ali ločil — zato je vse drugo zavrženo in poimenovano na stderr, namesto da bi bilo tiho pogoltnjeno.
