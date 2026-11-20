# Taste rapide

Puteți vedea toate principalele combinații de taste cu `Super + K` (combinațiile Tmux cu `Super + Alt + K` și combinațiile Herdr cu `Super + Ctrl + K`).

## Cum sunt organizate tastele rapide

Fiecare tastă rapidă se află pe un plan, definit de modificatorii ei, iar fiecare plan are un singur rol. Asta împiedică tastele rapide să se amestece între ele și înseamnă că de obicei puteți ghici unde se află ceva.

| Plan | Ce se află acolo | Exemple |
| --- | --- | --- |
| `Super + key` | Sistemul: ferestre, spații de lucru, aranjamente și meniuri de bază | `Super + Space` meniul Omarchy, `Super + W` închide fereastra, `Super + F` ecran complet |
| `Super + Shift + key` | Aplicații | `Super + Shift + B` browser, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panouri și meniuri de sistem | `Super + Ctrl + A` audio, `Super + Ctrl + N` rețea, `Super + Ctrl + C` meniu de captură |
| `Super + Ctrl + Alt + key` | Acțiuni rapide și anunțuri | `Super + Ctrl + Alt + T` afișează ora, `Super + Ctrl + Alt + B` baterie, `Super + Ctrl + Alt + C` captură de ecran |

Adăugarea tastei `Alt` la o tastă rapidă vă oferă o variantă a aceluiași lucru, niciodată ceva fără legătură:

- `Super + Shift + B` deschide browserul; `Super + Shift + Alt + B` deschide o fereastră privată
- `Super + Shift + E` deschide e-mailul; `Super + Shift + Alt + E` începe unul nou
- `Super + F` trece pe ecran complet; `Super + Alt + F` trece pe lățime completă
- `Super + Ctrl + C` deschide meniul de captură; `Super + Ctrl + Alt + C` sare peste meniu și face o captură de ecran

Când adăugați o tastă rapidă:

1. Alegeți planul în funcție de ce face, apoi alegeți tasta.
2. Nu mutați o tastă rapidă existentă ca să faceți loc. Găsiți o tastă liberă pe planul potrivit.
3. Folosiți `Alt` doar pentru o variantă a tastei rapide fără ea.

Câteva taste rapide încalcă aceste reguli pentru că sunt convenabile. `Shift` cu o săgeată sau cu `Tab` mută sau inversează în loc să deschidă o aplicație, iar `Print`, tastele media, `Alt + Tab` și `Ctrl + Alt + Del` funcționează la fel ca peste tot în altă parte. Sunt excepții, nu modele de copiat.

Dacă o valoare implicită nu vi se potrivește (să zicem că vreți `Super + Shift + S` pentru capturi de ecran ca pe Windows), realocați-o în `~/.config/hypr/bindings.lua`.

## Navigare

