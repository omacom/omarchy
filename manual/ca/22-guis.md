# GUIs

## Files

Files (Nautilus) és el gestor de fitxers gràfic. `Super + Shift + F` l'obre, i `Super + Shift + Alt + F` l'obre al directori on és el terminal, cosa que estalvia un munt de clics. `Ctrl + L` et permet escriure una ruta, i prémer `Space` sobre qualsevol fitxer et dona una vista prèvia ràpida sense obrir res.

Connecta una memòria USB o una targeta SD i es munta automàticament, de manera que apareix directament a la barra lateral. Per a qualsevol cosa més complicada —formatejar una unitat, comprovar l'estat SMART, crear particions— obre _Disks_ des del llançador d'aplicacions (`Super + Space`).

En fer doble clic s'apliquen opcions per defecte sensates: les imatges, els vídeos i la música s'obren a Omaview, els PDF a Document Viewer, el Markdown a Omawrite i el text sense format a l'editor triat a _Setup > Default > Editor_.

## Disktree

Quan el disc s'omple i no tens ni idea de què se l'està menjant, obre [Disktree](https://github.com/tobi/disktree) des del llançador d'aplicacions (`Super + Space`). Mostra un mapa d'arbre gràfic del teu directori personal. Els blocs més grans ocupen més espai; entra als directoris amb el teclat o el ratolí, marca el que ha de desaparèixer i revisa les seleccions abans d'eliminar res. Executa `disktree --disk` per escanejar tot el disc.

## Obsidian

[Obsidian](https://obsidian.md/) és una aplicació per prendre notes gratuïta i molt extensible que utilitza fitxers Markdown senzills per a l'emmagatzematge.

Obsidian és gratuït per a tots els usos, inclòs l'ús personal, comercial i sense ànim de lucre.

Obsidian també ofereix un [complement comercial per a la sincronització](https://obsidian.md/sync) amb aplicacions mòbils a iOS i Android. (https://obsidian.md/pricing).

Obres Obsidian amb `Super + Shift + O`. Per utilitzar la sincronització de temes, has de seleccionar el tema `Omarchy` a la configuració.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) és l'aplicació d'escriptura Markdown extremadament senzilla d'Omarchy. Sense cofres, sense complements, només tu i les paraules.

Obres Omawrite amb `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) és una eina d'edició d'imatges bàsica que va molt bé per retallar, redimensionar i fer altres manipulacions bàsiques. Simplement no esperis una alternativa a Photoshop. Però també té vareta màgica i capes!

Obres Pinta des del llançador d'aplicacions (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) és una aplicació de temes que pot extreure colors d'una imatge de fons i convertir-los en un tema complet i coherent. És la manera més fàcil de [crear el teu propi tema](43-making-your-own-theme.md).

Obres Aether des del llançador d'aplicacions (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) et permet enviar fitxers a altres dispositius de la mateixa xarxa que executin l'aplicació, com l'AirDrop d'Apple. Això sí, és multiplataforma, de manera que pots enviar i rebre fitxers amb Windows, macOS, Android, iOS i, per descomptat, Linux.

Pots obrir el menú Share amb `Super + Ctrl + S` o a _Trigger > Share_ al menú d'Omarchy. Et dona quatre opcions:

- **Clipboard** envia el que hagis copiat com a fitxer de text. Ideal per fer arribar un enllaç o un fragment al telèfon sense enviar-te un correu.
- **File** obre un selector de fitxers on en pots triar diversos alhora.
- **Folder** envia un directori sencer.
- **Receive** obre LocalSend pròpiament dit perquè un altre dispositiu et pugui enviar alguna cosa.

El mateix funciona des del terminal amb `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Omet la ruta i obtindràs el selector.

També pots enviar directament des del gestor de fitxers: fes clic amb el botó dret sobre qualsevol selecció a Nautilus i tria _Send via LocalSend_.

El tallafoc d'Omarchy és tancat per defecte excepte pel port de LocalSend, de manera que això funciona d'entrada en una instal·lació nova. Consulta [seguretat](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) és un paquet ofimàtic complet amb processador de textos, full de càlcul, presentacions, aplicació de dibuix i més. És compatible amb fitxers de Microsoft Office, de manera que és una manera excel·lent de poder obrir aquests documents de Word.

Obres LibreOffice des del llançador d'aplicacions (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) és l'aplicació de presentacions extremadament senzilla d'Omarchy. La teva presentació és un únic fitxer Markdown amb les seves imatges i vídeos al costat: escriu cada diapositiva sota una vista prèvia en directe, arrossega les diapositives per ordenar-les i després presenta a pantalla completa o exporta a PDF i PowerPoint. Fins i tot adopta el teu tema d'Omarchy.

Obres Hype des del llançador d'aplicacions (`Super + Space`). Prem `?` dins seu per veure totes les dreceres.

## Signed

[Signed](https://github.com/omacom/signed) és la manera extremadament senzilla d'Omarchy de signar PDF i emplenar-los. Posa la teva signatura guardada, text i la data d'avui on vulguis d'una pàgina i després desa una còpia signada al costat de l'original. Consulta [Emplenar PDF](27-filling-out-pdfs.md) per saber com fer-ho.

Obres Signed des del llançador d'aplicacions (`Super + Space`), o obre un PDF amb ell des del gestor de fitxers.

## Game Vibes

Game Vibes, al llançador d'aplicacions (`Super + Space`), és on viuen els petits jocs d'Omarchy: Checkmate, un joc d'escacs en 3D contra un amic o contra l'oponent integrat; Cards, el solitari Klondike; i Neon Swarm, un joc de trets arcade. Cadascun és una única pàgina web que segueix el teu tema. Tria'n un amb les fletxes i `Enter`, i torna a la llista amb `Esc` des de la pantalla de títol d'un joc o amb `Q` mentre està en pausa. S'obre a pantalla completa: `Super + F` el converteix en una finestra i `Super + W` el tanca.

Els jocs que crees amb un agent també apareixen aquí: tria _Make something cool → Game_ al panell d'agents i descriu-ne un, o anomena un joc que ja sigui a Game Vibes per continuar treballant-hi. L'agent el copia a `~/Games/vibes`, on és teu per modificar-lo, i l'obre quan acaba. Pots fer aquesta còpia tu mateix amb `omarchy games vibes copy <game>`. Un joc que comparteix una altra persona s'instal·la com un tema: tria _Install > Gaming > Game Vibes_ i enganxa'n l'adreça git, o executa `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ en torna a treure un, i _Update > Game Vibes Games_ n'obté versions noves. Els jocs carreguen three.js des del web, de manera que necessiten connexió per arrencar.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) és la calculadora extremadament senzilla d'Omarchy, que s'obre en una finestra flotant.

Obres Omacalc amb `Super + Shift + Q` (o la tecla de calculadora, si el teu teclat en té una).

## Signal

[Signal](https://signal.org/) és el pioner de la missatgeria xifrada E2E, i una opció de comunicació excel·lent per a qui prefereixi no passar per un dels grans conglomerats tecnològics.

Obres Signal amb `Super + Shift + G`. No forma part de la instal·lació base, de manera que la primera vegada que premis això, Omarchy t'oferirà instal·lar-te'l (també és a _Install > Service_ al menú d'Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) és el visor d'imatges i reproductor multimèdia extremadament senzill d'Omarchy: una finestra per a les teves fotos, vídeos i música. Obre una foto i les tecles de fletxa avancen per la resta de la seva carpeta, `N` i `P` ho fan per a qualsevol cosa i `Ctrl + M` mostra tota la carpeta com una quadrícula. També mostra fotos HEIC, AVIF i JPEG XL, i reprèn allà on ho vas deixar en qualsevol cosa llarga.

Prem `F` per a pantalla completa, `E` per editar una imatge a Omasnap o retallar un vídeo a Omacut, `Ctrl + P` per imprimir una imatge i `Delete` per moure un fitxer a la paperera (`Ctrl + Z` el recupera). Prem `?` dins seu per veure totes les dreceres.

Obres Omaview com a _Media Viewer_ des del llançador d'aplicacions (`Super + Space`), o simplement fes doble clic en una imatge, un vídeo o una cançó al gestor de fitxers.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) és el retallador de vídeo extremadament senzill d'Omarchy. Quan només necessites tallar el principi i el final d'un clip, supera de llarg obrir un editor de vídeo complet.

Obres Omacut des del llançador d'aplicacions (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) és la gravadora de càmera web extremadament senzilla d'Omarchy. Tria la càmera i el micròfon una vegada, després prem `Space` per gravar, i prem-lo de nou per pausar i reprendre la mateixa presa. Sempre grava a la resolució més alta de la càmera, amb un indicador de micròfon en directe perquè puguis comprovar els nivells abans de començar.

Atura la presa i s'obre de seguida en un editor integrat. Fes doble clic en un clip per dividir-lo, arrossega les nanses per retallar cada tros i elimina les parts que no vols. Després desa'l com a MP4. L'enregistrament original es conserva fins que el descartes, de manera que sempre pots tornar i tallar-lo d'una altra manera.

Obres Monologue des del llançador d'aplicacions (`Super + Space`).
