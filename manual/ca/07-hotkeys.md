# Dreceres de teclat

Pots veure totes les dreceres de teclat principals amb `Super + K` (les dreceres de Tmux amb `Super + Alt + K` i les de Herdr amb `Super + Ctrl + K`).

## Com s'organitzen les dreceres

Cada drecera se situa en un pla, definit pels seus modificadors, i cada pla té una única funció. Això és el que evita que les dreceres es confonguin entre elles, i vol dir que normalment pots endevinar on és cada cosa.

| Pla | Què hi viu | Exemples |
| --- | --- | --- |
| `Super + key` | El sistema: finestres, espais de treball, dissenys i menús principals | `Super + Space` menú d'Omarchy, `Super + W` tanca la finestra, `Super + F` pantalla completa |
| `Super + Shift + key` | Aplicacions | `Super + Shift + B` navegador, `Super + Shift + E` correu electrònic, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panells i menús del sistema | `Super + Ctrl + A` àudio, `Super + Ctrl + N` xarxa, `Super + Ctrl + C` menú de captura |
| `Super + Ctrl + Alt + key` | Accions ràpides i avisos | `Super + Ctrl + Alt + T` mostra l'hora, `Super + Ctrl + Alt + B` bateria, `Super + Ctrl + Alt + C` captura de pantalla |

Afegir `Alt` a una drecera et dona una variant de la mateixa cosa, mai una cosa sense cap relació:

- `Super + Shift + B` obre el navegador; `Super + Shift + Alt + B` obre una finestra privada
- `Super + Shift + E` obre el correu electrònic; `Super + Shift + Alt + E` en comença un de nou
- `Super + F` passa a pantalla completa; `Super + Alt + F` passa a amplada completa
- `Super + Ctrl + C` obre el menú de captura; `Super + Ctrl + Alt + C` se salta el menú i fa una captura de pantalla

Quan afegeixis una drecera:

1. Tria el pla segons el que fa, i després tria la tecla.
2. No moguis una drecera existent per fer lloc. Troba una tecla lliure al pla correcte.
3. Fes servir `Alt` només per a una variant de la drecera sense `Alt`.

Unes quantes dreceres incompleixen aquestes regles perquè són còmodes. `Shift` amb una fletxa o `Tab` mou o inverteix en lloc d'obrir una aplicació, i `Print`, les tecles multimèdia, `Alt + Tab` i `Ctrl + Alt + Del` funcionen com a tot arreu. Són excepcions, no patrons per copiar.

Si un valor per defecte no t'escau (posem que vols `Super + Shift + S` per a les captures de pantalla com a Windows), reassigna'l a `~/.config/hypr/bindings.lua`.

