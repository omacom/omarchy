# Extragerea textului și dictarea

### Extragerea textului

Apasă `Super + Ctrl + PrtScr` ca să selectezi o regiune de pe ecran pentru extragerea textului. Modelul OCR open source tesseract va converti apoi rapid acea selecție în text și o va pune pe clipboard. Apoi apeși doar `Super + V` ca să lipești.

Este foarte util pentru a scoate adrese din subsoluri de imagini sau numere de telefon încorporate în titluri de site-uri web.

 ![text-extraction](images/text-extraction.webp)

### Dictarea

La instalările noi, [Superwhisper](https://superwhisper.com/) este backendul implicit pentru dictare, folosind procesare în cloud fără descărcări de modele offline. Alege Superwhisper sau [Voxtype](https://voxtype.io/) prin _Configurare > Implicite > Dictation_ în meniul Omarchy. Selectarea unui backend îl instalează dacă este nevoie și îl face implicit pentru dictare. Voxtype încarcă un model de bază în engleză care ocupă 150 MB; schimbă modelul cu `voxtype setup model` și alte setări prin `~/.config/voxtype/config.toml`. Superwhisper își deschide setările ca să alegi procesarea în cloud sau locală, iar OPR păstrează aplicația actualizată.

Dictezi ținând apăsat `Right Alt` sau `F9`, sau comutând cu `Super + Ctrl + X`, iar textul dictat va apărea în zona de introducere focalizată. Aceste scurtături folosesc backendul selectat. Right Alt pornește dictarea și atunci când este folosit într-un acord de modificatori; folosește Left Alt pentru acele acorduri. Pe aranjările de tastatură în care Right Alt este AltGr, folosește `F9` ca să păstrezi AltGr disponibil pentru tastat.

Aceleași scurtături funcționează cu oricare dintre backenduri. Selectează backendul prin Configurare > Implicite > Dictation. Programul de instalare al backendului îl configurează și salvează selecția. Rulează `omarchy default dictation` ca să vezi care este selectat. Selecția este salvată în `~/.config/omarchy/defaults/dictation`. Instalările noi selectează automat Superwhisper.

Omarchy încarcă automat integrarea desktop a backendului selectat. Nu este nevoie de nicio configurare Superwhisper în `~/.config/hypr/`.

Mapările și scripturile personalizate pot folosi `omarchy dictation start`, `omarchy dictation stop` și `omarchy dictation toggle`. Backendul selectat se ocupă de înregistrare și transcriere. Selectarea Superwhisper dezactivează scurtătura sa nativă de menținere și setează comutarea nativă la `Alt + Space`, păstrând-o separată de tastele de înregistrare ale Omarchy. Superwhisper necesită cel puțin o scurtătură nativă de înregistrare, iar scurtătura sa de anulare rămâne disponibilă.

Backenduri suplimentare se pot integra fără să schimbe Omarchy. Oferă un executabil numit `omarchy-dictation-<backend>` pe PATH, care acceptă `start`, `stop` și `toggle` și se întoarce prompt, cu o stare nenulă la eșec. Programul său de instalare configurează furnizorul și apelează `omarchy-dictation-use <backend>` după o configurare reușită. Aceasta oprește backendul anterior și salvează selecția atomic; `stop` trebuie să reușească atunci când furnizorul este inactiv sau indisponibil. Numele de backenduri folosesc litere mici, cifre și cratime. Oferă `omarchy-install-dictation-<backend>` pentru configurare; `omarchy default dictation <backend>` îl lansează. Adaugă o intrare în meniul Implicite printr-o extensie de meniu Omarchy ca să apelezi acel selector. Integrarea desktop opțională poate trăi în `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
