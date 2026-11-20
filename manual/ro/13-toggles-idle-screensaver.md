# Comutatoare, inactivitate și screensaverul

O mare parte din ce schimbi zi de zi nu este, de fapt, o setare. Este un mod pe care îl pornești pentru o oră și îl oprești la loc: lumină de noapte cât timp lucrezi până târziu, nu deranja cât timp prezinți, rămâi treaz cât timp te uiți la ceva. Omarchy le numește comutatoare și toate funcționează la fel — o tastă rapidă, o intrare în meniu și o comandă, toate acționând același întrerupător.

### Meniul de comutatoare

`Super + Ctrl + O` deschide direct _Trigger > Toggle_, sau poți ajunge acolo din meniul Omarchy (`Super + Space`). Tot ce se află în lista aceea este un comutator pe care îl poți acționa fără să te gândești unde este păstrată starea. Comutatoarele pentru aspectul desktopului se află lângă el, sub _Appearance_.

Din terminal, aceleași comutatoare sunt `omarchy toggle <thing>`. Rulează `omarchy toggle` singur ca să vezi întregul grup.

| Comutator | Tastă rapidă | Comandă |
| ------ | ------ | ------- |
| Lumină de noapte | — | `omarchy toggle nightlight` |
| Silențierea notificărilor | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Rămâi treaz (fără blocare la inactivitate) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Captură în caz de crash | — | `omarchy toggle crash-capture` |
| Screensaver | — | `omarchy toggle screensaver` |
| Sincronizarea temei [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Bară de meniu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Ecran tactil | — | `omarchy device touchscreen` |
| Suspendare | — | `omarchy toggle suspend` |
| GPU hibrid | — | `omarchy toggle hybrid gpu` |

Comutatoarele pentru touchpad, ecran tactil și GPU hibrid se află sub _Trigger > Hardware_ (`Super + Ctrl + H`), nu sub Toggle, fiindcă apar doar când ai efectiv acel hardware. Cele pentru touchpad și ecran tactil supraviețuiesc unei reîncărcări Hyprland — numele dispozitivului dezactivat este salvat într-un mic fișier de stare pe care Hyprland îl citește la pornire ca să îl dezactiveze din nou.

_Appearance_ conține bara de meniu și animațiile, plus câteva lucruri care nu sunt comenzi `omarchy toggle`, dar se comportă la fel: procentul bateriei în bară, aspectul implicit al spațiului de lucru și, sub _Windows_, spațiile dintre ferestre (`Super + Shift + Backspace`) și aspectul pătrat pentru 1 fereastră (`Super + Ctrl + Backspace`).

Când Hyprland nu are niciun GPU cu care să deseneze și randează în schimb pe CPU (llvmpipe), ca pe Mac-urile al căror GPU nu este încă acceptat, în majoritatea mașinilor virtuale sau când un driver grafic nu se încarcă, Omarchy oprește animațiile, blur-ul și umbrele pentru sesiunea respectivă și îți spune acest lucru o singură dată printr-o notificare. _Appearance > Animations On_ le readuce, iar Omarchy reține acest lucru și pentru sesiunile ulterioare.

Majoritatea acestora sunt doar un fișier indicator sub `~/.local/state/omarchy/toggles/`. Dacă vrei să te ramifici în funcție de unul într-un script, `omarchy-toggle-enabled` îți dă un cod de ieșire în loc să te oblige să mergi să îl cauți:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Indicatorii sunt numiți după starea oprită — `screensaver-off`, `suspend-off`, `bar-off` — deci prezența lor înseamnă că funcția este dezactivată.

### Indicatorii din bară

Când un mod este activ, primești un mic glif în mijlocul barei de sus, lângă ceas. Acesta este widgetul de indicatori și conține dictarea, înregistrarea ecranului, mementourile în așteptare, lumina de noapte, nu deranja și rămâi treaz.

Indicatorii inactivi sunt ascunși. Treci cu cursorul oriunde pe bară și ei apar estompați, ca să poți face clic pe unul ca să îl pornești fără să îi cunoști tasta rapidă. Dacă faci clic pe unul activ, îl oprești la loc. Dacă preferi să îi vezi pe toți tot timpul, setează `alwaysShow` la `true` pe intrarea `omarchy.indicators` din `~/.config/omarchy/shell.json` — vezi [bara de sus](05-the-top-bar.md) pentru cum sunt configurate widgeturile din bară.

### Lumina de noapte

Lumina de noapte încălzește ecranul la 4000K, iar dacă o comuți din nou îl readuce la 6500K. Activeaz-o din meniul de comutatoare (`Super + Ctrl + O`) sau cu `omarchy toggle nightlight`. Este controlată de hyprsunset, pe care comutatorul îl pornește pentru tine dacă nu rulează deja.

În mod implicit, hyprsunset nu face absolut nimic ecranului tău. `~/.config/hypr/hyprsunset.conf` vine cu un profil de identitate tocmai ca afișajul să rămână neatins până când ceri căldură. Dacă preferi să comute după ceas, înlocuiește-l cu un profil bazat pe oră:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Apoi pornește hyprsunset la autentificare adăugând `o.launch_on_start("hyprsunset")` în `~/.config/hypr/autostart.lua`. Perechea 4000K/6500K folosită de comutator este fixă, deci fișierul de configurare este locul unde mergi dacă vrei o altă temperatură.

### Nu deranja

`Super + Ctrl + Alt + ,` silențiază notificările. Niciun toast nu apare cât timp este activ, iar indicatorul cu clopoțelul tăiat stă în bară ca să îți amintească de ce a tăcut desktopul.

Nu se pierde nimic, totuși. Notificările silențiate sunt reținute: pune-le pe ultimele câteva înapoi pe ecran cu `Super + Shift + Alt + ,`. Vezi [notificări](10-notices.md) pentru restul.

Două tipuri de mesaje trec totuși: toasturile proprii de confirmare ale Omarchy pentru ceva ce tocmai ai făcut ("Theme changed", "Screenshot saved") și alertele critice trimise din linia de comandă. Aplicațiile de chat care marchează totul drept critic ca să își forțeze intrarea în fața ta nu se califică.

### Inactivitate

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

Ambele numere sunt secunde numărate din momentul în care ai intrat în inactivitate — nu unul de la celălalt. Deci, cu valorile implicite, screensaverul apare după două minute și jumătate, iar ecranul de blocare preia controlul la cinci minute, indiferent dacă screensaverul a rulat sau nu. Salvează fișierul și shell-ul preia imediat noii timpi.

Dacă închizi screensaverul înainte de termenul de blocare, acest lucru contează ca activitate, iar blocarea în așteptare este anulată. Nu ajungi blocat afară pentru că ai aruncat o privire la mașina ta.

Ca să oprești complet blocarea la inactivitate, `Super + Ctrl + I` — sau `omarchy toggle idle` — activează rămâi treaz, iar indicatorul cu ceașca de cafea apare în bară. Pe acesta trebuie să îl apeși înaintea unei prezentări lungi sau a unui build pe care vrei să îl urmărești. Apasă-l din nou ca să revii la normal. `omarchy toggle idle status` afișează starea curentă ca JSON dacă ai nevoie de ea dintr-un script.

Aici este vorba despre blocare și screensaver, nu despre alimentare. Suspendarea și hibernarea își au configurarea proprie în [repausul sistemului](36-system-sleep.md).

### Screensaverul

Screensaverul Omarchy este artă ASCII care trece prin efecte de text aleatorii, câte o instanță per monitor. Orice tastă sau mișcare a mouse-ului îl închide.

Îl poți porni la cerere din _System > Screensaver_ (`Super + Esc`), ceea ce îl forțează să apară chiar dacă ai oprit screensaverul la inactivitate. În mod implicit, nu are nicio tastă rapidă alocată.

`omarchy toggle screensaver` este cel care îl oprește pe cel de la inactivitate, dacă preferi să treci direct de la lucru la blocat. Orice tastă, clic, derulare sau mișcare a mouse-ului îl închide.

Logo-ul pe care îl desenează poate fi schimbat de tine, sub _Appearance > Branding > Screensaver_. Încarcă un png sau svg și Omarchy îl convertește în ASCII. Vezi [identitatea vizuală](41-branding.md).

### Ecranul de blocare

`Super + Ctrl + L` blochează mașina. Aceasta rulează ecranul de blocare din shell-ul Omarchy, stinge afișajul, îți resetează aspectul tastaturii la primul, ca să nu îți tastezi parola în alfabetul greșit, și — dacă îl ai pornit — blochează 1Password la ieșire.

Ecranul de blocare acceptă o parolă și va accepta și o amprentă odată ce ai configurat una. Acest lucru și celelalte moduri de autentificare sunt tratate în [autentificarea hardware](37-hardware-authentication.md).
