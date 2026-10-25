# Fons de pantalla

Cada tema inclou el seu propi conjunt de fons de pantalla, i en pots afegir de teus a `~/.config/omarchy/backgrounds/[theme]`. Si vols afegir una imatge de fons extra, per exemple, al tema nord, només has de posar el fitxer a `~/.config/omarchy/backgrounds/nord`.

La manera més fàcil de fer-ho és anar a _Install > Style > Background_ al Menú d'Omarchy. Això obrirà la carpeta on es desen els fons d'aquest tema. Prem `Super + Shift + F` per obrir un altre gestor de fitxers, troba el teu fons i copia-l'hi. Ara s'inclourà entre les opcions de fons entre les quals pots triar amb `Super + Ctrl + W`.

Els fons també poden ser vídeos, a més d'imatges fixes. Deixa un fitxer `mp4`, `m4v`, `mov`, `webm`, `mkv` o `avi` a la mateixa carpeta i apareixerà al costat de les imatges. Els vídeos els reprodueix el motor de fons de pantalla OWE. Descodifica el vídeo una sola vegada per a tots els monitors i en reprodueix el so a través de la sortida d'àudio predeterminada, i atura la reproducció sempre que res no el pugui veure. Un fons de pantalla de vídeo continua consumint molta més energia que un de fix.

Els temes poden incloure una introducció curta per a un fons fix. Per a `backgrounds/road.webp`, el vídeo corresponent es troba a `backgrounds/intros/road.mp4`. Es reprodueix automàticament en arrencar i en canviar a un tema amb aquest fons seleccionat, i després torna a la imatge fixa. Els vídeos d'introducció no apareixen al selector de fons i mai es reprodueixen en bucle.

Desactivar _Appearance > Animations_ també desactiva les introduccions dels fons. Omarchy ho fa per defecte en una màquina virtual. L'ordre `omarchy theme bg intro toggle` pot activar o desactivar les introduccions per separat. Actualitzar un tema o triar un altre fons dins del mateix tema no reprodueix cap introducció.

Pots trobar una col·lecció enorme de fons seleccionats molt xulos a https://github.com/dharmx/walls.

La pantalla de bloqueig mostra un fotograma fix d'un fons de vídeo, de la mateixa manera que mostra un fotograma fix d'un GIF animat.
