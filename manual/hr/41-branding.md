# Brendiranje

Omarchy vam omogućuje da postavite logotip svoje tvrtke ili osobnu sliku i za čuvar zaslona i za zaslon About.

### Čuvar zaslona

Logotip koji se upotrebljava za čuvar zaslona možete promijeniti pod _Appearance > Branding > Screensaver_. To je ASCII logotip, pa tekst možete uređivati izravno, ali možete mu dati i png ili svg sliku, a mi ćemo je pretvoriti u ASCII. Izgleda prilično cool.

 ![branding-screensaver](images/branding-screensaver.webp)

U tom izborniku postoje tri stavke:

- **Edit Text** otvara `~/.config/omarchy/branding/screensaver.txt` u vašem uređivaču teksta. Upišite ili zalijepite što god želite — ASCII umjetnost, svoje ime, nepristojnu riječ. Spremite i izađite, a čuvar zaslona odmah će se pokrenuti da ga možete vidjeti.
- **Set From Image** otvara birač datoteka za png ili svg, pretvara je u ASCII i prikazuje vam rezultat. Logotipi s jasnom siluetom funkcioniraju daleko bolje od fotografija.
- **Restore Default** vraća logotip Omarchy.

### Zaslon About

Iste tri opcije nalaze se pod _Appearance > Branding > About_ za zaslon _About_ koji dobivate iz izbornika Omarchy i funkcioniraju identično — datoteka je `~/.config/omarchy/branding/about.txt`, a prozor About pojavljuje se nakon svake promjene. Umjetnost za About pretvara se u manju veličinu od one za čuvar zaslona jer mora stati u prozor, a ne ispuniti cijeli zaslon.

Dok je prozor otvoren, pojas jarke bijele svjetlosti svakih nekoliko sekundi prijeđe preko umjetnosti i zatim je ponovno ostavi mirnom. Dobiva ga i vaša vlastita umjetnost, sve dok je svaki znak u njoj širok jedan stupac — a sve što proizvede _Set From Image_ takvo i jest. Umjetnost sastavljena od emojija ili znakova dvostruke širine umjesto toga ostaje mirna, a isto vrijedi i za zaslon ako zadržite vlastitu konfiguraciju za fastfetch: miran logotip u tim slučajevima znači da se animacija drži po strani, a ne da je zakazala, jer bi pomicanje odsjaja preko njih ostatak retka smjestilo na pogrešno mjesto.

 ![branding-about](images/branding-about.webp)

### Samostalno pretvaranje slika

Obje opcije _Set From Image_ samo pozivaju `omarchy transcode ascii`, što možete pokrenuti i izravno ako želite kontrolu nad pretvorbom:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Prima `--width` i `--height` u stupcima i redcima terminala, `--mode` koji može biti `braille` (zadano i mnogo finije) ili `block`, postotak `--threshold` za odlučivanje koji se pikseli smatraju dijelom logotipa te `--invert` za slučaj kada je vaš logotip svijetao na tamnoj pozadini. Ako pretvorba ispadne kao mrlja, prag je obično postavka koju treba podesiti.

### Riječi umjesto logotipa

`omarchy ascii` crta tekst fontom Delta Corps Priest 1, FIGlet fontom kojim je ispisan i sam naziv Omarchy, pa čuvar zaslona može nešto reći umjesto da prikazuje sliku:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Prima tekst kao argumente ili ga čita iz cjevovoda kada mu se ne da nijedan. Font sadrži samo slova i razmake — nacrtan je bez znamenki i interpunkcije — pa se sve ostalo odbacuje i imenuje na stderr umjesto da se tiho proguta.
