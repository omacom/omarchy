# Fons

Cada tema ve amb el seu propi conjunt de fons, i pots afegir-ne de teus a `~/.config/omarchy/backgrounds/[theme]`. Si vols afegir una imatge de fons extra a, diguem-ne, el tema nord, només cal que posis el fitxer a `~/.config/omarchy/backgrounds/nord`.

La manera més fàcil de fer-ho és anar a _Instal·la > Estil > Fons_ al menú d'Omarchy. Això obrirà la carpeta on es desen els fons d'aquell tema. Prem `Super + Shift + F` per engegar un altre gestor de fitxers, troba el teu fons i copia'l. Ara quedarà inclòs entre les opcions de fons que pots triar fent servir `Super + Ctrl + Space`.

Els fons poden ser vídeos, a més d'imatges fixes. Deixa un fitxer `mp4`, `m4v`, `mov`, `webm`, `mkv` o `avi` a la mateixa carpeta i apareixerà al costat de les imatges. Els vídeos els reprodueix el motor de fons de pantalla OWE. Descodifica el vídeo una vegada per a tots els monitors i en reprodueix el so a través de la sortida d'àudio per defecte, i atura la reproducció sempre que res no el pugui veure. La pantalla de bloqueig dibuixa la mateixa descodificació, silenciada, a través d'OWE. Un fons de vídeo continua costant molta més energia que un de fix.

Els temes poden incloure una introducció curta per a un fons fix. Per a `backgrounds/road.webp`, el vídeo corresponent viu a `backgrounds/intros/road.mp4`. Es reprodueix automàticament en arrencar i en canviar a un tema amb aquell fons seleccionat, i després torna a la imatge fixa. Els vídeos d'introducció queden fora del selector de fons i mai no es repeteixen en bucle.

Desactivar _Activa > Aparença > Animacions_ també desactiva les introduccions de fons. Omarchy ho fa per defecte en una màquina virtual. L'ordre `omarchy theme bg intro toggle` pot commutar les introduccions per separat. Actualitzar un tema o triar un altre fons dins del mateix tema no reprodueix cap introducció.

Pots trobar una col·lecció enorme de fons genials i seleccionats a https://github.com/dharmx/walls.

Els fons de vídeo conserven una imatge fixa en memòria cau a la pantalla de bloqueig mentre la reproducció està en pausa o no està disponible. Els GIF animats es reprodueixen a l'escriptori i mostren un fotograma fix a la pantalla de bloqueig.
