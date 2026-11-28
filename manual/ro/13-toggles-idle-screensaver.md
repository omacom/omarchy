# Comutatoare, inactivitatea și screensaverul

O mare parte din ce schimbi zi de zi nu este, de fapt, o setare. Este un mod pe care îl pornești pentru o oră și îl oprești apoi: lumină de noapte cât lucrezi până târziu, nu deranja cât prezinți, rămâi treaz cât te uiți la ceva. Omarchy le numește comutatoare și toate funcționează la fel — o tastă rapidă, o intrare în meniu și o comandă, toate apasă același întrerupător.

### Meniul de comutatoare

`Super + Ctrl + O` deschide direct _Trigger > Toggle_, sau poți ajunge acolo din meniul Omarchy (`Super + Space`). Tot ce este în lista aceea este un comutator pe care îl poți răsuci fără să te gândești unde trăiește starea. Comutatoarele pentru cum arată desktopul stau lângă el, sub _Appearance_.

Din terminal, aceleași comutatoare sunt `omarchy toggle <thing>`. Rulează `omarchy toggle` singur ca să vezi tot grupul.

| Comutator | Tastă rapidă | Comandă |
| ------ | ------ | ------- |
| Lumină de noapte | — | `omarchy toggle nightlight` |
| Notificări silențioase | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Rămâi treaz (fără blocare la inactivitate) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Captură la prăbușire | — | `omarchy toggle crash-capture` |
| Screensaver | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) sincronizare temă | — | `omarchy toggle theme sync` |
| Bară de meniu | `Super + Shift + Space` | `omarchy toggle bar` |
| Desktop pe tot ecranul (fără bară, fără spații) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animații, blur și umbre | — | `omarchy toggle animations` |
| Touchpad | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Ecran tactil | — | `omarchy device touchscreen` |
| Suspendare | — | `omarchy toggle suspend` |
| GPU hibrid | — | `omarchy device gpu hybrid` |

Comutatoarele pentru touchpad, ecran tactil și GPU hibrid trăiesc sub _Trigger > Hardware_ (`Super + Ctrl + H`) mai degrabă decât sub Toggle, fiindcă apar doar când chiar ai hardware-ul respectiv. Cele pentru touchpad și ecran tactil supraviețuiesc unei reîncărcări Hyprland — numele dispozitivului dezactivat este salvat într-un mic fișier de stare pe care Hyprland îl citește la pornire ca să-l dezactiveze din nou.

_Appearance_ ține bara de meniu și animațiile, plus câteva lucruri care nu sunt comenzi `omarchy toggle`, dar se comportă la fel: procentul bateriei în bară, aspectul implicit al spațiului de lucru și, sub _Windows_, spațiile dintre ferestre (`Super + Shift + Backspace`) și aspectul pătrat pentru 1 fereastră (`Super + Ctrl + Backspace`).

Când Hyprland nu are niciun GPU cu care să deseneze și randează în schimb pe CPU (llvmpipe), ca pe Mac-urile al căror GPU nu este încă suportat, în majoritatea mașinilor virtuale sau când un driver grafic nu se încarcă, Omarchy oprește animațiile, blur-ul și umbrele pentru sesiunea aceea și îți spune o dată, printr-o notificare. _Appearance > Animations On_ le aduce înapoi, iar Omarchy ține minte asta și pentru sesiunile ulterioare.

Majoritatea acestora sunt doar un fișier indicator sub `~/.local/state/omarchy/toggles/`. Dacă vrei să te ramifici după unul într-un script, `omarchy-toggle-enabled` îți dă un cod de ieșire în loc să te pună să cauți:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Fișierele indicator sunt numite după starea oprită — `screensaver-off`, `suspend-off`, `bar-off` — așa că prezența lor înseamnă că funcția este dezactivată.

### Indicatoarele din bară

Când un mod este pornit, primești un mic glif în mijlocul barei de sus, lângă ceas. Acela este widgetul de indicatoare și poartă înregistrarea ecranului, mementourile în așteptare, lumina de noapte, nu deranja și rămâi treaz, plus avertismente cât timp sudo fără parolă este pornit sau cineva este conectat la o sesiune la distanță.

Indicatoarele inactive sunt ascunse. Treci cu cursorul oriunde pe bară și ele apar estompate, ca să poți face clic pe unul ca să-l pornești fără să-i știi tasta rapidă. Dacă faci clic pe unul activ, îl oprești la loc. Dacă preferi să le vezi pe toate tot timpul, setează `alwaysShow` la `true` pe intrarea `omarchy.indicators` din `~/.config/omarchy/shell.json` — vezi [bara de sus](05-the-top-bar.md) pentru cum sunt configurate widgeturile barei.

