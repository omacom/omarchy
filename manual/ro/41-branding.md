# Branding

Omarchy îți permite să setezi logo-ul companiei tale sau o imagine personală atât pentru deblocarea la pornire, cât și pentru economizorul de ecran și pentru ecranul Despre.

### Deblocarea la pornire

Poți folosi `omarchy plymouth preview` ca să vezi cum ar arăta logo-ul și culorile tale personalizate. Primește o culoare de fundal, o culoare a textului, un logo png și o cale pentru imaginea de previzualizare:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Apoi aplică configurația cu `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, care va oferi și ecranului de autentificare SDDM aceleași culori și același logo. Dacă vrei să revii, poți folosi `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Economizor ecran

Poți schimba logo-ul folosit pentru economizorul de ecran sub _Stil > Economizor ecran_. Este un logo ASCII, așa că poți edita textul direct, dar îi poți da și o imagine png sau svg, iar noi o vom converti în ASCII. Arată destul de grozav.

 ![branding-screensaver](images/branding-screensaver.webp)

Există trei intrări în acel meniu:

- **Editează textul** deschide `~/.config/omarchy/branding/screensaver.txt` în editorul tău. Tastează sau lipește ce vrei — artă ASCII, numele tău, un cuvânt nepoliticos. Salvează și ieși, iar economizorul de ecran pornește imediat ca să îl poți vedea.
- **Setează din imagine** deschide un selector de fișiere pentru un png sau svg, îl convertește în ASCII și îți arată rezultatul. Logo-urile cu o siluetă clară funcționează mult mai bine decât fotografiile.
- **Restabilește implicit** pune înapoi logo-ul Omarchy.

### Ecranul Despre

Aceleași trei opțiuni se află sub _Stil > Despre_ pentru ecranul _Despre_ pe care îl obții din meniul Omarchy, și funcționează identic — fișierul este `~/.config/omarchy/branding/about.txt`, iar fereastra Despre apare după fiecare schimbare. Arta Despre este convertită la o dimensiune mai mică decât cea a economizorului de ecran, deoarece trebuie să încapă într-o fereastră, nu să-ți umple afișajul.

Cât timp fereastra este deschisă, o sclipire verde se apleacă peste artă la fiecare câteva secunde și apoi o lasă din nou nemișcată. Și arta ta o primește, atâta timp cât fiecare caracter din ea are lățimea unei coloane — tot ce produce _Setează din imagine_ are. Arta construită din emoji sau caractere cu lățime dublă rămâne în schimb nemișcată, și la fel și ecranul dacă păstrezi o configurație fastfetch proprie: un logo nemișcat în acele cazuri este animația care se ferește din cale, nu una care eșuează, deoarece alunecarea unei sclipiri peste ele ar arunca restul rândului în locul greșit.

 ![branding-about](images/branding-about.webp)

### Convertirea imaginilor pe cont propriu

Ambele opțiuni _Setează din imagine_ doar apelează `omarchy transcode ascii`, pe care îl poți rula direct dacă vrei control asupra conversiei:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Primește `--width` și `--height` în coloane și rânduri de terminal, un `--mode` fie `braille` (implicitul, și mult mai fin), fie `block`, un procent `--threshold` pentru a decide care pixeli contează ca parte a logo-ului și `--invert` pentru atunci când logo-ul tău este deschis pe un fundal închis. Dacă o conversie iese ca o pată, pragul este de obicei butonul de rotit.

### Cuvinte în loc de logo

`omarchy ascii` desenează text în Delta Corps Priest 1, fontul FIGlet în care este desenat însuși marcajul verbal Omarchy, astfel încât un economizor de ecran poate spune ceva, în loc să arate o imagine:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Primește textul ca argumente sau îl citește dintr-o conductă când nu i se dă niciunul. Fontul conține doar litere și spații — a fost desenat fără cifre sau semne de punctuație — așa că orice altceva este aruncat și numit pe stderr, în loc să fie înghițit în tăcere.
