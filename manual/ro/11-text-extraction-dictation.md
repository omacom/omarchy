# Extragere de text și dictare

### Extragere de text

Apasă `Super + Ctrl + PrtScr` pentru a selecta o regiune de pe ecran pentru extragerea textului. Modelul OCR open source tesseract va converti apoi rapid acea selecție în text și o va plasa în clipboard. Apoi apeși pur și simplu `Super + V` ca să lipești.

Acest lucru este foarte util pentru a prelua adrese din subsolurile imaginilor sau numere de telefon înglobate în titlurile site-urilor web.

 ![text-extraction](images/text-extraction.webp)

### Dictare

Pe instalările noi, [Superwhisper](https://superwhisper.com/) este backendul implicit pentru dictare, folosind procesare în cloud fără descărcări de modele offline. Alege Superwhisper, [Voxtype](https://voxtype.io/) sau [Hex](https://anoma.ly/hex/) prin _Setup > Defaults > Dictation_ din meniul Omarchy. Selectarea unui backend îl instalează dacă este nevoie și îl face implicit pentru dictare. Voxtype încarcă un model de bază în engleză care ocupă 150MB; schimbă modelul cu `voxtype setup model` și alte setări prin `~/.config/voxtype/config.toml`. Superwhisper își deschide setările pentru a alege procesarea în cloud sau locală, iar OPR menține aplicația actualizată. Hex își descarcă modelul vocal on-device în timpul configurării și rulează ca serviciul de utilizator `hex.service`; deschide fereastra lui din pictograma din tava barei sau rulând `hex` pentru a schimba modelul și alte setări.

Dictezi ținând apăsat `Right Alt` sau comutând cu `Alt + Space`, iar textul dictat va apărea în zona de introducere focalizată. Aceste scurtături folosesc backendul selectat. Right Alt pornește dictarea și atunci când este folosit într-un acord de modificatori; folosește Left Alt pentru acele acorduri. Pe aspectele de tastatură unde Right Alt este AltGr, folosește `Alt + Space` pentru a păstra AltGr disponibil pentru tastare. Instalările de dinainte ca Alt + Space să devină implicit păstrează `F9` pentru push-to-talk și `Super + Ctrl + X` pentru comutare, adăugate în `~/.config/hypr/bindings.lua`; elimină-le de acolo pentru a reda acele taste aplicațiilor.

Aceleași scurtături funcționează cu fiecare backend. Selectează backendul tău prin Setup > Defaults > Dictation. Programul de instalare al backendului îl configurează și salvează selecția. Rulează `omarchy default dictation` pentru a vedea care este selectat. Selecția este salvată în `~/.config/omarchy/defaults/dictation`. Instalările noi selectează automat Superwhisper.

Omarchy încarcă automat integrarea desktop a backendului selectat. Nu este necesară nicio configurare Superwhisper în `~/.config/hypr/`.

Legăturile personalizate și scripturile pot folosi `omarchy dictation start`, `omarchy dictation stop` și `omarchy dictation toggle`. Backendul selectat se ocupă de înregistrare și transcriere. Selectarea Superwhisper dezactivează scurtătura lui nativă de menținere apăsată și îi setează comutarea nativă la `Ctrl + Alt + Space`, păstrând-o separată de tastele de înregistrare ale Omarchy. Superwhisper necesită cel puțin o scurtătură nativă de înregistrare, iar scurtătura lui de anulare rămâne disponibilă.

Backenduri suplimentare se pot integra fără să schimbe Omarchy. Furnizează un executabil numit `omarchy-dictation-<backend>` în PATH care acceptă `start`, `stop` și `toggle` și returnează prompt, cu un status diferit de zero în caz de eșec. Programul lui de instalare configurează furnizorul și apelează `omarchy-dictation-use <backend>` după o configurare reușită. Acest lucru oprește backendul anterior și salvează selecția în mod atomic; `stop` trebuie să reușească atunci când furnizorul este inactiv sau indisponibil. Numele backendurilor folosesc litere mici, cifre și cratime. Furnizează `omarchy-install-dictation-<backend>` pentru configurare; `omarchy default dictation <backend>` îl lansează. Adaugă o intrare în meniul Defaults printr-o extensie de meniu Omarchy pentru a apela acel selector. Integrarea desktop opțională poate locui în `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