### Lumina de noapte

Lumina de noapte încălzește ecranul la 4000K, iar comutarea ei din nou îl readuce la 6500K. Răsucește-o din meniul de comutatoare (`Super + Ctrl + O`) sau cu `omarchy toggle nightlight`. Este condusă de hyprsunset, pe care comutatorul îl pornește pentru tine dacă nu rulează deja.

Implicit, hyprsunset nu face absolut nimic ecranului tău. `~/.config/hypr/hyprsunset.conf` vine cu un profil identitate tocmai ca afișajul să rămână neatins până ceri căldură. Dacă preferi să comute după ceas, înlocuiește-l cu un profil de timp:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Apoi pornește hyprsunset la autentificare adăugând `o.launch_on_start("hyprsunset")` la `~/.config/hypr/autostart.lua`. Perechea 4000K/6500K folosită de comutator este fixă, așa că fișierul de configurare este locul unde mergi dacă vrei o altă temperatură.

### Nu deranja

`Super + Ctrl + Alt + ,` reduce la tăcere notificările. Nicio notificare toast nu apare cât timp este pornit, iar indicatorul cu clopoțel tăiat stă în bară ca să-ți amintească de ce desktopul a tăcut.

Nimic nu se pierde, totuși. Notificările reduse la tăcere sunt reținute: pune-le pe ultimele câteva înapoi pe ecran cu `Super + Shift + Alt + ,`. Vezi [notificări](10-notices.md) pentru restul.

Trei feluri de mesaje tot trec: notificările toast de confirmare ale Omarchy pentru ceva ce tocmai ai făcut ("Theme changed", "Screenshot saved"), alertele critice trimise din linia de comandă și codurile de verificare. Aplicațiile de chat care marchează totul ca fiind critic ca să-și forțeze intrarea în fața ta nu se califică.

### Inactivitatea

Shell-ul Omarchy deține comportamentul la inactivitate, iar timpii sunt un bloc `idle` de nivel superior în `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Ambele numere sunt secunde numărate din momentul în care ai devenit inactiv — nu unul de la celălalt. Așa că, cu valorile implicite, screensaverul apare după două minute și jumătate, iar ecranul de blocare preia controlul la cinci minute, indiferent dacă screensaverul a rulat sau nu. Salvează fișierul și shell-ul preia noii timpi imediat.

Dacă închizi screensaverul înainte de termenul de blocare, asta contează ca activitate, iar blocarea în așteptare este anulată. Nu ajungi blocat afară pentru că te-ai uitat la mașina ta.

Ca să oprești complet blocarea la inactivitate, `Super + Ctrl + I` — sau `omarchy toggle idle` — pornește rămâi treaz, iar indicatorul cu ceașcă de cafea apare în bară. Pe ăla trebuie să-l apeși înaintea unei prezentări lungi sau a unui build pe care vrei să-l urmărești. Apasă-l din nou ca să revii la normal. `omarchy toggle idle status` tipărește starea curentă ca JSON dacă ai nevoie de ea dintr-un script.

Asta ține de blocare și de screensaver, nu de alimentare. Suspendarea și hibernarea au configurarea lor în [repausul sistemului](36-system-sleep.md).

### Screensaverul

Screensaverul Omarchy este artă ASCII care rulează prin efecte de text aleatorii, câte o instanță per monitor. Orice tastă sau mișcare a mouse-ului îl închide.

Îl poți porni la cerere din _System > Screensaver_ (`Super + Esc`), ceea ce îl forțează să apară chiar dacă ai oprit screensaverul la inactivitate. Implicit nu are nicio tastă rapidă legată de el.

`omarchy toggle screensaver` este ce oprește pe cel de la inactivitate, dacă preferi să treci direct de la lucru la blocat. Orice tastă, clic, derulare sau mișcare a mouse-ului îl închide.

Logo-ul pe care îl desenează este al tău de schimbat, sub _Appearance > Branding > Screensaver_. Încarcă un png sau svg și Omarchy îl convertește în ASCII. Vezi [branding](41-branding.md).

### Ecranul de blocare

`Super + Ctrl + L` blochează mașina. Asta rulează ecranul de blocare din shell-ul Omarchy, stinge afișajul, îți resetează aspectul tastaturii la primul, ca să nu-ți tastezi parola în alfabetul greșit, și — dacă îl ai pornit — blochează 1Password la ieșire.

Ecranul de blocare acceptă o parolă și va accepta și o amprentă odată ce ai configurat una. Asta și celelalte moduri de autentificare sunt acoperite în [autentificarea hardware](37-hardware-authentication.md).