| Tastă rapidă                  | Funcție              |
| ----------------------- | --------------------- |
| `Super + Space`           | Meniul Omarchy (aplicații și tot restul)    |
| `Super + Alt + Space` | Grila de aplicații |
| `Super + Escape` | Meniul de sistem (suspendare, repornire etc.)  |
| `Super + Ctrl + L` | Blochează calculatorul |
| `Super + W` or `Super + Q` | Închide fereastra             |
| `Ctrl + Alt + Del` | Închide toate ferestrele |
| `Super + K` | Afișează toate tastele rapide |
| `Super + Alt + K` | Afișează tastele rapide tmux |
| `Super + Ctrl + K` | Afișează tastele rapide herdr |
| `Super + M` | Minimizează fereastra în dock |
| `Super + T`               | Comută fereastra între tiling/floating             |
| `Super + J` | Comută poziția ferestrei (orizontal/vertical) |
| `Super + O`               | Comută trecerea ferestrei în sticky'n'floating |
| `Super + L`               | Parcurge ciclic aranjamentele dwindle, scrolling și floating |
| `Super + Alt + L`         | Parcurge ciclic aranjamentele în sens invers |
| `Super + P`               | Comută stilul de fereastră pseudo (natural v stretch) |
| `Super + F`                 | Trece pe ecran complet              |
| `Super + Alt + F`                 | Trece pe lățime completă              |
| `Super + Ctrl + F`                 | Trece pe ecran complet în interiorul ferestrei              |
| `Super + 1…9/0`         | Sare la spațiul de lucru specific (0 este 10) pe monitorul focalizat |
| `Super + Tab` | Sare la următorul spațiu de lucru pe monitorul focalizat |
| `Super + Shift + Tab` | Sare la spațiul de lucru anterior pe monitorul focalizat |
| `Super + Ctrl + Tab` | Sare la fostul spațiu de lucru pe monitorul focalizat |
| `Super + Shift + 1…9/0` | Mută fereastra în spațiul de lucru pe monitorul focalizat |
| `Super + Shift + Alt + 1…9/0` | Mută fereastra în spațiul de lucru pe monitorul focalizat fără să o urmați |
| `Super + S` | Comută scratchpad-ul complet |
| `Super + Alt + S` | Mută fereastra în scratchpad-ul complet |
| `Super + Grave` | Comută consola Quake |
| `Super + Shift + Grave` | Mută fereastra în consola Quake |
| `Super + Shift + Ctrl + Arrows` | Mută fereastra pe monitorul în direcția respectivă |
| `Super + Shift + Alt + Arrows` | Mută spațiul de lucru pe monitorul în direcția respectivă |
| `Super + Arrow`  | Mută focalizarea la fereastra în direcția săgeții, trecând pe monitorul din acea parte la marginea ecranului |
| `Super + Shift + Arrow`  | Schimbă fereastra cu alta în direcția săgeții, inclusiv una de pe monitorul din acea parte |
| `Super + Minus` | Extinde fereastra spre stânga |
| `Super + Equal` | Micșorează fereastra spre stânga |
| `Super + Shift + Minus` | Micșorează fereastra în sus |
| `Super + Shift + Equal` | Extinde fereastra în jos |
| `Super + Alt + Minus/Equal` | Aceeași redimensionare în pași mai mici |
| `Super + Ctrl + Minus/Equal` | Aceeași redimensionare în pași mai mari |
| `Super + Alt + Home` | Salvează lățimea ferestrei |
| `Super + Home` | Restabilește lățimea salvată a ferestrei |
| `Super + Left Mouse` | Trage fereastra de colo-colo |
| `Super + Right Mouse` | Redimensionează fereastra |
| `Super + Scroll Wheel` | Derulează prin spațiile de lucru de pe monitorul focalizat |
| `Super + G`               | Comută gruparea ferestrelor      |
| `Super + Alt + G`               | Scoate fereastra din grupare      |
| `Super + Alt + Tab`               | Parcurge ciclic ferestrele din grupare      |
| `Super + Alt + Shift + Tab`               | Parcurge ciclic înapoi ferestrele din grupare      |
| `Super + Alt + Scroll Wheel` | Parcurge ciclic ferestrele din grupare |
| `Super + Alt + 1/2/3/4/5`               | Sare la o anumită fereastră din grupare      |
| `Super + Alt + Arrow`  | Mută fereastra în grupare în direcția săgeții, inclusiv una de pe monitorul din acea parte |
| `Super + Ctrl + Left/Right`  | Vă deplasați între ferestrele dintr-un grup de tiling |
| `Super + Ctrl + Z` | Mărește vizualizarea pe ecran (repetați pentru mai mult zoom) |
| `Super + Ctrl + Alt + Z` | Micșorează complet vizualizarea de pe ecran |
| `Super + /` | Trece înainte prin opțiunile de scalare a monitorului |
| `Super + Alt + /` | Trece înapoi prin opțiunile de scalare a monitorului |
| `Alt + Tab` | Parcurge ciclic înainte ferestrele din spațiul de lucru activ |
| `Alt + Shift + Tab` | Parcurge ciclic înapoi ferestrele din spațiul de lucru activ |
| `Ctrl + Alt + Tab`| Parcurge ciclic înainte focalizarea prin monitoare |
| `Ctrl + Alt + Shift + Tab`| Parcurge ciclic înapoi focalizarea prin monitoare |
| `Super + I` | Schimbă limba de introducere (cu mai mult de o dispunere sau metodă de introducere) |
| `Super + Shift + I` | Schimbă limba de introducere înapoi |

