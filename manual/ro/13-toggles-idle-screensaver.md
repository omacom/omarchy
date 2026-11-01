# Comutatoare, inactivitatea și screensaverul

O mare parte din ce schimbi zi de zi nu e, de fapt, o setare. E un mod pe care îl activezi pentru o oră și apoi îl dezactivezi: lumina de noapte cât lucrezi până târziu, nu deranja cât prezinți, rămâi treaz cât te uiți la ceva. Omarchy le numește comutatoare, și toate funcționează la fel — o tastă rapidă, o intrare în meniu și o comandă, toate acționând același întrerupător.

### Meniul de comutatoare

`Super + Ctrl + O` deschide direct _Trigger > Toggle_, sau poți ajunge acolo din meniul Omarchy (`Super + Space`). Tot ce e în lista aceea e un comutator pe care îl poți acționa fără să te gândești unde e stocată starea. Comutatoarele pentru aspectul desktopului se află alături, sub _Appearance_.

Din terminal, aceleași comutatoare sunt `omarchy toggle <thing>`. Rulează `omarchy toggle` singur ca să vezi tot grupul.

| Comutator | Tastă rapidă | Comandă |
| ------ | ------ | ------- |
| Lumină de noapte | — | `omarchy toggle nightlight` |
| Silențiază notificările | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Rămâi treaz (fără blocare la inactivitate) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Captură în caz de crash | — | `omarchy toggle crash-capture` |
| Screensaver | — | `omarchy toggle screensaver` |
| Sincronizarea temei [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Bara de meniu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Ecran tactil | — | `omarchy toggle touchscreen` |
| Suspendare | — | `omarchy toggle suspend` |
| GPU hibrid | — | `omarchy toggle hybrid gpu` |

Comutatoarele pentru touchpad, ecran tactil și GPU hibrid se află sub _Trigger > Hardware_ (`Super + Ctrl + H`), nu sub Toggle, fiindcă apar doar când ai efectiv hardware-ul respectiv. Cele pentru touchpad și ecran tactil supraviețuiesc unei reîncărcări Hyprland — numele dispozitivului dezactivat e salvat într-un mic fișier de stare pe care Hyprland îl citește la pornire ca să-l dezactiveze din nou.

_Appearance_ conține bara de meniu și animațiile, plus câteva lucruri care nu sunt comenzi `omarchy toggle`, dar se comportă la fel: procentul bateriei în bară, dispunerea implicită a spațiului de lucru și, sub _Windows_, spațiile dintre ferestre (`Super + Shift + Backspace`) și aspectul pătrat pentru 1 fereastră (`Super + Ctrl + Backspace`).

Cele mai multe dintre acestea sunt doar un fișier indicator sub `~/.local/state/omarchy/toggles/`. Dacă vrei să faci o ramificare după unul într-un script, `omarchy-toggle-enabled` îți dă un cod de ieșire în loc să te pună să-l cauți:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Indicatorii sunt numiți după starea dezactivată — `screensaver-off`, `suspend-off`, `bar-off` — așa că prezența lor înseamnă că funcția e dezactivată.

### Indicatori în bară

Când un mod e activ, primești un mic glif în mijlocul barei de sus, lângă ceas. Acela e widgetul de indicatori și conține dictarea, înregistrarea ecranului, mementourile în așteptare, lumina de noapte, nu deranja și rămâi treaz.

Indicatorii inactivi sunt ascunși. Treci cu cursorul oriunde pe bară și ei apar estompați, ca să poți da clic pe unul ca să-l pornești fără să-i știi tasta rapidă. Dacă dai clic pe unul activ, îl oprești la loc. Dacă preferi să-i vezi pe toți tot timpul, setează `alwaysShow` la `true` pe intrarea `omarchy.indicators` din `~/.config/omarchy/shell.json` — vezi [bara de sus](05-the-top-bar.md) pentru cum se configurează widgeturile barei.

### Lumină de noapte

Lumina de noapte încălzește ecranul la 4000K, iar dacă o comuți din nou, revine la 6500K. Activeaz-o din meniul de comutatoare (`Super + Ctrl + O`) sau cu `omarchy toggle nightlight`. E controlată de hyprsunset, pe care comutatorul îl pornește pentru tine dacă nu rulează deja.

Implicit, hyprsunset nu face absolut nimic ecranului tău. `~/.config/hypr/hyprsunset.conf` vine cu un profil identitate tocmai ca afișajul să rămână neatins până când ceri căldură. Dacă preferi să comute după ceas, înlocuiește-l cu un profil bazat pe oră:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Apoi pornește hyprsunset la autentificare adăugând `o.launch_on_start("hyprsunset")` în `~/.config/hypr/autostart.lua`. Perechea 4000K/6500K folosită de comutator e fixă, așa că în fișierul de configurare te duci dacă vrei o altă temperatură.

### Nu deranja

`Super + Ctrl + Alt + ,` silențiază notificările. Cât e activ, nu apare niciun toast, iar indicatorul cu clopoțelul tăiat stă în bară ca să-ți amintească de ce desktopul a tăcut.

Totuși, nu se pierde nimic. Notificările silențiate sunt reținute: pune-le pe ultimele câteva înapoi pe ecran cu `Super + Shift + Alt + ,`. Vezi [notificări](10-notices.md) pentru restul.

Două tipuri de mesaje tot trec: toasturile proprii de confirmare ale Omarchy pentru ceva ce tocmai ai făcut ("Theme changed", "Screenshot saved") și alertele critice trimise din linia de comandă. Aplicațiile de chat care marchează totul drept critic ca să se bage cu forța în fața ta nu se califică.

### Inactivitatea

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

Ambele numere sunt secunde numărate din momentul în care ai devenit inactiv — nu unul de la celălalt. Așa că, cu valorile implicite, screensaverul apare după două minute și jumătate, iar ecranul de blocare preia controlul la cinci minute, indiferent dacă screensaverul a rulat sau nu. Salvează fișierul și shell-ul preia imediat noii timpi.

Dacă închizi screensaverul înainte de termenul de blocare, asta contează ca activitate și blocarea în așteptare e anulată. Nu rămâi blocat afară pentru că ai aruncat o privire la mașină.

Ca să oprești complet blocarea la inactivitate, `Super + Ctrl + I` — sau `omarchy toggle idle` — activează rămâi treaz, iar indicatorul cu ceașca de cafea apare în bară. Pe ăsta îl apeși înainte de o prezentare lungă sau de un build pe care vrei să-l urmărești. Apasă-l din nou ca să revii la normal. `omarchy toggle idle status` afișează starea curentă ca JSON, dacă ai nevoie de ea dintr-un script.

Aici e vorba despre blocare și screensaver, nu despre alimentare. Suspendarea și hibernarea au configurarea lor în [repausul sistemului](36-system-sleep.md).

### Screensaverul

Screensaverul Omarchy e artă ASCII care trece prin efecte de text aleatorii, câte o instanță per monitor. Orice tastă sau mișcare a mouse-ului îl închide.

Îl poți porni la cerere din _System > Screensaver_ (`Super + Esc`), ceea ce îl forțează pe ecran chiar dacă ai oprit screensaverul la inactivitate. Implicit, nu are nicio tastă rapidă alocată.

`omarchy toggle screensaver` e ce oprește screensaverul la inactivitate, dacă preferi să treci direct de la lucru la blocat. Orice tastă, clic, derulare sau mișcare a mouse-ului îl închide.

Logo-ul pe care îl desenează e al tău, ca să-l schimbi, sub _Appearance > Branding > Screensaver_. Încarcă un png sau svg și Omarchy îl convertește în ASCII. Vezi [identitatea vizuală](41-branding.md).

### Ecranul de blocare

`Super + Ctrl + L` blochează mașina. Asta rulează ecranul de blocare din shell-ul Omarchy, stinge afișajul, resetează dispunerea tastaturii la prima, ca să nu-ți tastezi parola în alfabetul greșit, și — dacă îl ai pornit — blochează 1Password la ieșire.

Ecranul de blocare acceptă o parolă și va accepta și o amprentă după ce ai configurat una. Asta și celelalte moduri de autentificare sunt tratate în [autentificarea hardware](37-hardware-authentication.md).
