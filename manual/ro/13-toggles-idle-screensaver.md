# Comutări, inactivitatea și economizorul de ecran

Multe dintre lucrurile pe care le schimbi zi de zi nu sunt cu adevărat setări. Sunt moduri pe care le activezi pentru o oră și le dezactivezi iar: lumina de noapte cât lucrezi târziu, nu deranja cât prezinți, rămâi treaz cât vizionezi ceva. Omarchy le numește comutări și toate funcționează la fel — o scurtătură, o intrare în meniu și o comandă, toate atingând același întrerupător.

### Meniul de comutare

`Super + Ctrl + O` deschide direct _Declanșator > Comută_ sau poți merge acolo din meniul Omarchy (`Super + Space`). Tot ce e în acea listă este un întrerupător pe care îl poți acționa fără să te gândești unde trăiește starea. Întrerupătoarele pentru aspectul desktopului stau lângă el, sub _Declanșator > Aspect_.

Din terminal, aceleași întrerupătoare sunt `omarchy toggle <thing>`. Rulează `omarchy toggle` singur ca să vezi întregul grup.

| Comutare | Scurtătură | Comandă |
| ------ | ------ | ------- |
| Lumina de noapte | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Oprește sunetul notificărilor | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Rămâi treaz (fără blocare la inactivitate) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Captură erori | — | `omarchy toggle crash-capture` |
| Economizor ecran | — | `omarchy toggle screensaver` |
| Sincronizarea temei [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Bara de meniu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Ecran tactil | — | `omarchy toggle touchscreen` |
| Suspendă | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Întrerupătoarele pentru touchpad, ecran tactil și GPU hibrid trăiesc sub _Declanșator > Hardware_ (`Super + Ctrl + H`), mai degrabă decât sub Comută, deoarece apar doar atunci când ai cu adevărat acel hardware. Cele pentru touchpad și ecran tactil supraviețuiesc unei reîncărcări Hyprland — numele dispozitivului dezactivat este salvat într-un mic fișier de stare pe care Hyprland îl citește la pornire ca să-l dezactiveze din nou.

_Declanșator > Aspect_ ține bara de meniu și animațiile, plus câteva lucruri care nu sunt comenzi `omarchy toggle`, dar se comportă la fel: procentul bateriei în bară, aranjarea implicită a spațiilor de lucru, spațiile dintre ferestre (`Super + Shift + Backspace`) și aspectul pătrat pentru 1 fereastră (`Super + Ctrl + Backspace`).

Majoritatea acestora sunt doar un fișier indicator sub `~/.local/state/omarchy/toggles/`. Dacă vrei să te ramifici după unul într-un script, `omarchy-toggle-enabled` îți dă un cod de ieșire, în loc să te facă să mergi să cauți:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Indicatoarele sunt numite după starea dezactivată — `screensaver-off`, `suspend-off`, `bar-off` — astfel încât prezența lor înseamnă că funcția este dezactivată.

### Indicatori în bară

Atunci când un mod este activat, primești o mică glifă în mijlocul barei de sus, lângă ceas. Acesta este widgetul de indicatori și poartă dictarea, înregistrarea ecranului, memento-urile în așteptare, lumina de noapte, nu deranja și rămâi treaz.

Indicatorii inactivi sunt ascunși. Trece cu indicatorul peste zona din jurul lor și apar estompați, astfel încât să poți face clic pe unul ca să-l activezi fără să-i știi scurtătura. Clicul pe unul activ îl dezactivează din nou. Dacă preferi să le vezi pe toate tot timpul, setează `alwaysShow` la `true` pe intrarea `omarchy.indicators` din `~/.config/omarchy/shell.json` — vezi [bara de sus](05-the-top-bar.md) pentru modul în care sunt configurate widgeturile barei.

### Lumina de noapte

`Super + Ctrl + N` încălzește ecranul la 4000 K, iar o nouă apăsare îl readuce la 6500 K. Este condus de hyprsunset, pe care comutarea îl pornește pentru tine dacă nu rulează deja.

Implicit, hyprsunset nu face absolut nimic ecranului tău. `~/.config/hypr/hyprsunset.conf` vine cu un profil identitar tocmai pentru ca afișajul să rămână neatins până când ceri căldură. Dacă preferi să se schimbe după ceas, înlocuiește-l cu un profil de timp:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Apoi pornește hyprsunset la autentificare adăugând `o.launch_on_start("hyprsunset")` la `~/.config/hypr/autostart.lua`. Perechea 4000 K/6500 K folosită de comutare este fixă, așa că fișierul de configurare este locul în care mergi dacă vrei o altă temperatură.

### Nu deranja

`Super + Ctrl + ,` oprește sunetul notificărilor. Niciun toast nu apare cât timp este activat, iar indicatorul clopoțelului tăiat stă în bară ca să-ți amintească de ce desktopul a tăcut.

Totuși, nimic nu se pierde. O notificare fără sunet este scrisă direct în istoricul tău de notificări, care este exact înregistrarea pe care o vrei atunci când te întorci și te întrebi ce ai ratat. Deschide-l cu `Super + Shift + Alt + ,`. Vezi [notificările rapide](10-notices.md) pentru restul poveștii notificărilor.

Două feluri de mesaje trec în continuare: toasturile de confirmare ale Omarchy pentru ceva ce tocmai ai făcut („Theme changed”, „Screenshot saved”) și alertele critice trimise din linia de comandă. Aplicațiile de chat care marchează totul critic ca să-și forțeze drumul în fața ta nu se califică.

### Inactivitatea

Shellul Omarchy deține comportamentul la inactivitate, iar timpii sunt un bloc `idle` de nivel superior în `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Ambele numere sunt secunde numărate din momentul în care ai devenit inactiv — nu unul de la altul. Astfel, cu valorile implicite, economizorul de ecran apare după două minute și jumătate, iar ecranul de blocare preia controlul la cinci minute, indiferent dacă economizorul de ecran a rulat sau nu. Salvează fișierul și shellul preia noii timpi imediat.

Dacă închizi economizorul de ecran înainte de termenul de blocare, aceasta contează ca activitate, iar blocarea în așteptare este anulată. Nu te blochezi afară pentru că ai aruncat o privire la mașina ta.

Ca să oprești complet blocarea la inactivitate, `Super + Ctrl + I` — sau `omarchy toggle idle` — activează „rămâi treaz”, iar indicatorul ceștii de cafea apare în bară. Acesta este cel de apăsat înainte de o prezentare lungă sau de o compilare pe care vrei s-o urmărești. Apasă-l din nou ca să revii la normal. `omarchy toggle idle status` tipărește starea curentă ca JSON dacă ai nevoie de ea dintr-un script.

Asta ține de blocare și de economizorul de ecran, nu de alimentare. Suspendarea și hibernarea au propria lor configurare în [suspendarea sistemului](36-system-sleep.md).

### Economizorul de ecran

Economizorul de ecran al Omarchy este artă ASCII care trece prin efecte text aleatorii, câte o instanță per monitor. Orice tastă sau mișcare a mouse-ului iese din el.

Îl poți porni la cerere din _System > Economizor ecran_ (`Super + Esc`), ceea ce îl forțează să apară chiar dacă ai dezactivat economizorul de ecran la inactivitate. Nu există nicio scurtătură legată de el implicit.

`omarchy toggle screensaver` este cel care îl dezactivează pe cel de la inactivitate, dacă preferi să mergi direct de la lucru la blocat. Are nevoie de un terminal pe care știe cum să-l configureze — Alacritty, Foot, Ghostty sau Kitty — și îți va spune asta dacă terminalul tău implicit este altceva.

Logo-ul pe care îl desenează este al tău să-l schimbi, sub _Stil > Economizor ecran_. Încarcă un png sau un svg și Omarchy îl convertește în ASCII. Vezi [brandingul](41-branding.md).

### Ecranul de blocare

`Super + Ctrl + L` blochează mașina. Aceasta rulează ecranul de blocare din shellul Omarchy, înnegrește afișajul, resetează aranjarea tastaturii la prima, astfel încât să nu-ți tastezi parola în alfabetul greșit, și — dacă îl ai în funcțiune — blochează 1Password la ieșire.

Ecranul de blocare acceptă o parolă și va accepta și o amprentă odată ce ai configurat una. Aceasta și celelalte moduri de autentificare sunt tratate în [autentificarea hardware](37-hardware-authentication.md).