Pe un touchpad, glisările cu trei și patru degete schimbă spațiile de lucru, mută ferestrele și deschid meniul și consola Quake; vedeți [tastatură, mouse și trackpad](34-keyboard-mouse-trackpad.md) pentru gesturi.

Comenzile rapide de redimensionare folosesc tastele fizice `code:20` și `code:21` (XKB `<AE11>` și `<AE12>`), indiferent de caracterele imprimate pe tastatură. Pe tastaturile US aceste taste sunt `-` și `=`; pe tastaturile japoneze (JIS) sunt `-` și `^`; pe tastaturile spaniole sunt `'` și `¡`. Pe JIS, `Super + ^` este `Super + Equal`, în timp ce `Super + Shift + -` (care tastează `=`) este `Super + Shift + Minus`.

## Controale de sistem

| Tastă rapidă                  | Funcție              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panoul audio    |
| `Super + Ctrl + B`           | Panoul Bluetooth    |
| `Super + Ctrl + N`           | Panoul Wi-Fi/rețea    |
| `Super + Ctrl + D`           | Panoul de afișare    |
| `Super + Ctrl + P`           | Panoul de alimentare    |
| `Super + Ctrl + X`           | Panoul de agenți    |
| `Super + Ctrl + Alt + D`           | Panoul de calendar    |
| `Super + Ctrl + Alt + E`           | Panoul de ceas mondial    |
| `Super + Ctrl + 1-9`           | Comută panoul barei după poziție    |
| `Super + Ctrl + S` | Meniul de partajare (prin LocalSend) |
| `Super + Ctrl + C` | Controale de captură (captură de ecran/înregistrare/selector) |
| `Super + Ctrl + O` | Comută meniul |
| `Super + Ctrl + H` | Meniul hardware |
| `Super + Ctrl + E` | Selector de emoji |
| `Super + Ctrl + .` | Transcodează fișierele media |
| `Super + Shift + Ctrl + A` | Alegeți un agent AI |
| `Power` key | Meniul de sistem |
| `Super + Shift + Copilot` key | Meniul Omarchy |

## Ajustări

| Tastă rapidă                  | Funcție              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Luminozitate maximă a ecranului |
| `Shift + Brightness Down` | Luminozitate minimă a ecranului |
| `Alt + Brightness Up/Down` | Modificări precise ale luminozității cu 1% |
| `Alt + Volume Up/Down` | Modificări precise ale volumului cu 1% |
| `Keyboard Brightness Up/Down` | Iluminarea tastaturii mai puternică/mai slabă |
| `Keyboard Backlight` | Parcurge ciclic nivelurile de iluminare a tastaturii |
| `Ctrl + Brightness Up/Down` | Iluminarea tastaturii mai puternică/mai slabă, pe tastaturile fără taste proprii pentru asta |
| `Mic Mute` | Dezactivează microfonul |
| `Shift + Mute` | Schimbă ieșirea audio |
| `Touchpad Toggle` | Pornește sau oprește touchpad-ul |
| `Display` key | Parcurge ciclic aranjamentul spațiului de lucru |
| `Alt + Play` | Următoarea piesă |
| `Alt + Shift + Play` | Piesa anterioară |

## Lansarea aplicațiilor

