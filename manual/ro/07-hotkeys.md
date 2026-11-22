# Taste rapide

Poți vedea toate combinațiile principale de taste cu `Super + K` (combinațiile Tmux cu `Super + Alt + K` și combinațiile Herdr cu `Super + Ctrl + K`).

## Cum sunt organizate tastele rapide

Fiecare tastă rapidă se află pe un plan, stabilit de modificatorii ei, și fiecare plan are o singură sarcină. Asta împiedică tastele rapide să se amestece între ele și înseamnă că de obicei poți ghici unde se află ceva.

| Plan | Ce se află acolo | Exemple |
| --- | --- | --- |
| `Super + key` | Sistemul: ferestre, spații de lucru, aspecte și meniuri de bază | `Super + Space` meniul Omarchy, `Super + W` închide fereastra, `Super + F` ecran complet |
| `Super + Shift + key` | Aplicații | `Super + Shift + B` browser, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panouri și meniuri de sistem | `Super + Ctrl + A` audio, `Super + Ctrl + N` rețea, `Super + Ctrl + C` meniul de captură |
| `Super + Ctrl + Alt + key` | Acțiuni rapide și notițe | `Super + Ctrl + Alt + T` arată ora, `Super + Ctrl + Alt + B` bateria, `Super + Ctrl + Alt + C` captură de ecran |

Adăugarea tastei `Alt` la o tastă rapidă îți oferă o variantă a aceluiași lucru, niciodată ceva fără legătură:

- `Super + Shift + B` deschide browserul; `Super + Shift + Alt + B` deschide o fereastră privată
- `Super + Shift + E` deschide e-mailul; `Super + Shift + Alt + E` începe unul nou
- `Super + F` trece pe ecran complet; `Super + Alt + F` trece pe lățime completă
- `Super + Ctrl + C` deschide meniul de captură; `Super + Ctrl + Alt + C` sare peste meniu și face o captură de ecran

Când adaugi o tastă rapidă:

1. Alege planul după ce face, apoi alege tasta.
2. Nu muta o tastă rapidă existentă ca să faci loc. Găsește o tastă liberă pe planul potrivit.
3. Folosește `Alt` doar pentru o variantă a tastei rapide fără ea.

Câteva taste rapide încalcă aceste reguli pentru că sunt practice. `Shift` cu o săgeată sau cu `Tab` mută sau inversează în loc să deschidă o aplicație, iar `Print`, tastele media, `Alt + Tab` și `Ctrl + Alt + Del` funcționează la fel ca peste tot în altă parte. Sunt excepții, nu modele de copiat.

Dacă o setare implicită nu ți se potrivește (să zicem că vrei `Super + Shift + S` pentru capturi de ecran ca pe Windows), realoc-o în `~/.config/hypr/bindings.lua`.

## Navigare

