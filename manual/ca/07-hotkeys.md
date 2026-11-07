# Dreceres de teclat

Pots veure totes les dreceres de teclat principals amb `Super + K` (les dreceres de Tmux amb `Super + Alt + K` i les de Herdr amb `Super + Ctrl + K`).

## Com s'organitzen les dreceres de teclat

Cada drecera es troba en un pla, definit pels seus modificadors, i cada pla té una sola funció. Això és el que evita que les dreceres es barregin, i vol dir que normalment pots endevinar on es troba cada cosa.

| Pla | Què hi ha | Exemples |
| --- | --- | --- |
| `Super + key` | El sistema: finestres, espais de treball, disposicions i menús principals | `Super + Space` menú d'Omarchy, `Super + W` tanca la finestra, `Super + F` pantalla completa |
| `Super + Shift + key` | Aplicacions | `Super + Shift + B` navegador, `Super + Shift + E` correu electrònic, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panells i menús del sistema | `Super + Ctrl + A` àudio, `Super + Ctrl + N` xarxa, `Super + Ctrl + C` menú de captura |
| `Super + Ctrl + Alt + key` | Accions ràpides i avisos | `Super + Ctrl + Alt + T` mostra l'hora, `Super + Ctrl + Alt + B` bateria, `Super + Ctrl + Alt + C` captura de pantalla |

Afegir `Alt` a una drecera et dona una variant del mateix, mai una cosa sense cap relació:

- `Super + Shift + B` obre el navegador; `Super + Shift + Alt + B` obre una finestra privada
- `Super + Shift + E` obre el correu electrònic; `Super + Shift + Alt + E` en comença un de nou
- `Super + F` passa a pantalla completa; `Super + Alt + F` passa a amplada completa
- `Super + Ctrl + C` obre el menú de captura; `Super + Ctrl + Alt + C` se salta el menú i fa una captura de pantalla

Quan afegeixis una drecera:

1. Tria el pla segons el que fa, i després tria la tecla.
2. No moguis una drecera existent per fer espai. Troba una tecla lliure al pla correcte.
3. Fes servir `Alt` només per a una variant de la drecera sense ell.

Unes quantes dreceres trenquen aquestes regles perquè són pràctiques. `Shift` amb una fletxa o `Tab` mou o inverteix en lloc d'obrir una aplicació, i `Print`, les tecles multimèdia, `Alt + Tab` i `Ctrl + Alt + Del` funcionen com a tot arreu. Són excepcions, no patrons per copiar.

Si un valor per defecte no t'escau (posem que vols `Super + Shift + S` per a captures de pantalla com a Windows), reassigna'l a `~/.config/hypr/bindings.lua`.

## Navegació

