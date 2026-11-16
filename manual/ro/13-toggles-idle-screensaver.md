# Comutatoare, Inactivitate & Screensaverul

Multe dintre lucrurile pe care le schimbi zi de zi nu sunt de fapt o setare. Este un mod pe care îl pornești pentru o oră și îl oprești apoi: lumina de noapte cât lucrezi până târziu, nu deranja cât prezinți, rămâi treaz cât te uiți la ceva. Omarchy le numește comutatoare și toate funcționează la fel — o tastă rapidă, o intrare în meniu și o comandă, toate acționând același întrerupător.

### Meniul de comutatoare

`Super + Ctrl + O` deschide direct _Trigger > Toggle_, sau poți ajunge acolo din meniul Omarchy (`Super + Space`). Tot ce se află în lista aceea este un comutator pe care îl poți acționa fără să te gândești unde este păstrată starea. Comutatoarele pentru cum arată desktopul se află alături, sub _Appearance_.

Din terminal, aceleași comutatoare sunt `omarchy toggle <thing>`. Rulează `omarchy toggle` singur ca să vezi tot grupul.

| Comutator | Tastă rapidă | Comandă |
| ------ | ------ | ------- |
| Lumină de noapte | — | `omarchy toggle nightlight` |
| Silențiază notificările | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Rămâi treaz (fără blocare la inactivitate) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Captură în caz de prăbușire | — | `omarchy toggle crash-capture` |
| Screensaver | — | `omarchy toggle screensaver` |
| Sincronizare temă [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Bară de meniu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Ecran tactil | — | `omarchy toggle touchscreen` |
| Suspendare | — | `omarchy toggle suspend` |
| GPU hibrid | — | `omarchy toggle hybrid gpu` |

Comutatoarele pentru touchpad, ecran tactil și GPU hibrid se află sub _Trigger > Hardware_ (`Super + Ctrl + H`) și nu sub Toggle, deoarece apar numai atunci când chiar ai acel hardware. Cele pentru touchpad și ecran tactil supraviețuiesc unei reîncărcări Hyprland — numele dispozitivului dezactivat este salvat într-un mic fișier de stare pe care Hyprland îl citește la pornire ca să îl dezactiveze din nou.

_Appearance_ conține bara de meniu și animațiile, plus câteva lucruri care nu sunt comenzi `omarchy toggle`, dar se comportă la fel: procentul bateriei în bară, aspectul implicit al spațiului de lucru și, sub _Windows_, spațiile dintre ferestre (`Super + Shift + Backspace`) și aspectul pătrat pentru 1 fereastră (`Super + Ctrl + Backspace`).

Când Hyprland nu are niciun GPU cu care să deseneze și randează în schimb pe CPU (llvmpipe), ca pe Mac-urile al căror GPU nu este încă acceptat, în majoritatea mașinilor virtuale sau când un driver grafic nu se încarcă, Omarchy oprește animațiile, estomparea și umbrele pentru sesiunea respectivă și îți spune acest lucru o singură dată printr-o notificare. _Appearance > Animations On_ le aduce înapoi, iar Omarchy reține acest lucru și pentru sesiunile ulterioare.

Majoritatea acestora sunt doar un fișier indicator sub `~/.local/state/omarchy/toggles/`. Dacă vrei să te ramifici în funcție de unul într-un script, `omarchy-toggle-enabled` îți oferă un cod de ieșire în loc să te pună să îl cauți:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Indicatoarele sunt numite după starea oprită — `screensaver-off`, `suspend-off`, `bar-off` — așa că prezența lor înseamnă că funcția este dezactivată.

### Indicatori în bară

Când un mod este pornit, primești un mic glif în mijlocul barei de sus, lângă ceas. Acesta este widgetul de indicatori și conține dictarea, înregistrarea ecranului, mementourile în așteptare, lumina de noapte, nu deranja și rămâi treaz.

Indicatorii inactivi sunt ascunși. Treci cu mouse-ul oriunde pe bară și ei apar estompați, ca să poți face clic pe unul pentru a-l porni fără să îi cunoști tasta rapidă. Dacă faci clic pe unul activ, îl oprești la loc. Dacă preferi să îi vezi pe toți tot timpul, setează `alwaysShow` la `true` pe intrarea `omarchy.indicators` din `~/.config/omarchy/shell.json` — vezi [bara de sus](05-the-top-bar.md) pentru cum sunt configurate widgeturile barei.

### Lumină de noapte

Lumina de noapte încălzește ecranul la 4000K, iar comutarea ei din nou îl readuce la 6500K. Acționeaz-o din meniul de comutatoare (`Super + Ctrl + O`) sau cu `omarchy toggle nightlight`. Este controlată de hyprsunset, pe care comutatorul îl pornește pentru tine dacă nu rulează deja.

În mod implicit, hyprsunset nu face absolut nimic ecranului tău. `~/.config/hypr/hyprsunset.conf` vine cu un profil de identitate tocmai pentru ca afișajul să rămână neatins până când ceri căldură. Dacă preferi să comute după ceas, înlocuiește-l cu un profil de timp:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Apoi pornește hyprsunset la autentificare adăugând `o.launch_on_start("hyprsunset")` în `~/.config/hypr/autostart.lua`. Perechea 4000K/6500K folosită de comutator este fixă, așa că fișierul de configurare este locul unde mergi dacă vrei o altă temperatură.

### Nu deranja

`Super + Ctrl + Alt + ,` silențiază notificările. Niciun toast nu apare cât timp este pornit, iar indicatorul cu clopoțelul tăiat stă în bară ca să îți amintească de ce desktopul a tăcut.

Nu se pierde nimic, totuși. Notificările silențiate sunt reținute: pune ultimele câteva înapoi pe ecran cu `Super + Shift + Alt + ,`. Vezi [notificări](10-notices.md) pentru restul.

Două tipuri de mesaje tot trec: toasturile proprii de confirmare ale Omarchy pentru ceva ce tocmai ai făcut ("Theme changed", "Screenshot saved") și alertele critice trimise din linia de comandă. Aplicațiile de chat care marchează totul drept critic ca să se bage cu forța în fața ta nu se califică.

### Inactivitate

Shell-ul Omarchy deține comportamentul la inactivitate, iar timpii sunt un bloc `idle` la nivel superior în `~/.config/omarchy/shell.json`:

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

Dacă închizi screensaverul înainte de termenul de blocare, acest lucru contează ca activitate, iar blocarea în așteptare este anulată. Nu rămâi blocat afară pentru că te-ai uitat la mașina ta.

Pentru a opri complet blocarea la inactivitate, `Super + Ctrl + I` — sau `omarchy toggle idle` — pornește rămâi treaz, iar indicatorul cu ceașca de cafea apare în bară. Pe acela trebuie să îl apeși înainte de o prezentare lungă sau de o compilare pe care vrei să o urmărești. Apasă-l din nou pentru a reveni la normal. `omarchy toggle idle status` afișează starea curentă ca JSON, dacă ai nevoie de ea dintr-un script.

Este vorba despre blocare și screensaver, nu despre alimentare. Suspendarea și hibernarea au propria configurare în [suspendarea sistemului](36-system-sleep.md).

### Screensaverul

Screensaverul Omarchy este artă ASCII care rulează prin efecte de text aleatorii, câte o instanță pe monitor. Orice tastă sau mișcare a mouse-ului îl închide.

Îl poți porni la cerere din _System > Screensaver_ (`Super + Esc`), ceea ce îl forțează să apară chiar dacă ai oprit screensaverul la inactivitate. În mod implicit, nu are nicio tastă rapidă asociată.

`omarchy toggle screensaver` este ceea ce îl oprește pe cel la inactivitate, dacă preferi să treci direct de la lucru la blocat. Orice tastă, clic, derulare sau mișcare a mouse-ului îl închide.

Logo-ul pe care îl desenează îl poți schimba tu, sub _Appearance > Branding > Screensaver_. Încarcă un png sau svg și Omarchy îl convertește în ASCII. Vezi [branding](41-branding.md).

### Ecranul de blocare

`Super + Ctrl + L` blochează mașina. Aceasta rulează ecranul de blocare din shell-ul Omarchy, stinge afișajul, resetează aspectul tastaturii la primul, ca să nu îți tastezi parola în alfabetul greșit, și — dacă îl ai pornit — blochează 1Password la ieșire.

Ecranul de blocare acceptă o parolă și va accepta și o amprentă după ce ai configurat una. Acest lucru, precum și celelalte modalități de autentificare, sunt tratate în [autentificarea hardware](37-hardware-authentication.md).