| Tastă rapidă | Funcție |
| ----------------------- | --------------------- |
| `Super + Space` | Meniul Omarchy (aplicații și tot restul) |
| `Super + Alt + Space` | Grila de aplicații |
| `Super + Escape` | Meniul de sistem (suspendare, repornire etc.) |
| `Super + Ctrl + L` | Blochează calculatorul |
| `Super + W` sau `Super + Q` | Închide fereastra |
| `Ctrl + Alt + Del` | Închide toate ferestrele |
| `Super + K` | Afișează toate tastele rapide |
| `Super + Alt + K` | Afișează tastele rapide tmux |
| `Super + Ctrl + K` | Afișează tastele rapide herdr |
| `Super + M` | Minimizează fereastra în dock |
| `Super + T` | Comută fereastra între modul mozaic/plutitor |
| `Super + J` | Comută poziția ferestrei (orizontal/vertical) |
| `Super + O` | Comută trecerea ferestrei în modul lipicios și plutitor |
| `Super + L` | Parcurge ciclic aspectele dwindle, scrolling și plutitor |
| `Super + Alt + L` | Parcurge ciclic aspectele în sens invers |
| `Super + P` | Comută stilul ferestrei pseudo (natural față de întins) |
| `Super + F` | Trece pe ecran complet |
| `Super + Alt + F` | Trece pe lățime completă |
| `Super + Ctrl + F` | Trece pe ecran complet în interiorul ferestrei |
| `Super + 1…9/0` | Sari la spațiul de lucru specificat (0 este 10) pe monitorul focalizat |
| `Super + Tab` | Sari la următorul spațiu de lucru pe monitorul focalizat |
| `Super + Shift + Tab` | Sari la spațiul de lucru anterior pe monitorul focalizat |
| `Super + Ctrl + Tab` | Sari la spațiul de lucru precedent pe monitorul focalizat |
| `Super + Shift + 1…9/0` | Mută fereastra în spațiul de lucru de pe monitorul focalizat |
| `Super + Shift + Alt + 1…9/0` | Mută fereastra în spațiul de lucru de pe monitorul focalizat fără să o urmezi |
| `Super + S` | Comută scratchpad-ul complet |
| `Super + Alt + S` | Mută fereastra în scratchpad-ul complet |
| `Super + Grave` | Comută consola Quake |
| `Super + Shift + Grave` | Mută fereastra în consola Quake |
| `Super + Shift + Ctrl + Arrows` | Mută fereastra pe monitorul în direcția respectivă |
| `Super + Shift + Alt + Arrows` | Mută spațiul de lucru pe monitorul în direcția respectivă |
| `Super + Arrow` | Mută focalizarea la fereastra în direcția săgeții, trecând pe monitorul de pe acea parte la marginea ecranului |
| `Super + Shift + Arrow` | Schimbă fereastra cu alta în direcția săgeții, inclusiv una de pe monitorul de pe acea parte |
| `Super + Minus` | Extinde fereastra spre stânga |
| `Super + Equal` | Micșorează fereastra spre stânga |
| `Super + Shift + Minus` | Micșorează fereastra în sus |
| `Super + Shift + Equal` | Extinde fereastra în jos |
| `Super + Alt + Minus/Equal` | Aceeași redimensionare în pași mai mici |
| `Super + Ctrl + Minus/Equal` | Aceeași redimensionare în pași mai mari |
| `Super + Alt + Home` | Salvează lățimea ferestrei |
| `Super + Home` | Restaurează lățimea salvată a ferestrei |
| `Super + Left Mouse` | Trage fereastra dintr-un loc în altul |
| `Super + Right Mouse` | Redimensionează fereastra |
| `Super + Scroll Wheel` | Derulează prin spațiile de lucru de pe monitorul focalizat |
| `Super + G` | Comută gruparea ferestrelor |
| `Super + Alt + G` | Scoate fereastra din grupare |
| `Super + Alt + Tab` | Parcurge ciclic ferestrele din grupare |
| `Super + Alt + Shift + Tab` | Parcurge ciclic înapoi ferestrele din grupare |
| `Super + Alt + Scroll Wheel` | Parcurge ciclic ferestrele din grupare |
| `Super + Alt + 1/2/3/4/5` | Sari la o anumită fereastră din grupare |
| `Super + Alt + Arrow` | Mută fereastra în grupare în direcția săgeții, inclusiv una de pe monitorul de pe acea parte |
| `Super + Ctrl + Left/Right` | Mută între ferestrele dintr-un grup de mozaic |
| `Super + Ctrl + Z` | Mărește imaginea pe ecran (repetă pentru mai mult zoom) |
| `Super + Ctrl + Alt + Z` | Micșorează complet imaginea de pe ecran |
| `Super + /` | Avansează prin opțiunile de scalare a monitorului |
| `Super + Alt + /` | Mergi înapoi prin opțiunile de scalare a monitorului |
| `Alt + Tab` | Parcurge ciclic înainte ferestrele din spațiul de lucru activ |
| `Alt + Shift + Tab` | Parcurge ciclic înapoi ferestrele din spațiul de lucru activ |
| `Ctrl + Alt + Tab` | Parcurge ciclic înainte focalizarea prin monitoare |
| `Ctrl + Alt + Shift + Tab` | Parcurge ciclic înapoi focalizarea prin monitoare |
| `Super + I` | Schimbă limba de introducere (cu mai mult de un aspect sau o metodă de introducere) |
| `Super + Shift + I` | Schimbă limba de introducere înapoi |

