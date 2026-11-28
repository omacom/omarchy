# Branding

Omarchy îți permite să setezi logo-ul companiei tale sau o imagine personală atât pentru deblocarea la pornire, cât și pentru screensaver și ecranul Despre.

### Deblocarea la pornire

Poți folosi `omarchy plymouth preview` ca să vezi cum ar arăta logo-ul și culorile tale personalizate. Primește o culoare de fundal, o culoare pentru text, un png cu logo-ul și o cale pentru imaginea de previzualizare:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Apoi aplică configurația cu `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, ceea ce îi va da și ecranului de autentificare SDDM aceleași culori și același logo. Dacă vrei să revii la ce era înainte, poți folosi `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Screensaver

Poți schimba logo-ul folosit pentru screensaver din _Aspect > Branding > Screensaver_. Este un logo ASCII, așa că poți edita textul direct, dar îi poți da și o imagine png sau svg, iar noi o vom converti în ASCII. Arată destul de tare.

 ![branding-screensaver](images/branding-screensaver.webp)

În acel meniu sunt trei intrări:

- **Editare text** deschide `~/.config/omarchy/branding/screensaver.txt` în editorul tău. Tastează sau lipește ce vrei — artă ASCII, numele tău, un cuvânt nepoliticos. Salvează și închide, iar screensaver-ul pornește imediat ca să îl poți vedea.
- **Setează din imagine** deschide un selector de fișiere pentru un png sau svg, îl convertește în ASCII și îți arată rezultatul. Logo-urile cu o siluetă clară funcționează mult mai bine decât fotografiile.
- **Restabilește implicitul** pune logo-ul Omarchy la loc.

### Ecranul Despre

Aceleași trei opțiuni se află sub _Aspect > Branding > Despre_ pentru ecranul _Despre_ pe care îl obții din meniul Omarchy și funcționează identic — fișierul este `~/.config/omarchy/branding/about.txt`, iar fereastra Despre apare după fiecare modificare. Desenul Despre este convertit la o dimensiune mai mică decât cel al screensaver-ului, deoarece trebuie să încapă într-o fereastră, nu să îți umple ecranul.

Cât timp fereastra este deschisă, o bandă de lumină albă strălucitoare trece înclinat peste desen la fiecare câteva secunde și apoi îl lasă din nou nemișcat. Și desenul tău primește același tratament, atâta timp cât fiecare caracter din el are lățimea de o coloană — tot ce produce _Setează din imagine_ are. Desenele construite din emoji sau caractere cu lățime dublă rămân nemișcate în schimb, la fel și ecranul dacă păstrezi un config fastfetch propriu: un logo nemișcat în aceste cazuri înseamnă că animația se dă la o parte, nu că eșuează, deoarece glisarea unei sclipiri peste ele ar așeza restul rândului în locul greșit.

 ![branding-about](images/branding-about.webp)

### Convertirea imaginilor pe cont propriu

Ambele opțiuni _Setează din imagine_ nu fac decât să apeleze `omarchy transcode ascii`, pe care îl poți rula direct dacă vrei control asupra conversiei:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Primește `--width` și `--height` în coloane și rânduri de terminal, un `--mode` fie `braille` (implicitul și mult mai fin), fie `block`, un procent `--threshold` pentru a decide care pixeli contează ca parte din logo și `--invert` pentru atunci când logo-ul tău este deschis pe un fundal întunecat. Dacă o conversie iese ca o pată, de obicei trebuie să umbli la threshold.

### Cuvinte în loc de logo

`omarchy ascii` desenează text în Delta Corps Priest 1, fontul FIGlet în care este desenat însuși cuvântul-sigla Omarchy, așa că un screensaver poate spune ceva în loc să arate o imagine:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Primește textul ca argumente sau îl citește dintr-un pipe atunci când nu primește niciunul. Fontul conține doar litere și spații — a fost desenat fără cifre sau punctuație — așa că orice altceva este eliminat și numit pe stderr, în loc să fie înghițit în tăcere.