## Navegació

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menú d'Omarchy (aplicacions i tota la resta)    |
| `Super + Alt + Space` | Graella d'aplicacions |
| `Super + Escape` | Menú del sistema (suspèn, reinicia, etc.)  |
| `Super + Ctrl + L` | Bloqueja l'ordinador |
| `Super + W` or `Super + Q` | Tanca la finestra             |
| `Ctrl + Alt + Del` | Tanca totes les finestres |
| `Super + K` | Mostra totes les dreceres |
| `Super + Alt + K` | Mostra les dreceres de tmux |
| `Super + Ctrl + K` | Mostra les dreceres de herdr |
| `Super + M` | Minimitza la finestra al dock |
| `Super + T`               | Commuta la finestra entre mosaic i flotant             |
| `Super + J` | Commuta la posició de la finestra (horitzontal/vertical) |
| `Super + O`               | Commuta la finestra emergent a sticky'n'floating |
| `Super + L`               | Recorre els dissenys dwindle, scrolling i floating |
| `Super + Alt + L`         | Recorre els dissenys en ordre invers |
| `Super + P`               | Commuta l'estil pseudo de la finestra (natural o estirat) |
| `Super + F`                 | Passa a pantalla completa              |
| `Super + Alt + F`                 | Passa a amplada completa              |
| `Super + Ctrl + F`                 | Passa a pantalla completa dins de la finestra              |
| `Super + 1…9/0`         | Salta a un espai de treball concret (el 0 és el 10) al monitor amb el focus |
| `Super + Tab` | Salta a l'espai de treball següent al monitor amb el focus |
| `Super + Shift + Tab` | Salta a l'espai de treball anterior al monitor amb el focus |
| `Super + Ctrl + Tab` | Salta a l'espai de treball d'abans al monitor amb el focus |
| `Super + Shift + 1…9/0` | Mou la finestra a l'espai de treball al monitor amb el focus |
| `Super + Shift + Alt + 1…9/0` | Mou la finestra a l'espai de treball al monitor amb el focus sense seguir-la |
| `Super + S` | Commuta el scratchpad complet |
| `Super + Alt + S` | Mou la finestra al scratchpad complet |
| `Super + the key above Tab` (accent greu en les distribucions dels EUA) | Commuta la consola Quake |
| `Super + Shift + the key above Tab` (accent greu en les distribucions dels EUA) | Mou la finestra a la consola Quake |
| `Super + Shift + Ctrl + Arrows` | Mou la finestra al monitor en aquella direcció |
| `Super + Shift + Alt + Arrows` | Mou l'espai de treball al monitor en aquella direcció |
| `Super + Arrow`  | Mou el focus a la finestra en la direcció de la fletxa, i passa al monitor d'aquell costat en arribar a la vora de la pantalla |
| `Super + Shift + Arrow`  | Intercanvia la finestra amb una altra en la direcció de la fletxa, inclosa una del monitor d'aquell costat |
| `Super + Minus` | Eixampla la finestra cap a l'esquerra |
| `Super + Equal` | Encongeix la finestra cap a l'esquerra |
| `Super + Shift + Minus` | Encongeix la finestra cap amunt |
| `Super + Shift + Equal` | Eixampla la finestra cap avall |
| `Super + Alt + Minus/Equal` | El mateix redimensionament en passos més petits |
| `Super + Ctrl + Minus/Equal` | El mateix redimensionament en passos més grans |
| `Super + Alt + Home` | Desa l'amplada de la finestra |
| `Super + Home` | Restaura l'amplada de finestra desada |
| `Super + Left Mouse` | Arrossega la finestra |
| `Super + Right Mouse` | Redimensiona la finestra |
| `Super + Scroll Wheel` | Desplaça't pels espais de treball al monitor amb el focus |
| `Super + G`               | Commuta l'agrupació de finestres      |
| `Super + Alt + G`               | Treu la finestra de l'agrupació      |
| `Super + Alt + Tab`               | Recorre les finestres de l'agrupació      |
| `Super + Alt + Shift + Tab`               | Recorre les finestres de l'agrupació cap enrere      |
| `Super + Alt + Scroll Wheel` | Recorre les finestres de l'agrupació |
| `Super + Alt + 1/2/3/4/5`               | Salta a una finestra concreta de l'agrupació      |
| `Super + Alt + Arrow`  | Mou la finestra dins l'agrupació en la direcció de la fletxa, inclosa una del monitor d'aquell costat |
| `Super + Ctrl + Left/Right`  | Mou-te entre finestres dins d'un grup en mosaic |
| `Super + Ctrl + Z` | Amplia la pantalla (repeteix per ampliar més) |
| `Super + Ctrl + Alt + Z` | Redueix la pantalla al màxim |
| `Super + /` | Avança per les opcions d'escalat del monitor |
| `Super + Alt + /` | Retrocedeix per les opcions d'escalat del monitor |
| `Alt + Tab` | Recorre cap endavant les finestres de l'espai de treball actiu |
| `Alt + Shift + Tab` | Recorre cap enrere les finestres de l'espai de treball actiu |
| `Ctrl + Alt + Tab`| Mou el focus cap endavant entre monitors |
| `Ctrl + Alt + Shift + Tab`| Mou el focus cap enrere entre monitors |
| `Super + I` | Canvia la llengua d'entrada (amb més d'una distribució o mètode d'entrada) |
| `Super + Shift + I` | Torna a la llengua d'entrada anterior |