Pe un touchpad, glisările cu trei și patru degete schimbă spațiile de lucru, mută ferestre și deschid meniul și consola Quake; vezi [tastatură, mouse și trackpad](34-keyboard-mouse-trackpad.md) pentru gesturi.

Comenzile rapide de redimensionare folosesc tastele fizice `code:20` și `code:21` (XKB `<AE11>` și `<AE12>`), indiferent de caracterele imprimate pe tastatură. Pe tastaturile US aceste taste sunt `-` și `=`; pe tastaturile japoneze (JIS) sunt `-` și `^`; pe tastaturile spaniole sunt `'` și `¡`. Pe JIS, `Super + ^` este `Super + Equal`, în timp ce `Super + Shift + -` (care tastează `=`) este `Super + Shift + Minus`.

## Comenzi de sistem

| Tastă rapidă | Funcție |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Panoul audio |
| `Super + Ctrl + B` | Panoul Bluetooth |
| `Super + Ctrl + N` | Panoul Wifi/rețea |
| `Super + Ctrl + D` | Panoul de afișare |
| `Super + Ctrl + P` | Panoul de alimentare |
| `Super + Ctrl + X` | Panoul de agenți |
| `Super + Ctrl + Alt + X` | Panoul de modele locale |
| `Super + Ctrl + Alt + D` | Panoul calendar |
| `Super + Ctrl + Alt + E` | Panoul ceas mondial |
| `Super + Ctrl + 1-9` | Comută panoul barei după poziție |
| `Super + Ctrl + S` | Meniul de partajare (prin LocalSend) |
| `Super + Ctrl + C` | Comenzi de captură (captură de ecran/înregistrare/selector) |
| `Super + Ctrl + O` | Comută meniul |
| `Super + Ctrl + H` | Meniul hardware |
| `Super + Ctrl + E` | Selector de emoji |
| `Super + Ctrl + .` | Transcodează media |
| `Super + Shift + Ctrl + A` | Alege un agent AI |
| `Power` key | Meniul de sistem |
| `Super + Shift + Copilot` key | Meniul Omarchy |

## Ajustări

| Tastă rapidă | Funcție |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Luminozitate maximă a ecranului |
| `Shift + Brightness Down` | Luminozitate minimă a ecranului |
| `Alt + Brightness Up/Down` | Modificări precise ale luminozității cu 1% |
| `Alt + Volume Up/Down` | Modificări precise ale volumului cu 1% |
| `Keyboard Brightness Up/Down` | Iluminarea tastaturii mai puternică/mai slabă |
| `Keyboard Backlight` | Parcurge ciclic nivelurile de iluminare a tastaturii |
| `Ctrl + Brightness Up/Down` | Iluminarea tastaturii mai puternică/mai slabă, pe tastaturile fără taste proprii pentru asta |
| `Mic Mute` | Dezactivează sunetul microfonului |
| `Shift + Mute` | Schimbă ieșirea audio |
| `Touchpad Toggle` | Pornește sau oprește touchpad-ul |
| `Display` key | Parcurge ciclic aspectul spațiului de lucru |
| `Alt + Play` | Piesa următoare |
| `Alt + Shift + Play` | Piesa anterioară |

## Lansarea aplicațiilor

