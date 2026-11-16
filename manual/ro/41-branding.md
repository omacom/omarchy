# Branding

Omarchy îți permite să setezi logo-ul companiei tale sau o imagine personală atât pentru deblocarea la pornire, cât și pentru screensaver și pentru ecranul despre.

### Deblocarea la pornire

Poți folosi `omarchy plymouth preview` ca să vezi cum ar arăta logo-ul și culorile tale personalizate. Primește o culoare de fundal, o culoare de text, un png cu logo și o cale pentru imaginea de previzualizare:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Apoi aplică configurația cu `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, care va da și ecranului de autentificare SDDM aceleași culori și același logo. Dacă vrei să revii, poți folosi `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Screensaver

Poți schimba logo-ul folosit pentru screensaver în _Appearance > Branding > Screensaver_. Este un logo ASCII, așa că poți edita textul direct, dar îi poți da și o imagine png sau svg, iar noi o vom converti în ASCII. Arată destul de tare.

 ![branding-screensaver](images/branding-screensaver.webp)

În acel meniu sunt trei intrări:

- **Edit Text** deschide `~/.config/omarchy/branding/screensaver.txt` în editorul tău. Tastează sau lipește ce vrei — artă ASCII, numele tău, un cuvânt nepoliticos. Salvează și închide, iar screensaverul pornește imediat ca să îl poți vedea.
- **Set From Image** deschide un selector de fișiere pentru un png sau svg, îl convertește în ASCII și îți arată rezultatul. Logo-urile cu o siluetă clară funcționează mult mai bine decât fotografiile.
- **Restore Default** pune logo-ul Omarchy la loc.

### Ecranul despre

Aceleași trei opțiuni se află în _Appearance > Branding > About_ pentru ecranul _About_ pe care îl obții din meniul Omarchy și funcționează identic — fișierul este `~/.config/omarchy/branding/about.txt`, iar fereastra About apare după fiecare modificare. Arta pentru About este convertită la o dimensiune mai mică decât cea a screensaverului, deoarece trebuie să încapă într-o fereastră, nu să îți umple ecranul.

Cât timp fereastra este deschisă, o strălucire verde se apleacă peste artă la fiecare câteva secunde și apoi o lasă din nou nemișcată. Și arta ta o primește, atâta timp cât fiecare caracter din ea are o lățime de o coloană — tot ce produce _Set From Image_ are. Arta construită din emoji sau caractere cu lățime dublă rămâne nemișcată, la fel și ecranul dacă păstrezi o configurație fastfetch proprie: un logo nemișcat în aceste cazuri este animația care se dă la o parte, nu una care eșuează, deoarece alunecarea unei străluciri peste ele ar face ca restul rândului să ajungă în locul greșit.

 ![branding-about](images/branding-about.webp)

### Convertirea imaginilor pe cont propriu

Ambele opțiuni _Set From Image_ nu fac decât să apeleze `omarchy transcode ascii`, pe care îl poți rula direct dacă vrei control asupra conversiei:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Primește `--width` și `--height` în coloane și rânduri de terminal, un `--mode` fie `braille` (implicit și mult mai fin), fie `block`, un procent `--threshold` pentru a decide ce pixeli contează ca parte din logo și `--invert` pentru când logo-ul tău este deschis pe un fundal întunecat. Dacă o conversie iese ca o pată informă, pragul este de obicei butonul de reglat.

### Cuvinte în loc de logo

`omarchy ascii` desenează text în Delta Corps Priest 1, fontul FIGlet în care este desenat însuși logotipul Omarchy, așa că un screensaver poate spune ceva în loc să arate o imagine:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Primește textul ca argumente sau îl citește dintr-o conductă când nu primește niciunul. Fontul conține doar litere și spații — a fost desenat fără cifre sau punctuație — așa că orice altceva este eliminat și numit în stderr, nu înghițit în liniște.
