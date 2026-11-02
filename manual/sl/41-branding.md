# Blagovna znamka

Omarchy vam omogoča, da nastavite logotip svojega podjetja ali osebno sliko za odklepanje ob zagonu, ohranjevalnik zaslona in zaslon O programu.

### Odklepanje ob zagonu

Z `omarchy plymouth preview` si lahko ogledate, kako bi bili videti vaš logotip in barve po meri. Sprejme barvo ozadja, barvo besedila, png z logotipom in pot za sliko predogleda:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Nato nastavitev uporabite z `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, kar bo tudi prijavnemu zaslonu SDDM dalo enake barve in logotip. Če želite spremembo razveljaviti, lahko uporabite `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Ohranjevalnik zaslona

Logotip za ohranjevalnik zaslona lahko spremenite pod _Videz > Blagovna znamka > Ohranjevalnik zaslona_. Gre za logotip ASCII, zato lahko besedilo uredite neposredno, lahko pa mu podate tudi sliko png ali svg in pretvorili jo bomo v ASCII. Videti je precej kul.

 ![branding-screensaver](images/branding-screensaver.webp)

V tem meniju so trije vnosi:

- **Uredi besedilo** odpre `~/.config/omarchy/branding/screensaver.txt` v vašem urejevalniku. Vnesite ali prilepite, kar želite — umetnost ASCII, svoje ime, prostaško besedo. Shranite in zaprite in ohranjevalnik zaslona se takoj zažene, da si ga lahko ogledate.
- **Nastavi iz slike** odpre izbirnik datotek za png ali svg, jo pretvori v ASCII in vam pokaže rezultat. Logotipi z jasno silhueto delujejo veliko bolje kot fotografije.
- **Obnovi privzeto** vrne logotip Omarchy nazaj.

### Zaslon O programu

Iste tri možnosti so pod _Videz > Blagovna znamka > O programu_ za zaslon _O programu_, ki ga dobite iz menija Omarchy, in delujejo enako — datoteka je `~/.config/omarchy/branding/about.txt`, okno O programu pa se po vsaki spremembi pojavi. Umetnost za zaslon O programu se pretvori v manjšo velikost kot tista za ohranjevalnik zaslona, saj se mora prilegati v okno, namesto da bi zapolnila vaš zaslon.

Medtem ko je okno odprto, se vsakih nekaj sekund čez umetnost nagne zelen lesk in jo nato spet pusti pri miru. Tudi vaša lastna umetnost ga dobi, če je vsak znak v njej širok en stolpec — vse, kar ustvari _Nastavi iz slike_, je. Umetnost, sestavljena iz emojijev ali znakov dvojne širine, namesto tega ostane pri miru, prav tako pa zaslon, če obdržite svojo konfiguracijo fastfetch: mirujoč logotip je v teh primerih animacija, ki se umakne s poti, namesto da bi odpovedala, saj bi drsenje leska čez njih preostanek vrstice postavilo na napačno mesto.

 ![branding-about](images/branding-about.webp)

### Samostojno pretvarjanje slik

Obe možnosti _Nastavi iz slike_ samo kličeta `omarchy transcode ascii`, ki ga lahko zaženete neposredno, če želite nadzor nad pretvorbo:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Sprejme `--width` in `--height` v stolpcih in vrsticah terminala, `--mode` z vrednostjo `braille` (privzeta in veliko finejša) ali `block`, odstotek `--threshold` za odločanje, kateri piksli štejejo kot del logotipa, in `--invert` za primere, ko je vaš logotip svetel na temnem ozadju. Če pretvorba izpade kot kepa, je prag običajno gumb, ki ga je treba zavrteti.

### Besede namesto logotipa

`omarchy ascii` riše besedilo v Delta Corps Priest 1, pisavi FIGlet, v kateri je narisan tudi sam besedni znak Omarchy, tako da lahko ohranjevalnik zaslona nekaj pove, namesto da pokaže sliko:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Besedilo sprejme kot argumente ali ga bere iz cevi, kadar mu ni podano nobeno. Pisava vsebuje samo črke in presledke — narisana je bila brez števk ali ločil — zato je vse drugo zavrženo in navedeno na stderr, namesto da bi bilo tiho pogoltnjeno.
