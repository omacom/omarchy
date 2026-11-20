# Fons de pantalla

Cada tema inclou el seu propi conjunt de fons de pantalla, i en pots afegir de propis a `~/.config/omarchy/backgrounds/[theme]`. Si vols afegir una imatge de fons extra, posem per cas, al tema nord, només has de posar el fitxer a `~/.config/omarchy/backgrounds/nord`.

La manera més fàcil de fer-ho és anar a _Instal·la > Estil > Fons_ al menú d'Omarchy. Això obrirà la carpeta on es desen els fons d'aquell tema. Prem `Super + Shift + F` per obrir un altre gestor de fitxers, troba el teu fons i copia-l'hi. Ara s'inclourà entre les opcions de fons entre les quals pots triar amb `Super + Ctrl + W`.

Els fons de pantalla poden ser vídeos a més d'imatges fixes. Deixa anar un fitxer `mp4`, `m4v`, `mov`, `webm`, `mkv` o `avi` a la mateixa carpeta i apareixerà al costat de les imatges. Els vídeos els reprodueix el motor de fons de pantalla OWE. Descodifica el vídeo una sola vegada per a tots els monitors i en reprodueix el so per la sortida d'àudio predeterminada, i atura la reproducció sempre que no el pugui veure res. Un fons de pantalla de vídeo continua costant molta més energia que un de fix.

Els temes poden incloure una introducció curta per a un fons fix. Per a `backgrounds/road.webp`, el vídeo corresponent es troba a `backgrounds/intros/road.mp4`. Es reprodueix automàticament a l'arrencada, en canviar a un tema amb aquell fons seleccionat i en triar aquell fons, i després torna a la imatge fixa. Els vídeos d'introducció no apareixen al selector de fons i mai es reprodueixen en bucle.

Desactivar _Aparença > Animacions_ també desactiva les introduccions dels fons. Omarchy ho fa per defecte en una màquina virtual. L'ordre `omarchy theme bg intro toggle` pot activar i desactivar les introduccions per separat. Actualitzar un tema no reprodueix cap introducció.

Una imatge fixa també pot tenir un bucle, una versió tranquil·la de la mateixa imatge que es continua movent, a `backgrounds/loops/road.mp4`. Es reprodueix en lloc de la imatge fixa, després de la seva introducció si en té una, i s'atura quan es desactiven les animacions. Els bucles no apareixen al selector de fons i, com qualsevol fons de vídeo, costen més energia que una imatge fixa.

Pots trobar una col·lecció enorme de fons genials i seleccionats a [dharmx/walls](https://github.com/dharmx/walls).

La pantalla de bloqueig mostra un fotograma fix d'un fons de vídeo, de la mateixa manera que mostra un fotograma fix d'un GIF animat.
