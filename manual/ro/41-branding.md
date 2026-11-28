# Branding

Omarchy îți permite să setezi logo-ul companiei tale sau o imagine personală atât pentru screensaver, cât și pentru ecranul Despre.

### Screensaver

Poți schimba logo-ul folosit pentru screensaver din _Appearance > Branding > Screensaver_. Este un logo ASCII, așa că poți edita textul direct, dar îi poți da și o imagine png sau svg, iar noi o vom converti în ASCII. Arată destul de tare.

 ![branding-screensaver](images/branding-screensaver.webp)

Există trei intrări în acel meniu:

- **Edit Text** deschide `~/.config/omarchy/branding/screensaver.txt` în editorul tău. Tastează sau lipește orice vrei — artă ASCII, numele tău, o înjurătură. Salvează și închide, iar screensaver-ul pornește imediat ca să îl poți vedea.
- **Set From Image** deschide un selector de fișiere pentru un png sau svg, îl convertește în ASCII și îți arată rezultatul. Logo-urile cu o siluetă clară funcționează mult mai bine decât fotografiile.
- **Restore Default** repune logo-ul Omarchy.

### Ecranul Despre

Aceleași trei opțiuni se află sub _Appearance > Branding > About_ pentru ecranul _About_ pe care îl obții din meniul Omarchy și funcționează identic — fișierul este `~/.config/omarchy/branding/about.txt`, iar fereastra About apare după fiecare modificare. Arta About este convertită la o dimensiune mai mică decât cea a screensaver-ului, deoarece trebuie să încapă într-o fereastră, nu să îți umple ecranul.

Cât timp fereastra este deschisă, o bandă de lumină albă strălucitoare se înclină peste artă la fiecare câteva secunde și apoi o lasă din nou nemișcată. Și arta ta o primește, atâta timp cât fiecare caracter din ea are lățimea de o singură coloană — tot ce produce _Set From Image_ are. Arta construită din emoji sau din caractere cu lățime dublă rămâne în schimb nemișcată, la fel și ecranul dacă păstrezi o configurație fastfetch proprie: un logo nemișcat în aceste cazuri înseamnă că animația se dă la o parte, nu că eșuează, deoarece alunecarea unei sclipiri peste ele ar face ca restul rândului să ajungă în locul greșit.

 ![branding-about](images/branding-about.webp)

### Conversia imaginilor pe cont propriu

Ambele opțiuni _Set From Image_ nu fac decât să apeleze `omarchy transcode ascii`, pe care îl poți rula direct dacă vrei control asupra conversiei:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Preia `--width` și `--height` în coloane și rânduri de terminal, un `--mode` fie `braille` (implicitul, și mult mai fin), fie `block`, un `--threshold` exprimat procentual pentru a decide care pixeli contează ca parte din logo și `--invert` pentru atunci când logo-ul tău este deschis la culoare pe un fundal închis. Dacă o conversie iese ca o pată, pragul este de obicei reglajul la care trebuie să umbli.

### Cuvinte în loc de logo

`omarchy ascii` desenează text în Delta Corps Priest 1, fontul FIGlet în care este desenat însuși cuvântul-sigla Omarchy, așa că un screensaver poate spune ceva în loc să arate o imagine:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Preia textul ca argumente sau îl citește dintr-un pipe atunci când nu i se dă niciunul. Fontul conține doar litere și spații — a fost desenat fără cifre sau semne de punctuație — așa că orice altceva este eliminat și numit pe stderr, nu înghițit pe tăcute.
