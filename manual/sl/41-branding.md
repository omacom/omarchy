# Blagovna znamka

Omarchy vam omogoča, da nastavite logotip svojega podjetja ali osebno sliko za odklepanje ob zagonu, ohranjevalnik in zaslon Vizitka.

### Odklepanje ob zagonu

Z `omarchy plymouth preview` lahko vidite, kako bi izgledala vaš logotip in barve po meri. Sprejme barvo ozadja, barvo besedila, png logotip in pot za sliko predogleda:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Nato uporabite nastavitev z `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, kar bo dalo tudi prijavnemu zaslonu SDDM iste barve in logotip. Če želite povrniti, uporabite `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Ohranjevalnik

Logotip, ki se uporablja za ohranjevalnik, lahko spremenite pod _Slog > Ohranjevalnik_. To je ASCII logotip, tako da lahko besedilo urejate neposredno, lahko pa mu podate tudi sliko png ali svg in to bomo pretvorili v ASCII. Izgleda precej kul.

 ![branding-screensaver](images/branding-screensaver.webp)

V tem meniju so trije vnosi:

- **Uredi besedilo** odpre `~/.config/omarchy/branding/screensaver.txt` v vašem urejevalniku. Vnesite ali prilepite kar koli želite — ASCII umetnost, svoje ime, nespodobno besedo. Shranite in zapustite, ohranjevalnik se takoj zažene, da ga lahko vidite.
- **Nastavi iz slike** odpre izbirnik datotek za png ali svg, ga pretvori v ASCII in vam pokaže rezultat. Logotipi z jasno silhueto delujejo veliko bolje kot fotografije.
- **Obnovi privzeto** vrne logotip Omarchy.

### Zaslon Vizitka

Iste tri možnosti so pod _Slog > Vizitka_ za zaslon _Vizitka_, ki ga dobite iz menija Omarchy, in delujejo enako — datoteka je `~/.config/omarchy/branding/about.txt`, okno Vizitka pa se prikaže po vsaki spremembi. Umetnost Vizitka je pretvorjena v manjšo velikost kot tista za ohranjevalnik, saj mora stati v okno in ne zapolniti vašega zaslona.

Medtem ko je okno odprto, se vsakih nekaj sekund čez umetnost nagne lesk zelene in jo nato spet pusti pri miru. Dobijo ga tudi vaša umetnost, dokler je vsak znak v njej širok en stolpec — kar koli _Nastavi iz slike_ proizvede, je. Umetnost, sestavljena iz emojijev ali znakov dvojne širine, ostane pri miru, prav tako zaslon, če obdržite svojo lastno konfiguracijo fastfetch: nepremičen logotip v teh primerih pomeni, da animacija ostane ob strani namesto da bi odpovedala, saj bi drsenje leska čez njih preostanek vrstice postavilo na napačno mesto.

 ![branding-about](images/branding-about.webp)

### Pretvorba slik sami

Obe možnosti _Nastavi iz slike_ samo kličeta `omarchy transcode ascii`, ki ga lahko zaženete neposredno, če želite nadzor nad pretvorbo:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Sprejme `--width` in `--height` v stolpcih in vrsticah terminala, `--mode` ali `braille` (privzeto in veliko finejše) ali `block`, odstotek `--threshold` za odločanje, katere piksle štejejo kot del logotipa, in `--invert`, ko je vaš logotip svetel na temnem ozadju. Če pretvorba izpadne kot kepa, je prag običajno gumb, ki ga je treba zavrteti.

### Besede namesto logotipa

`omarchy ascii` riše besedilo v Delta Corps Priest 1, pisavi FIGlet, v kateri je narisana sama besedna znamka Omarchy, tako da lahko ohranjevalnik nekaj pove namesto da pokaže sliko:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Besedilo sprejme kot argumente ali ga bere iz cevi, kadar ni podanih. Pisava vsebuje samo črke in presledke — narisana je bila brez števk ali ločil — zato je vse drugo izpuščeno in poimenovano na stderr namesto da bi tiho izginilo.
