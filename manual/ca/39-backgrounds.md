# Fons de pantalla

Cada tema inclou el seu propi conjunt de fons de pantalla, i en pots afegir de propis a `~/.config/omarchy/backgrounds/[theme]`. Si vols afegir una imatge de fons addicional, per exemple, al tema nord, només has de posar el fitxer a `~/.config/omarchy/backgrounds/nord`.

La manera més fàcil de fer-ho és anar a _Instal·la > Estil > Fons_ al menú d'Omarchy. Això obrirà la carpeta on s'emmagatzemen els fons d'aquell tema. Prem `Super + Shift + F` per obrir un altre gestor de fitxers, troba el teu fons i copia-l'hi. Ara s'inclourà entre les opcions de fons que pots triar amb `Super + Ctrl + W`.

Un tema sense fons propis en rep un de generat a partir dels seus colors: el logotip d'Omarchy amb el color d'accent del tema sobre el seu color de fons. Afegeix-ne un de propi per substituir-lo.

Els fons també poden ser vídeos, a més d'imatges fixes. Deixa un fitxer `mp4`, `m4v`, `mov`, `webm`, `mkv` o `avi` a la mateixa carpeta i apareixerà al costat de les imatges. Els vídeos els reprodueix el motor de fons de pantalla OWE. Descodifica el vídeo una sola vegada per a tots els monitors, en reprodueix el so a través de la sortida d'àudio per defecte i atura la reproducció sempre que res no el pugui veure. Tot i així, un fons de pantalla de vídeo consumeix molta més energia que un de fix.

Els temes poden incloure una introducció curta per a un fons fix. Per a `backgrounds/road.webp`, el vídeo corresponent es troba a `backgrounds/intros/road.mp4`. Es reprodueix automàticament en arrencar, en canviar a un tema amb aquest fons seleccionat i en triar aquest fons, i després torna a la imatge fixa. Els vídeos d'introducció no apareixen al selector de fons i mai no es reprodueixen en bucle.

Triar _Aparença > Animacions desactivades_ també desactiva les introduccions de fons. Omarchy ho fa per defecte en una màquina virtual. L'ordre `omarchy theme bg intro toggle` permet activar o desactivar les introduccions per separat. Actualitzar un tema no reprodueix cap introducció.

Una imatge fixa també pot tenir un bucle, una versió tranquil·la de la mateixa imatge que continua movent-se, a `backgrounds/loops/road.mp4`. Es reprodueix en lloc de la imatge fixa, després de la seva introducció si en té, i s'atura quan es desactiven les animacions. Amb la bateria, es mostra la imatge fixa, i el bucle torna quan connectes l'equip. Els bucles no apareixen al selector de fons.

Pots trobar una col·lecció enorme de fons fantàstics i seleccionats a [dharmx/walls](https://github.com/dharmx/walls).

La pantalla de bloqueig mostra un fotograma fix d'un fons de vídeo, de la mateixa manera que mostra un fotograma fix d'un GIF animat.