| Tastă rapidă                  | Funcție              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (manager de agenți) |
| `Super + Shift + Return` or `Super + Shift + B`  | Browser    |
| `Super + Shift + Alt + B`           | Browser (privat/incognito)    |
| `Super + Shift + F`           | Manager de fișiere    |
| `Super + Shift + Alt + F`           | Manager de fișiere în cwd-ul terminalului    |
| `Super + Shift + M`           | Muzică (Spotify)    |
| `Super + Shift + Alt + M`           | Muzică (cliamp)    |
| `Super + Shift + /`           | Manager de parole (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Calculator (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, după instalare)    |
| `Super + Shift + T`           | Activitate (btop)    |
| `Super + Shift + N`           | Editor (Plain sau editorul implicit ales de dvs.)  |
| `Super + Shift + C`           | Calendar ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-mail ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | E-mail nou ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Mesagerie (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Mesagerie (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Mesagerie (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Scris (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (postare nouă) |
| `Super + Shift + Y`           | YouTube |

Schimbați/adăugați alocări în `~/.config/hypr/bindings.lua`.

## Clipboard universal

| Tastă rapidă                  | Funcție              |
| ----------------------- | --------------------- |
| `Super + A`           | Selectează tot în aplicațiile care acceptă `Ctrl + A`    |
| `Super + C`           | Copiază    |
| `Super + X`           | Taie (nu în terminal)    |
| `Super + V`           | Lipește    |
| `Super + Ctrl + V`           | Manager de clipboard    |

De obicei pe Linux aveți nevoie de `Ctrl + Shift + C/V` ca să copiați și să lipiți în terminal și de `Ctrl + C/V` ca să faceți asta peste tot în altă parte. Aceste taste rapide unificate pentru clipboard din Omarchy funcționează peste tot.

## Captură

| Tastă rapidă              | Funcție                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Captură de ecran                      |
| `Super + Ctrl + Alt + C`            | Captură de ecran (aceeași captură, pentru tastaturile fără tasta Print Screen) |
| `Super + Ctrl + C` | Meniul de captură |
| `Alt + Print Screen`            | Înregistrare a ecranului                     |
| `Super + Shift + Ctrl + Alt + C` | Înregistrare a ecranului fără sunet, fără meniu (apăsați din nou ca să opriți) |
| `Super + Print Screen` | Selector de culoare |
| `Super + Ctrl + Print Screen` | Extragerea textului în clipboard |
| `Super + Alt + [` | Micșorează suprapunerea webcamului în timpul înregistrării |
| `Super + Alt + ]` | Mărește suprapunerea webcamului în timpul înregistrării |
| `Alt + Shift + L` | Copiază URL-ul curent din aplicația web sau din browser |
| `Alt + Shift + D` | Descarcă videoclipul de pe pagina curentă în `~/Videos` |
| `Alt + Space` | Pornește/oprește dictarea (necesită _Configurare > Valori implicite > Dictare_) |
| `Right Alt` | Țineți apăsat pentru a dicta (necesită _Configurare > Valori implicite > Dictare_) |

În cazul înregistrărilor de ecran, tasta rapidă întreabă mai întâi ce sunet doriți, apoi începe înregistrarea. Apăsați-o din nou ca să opriți. Vedeți [capturi de ecran și înregistrare](12-screenshots-recording.md) pentru detalii.

Toate opțiunile de captură sunt accesibile și sub _Declanșator > Captură_ în meniul Omarchy (`Super + Space`).

## Notificări

| Tastă rapidă                  | Funcție              |
| ----------------------- | --------------------- |
| `Super + ,` | Acționați asupra celei mai recente notificări: deschideți-o sau apăsați singurul ei buton, alegeți dintre opțiunile ei sau închideți-o când nu are niciunul  |
| `Super + Shift + ,` | Închideți toate notificările |
| `Super + Ctrl + ,` | Controlați notificările cu tastatura  |
| `Super + Alt + ,` | Închideți cea mai recentă notificare  |
| `Super + Shift + Alt + ,` | Deschideți istoricul notificărilor  |
| `Super + Ctrl + Alt + ,` | Comutați silențierea notificărilor  |

## Stil

| Tastă rapidă                  | Funcție              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Alegeți o temă nouă (și `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Alegeți fundalul temei (și `Super + Ctrl + Space`) |
| `Super + Backspace` | Comutați transparența unei ferestre |
| `Super + Ctrl + Backspace` | Comutați formatul pătrat pentru o singură fereastră |

Imaginile de fundal suplimentare se află în `~/.config/omarchy/backgrounds/<theme name>`. Disponibile și prin _Instalare > Stil > Fundal_ în meniul Omarchy.

Toate opțiunile de stil sunt accesibile și sub _Aspect_ în meniul Omarchy (`Super + Space`).

## Comutatoare

| Tastă rapidă                  | Funcție              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Comutați blocarea la inactivitate |
| `Super + Ctrl + Delete` | Comutați pornirea/oprirea ecranului laptopului |
| `Super + Ctrl + Alt + Delete` | Comutați oglindirea ecranului laptopului |
| `Super + Shift + Space` | Comutați bara superioară  |
| `Shift + Mute` | Treceți la următoarea ieșire audio |
| `Shift + Play` | Treceți la următoarea sursă media |
| `Super + Shift + Backspace` | Comutați spațiile dintre ferestre |
| `Super + Ctrl + Alt + F` | Comutați desktopul pe ecran complet (bara superioară + spațiile dintre ferestre) |

## Mementouri

| Tastă rapidă                  | Funcție              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Setați un memento  |
| `Super + Ctrl + Alt + R` | Vedeți toate mementourile  |
| `Super + Ctrl + Shift + R` | Ștergeți toate mementourile  |

## Afișări informative

| Tastă rapidă                  | Funcție              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Afișează ora ca notificare  |
| `Super + Ctrl + Alt + B` | Afișează bateria ca notificare  |
| `Super + Ctrl + Alt + W` | Comutați afișarea vremii ca notificare  |

## Tmux

Tasta prefix este `Ctrl + Space` (`Ctrl + B` funcționează și ea). Puteți schimba aceste alocări în `~/.config/tmux/tmux.conf`.

### Panouri

| Tastă rapidă                  | Funcție              |
| ----------------------- | --------------------- |
| `Prefix + v` | Împarte panoul alături (vertical) |
| `Prefix + h` | Împarte panoul dedesubt (orizontal) |
| `Prefix + x` | Închide panoul |
| `Prefix + z` | Comută zoom-ul panoului (ecran complet) |
| `Alt + Enter` | Împarte panoul dedesubt (fără prefix) |
| `Alt + Shift + Enter` | Împarte panoul alături (fără prefix) |
| `Alt + Escape` | Închide panoul (fără prefix) |
| `Ctrl + Alt + Arrows` | Vă deplasați între panouri |
| `Ctrl + Alt + Shift + Arrows` | Redimensionați panourile |

### Ferestre

| Tastă rapidă                  | Funcție              |
| ----------------------- | --------------------- |
| `Prefix + c` | Fereastră nouă |
| `Prefix + k` | Închide fereastra |
| `Prefix + r` | Redenumește fereastra |
| `Alt + 1-9` | Mergeți la o anumită fereastră |
| `Alt + Arrow Left/Right` | Vă deplasați între ferestre |
| `Alt + Shift + Arrow Left/Right` | Mutați fereastra la stânga/dreapta |

### Sesiuni

| Tastă rapidă                  | Funcție              |
| ----------------------- | --------------------- |
| `Prefix + C` | Sesiune nouă |
| `Prefix + K` | Închide sesiunea |
| `Prefix + R` | Redenumește sesiunea |
| `Prefix + N` | Sesiunea următoare |
| `Prefix + P` | Sesiunea anterioară |
| `Alt + Arrow Up/Down` | Vă deplasați între sesiuni |
| `Prefix + s` | Listează sesiunile |
| `Prefix + d` | Detașați-vă de sesiune |

### Modul de copiere (în stil vi)

| Tastă rapidă                  | Funcție              |
| ----------------------- | --------------------- |
| `Prefix + [` | Intrați în modul de copiere |
| `v` | Începe selecția (în modul de copiere) |
| `y` | Copiază selecția (în modul de copiere) |

### Generale

| Tastă rapidă                  | Funcție              |
| ----------------------- | --------------------- |
| `Prefix + q` | Reîncarcă configurarea |
| `Prefix + ?` | Afișează tastele rapide Tmux |
| `Prefix + :` | Prompt de comandă |

### Funcții de aranjament Tmux

Aceste funcții trebuie rulate în interiorul unei sesiuni Tmux.

| Comandă | Funcție |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Creează un aranjament de dezvoltare cu editor, AI și terminal |
| `tdlm <ai> [<second_ai>]` | Creează un aranjament de dezvoltare pentru fiecare subdirector |
| `tsl <count> <command>` | Creează un aranjament swarm cu mai multe panouri |

## Terminalul Ghostty

Terminalul Ghostty se instalează folosind _Instalare > Terminal_ prin meniul Omarchy.

| Tastă rapidă                  | Funcție              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nouă împărțire dedesubt |
| `Ctrl + Shift + O` | Nouă împărțire alături |
| `Ctrl + Alt + Arrows` | Vă deplasați între împărțiri |
| `Super + Ctrl + Shift + Arrows` | Redimensionați împărțirea cu 10 linii |
| `Super + Ctrl + Shift + Alt + Arrows` | Redimensionați împărțirea cu 100 de linii |
| `Ctrl + Shift + T` | Filă nouă  |
| `Ctrl + Shift + Arrows` | Vă deplasați între file |
| `Alt + Numbers` | Mergeți la o anumită filă |
| `Shift + Pg Up/Down` | Derulați istoricul |
| `Ctrl + Left mouse` | Deschideți linkul în browser |

## Manager de fișiere

| Tastă rapidă              | Funcție                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Mergeți la cale                     |
| `Space`               | Previzualizați fișierul (săgețile navighează) |
| `Alt + Up`       | Mergeți sus în folderul părinte        |

## Neovim (cu lazyvim)

### Navigare

| Tastă rapidă                   | Funcție                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Afișează opțiunile de comandă            |
| `Space Space`              | Deschide fișierul prin căutare fuzzy      |
| `Space E`                  | Comută bara laterală                  |
| `Space G G`                | Afișează controalele git               |
| `Space S G`                | Caută în conținutul fișierului             |
| `Ctrl + W W`               | Sari între bara laterală și editor |
| `Ctrl + Left/right arrow`  | Schimbă dimensiunea barei laterale          |
| `Shift + H`                      | Mergeți la fila de fișier din stânga             |
| `Shift + L`                      | Mergeți la fila de fișier din dreapta            |
| `Space B D`                | Închide fila de fișier                  |

### În bara laterală

| Tastă rapidă                   | Funcție                        |
| ------------------------ | ------------------------------- |
| `A`                        | Adaugă un fișier nou în directorul părinte      |
| `Shift + A`                | Adaugă un subdirector nou în directorul părinte    |
| `D`                        | Șterge fișierul/directorul evidențiat     |
| `M`                        | Mută fișierul/directorul evidențiat       |
| `R`                        | Redenumește fișierul/directorul evidențiat     |
| `?`                        | Afișează ajutorul pentru toate comenzile      |

[Vedeți toate tastele rapide Neovim configurate de LazyVim](https://www.lazyvim.org/keymaps).

## Emoji rapide

Puteți folosi `Super + Ctrl + E` ca să afișați un selector complet de emoji care va pune selecția în clipboard sau puteți folosi aceste opțiuni de acces rapid.

| Tastă rapidă       | EM | Indiciu       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | zâmbet      |
| `Shift + CapsLock M C` | 😂 | plâns        |
| `Shift + CapsLock M L` | 😍 | dragoste       |
| `Shift + CapsLock M V` | ✌️ | victorie    |
| `Shift + CapsLock M H` | ❤️ | inimă      |
| `Shift + CapsLock M Y` | 👍 | da        |
| `Shift + CapsLock M N` | 👎 | nu         |
| `Shift + CapsLock M F` | 🖕 | naiba       |
| `Shift + CapsLock M W` | 🤞 | dorință       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | sărut       |
| `Shift + CapsLock M E` | 🙄 | dat ochii peste cap    |
| `Shift + CapsLock M I` | 😉 | clipit       |
| `Shift + CapsLock M P` | 🙏 | rugăciune |
| `Shift + CapsLock M D` | 🤤 | salivat      |
| `Shift + CapsLock M M` | 💰 | bani      |
| `Shift + CapsLock M X` | 🎉 | sărbătoare |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | închinare      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | salut |
| `Shift + CapsLock M A` |💪 | braț |
| `Shift + CapsLock M B` |🤯 | explozie |

## Completări rapide

| Tastă rapidă       | Completare       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (linie de pauză lungă)   |
| `Shift + CapsLock Space N` | Numele dvs. (așa cum a fost introdus la configurare)  |
| `Shift + CapsLock Space E` | E-mailul dvs. (așa cum a fost introdus la configurare)  |

Puteți adăuga mai multe de-ale dvs. editând `~/.XCompose`, apoi rulând `omarchy restart xcompose` în terminal ca modificările să fie preluate.