| Drecera                  | Funció              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menú d'Omarchy (aplicacions i tota la resta)    |
| `Super + Alt + Space` | Graella d'aplicacions |
| `Super + Escape` | Menú del sistema (suspendre, reiniciar, etc.)  |
| `Super + Ctrl + L` | Bloqueja l'ordinador |
| `Super + W` o `Super + Q` | Tanca la finestra             |
| `Ctrl + Alt + Del` | Tanca totes les finestres |
| `Super + T`               | Commuta la finestra entre mosaic/flotant             |
| `Super + J` | Commuta la posició de la finestra (horitzontal/vertical) |
| `Super + O`               | Commuta passar la finestra a sticky'n'floating |
| `Super + L`               | Passa per les disposicions dwindle, scrolling i floating |
| `Super + Alt + L`         | Passa per les disposicions en ordre invers |
| `Super + P`               | Commuta l'estil de finestra pseudo (natural v estirat) |
| `Super + F`                 | Passa a pantalla completa              |
| `Super + Alt + F`                 | Passa a amplada completa              |
| `Super + Ctrl + F`                 | Passa a pantalla completa dins de la finestra              |
| `Super + 1/2/3/4`         | Salta a un espai de treball concret al monitor enfocat |
| `Super + Tab` | Salta a l'espai de treball següent al monitor enfocat |
| `Super + Shift + Tab` | Salta a l'espai de treball anterior al monitor enfocat |
| `Super + Ctrl + Tab` | Salta a l'espai de treball previ al monitor enfocat |
| `Super + Shift + 1/2/3/4` | Mou la finestra a l'espai de treball al monitor enfocat |
| `Super + Shift + Alt + 1/2/3/4` | Mou la finestra a l'espai de treball al monitor enfocat sense seguir-la |
| `Super + S` | Commuta el scratchpad complet |
| `Super + Alt + S` | Mou la finestra al scratchpad complet |
| `Super + Grave` | Commuta la consola Quake |
| `Super + Shift + Grave` | Mou la finestra a la consola Quake |
| `Super + Shift + Ctrl + Arrows` | Mou la finestra al monitor en aquella direcció |
| `Super + Shift + Alt + Arrows` | Mou l'espai de treball al monitor en aquella direcció |
| `Super + Arrow`  | Mou el focus a la finestra en la direcció de la fletxa, creuant al monitor d'aquell costat a la vora de la pantalla |
| `Super + Shift + Arrow`  | Intercanvia la finestra amb una altra en la direcció de la fletxa, inclosa una del monitor d'aquell costat |
| `Super + Minus` | Expandeix la finestra cap a l'esquerra |
| `Super + Equal` | Encongeix la finestra cap a l'esquerra |
| `Super + Shift + Minus` | Encongeix la finestra cap amunt |
| `Super + Shift + Equal` | Expandeix la finestra cap avall |
| `Super + Alt + Minus/Equal` | El mateix redimensionament en passos més petits |
| `Super + Ctrl + Minus/Equal` | El mateix redimensionament en passos més grans |
| `Super + Alt + Home` | Desa l'amplada de la finestra |
| `Super + Home` | Restaura l'amplada de la finestra desada |
| `Super + Left Mouse` | Arrossega la finestra |
| `Super + Right Mouse` | Redimensiona la finestra |
| `Super + Scroll Wheel` | Desplaça't pels espais de treball al monitor enfocat |
| `Super + G`               | Commuta l'agrupació de finestres      |
| `Super + Alt + G`               | Treu la finestra de l'agrupació      |
| `Super + Alt + Tab`               | Passa per les finestres de l'agrupació      |
| `Super + Alt + Shift + Tab`               | Passa enrere per les finestres de l'agrupació      |
| `Super + Alt + Scroll Wheel` | Passa per les finestres de l'agrupació |
| `Super + Alt + 1/2/3/4/5`               | Salta a una finestra concreta de l'agrupació      |
| `Super + Alt + Arrow`  | Mou la finestra dins de l'agrupació en la direcció de la fletxa, inclosa una del monitor d'aquell costat |
| `Super + Ctrl + Left/Right`  | Mou-te entre finestres dins d'un grup en mosaic |
| `Super + Ctrl + Z` | Fes zoom a la pantalla (repeteix per a més zoom) |
| `Super + Ctrl + Alt + Z` | Allunya completament el zoom de la pantalla |
| `Super + /` | Avança per les opcions d'escalat del monitor |
| `Super + Alt + /` | Retrocedeix per les opcions d'escalat del monitor |
| `Alt + Tab` | Passa endavant per les finestres de l'espai de treball actiu |
| `Alt + Shift + Tab` | Passa enrere per les finestres de l'espai de treball actiu |
| `Ctrl + Alt + Tab`| Passa el focus endavant pels monitors |
| `Ctrl + Alt + Shift + Tab`| Passa el focus enrere pels monitors |

Les dreceres de redimensionament fan servir les tecles físiques `code:20` i `code:21` (XKB `<AE11>` i `<AE12>`), independentment dels caràcters impresos al teclat. Als teclats dels EUA aquestes tecles són `-` i `=`; als teclats japonesos (JIS) són `-` i `^`; als teclats espanyols són `'` i `¡`. A JIS, `Super + ^` és `Super + Equal`, mentre que `Super + Shift + -` (que escriu `=`) és `Super + Shift + Minus`.

## Controls del sistema

| Drecera                  | Funció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panell d'àudio    |
| `Super + Ctrl + B`           | Panell de Bluetooth    |
| `Super + Ctrl + N`           | Panell de Wi-Fi/xarxa    |
| `Super + Ctrl + D`           | Panell de pantalla    |
| `Super + Ctrl + P`           | Panell d'energia    |
| `Super + Ctrl + Alt + D`           | Panell del calendari    |
| `Super + Ctrl + Alt + E`           | Panell del rellotge mundial    |
| `Super + Ctrl + 1-9`           | Commuta el panell de la barra per posició    |
| `Super + Ctrl + S` | Menú de compartir (via LocalSend) |
| `Super + Ctrl + C` | Controls de captura (captura de pantalla/gravació/selector) |
| `Super + Ctrl + O` | Menú de commutació |
| `Super + Ctrl + H` | Menú de maquinari |
| `Super + Ctrl + E` | Selector d'emojis |
| `Super + Ctrl + .` | Transcodifica contingut multimèdia |
| `Super + Shift + Ctrl + A` | Tria un agent d'IA |