| Tastă rapidă | Funcție |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (manager de agenți) |
| `Super + Shift + Return` sau `Super + Shift + B` | Browser |
| `Super + Shift + Alt + B` | Browser (privat/incognito) |
| `Super + Shift + F` | Manager de fișiere |
| `Super + Shift + Alt + F` | Manager de fișiere în cwd-ul terminalului |
| `Super + Shift + M` | Muzică (Spotify) |
| `Super + Shift + Alt + M` | Muzică (cliamp) |
| `Super + Shift + /` | Manager de parole (1password) |
| `Super + Shift + Q` sau `Calculator` key | Calculator (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, după instalare) |
| `Super + Shift + T` | Activitate (btop) |
| `Super + Shift + N` | Editor (Plain sau editorul implicit ales de tine) |
| `Super + Shift + C` | Calendar ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-mail ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | E-mail nou ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Mesagerie (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Mesagerie (WhatsApp) |
| `Super + Shift + Ctrl + G` | Mesagerie (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Scris (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (postare nouă) |
| `Super + Shift + Y` | YouTube |

Schimbă/adaugă combinații în `~/.config/hypr/bindings.lua`.

## Clipboard universal

| Tastă rapidă | Funcție |
| ----------------------- | --------------------- |
| `Super + A` | Selectează tot în aplicațiile care acceptă `Ctrl + A` |
| `Super + C` | Copiază |
| `Super + X` | Taie (nu în terminal) |
| `Super + V` | Lipește |
| `Super + Ctrl + V` | Manager de clipboard |

De obicei pe Linux, ai nevoie de `Ctrl + Shift + C/V` ca să copiezi și să lipești în terminal și de `Ctrl + C/V` ca să o faci peste tot în altă parte. Aceste taste rapide unificate pentru clipboard din Omarchy funcționează peste tot.

## Captură

| Tastă rapidă | Funcție |
| ------------------- | ------------------------------ |
| `Print Screen` | Captură de ecran |
| `Super + Ctrl + Alt + C` | Captură de ecran (aceeași captură, pentru tastaturi fără tasta Print Screen) |
| `Super + Ctrl + C` | Meniul de captură |
| `Alt + Print Screen` | Înregistrare de ecran |
| `Super + Shift + Ctrl + Alt + C` | Înregistrare de ecran fără sunet, fără meniu (apasă din nou pentru a opri) |
| `Super + Print Screen` | Selector de culoare |
| `Super + Ctrl + Print Screen` | Extragere de text în clipboard |
| `Super + Alt + [` | Micșorează suprapunerea webcam în timpul înregistrării |
| `Super + Alt + ]` | Mărește suprapunerea webcam în timpul înregistrării |
| `Alt + Shift + L` | Copiază URL-ul curent din aplicația web sau din browser |
| `Alt + Shift + D` | Descarcă videoclipul de pe pagina curentă în `~/Videos` |
| `Alt + Space` | Pornește/oprește dictarea (necesită _Setup > Defaults > Dictation_) |
| `Right Alt` | Ține apăsat pentru a dicta (necesită _Setup > Defaults > Dictation_) |

În cazul înregistrărilor de ecran, tasta rapidă întreabă mai întâi ce sunet vrei, apoi începe înregistrarea. Apas-o din nou pentru a opri. Vezi [capturi de ecran și înregistrare](12-screenshots-recording.md) pentru detalii.

Toate opțiunile de captură sunt accesibile și sub _Trigger > Capture_ în meniul Omarchy (`Super + Space`).

## Notificări

| Tastă rapidă | Funcție |
| ----------------------- | --------------------- |
| `Super + ,` | Acționează asupra celei mai recente notificări: deschide-o sau apasă singurul ei buton, alege dintre opțiunile ei sau închide-o când nu are niciuna |
| `Super + Shift + ,` | Închide toate notificările |
| `Super + Ctrl + ,` | Controlează notificările cu tastatura |
| `Super + Alt + ,` | Închide cea mai recentă notificare |
| `Super + Shift + Alt + ,` | Deschide istoricul notificărilor |
| `Super + Ctrl + Alt + ,` | Comută reducerea la tăcere a notificărilor |

## Stil

| Tastă rapidă | Funcție |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Alege o temă nouă (și `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Alege fundalul temei (și `Super + Ctrl + Space`) |
| `Super + Backspace` | Comută transparența unei ferestre |
| `Super + Ctrl + Backspace` | Comută aspectul pătrat pentru o singură fereastră |

Imaginile de fundal suplimentare se află în `~/.config/omarchy/backgrounds/<theme name>`. Disponibil și prin _Install > Style > Background_ în meniul Omarchy.

Toate opțiunile de stil sunt accesibile și sub _Appearance_ în meniul Omarchy (`Super + Space`).

## Comutări

| Tastă rapidă | Funcție |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Comută blocarea la inactivitate |
| `Super + Ctrl + Delete` | Comută pornirea/oprirea afișajului laptopului |
| `Super + Ctrl + Alt + Delete` | Comută oglindirea afișajului laptopului |
| `Super + Shift + Space` | Comută bara de sus |
| `Shift + Mute` | Schimbă la următoarea ieșire audio |
| `Shift + Play` | Schimbă la următoarea sursă media |
| `Super + Shift + Backspace` | Comută spațiile dintre ferestre |
| `Super + Ctrl + Alt + F` | Comută desktopul pe ecran complet (bara de sus + spațiile dintre ferestre) |

## Mementouri

| Tastă rapidă | Funcție |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Setează un memento |
| `Super + Ctrl + Alt + R` | Vezi toate mementourile |
| `Super + Ctrl + Shift + R` | Șterge toate mementourile |

## Anunțuri

| Tastă rapidă | Funcție |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Afișează ora ca notificare |
| `Super + Ctrl + Alt + B` | Afișează bateria ca notificare |
| `Super + Ctrl + Alt + W` | Comută vremea ca notificare |

## Tmux

Tasta prefix este `Ctrl + Space` (funcționează și `Ctrl + B`). Poți schimba aceste combinații în `~/.config/tmux/tmux.conf`.

### Panouri

| Tastă rapidă | Funcție |
| ----------------------- | --------------------- |
| `Prefix + v` | Desparte panoul alăturat (vertical) |
| `Prefix + h` | Desparte panoul dedesubt (orizontal) |
| `Prefix + x` | Închide panoul |
| `Prefix + z` | Comută zoomul panoului (ecran complet) |
| `Alt + Enter` | Desparte panoul dedesubt (fără prefix) |
| `Alt + Shift + Enter` | Desparte panoul alăturat (fără prefix) |
| `Alt + Escape` | Închide panoul (fără prefix) |
| `Ctrl + Alt + Arrows` | Mută între panouri |
| `Ctrl + Alt + Shift + Arrows` | Redimensionează panourile |

### Ferestre

| Tastă rapidă | Funcție |
| ----------------------- | --------------------- |
| `Prefix + c` | Fereastră nouă |
| `Prefix + k` | Închide fereastra |
| `Prefix + r` | Redenumește fereastra |
| `Alt + 1-9` | Mergi la o anumită fereastră |
| `Alt + Arrow Left/Right` | Mută între ferestre |
| `Alt + Shift + Arrow Left/Right` | Mută fereastra la stânga/dreapta |

### Sesiuni

| Tastă rapidă | Funcție |
| ----------------------- | --------------------- |
| `Prefix + C` | Sesiune nouă |
| `Prefix + K` | Închide sesiunea |
| `Prefix + R` | Redenumește sesiunea |
| `Prefix + N` | Sesiunea următoare |
| `Prefix + P` | Sesiunea anterioară |
| `Alt + Arrow Up/Down` | Mută între sesiuni |
| `Prefix + s` | Listează sesiunile |
| `Prefix + d` | Detașează-te de sesiune |

### Mod de copiere (stil vi)

| Tastă rapidă | Funcție |
| ----------------------- | --------------------- |
| `Prefix + [` | Intră în modul de copiere |
| `v` | Începe selecția (în modul de copiere) |
| `y` | Copiază selecția (în modul de copiere) |

### General

| Tastă rapidă | Funcție |
| ----------------------- | --------------------- |
| `Prefix + q` | Reîncarcă configurația |
| `Prefix + ?` | Afișează combinațiile de taste Tmux |
| `Prefix + :` | Linie de comandă |

### Funcții de aspect Tmux

Aceste funcții trebuie rulate în interiorul unei sesiuni Tmux.

| Comandă | Funcție |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Creează un aspect de dezvoltare cu editor, AI și terminal |
| `tdlm <ai> [<second_ai>]` | Creează un aspect de dezvoltare pentru fiecare subdirector |
| `tsl <count> <command>` | Creează un aspect roi cu mai multe panouri |

## Terminal Ghostty

Terminalul Ghostty se instalează folosind _Install > Terminal_ prin meniul Omarchy.

| Tastă rapidă | Funcție |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nouă împărțire dedesubt |
| `Ctrl + Shift + O` | Nouă împărțire alăturată |
| `Ctrl + Alt + Arrows` | Mută între împărțiri |
| `Super + Ctrl + Shift + Arrows` | Redimensionează împărțirea cu 10 linii |
| `Super + Ctrl + Shift + Alt + Arrows` | Redimensionează împărțirea cu 100 de linii |
| `Ctrl + Shift + T` | Filă nouă |
| `Ctrl + Shift + Arrows` | Mută între file |
| `Alt + Numbers` | Mergi la o anumită filă |
| `Shift + Pg Up/Down` | Derulează istoricul |
| `Ctrl + Left mouse` | Deschide linkul în browser |

## Manager de fișiere

| Tastă rapidă | Funcție |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Mergi la cale |
| `Space` | Previzualizează fișierul (săgețile navighează) |
| `Alt + Up` | Mergi sus la dosarul părinte |

## Neovim (cu lazyvim)

### Navigare

| Tastă rapidă | Funcție |
| ------------------------ | ------------------------------- |
| `Space` | Afișează opțiunile de comandă |
| `Space Space` | Deschide fișierul prin căutare fuzzy |
| `Space E` | Comută bara laterală |
| `Space G G` | Afișează comenzile git |
| `Space S G` | Caută în conținutul fișierului |
| `Ctrl + W W` | Sari între bara laterală și editor |
| `Ctrl + Left/right arrow` | Schimbă dimensiunea barei laterale |
| `Shift + H` | Mergi la fila de fișier din stânga |
| `Shift + L` | Mergi la fila de fișier din dreapta |
| `Space B D` | Închide fila de fișier |

### În bara laterală

| Tastă rapidă | Funcție |
| ------------------------ | ------------------------------- |
| `A` | Adaugă un fișier nou în directorul părinte |
| `Shift + A` | Adaugă un subdirector nou în directorul părinte |
| `D` | Șterge fișierul/directorul evidențiat |
| `M` | Mută fișierul/directorul evidențiat |
| `R` | Redenumește fișierul/directorul evidențiat |
| `?` | Afișează ajutorul pentru toate comenzile |

[Vezi toate tastele rapide Neovim configurate de LazyVim](https://www.lazyvim.org/keymaps).

## Emoji rapide

Poți folosi `Super + Ctrl + E` pentru a afișa un selector complet de emoji care va pune selecția în clipboard sau poți folosi aceste opțiuni de acces rapid.

| Tastă rapidă | EM | Indiciu |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | zâmbet |
| `Shift + CapsLock M C` | 😂 | plâns |
| `Shift + CapsLock M L` | 😍 | dragoste |
| `Shift + CapsLock M V` | ✌️ | victorie |
| `Shift + CapsLock M H` | ❤️ | inimă |
| `Shift + CapsLock M Y` | 👍 | da |
| `Shift + CapsLock M N` | 👎 | nu |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | dorință |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | sărut |
| `Shift + CapsLock M E` | 🙄 | dat ochii peste cap |
| `Shift + CapsLock M I` | 😉 | clipit cu ochiul |
| `Shift + CapsLock M P` | 🙏 | rugăciune |
| `Shift + CapsLock M D` | 🤤 | salivare |
| `Shift + CapsLock M M` | 💰 | bani |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | toast |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | salut |
| `Shift + CapsLock M A` |💪 | braț |
| `Shift + CapsLock M B` |🤯 | uimire |

## Completări rapide

| Tastă rapidă | Completare |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (linie lungă) |
| `Shift + CapsLock Space N` | Numele tău (așa cum a fost introdus la configurare) |
| `Shift + CapsLock Space E` | E-mailul tău (așa cum a fost introdus la configurare) |

Poți adăuga mai multe ale tale editând `~/.XCompose`, apoi rulând `omarchy restart xcompose` în terminal pentru ca modificările să fie preluate.
