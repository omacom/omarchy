# Brendiranje

Omarchy vam omogućuje da postavite logotip svoje tvrtke ili osobnu sliku za otključavanje pri pokretanju, čuvar zaslona i zaslon O programu.

### Otključavanje pri pokretanju

Možete upotrijebiti `omarchy plymouth preview` da vidite kako bi izgledali vaš prilagođeni logotip i boje. Prima boju pozadine, boju teksta, png logotip i putanju za sliku pretpregleda:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Zatim primijenite postavke s `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, čime će i SDDM zaslon za prijavu dobiti iste boje i logotip. Ako se želite vratiti na staro, možete upotrijebiti `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Čuvar zaslona

Logotip koji se koristi za čuvar zaslona možete promijeniti pod _Izgled > Brendiranje > Čuvar zaslona_. To je ASCII logotip, pa tekst možete uređivati izravno, ali možete mu dati i png ili svg sliku, a mi ćemo je pretvoriti u ASCII. Izgleda prilično fora.

 ![branding-screensaver](images/branding-screensaver.webp)

U tom izborniku postoje tri stavke:

- **Uredi tekst** otvara `~/.config/omarchy/branding/screensaver.txt` u vašem uređivaču. Upišite ili zalijepite što god želite — ASCII umjetnost, svoje ime, nepristojnu riječ. Spremite i izađite, i čuvar zaslona odmah se pokreće da ga možete vidjeti.
- **Postavi iz slike** otvara birač datoteka za png ili svg, pretvara je u ASCII i pokazuje vam rezultat. Logotipi s jasnom siluetom rade daleko bolje od fotografija.
- **Vrati zadano** vraća Omarchy logotip.

### Zaslon O programu

Iste tri opcije nalaze se pod _Izgled > Brendiranje > O programu_ za zaslon _O programu_ koji dobivate iz Omarchy izbornika i rade identično — datoteka je `~/.config/omarchy/branding/about.txt`, a prozor O programu pojavljuje se nakon svake promjene. Grafika za O programu pretvara se u manju veličinu od one za čuvar zaslona, jer mora stati u prozor umjesto da ispuni cijeli vaš zaslon.

Dok je prozor otvoren, odsjaj zelene boje svakih nekoliko sekundi nagne se preko grafike i zatim je ponovno ostavi mirnu. I vaša vlastita grafika dobiva ga, sve dok je svaki znak u njoj širok jedan stupac — sve što proizvede _Postavi iz slike_ jest. Grafika sastavljena od emojija ili znakova dvostruke širine umjesto toga ostaje mirna, a isto vrijedi i za zaslon ako zadržite vlastitu fastfetch konfiguraciju: nepomičan logotip u tim slučajevima znači da se animacija drži po strani, a ne da je zakazala, jer bi klizanje odsjaja preko njih ostatak retka odvelo na pogrešno mjesto.

 ![branding-about](images/branding-about.webp)

### Samostalno pretvaranje slika

Obje opcije _Postavi iz slike_ zapravo samo pozivaju `omarchy transcode ascii`, što možete pokrenuti i izravno ako želite kontrolu nad pretvorbom:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Prima `--width` i `--height` u stupcima i recima terminala, `--mode` koji može biti `braille` (zadano i mnogo finije) ili `block`, postotak `--threshold` za odlučivanje koji se pikseli smatraju dijelom logotipa i `--invert` za slučaj kada je vaš logotip svijetao na tamnoj pozadini. Ako pretvorba ispadne kao mrlja, prag je obično ono što treba podesiti.

### Riječi umjesto logotipa

`omarchy ascii` iscrtava tekst u Delta Corps Priest 1, FIGlet fontu u kojem je iscrtan i sam Omarchy wordmark, pa čuvar zaslona može nešto reći umjesto da prikazuje sliku:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Tekst prima kao argumente ili ga čita iz cijevi kada mu se ne zada nijedan. Font sadrži samo slova i razmake — nacrtan je bez znamenki i interpunkcije — pa se sve ostalo ispusti i navede na stderr umjesto da se tiho proguta.