En un panell tàctil, els lliscaments amb tres i quatre dits canvien d'espai de treball, mouen finestres i obren el menú i la consola Quake; consulta [teclat, ratolí i panell tàctil](34-keyboard-mouse-trackpad.md) per als gestos.

El redimensionament fa servir les dues tecles a la dreta del 0, imprimeixi el que imprimeixi el teu teclat: `-` i `=` als teclats dels EUA, `+` i `´` als danesos i suecs, `+` i `\` als noruecs, `ß` i `´` als alemanys, `'` i `¡` als espanyols, i `-` i `^` als japonesos (JIS). `Super + K` les mostra tal com les imprimeix el teu teclat. En JIS, `Super + ^` és `Super + Equal`, mentre que `Super + Shift + -` (que escriu `=`) és `Super + Shift + Minus`. L'escalat del monitor i el gestor de contrasenyes fan servir `/`; a les distribucions que només escriuen `/` amb Shift, com la majoria de les europees, fan servir en canvi la tecla a l'esquerra de Shift dret (`-` a la danesa i l'alemanya).

## Controls del sistema

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panell d'àudio    |
| `Super + Ctrl + B`           | Panell de Bluetooth    |
| `Super + Ctrl + N`           | Panell de Wi-Fi/xarxa    |
| `Super + Ctrl + D`           | Panell de pantalla    |
| `Super + Ctrl + P`           | Panell d'energia    |
| `Super + Ctrl + X`           | Panell d'agents    |
| `Super + Ctrl + Alt + D`           | Panell del calendari    |
| `Super + Ctrl + Alt + E`           | Panell del rellotge mundial    |
| `Super + Ctrl + 1-9`           | Commuta el panell de la barra per posició    |
| `Super + Ctrl + S` | Menú per compartir (via LocalSend) |
| `Super + Ctrl + C` | Controls de captura (captura de pantalla/-enregistrament/selector) |
| `Super + Ctrl + O` | Commuta el menú |
| `Super + Ctrl + H` | Menú de maquinari |
| `Super + Ctrl + E` | Selector d'emojis |
| `Super + Ctrl + .` | Transcodifica contingut multimèdia |
| `Super + Shift + Ctrl + A` | Inicia el teu agent per defecte |
| `Power` key | Menú del sistema |
| `Super + Shift + Copilot` key | Menú d'Omarchy |

## Ajustos

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Lluentor màxima de la pantalla |
| `Shift + Brightness Down` | Lluentor mínima de la pantalla |
| `Alt + Brightness Up/Down` | Canvis precisos de lluentor de l'1% |
| `Alt + Volume Up/Down` | Canvis precisos de volum de l'1% |
| `Keyboard Brightness Up/Down` | Retroil·luminació del teclat més forta/més feble |
| `Keyboard Backlight` | Recorre els nivells de retroil·luminació del teclat |
| `Ctrl + Brightness Up/Down` | Retroil·luminació del teclat més forta/més feble, en teclats sense tecles pròpies |
| `Mic Mute` | Silencia el micròfon |
| `Shift + Mute` | Canvia la sortida d'àudio |
| `Touchpad Toggle` | Activa o desactiva el panell tàctil |
| `Display` key | Recorre els dissenys de l'espai de treball |
| `Alt + Play` | Pista següent |
| `Alt + Shift + Play` | Pista anterior |

