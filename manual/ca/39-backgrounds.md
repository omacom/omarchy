# Fons de pantalla

Cada tema inclou el seu propi conjunt de fons, i en pots afegir d'extra de teus a `~/.config/omarchy/backgrounds/[theme]`. Si vols afegir una imatge de fons extra a, posem, el tema nord, només cal que posis el fitxer a `~/.config/omarchy/backgrounds/nord`.

Pots fer-ho de la manera més fàcil anant a _Install > Style > Background_ al Menú d'Omarchy. Això obrirà la carpeta on es desen els fons d'aquell tema. Prem `Super + Shift + F` per obrir un altre gestor de fitxers, troba el teu fons i copia-l'hi. Ara s'inclourà entre les opcions de fons que pots anar triant amb `Super + Ctrl + W`.

Els fons poden ser vídeos a més d'imatges fixes. Deixa anar un fitxer `mp4`, `m4v`, `mov`, `webm`, `mkv` o `avi` a la mateixa carpeta i apareixerà al costat de les imatges. Els vídeos els reprodueix el motor de fons de pantalla OWE. Descodifica el vídeo un cop per a tots els monitors i en reprodueix el so per la sortida d'àudio per defecte, i atura la reproducció sempre que res no el pugui veure. Un fons de pantalla de vídeo continua costant molta més energia que un de fix.

Els temes poden incloure una introducció curta per a un fons fix. Per a `backgrounds/road.webp`, el vídeo corresponent es troba a `backgrounds/intros/road.mp4`. Es reprodueix automàticament a l'arrencada, en canviar a un tema amb aquell fons seleccionat i en triar aquell fons, i després torna a la imatge fixa. Els vídeos d'introducció no apareixen al selector de fons i mai es reprodueixen en bucle.

Triar _Appearance > Animations Off_ també desactiva les introduccions dels fons. Omarchy ho fa per defecte en una màquina virtual. L'ordre `omarchy theme bg intro toggle` pot activar i desactivar les introduccions per separat. Actualitzar un tema no reprodueix cap introducció.

Una imatge fixa també pot tenir un bucle, una versió tranquil·la de la mateixa imatge que es continua movent, a `backgrounds/loops/road.mp4`. Es reprodueix en lloc de la imatge fixa, després de la seva introducció si en té, i s'atura quan es desactiven les animacions. Amb bateria, es mostra la imatge fixa en lloc del bucle, i el bucle torna un cop connectes l'equip. Els bucles no apareixen al selector de fons.

Pots trobar una col·lecció enorme de fons seleccionats ben xulos a [dharmx/walls](https://github.com/dharmx/walls).

La pantalla de bloqueig mostra un fotograma fix d'un fons de vídeo, de la mateixa manera que mostra un fotograma fix d'un GIF animat.