## Ajustaments

| Drecera                  | Funció              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Lluminositat màxima de la pantalla |
| `Shift + Brightness Down` | Lluminositat mínima de la pantalla |
| `Alt + Brightness Up/Down` | Canvis precisos de lluminositat de l'1% |
| `Alt + Volume Up/Down` | Canvis precisos de volum de l'1% |
| `Keyboard Brightness Up/Down` | Retroil·luminació del teclat més brillant/més tènue |
| `Keyboard Backlight` | Passa pels nivells de retroil·luminació del teclat |
| `Alt + Play` | Pista següent |
| `Alt + Shift + Play` | Pista anterior |

## Llançament d'aplicacions

| Drecera                  | Funció              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (gestor d'agents) |
| `Super + Shift + Return`           | Navegador    |
| `Super + Shift + Alt + B`           | Navegador (privat/d'incògnit)    |
| `Super + Shift + F`           | Gestor de fitxers    |
| `Super + Shift + Alt + F`           | Gestor de fitxers al cwd del terminal    |
| `Super + Shift + M`           | Música (Spotify)    |
| `Super + Shift + Alt + M`           | Música (cliamp)    |
| `Super + Shift + /`           | Gestor de contrasenyes (1password)    |
| `Super + Shift + Q`           | Calculadora (Omacalc)    |
| `Super + Shift + T`           | Activitat (btop)    |
| `Super + Shift + N`           | Editor (Neovim)  |
| `Super + Shift + C`           | Calendari ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Correu electrònic ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Correu electrònic nou ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | IA (ChatGPT)  |
| `Super + Shift + Alt + A`           | IA (Grok)  |
| `Super + Shift + G`           | Missatgeria (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Missatgeria (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Missatgeria (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Escriptura (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Canvia/afegeix dreceres a `~/.config/hypr/bindings.lua`.

## Porta-retalls universal

| Drecera                  | Funció              |
| ----------------------- | --------------------- |
| `Super + A`           | Selecciona-ho tot a les aplicacions que admeten `Ctrl + A`    |
| `Super + C`           | Copia    |
| `Super + X`           | Retalla (no al terminal)    |
| `Super + V`           | Enganxa    |
| `Super + Ctrl + V`           | Gestor del porta-retalls    |

Normalment a Linux, necessites `Ctrl + Shift + C/V` per copiar i enganxar al terminal i `Ctrl + C/V` per fer-ho a tot arreu. Aquestes dreceres unificades de porta-retalls d'Omarchy funcionen a tot arreu.

## Captura

| Drecera              | Funció                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Captura de pantalla                      |
| `Super + Ctrl + Alt + C`            | Captura de pantalla (la mateixa captura, per a teclats sense tecla Print Screen) |
| `Super + Ctrl + C` | Menú de captura |
| `Alt + Print Screen`            | Gravació de pantalla                     |
| `Super + Print Screen` | Selector de color |
| `Super + Ctrl + Print Screen` | Extracció de text al porta-retalls |
| `Super + Alt + [` | Fes més petita la superposició de la càmera web mentre graves |
| `Super + Alt + ]` | Fes més gran la superposició de la càmera web mentre graves |
| `Alt + Shift + L` | Copia l'URL actual des de l'aplicació web o Chromium |
| `Alt + Shift + D` | Descarrega el vídeo de la pàgina actual a `~/Videos` |
| `Alt + Space` | Inicia/atura el dictat (requereix _Configuració > Valors per defecte > Dictat_) |
| `Right Alt` | Mantén premut per dictar (requereix _Configuració > Valors per defecte > Dictat_) |

Amb les gravacions de pantalla, la drecera primer pregunta quin àudio vols, i després comença a gravar. Prem-la de nou per aturar. Consulta [captures de pantalla i gravació](12-screenshots-recording.md) per als detalls.

Totes les opcions de captura també són accessibles a _Activa > Captura_ al menú d'Omarchy (`Super + Space`).

## Notificacions

| Drecera                  | Funció              |
| ----------------------- | --------------------- |
| `Super + ,` | Actua sobre l'última notificació: obre-la o prem el seu únic botó, tria entre les seves opcions, o descarta-la quan no en tingui cap  |
| `Super + Shift + ,` | Descarta totes les notificacions |
| `Super + Ctrl + ,` | Controla les notificacions amb el teclat  |
| `Super + Alt + ,` | Descarta l'última notificació  |
| `Super + Shift + Alt + ,` | Obre l'historial de notificacions  |
| `Super + Ctrl + Alt + ,` | Commuta silenciar les notificacions  |

## Estil

| Drecera                  | Funció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Tria un tema nou (també `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Tria el fons del tema (també `Super + Ctrl + Space`) |
| `Super + Backspace` | Commuta la transparència d'una finestra |
| `Super + Ctrl + Backspace` | Commuta la proporció quadrada d'una sola finestra |

Les imatges de fons addicionals es troben a `~/.config/omarchy/backgrounds/<theme name>`. També disponible via _Instal·la > Estil > Fons_ al menú d'Omarchy.

Totes les opcions d'estil també són accessibles a _Estil_ al menú d'Omarchy (`Super + Space`).

## Commutadors

| Drecera                  | Funció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Commuta el bloqueig en inactivitat |
| `Super + Ctrl + Delete` | Commuta encendre/apagar la pantalla del portàtil |
| `Super + Ctrl + Alt + Delete` | Commuta la duplicació de la pantalla del portàtil |
| `Super + Shift + Space` | Commuta la barra superior  |
| `Shift + Mute` | Canvia a la sortida d'àudio següent |
| `Shift + Play` | Canvia a la font multimèdia següent |
| `Super + Shift + Backspace` | Commuta els espais entre finestres |
| `Super + Ctrl + Alt + F` | Commuta l'escriptori a pantalla completa (barra superior + espais entre finestres) |

## Recordatoris

| Drecera                  | Funció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Defineix un recordatori  |
| `Super + Ctrl + Alt + R` | Mostra tots els recordatoris  |
| `Super + Ctrl + Shift + R` | Esborra tots els recordatoris  |

## Avisos

| Drecera                  | Funció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Mostra l'hora com a notificació  |
| `Super + Ctrl + Alt + B` | Mostra la bateria com a notificació  |
| `Super + Ctrl + Alt + W` | Commuta mostrar la meteorologia com a notificació  |

## Tmux

La tecla de prefix és `Ctrl + Space` (`Ctrl + B` també funciona). Pots canviar aquestes dreceres a `~/.config/tmux/tmux.conf`.

### Panells

| Drecera                  | Funció              |
| ----------------------- | --------------------- |
| `Prefix + v` | Divideix el panell al costat (vertical) |
| `Prefix + h` | Divideix el panell a sota (horitzontal) |
| `Prefix + x` | Elimina el panell |
| `Prefix + z` | Commuta el zoom del panell (pantalla completa) |
| `Alt + Enter` | Divideix el panell a sota (sense prefix) |
| `Alt + Shift + Enter` | Divideix el panell al costat (sense prefix) |
| `Alt + Escape` | Elimina el panell (sense prefix) |
| `Ctrl + Alt + Arrows` | Mou-te entre panells |
| `Ctrl + Alt + Shift + Arrows` | Redimensiona els panells |

### Finestres

| Drecera                  | Funció              |
| ----------------------- | --------------------- |
| `Prefix + c` | Finestra nova |
| `Prefix + k` | Elimina la finestra |
| `Prefix + r` | Reanomena la finestra |
| `Alt + 1-9` | Ves a una finestra concreta |
| `Alt + Arrow Left/Right` | Mou-te entre finestres |
| `Alt + Shift + Arrow Left/Right` | Mou la finestra a l'esquerra/dreta |

### Sessions

| Drecera                  | Funció              |
| ----------------------- | --------------------- |
| `Prefix + C` | Sessió nova |
| `Prefix + K` | Elimina la sessió |
| `Prefix + R` | Reanomena la sessió |
| `Prefix + N` | Sessió següent |
| `Prefix + P` | Sessió anterior |
| `Alt + Arrow Up/Down` | Mou-te entre sessions |
| `Prefix + s` | Llista les sessions |
| `Prefix + d` | Desconnecta't de la sessió |

### Mode de còpia (estil vi)

| Drecera                  | Funció              |
| ----------------------- | --------------------- |
| `Prefix + [` | Entra al mode de còpia |
| `v` | Comença la selecció (al mode de còpia) |
| `y` | Copia la selecció (al mode de còpia) |

### General

| Drecera                  | Funció              |
| ----------------------- | --------------------- |
| `Prefix + q` | Recarrega la configuració |
| `Prefix + ?` | Mostra les dreceres de teclat de Tmux |
| `Prefix + :` | Indicador d'ordres |

### Funcions de disposició de Tmux

Aquestes funcions s'han d'executar dins d'una sessió de Tmux.

| Ordre | Funció |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Crea una disposició de desenvolupament amb editor, IA i terminal |
| `tdlm <ai> [<second_ai>]` | Crea una disposició de desenvolupament per subdirectori |
| `tsl <count> <command>` | Crea una disposició d'eixam amb diversos panells |

## Terminal Ghostty

El terminal Ghostty s'instal·la amb _Instal·la > Terminal_ via el menú d'Omarchy.

| Drecera                  | Funció              |
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

| Drecera              | Funció                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Ves a la ruta                     |
| `Space`               | Previsualitza el fitxer (les fletxes naveguen) |
| `Alt + Up`       | Puja a la carpeta pare        |

## Neovim (amb lazyvim)

### Navegació

| Drecera                   | Funció                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Mostra les opcions d'ordres            |
| `Space Space`              | Obre un fitxer via cerca difusa      |
| `Space E`                  | Commuta la barra lateral                  |
| `Space G G`                | Mostra els controls de git               |
| `Space S G`                | Cerca el contingut dels fitxers             |
| `Ctrl + W W`               | Salta entre la barra lateral i l'editor |
| `Ctrl + Left/right arrow`  | Canvia la mida de la barra lateral          |
| `Shift + H`                      | Ves a la pestanya de fitxer de l'esquerra             |
| `Shift + L`                      | Ves a la pestanya de fitxer de la dreta            |
| `Space B D`                | Tanca la pestanya de fitxer                  |

### Mentre ets a la barra lateral

| Drecera                   | Funció                        |
| ------------------------ | ------------------------------- |
| `A`                        | Afegeix un fitxer nou al directori pare      |
| `Shift + A`                | Afegeix un subdirectori nou al directori pare    |
| `D`                        | Elimina el fitxer/directori destacat     |
| `M`                        | Mou el fitxer/directori destacat       |
| `R`                        | Reanomena el fitxer/directori destacat     |
| `?`                        | Mostra l'ajuda de totes les ordres      |

[Consulta totes les dreceres de teclat de Neovim configurades per LazyVim](https://www.lazyvim.org/keymaps).

## Emojis ràpids

Pots fer servir `Super + Ctrl + E` per mostrar un selector d'emojis complet que posarà la selecció al porta-retalls o pots fer servir aquestes opcions d'accés ràpid.

| Drecera       | EM | Pista       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | somriure      |
| `Shift + CapsLock M C` | 😂 | plora        |
| `Shift + CapsLock M L` | 😍 | amor       |
| `Shift + CapsLock M V` | ✌️ | victòria    |
| `Shift + CapsLock M H` | ❤️ | cor      |
| `Shift + CapsLock M Y` | 👍 | sí        |
| `Shift + CapsLock M N` | 👎 | no         |
| `Shift + CapsLock M F` | 🖕 | fotre       |
| `Shift + CapsLock M W` | 🤞 | desig       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | petó       |
| `Shift + CapsLock M E` | 🙄 | ulls en blanc    |
| `Shift + CapsLock M I` | 😉 | picada d'ullet       |
| `Shift + CapsLock M P` | 🙏 | prega |
| `Shift + CapsLock M D` | 🤤 | baveja      |
| `Shift + CapsLock M M` | 💰 | diners      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | brindis      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | salutació |
| `Shift + CapsLock M A` |💪 | braç |
| `Shift + CapsLock M B` |🤯 | bufant |

## Complecions ràpides

| Drecera       | Compleció       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (guió llarg)   |
| `Shift + CapsLock Space N` | El teu nom (tal com el vas introduir a la configuració)  |
| `Shift + CapsLock Space E` | El teu correu electrònic (tal com el vas introduir a la configuració)  |

Pots afegir-ne més de teves editant `~/.XCompose`, i després executant `omarchy-restart-xcompose` al terminal perquè els canvis s'apliquin.