## Obertura d'aplicacions

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (gestor d'agents) |
| `Super + Shift + Return` or `Super + Shift + B`  | Navegador    |
| `Super + Shift + Alt + B`           | Navegador (privat/d'incògnit)    |
| `Super + Shift + F`           | Gestor de fitxers    |
| `Super + Shift + Alt + F`           | Gestor de fitxers al cwd del terminal    |
| `Super + Shift + M`           | Música (Spotify)    |
| `Super + Shift + Alt + M`           | Música (cliamp)    |
| `Super + Shift + /`           | Gestor de contrasenyes (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Calculadora (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, un cop instal·lat)    |
| `Super + Shift + T`           | Activitat (btop)    |
| `Super + Shift + N`           | Editor (Plain, o el que hagis triat com a predeterminat)  |
| `Super + Shift + C`           | Calendari ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Correu electrònic ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Correu electrònic nou ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | El teu agent per defecte, o ChatGPT fins que en triïs un |
| `Super + Shift + Alt + A`           | IA (Grok)  |
| `Super + Shift + G`           | Missatgeria (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Missatgeria (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Missatgeria (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Escriptura (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (publicació nova) |
| `Super + Shift + Y`           | YouTube |

Canvia/afegeix dreceres a `~/.config/hypr/bindings.lua`.

## Porta-retalls universal

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + A`           | Selecciona-ho tot a les aplicacions compatibles amb `Ctrl + A`    |
| `Super + C`           | Copia    |
| `Super + X`           | Retalla (no al terminal)    |
| `Super + V`           | Enganxa    |
| `Super + Ctrl + V`           | Gestor del porta-retalls    |

Normalment a Linux necessites `Ctrl + Shift + C/V` per copiar i enganxar al terminal i `Ctrl + C/V` per fer-ho a tota la resta. Aquestes dreceres unificades del porta-retalls d'Omarchy funcionen a tot arreu.

## Captura

| Hotkey              | Function                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Captura de pantalla                      |
| `Super + Ctrl + Alt + C`            | Captura de pantalla (la mateixa captura, per a teclats sense tecla Print Screen) |
| `Super + Ctrl + C` | Menú de captura |
| `Alt + Print Screen`            | Enregistrament de pantalla                     |
| `Super + Shift + Ctrl + Alt + C` | Enregistrament de pantalla sense àudio, saltant-se el menú (prem-ho de nou per aturar-lo) |
| `Super + Print Screen` | Selector de color |
| `Super + Ctrl + Print Screen` | Extracció de text al porta-retalls |
| `Super + Alt + [` | Fes més petita la superposició de la càmera web mentre enregistres |
| `Super + Alt + ]` | Fes més gran la superposició de la càmera web mentre enregistres |
| `Alt + Shift + L` | Copia l'URL actual de l'aplicació web o del navegador |
| `Alt + Shift + D` | Baixa el vídeo de la pàgina actual a `~/Videos` |
| `Alt + Space` | Inicia/atura el dictat (requereix _Setup > Defaults > Dictation_) |
| `Right Alt` | Mantén premut per dictar (requereix _Setup > Defaults > Dictation_) |

Amb els enregistraments de pantalla, la drecera pregunta primer quin àudio vols i després comença a enregistrar. Prem-ho de nou per aturar-ho. Consulta [captures de pantalla i enregistrament](12-screenshots-recording.md) per als detalls.

Totes les opcions de captura també són accessibles a _Trigger > Capture_ al menú d'Omarchy (`Super + Space`).

## Notificacions

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + ,` | Actua sobre la notificació més recent: obre-la o prem el seu únic botó, tria entre les seves opcions o descarta-la quan no en tingui cap  |
| `Super + Shift + ,` | Descarta totes les notificacions |
| `Super + Ctrl + ,` | Controla les notificacions amb el teclat  |
| `Super + Alt + ,` | Descarta la notificació més recent  |
| `Super + Shift + Alt + ,` | Obre l'historial de notificacions  |
| `Super + Ctrl + Alt + ,` | Commuta el silenciament de notificacions  |

## Estil

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Tria un tema nou (també `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Tria el fons del tema (també `Super + Ctrl + Space`) |
| `Super + Backspace` | Commuta la transparència d'una finestra |
| `Super + Ctrl + Backspace` | Commuta la proporció quadrada d'una sola finestra |

Les imatges de fons addicionals són a `~/.config/omarchy/backgrounds/<theme name>`. També disponibles via _Install > Style > Background_ al menú d'Omarchy.

Totes les opcions d'estil també són accessibles a _Appearance_ al menú d'Omarchy (`Super + Space`).

## Commutadors

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Commuta el bloqueig en inactivitat |
| `Super + Ctrl + Delete` | Activa/desactiva la pantalla del portàtil |
| `Super + Ctrl + Alt + Delete` | Commuta la duplicació de la pantalla del portàtil |
| `Super + Shift + Space` | Commuta la barra superior  |
| `Shift + Mute` | Canvia a la sortida d'àudio següent |
| `Shift + Play` | Canvia a la font multimèdia següent |
| `Super + Shift + Backspace` | Commuta els buits entre finestres |
| `Super + Ctrl + Alt + F` | Commuta l'escriptori a pantalla completa (barra superior + buits entre finestres) |

## Recordatoris

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Crea un recordatori  |
| `Super + Ctrl + Alt + R` | Mostra tots els recordatoris  |
| `Super + Ctrl + Shift + R` | Esborra tots els recordatoris  |

## Avisos

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Mostra l'hora com a notificació  |
| `Super + Ctrl + Alt + B` | Mostra la bateria com a notificació  |
| `Super + Ctrl + Alt + W` | Commuta el temps com a notificació  |

## Tmux

La tecla de prefix és `Ctrl + Space` (`Ctrl + B` també funciona). Pots canviar aquestes dreceres a `~/.config/tmux/tmux.conf`.

### Panells

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + v` | Divideix el panell al costat (vertical) |
| `Prefix + h` | Divideix el panell a sota (horitzontal) |
| `Prefix + x` | Mata el panell |
| `Prefix + z` | Commuta el zoom del panell (pantalla completa) |
| `Alt + Enter` | Divideix el panell a sota (sense prefix) |
| `Alt + Shift + Enter` | Divideix el panell al costat (sense prefix) |
| `Alt + Escape` | Mata el panell (sense prefix) |
| `Ctrl + Alt + Arrows` | Mou-te entre panells |
| `Ctrl + Alt + Shift + Arrows` | Redimensiona els panells |

### Finestres

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + c` | Finestra nova |
| `Prefix + k` | Mata la finestra |
| `Prefix + r` | Reanomena la finestra |
| `Alt + 1-9` | Ves a una finestra concreta |
| `Alt + Arrow Left/Right` | Mou-te entre finestres |
| `Alt + Shift + Arrow Left/Right` | Mou la finestra a l'esquerra/dreta |

### Sessions

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + C` | Sessió nova |
| `Prefix + K` | Mata la sessió |
| `Prefix + R` | Reanomena la sessió |
| `Prefix + N` | Sessió següent |
| `Prefix + P` | Sessió anterior |
| `Alt + Arrow Up/Down` | Mou-te entre sessions |
| `Prefix + s` | Llista les sessions |
| `Prefix + d` | Desconnecta't de la sessió |

### Mode de còpia (estil vi)

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + [` | Entra en mode de còpia |
| `v` | Comença la selecció (en mode de còpia) |
| `y` | Copia la selecció (en mode de còpia) |

### General

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + q` | Recarrega la configuració |
| `Prefix + ?` | Mostra les dreceres de Tmux |
| `Prefix + :` | Indicador d'ordres |

### Funcions de disseny de Tmux

Aquestes funcions s'han d'executar dins d'una sessió de Tmux.

| Command | Function |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Crea un disseny de desenvolupament amb editor, IA i terminal |
| `tdlm <ai> [<second_ai>]` | Crea un disseny de desenvolupament per subdirectori |
| `tsl <count> <command>` | Crea un disseny d'eixam amb diversos panells |

## Terminal Ghostty

El terminal Ghostty s'instal·la amb _Install > Terminal_ via el menú d'Omarchy.

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nova divisió a sota |
| `Ctrl + Shift + O` | Nova divisió al costat |
| `Ctrl + Alt + Arrows` | Mou-te entre divisions |
| `Super + Ctrl + Shift + Arrows` | Redimensiona la divisió en 10 línies |
| `Super + Ctrl + Shift + Alt + Arrows` | Redimensiona la divisió en 100 línies |
| `Ctrl + Shift + T` | Pestanya nova  |
| `Ctrl + Shift + Arrows` | Mou-te entre pestanyes |
| `Alt + Numbers` | Ves a una pestanya concreta |
| `Shift + Pg Up/Down` | Desplaça't per l'historial |
| `Ctrl + Left mouse` | Obre l'enllaç al navegador |

## Gestor de fitxers

| Hotkey              | Function                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Ves a la ruta                     |
| `Space`               | Previsualitza el fitxer (les fletxes naveguen) |
| `Alt + Up`       | Puja a la carpeta pare        |

## Neovim (amb lazyvim)

### Navegació

| Hotkey                   | Function                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Mostra les opcions d'ordres            |
| `Space Space`              | Obre un fitxer amb cerca difusa      |
| `Space E`                  | Commuta la barra lateral                  |
| `Space G G`                | Mostra els controls de git               |
| `Space S G`                | Cerca el contingut dels fitxers             |
| `Ctrl + W W`               | Salta entre la barra lateral i l'editor |
| `Ctrl + Left/right arrow`  | Canvia la mida de la barra lateral          |
| `Shift + H`                      | Ves a la pestanya de fitxer de l'esquerra             |
| `Shift + L`                      | Ves a la pestanya de fitxer de la dreta            |
| `Space B D`                | Tanca la pestanya de fitxer                  |

### Mentre ets a la barra lateral

| Hotkey                   | Function                        |
| ------------------------ | ------------------------------- |
| `A`                        | Afegeix un fitxer nou al directori pare      |
| `Shift + A`                | Afegeix un subdirectori nou al directori pare    |
| `D`                        | Suprimeix el fitxer/directori destacat     |
| `M`                        | Mou el fitxer/directori destacat       |
| `R`                        | Reanomena el fitxer/directori destacat     |
| `?`                        | Mostra l'ajuda de totes les ordres      |

[Consulta totes les dreceres de Neovim configurades per LazyVim](https://www.lazyvim.org/keymaps).

## Emojis ràpids

Pots fer servir `Super + Ctrl + E` per mostrar un selector d'emojis complet que posarà la selecció al porta-retalls, o pots fer servir aquestes opcions d'accés ràpid.

| Hotkey       | EM | Clue       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | somriure      |
| `Shift + CapsLock M C` | 😂 | plor        |
| `Shift + CapsLock M L` | 😍 | amor       |
| `Shift + CapsLock M V` | ✌️ | victòria    |
| `Shift + CapsLock M H` | ❤️ | cor      |
| `Shift + CapsLock M Y` | 👍 | sí        |
| `Shift + CapsLock M N` | 👎 | no         |
| `Shift + CapsLock M F` | 🖕 | fot       |
| `Shift + CapsLock M W` | 🤞 | desig       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | petó       |
| `Shift + CapsLock M E` | 🙄 | ulls en blanc    |
| `Shift + CapsLock M I` | 😉 | picar l'ullet       |
| `Shift + CapsLock M P` | 🙏 | pregar |
| `Shift + CapsLock M D` | 🤤 | bavejar      |
| `Shift + CapsLock M M` | 💰 | diners      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | brindis      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | salutació |
| `Shift + CapsLock M A` |💪 | braç |
| `Shift + CapsLock M B` |🤯 | bufant |

## Completaments ràpids

| Hotkey       | Completion       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (guió llarg)   |
| `Shift + CapsLock Space N` | El teu nom (tal com el vas introduir a la configuració)  |
| `Shift + CapsLock Space E` | El teu correu electrònic (tal com el vas introduir a la configuració)  |

Pots afegir-ne més de teus editant `~/.XCompose` i després executant `omarchy restart xcompose` al terminal perquè els canvis s'apliquin.
