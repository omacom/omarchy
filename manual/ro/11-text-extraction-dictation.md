# Extragerea textului și dictarea

### Extragerea textului

Apasă `Super + Ctrl + PrtScr` pentru a selecta o regiune de pe ecran pentru extragerea textului. Modelul OCR open source tesseract va converti apoi rapid selecția respectivă în text și o va plasa în clipboard. Apoi apeși pur și simplu `Super + V` pentru a lipi.

Acest lucru este foarte util pentru a prelua adrese din subsolurile imaginilor sau numere de telefon încorporate în titlurile site-urilor web.

 ![text-extraction](images/text-extraction.webp)

### Dictarea

Pe instalările noi, [Superwhisper](https://superwhisper.com/) este backend-ul implicit pentru dictare, folosind procesare în cloud fără descărcări offline de modele. Alege Superwhisper sau [Voxtype](https://voxtype.io/) prin _Setup > Defaults > Dictation_ în meniul Omarchy. Selectarea unui backend îl instalează dacă este necesar și îl setează ca implicit pentru dictare. Voxtype încarcă un model de bază pentru limba engleză care ocupă 150MB; schimbă modelul cu `voxtype setup model` și alte setări prin `~/.config/voxtype/config.toml`. Superwhisper își deschide setările pentru a alege procesarea în cloud sau locală, iar OPR menține aplicația actualizată.

Dictezi ținând apăsat `Right Alt` sau comutând cu `Alt + Space`, iar textul dictat va apărea în zona de introducere focalizată. Aceste scurtături folosesc backend-ul selectat. Right Alt pornește dictarea și atunci când este folosit într-o combinație de modificatori; folosește Left Alt pentru combinațiile respective. Pe configurațiile de tastatură unde Right Alt este AltGr, folosește `Alt + Space` pentru a păstra AltGr disponibil pentru tastare. Instalările dinainte ca Alt + Space să devină implicit păstrează `F9` pentru push-to-talk și `Super + Ctrl + X` pentru comutare, adăugate în `~/.config/hypr/bindings.lua`; elimină-le de acolo pentru a reda tastele respective aplicațiilor.

Aceleași scurtături funcționează cu oricare dintre backend-uri. Selectează backend-ul prin Setup > Defaults > Dictation. Programul de instalare al backend-ului îl configurează și salvează selecția. Rulează `omarchy default dictation` pentru a vedea care este selectat. Selecția este salvată în `~/.config/omarchy/defaults/dictation`. Instalările noi selectează automat Superwhisper.

Omarchy încarcă automat integrarea desktop a backend-ului selectat. Nu este necesară nicio configurare Superwhisper în `~/.config/hypr/`.

Legăturile personalizate și scripturile pot folosi `omarchy dictation start`, `omarchy dictation stop` și `omarchy dictation toggle`. Backend-ul selectat se ocupă de înregistrare și transcriere. Selectarea Superwhisper dezactivează scurtătura sa nativă de menținere și setează comutarea sa nativă la `Ctrl + Alt + Space`, păstrând-o separat de tastele de înregistrare ale Omarchy. Superwhisper necesită cel puțin o scurtătură nativă de înregistrare, iar scurtătura sa de anulare rămâne disponibilă.

Backend-uri suplimentare se pot integra fără a modifica Omarchy. Furnizează un executabil numit `omarchy-dictation-<backend>` pe PATH care acceptă `start`, `stop` și `toggle` și returnează prompt, cu un status diferit de zero în caz de eșec. Programul său de instalare configurează furnizorul și apelează `omarchy-dictation-use <backend>` după configurarea reușită. Acest lucru oprește backend-ul anterior și salvează selecția în mod atomic; `stop` trebuie să reușească atunci când furnizorul este inactiv sau indisponibil. Numele backend-urilor folosesc litere mici, cifre și cratime. Furnizează `omarchy-install-dictation-<backend>` pentru configurare; `omarchy default dictation <backend>` îl lansează. Adaugă o intrare în meniul Defaults printr-o extensie de meniu Omarchy pentru a apela selectorul respectiv. Integrarea desktop opțională poate locui în `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
