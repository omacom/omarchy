# Fons

Cada tema inclou el seu propi conjunt de fons, i pots afegir-ne d'extra de propis a `~/.config/omarchy/backgrounds/[theme]`. Si vols afegir una imatge de fons extra, per exemple, al tema nord, només cal que posis el fitxer a `~/.config/omarchy/backgrounds/nord`.

La manera més fàcil de fer-ho és anar a _Instal·la > Estil > Fons_ al menú d'Omarchy. Això obrirà la carpeta on es desen els fons d'aquell tema. Prem `Super + Shift + F` per obrir un altre gestor de fitxers, busca el teu fons i copia-l'hi. Ara s'inclourà entre les opcions de fons entre les quals pots triar amb `Super + Ctrl + W`.

Els fons poden ser vídeos a més d'imatges fixes. Deixa un fitxer `mp4`, `m4v`, `mov`, `webm`, `mkv` o `avi` a la mateixa carpeta i apareixerà al costat de les imatges. Els vídeos els reprodueix el motor de fons de pantalla OWE. Descodifica el vídeo una sola vegada per a tots els monitors i en reprodueix el so a través de la sortida d'àudio predeterminada, i atura la reproducció sempre que res no el pugui veure. Un fons de pantalla en vídeo continua costant molta més energia que un de fix.

Els temes poden incloure una introducció curta per a un fons fix. Per a `backgrounds/road.webp`, el vídeo corresponent es troba a `backgrounds/intros/road.mp4`. Es reprodueix automàticament en arrencar, quan es canvia a un tema amb aquell fons seleccionat i quan es tria aquell fons, i després torna a la imatge fixa. Els vídeos d'introducció queden fora del selector de fons i mai es reprodueixen en bucle.

Desactivar _Aparença > Animacions_ també desactiva les introduccions dels fons. Omarchy ho fa per defecte en una màquina virtual. L'ordre `omarchy theme bg intro toggle` pot activar o desactivar les introduccions per separat. Actualitzar un tema no reprodueix cap introducció.

Pots trobar una col·lecció enorme de fons genials i ben triats a [dharmx/walls](https://github.com/dharmx/walls).

La pantalla de bloqueig mostra un fotograma fix d'un fons en vídeo, de la mateixa manera que mostra un fotograma fix d'un GIF animat.
