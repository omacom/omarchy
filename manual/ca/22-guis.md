# GUIs

## Fitxers

Fitxers (Nautilus) és el gestor de fitxers gràfic. `Super + Shift + F` l'obre, i `Super + Shift + Alt + F` l'obre al directori on és el teu terminal, cosa que estalvia molts clics. `Ctrl + L` et permet escriure una ruta, i prémer `Space` sobre qualsevol fitxer et dona una vista prèvia ràpida sense obrir res.

Connecta una memòria USB o una targeta SD i es munta automàticament, de manera que apareix directament a la barra lateral. Per a qualsevol cosa més complexa — formatar una unitat, comprovar l'estat SMART, crear particions — obre _Disks_ des del llançador d'aplicacions (`Super + Space`).

En fer doble clic s'apliquen opcions predeterminades sensates: les imatges, els vídeos i la música s'obren a Omaview, els PDF a Document Viewer, el Markdown a Omawrite i el text sense format a l'editor triat a _Setup > Default > Editor_.

## Disktree

Quan la unitat s'omple i no tens ni idea de què se l'està menjant, obre [Disktree](https://github.com/tobi/disktree) des del llançador d'aplicacions (`Super + Space`). Mostra un mapa d'arbre gràfic del teu directori personal. Els blocs més grans ocupen més espai; entra als directoris amb el teclat o el ratolí, marca el que ha de desaparèixer i revisa les teves seleccions abans d'eliminar res. Executa `disktree --disk` per escanejar tot el disc.

## Obsidian

[Obsidian](https://obsidian.md/) és una aplicació per prendre notes gratuïta i molt extensible que utilitza fitxers Markdown simples per a l'emmagatzematge.

Obsidian és gratuït per a tots els usos, inclosos l'ús personal, comercial i sense ànim de lucre.

Obsidian també ofereix un [complement comercial de sincronització](https://obsidian.md/sync) amb aplicacions mòbils a iOS i Android. (https://obsidian.md/pricing).

Obres Obsidian amb `Super + Shift + O`. Per utilitzar la sincronització de temes, has de seleccionar el tema `Omarchy` a la configuració.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) és l'aplicació d'escriptura Markdown extremadament senzilla d'Omarchy. Sense cofres, sense complements, només tu i les paraules.

Obres Omawrite amb `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) és una eina bàsica d'edició d'imatges ideal per retallar, redimensionar i fer altres manipulacions bàsiques. No esperis, però, una alternativa a Photoshop. Però tot i així té vareta màgica i capes!

Obres Pinta mitjançant el llançador d'aplicacions (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) és una aplicació de temes que pot extreure colors d'una imatge de fons i convertir-los en un tema complet i cohesionat. És la manera més fàcil de [crear el teu propi tema](43-making-your-own-theme.md).

Obres Aether mitjançant el llançador d'aplicacions (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) et permet enviar fitxers a altres dispositius de la mateixa xarxa que executin l'aplicació, com l'AirDrop d'Apple. Això sí, és multiplataforma, així que pots enviar fitxers cap a i des de Windows, macOS, Android, iOS i, per descomptat, Linux.

Pots obrir el menú Share amb `Super + Ctrl + S` o a _Trigger > Share_ al menú d'Omarchy. Et dona quatre opcions:

- **Clipboard** envia el que hagis copiat com a fitxer de text. Ideal per passar un enllaç o un fragment al telèfon sense enviar-te un correu electrònic a tu mateix.
- **File** obre un selector de fitxers on en pots seleccionar diversos alhora.
- **Folder** envia un directori sencer.
- **Receive** obre LocalSend pròpiament dit perquè un altre dispositiu et pugui enviar alguna cosa.

El mateix funciona des del terminal amb `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Omet la ruta i obtindràs el selector.

També pots enviar directament des del gestor de fitxers: fes clic amb el botó dret sobre qualsevol selecció a Nautilus i tria _Send via LocalSend_.

El tallafoc d'Omarchy està tancat per defecte excepte pel port de LocalSend, així que això funciona des del primer moment en una instal·lació nova. Consulta [seguretat](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) és un paquet ofimàtic complet amb processador de textos, full de càlcul, presentacions, aplicació de dibuix i molt més. És compatible amb fitxers de Microsoft Office, així que és una manera fantàstica de poder obrir aquests documents de Word.

Obres LibreOffice mitjançant el llançador d'aplicacions (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) és l'aplicació de presentacions extremadament senzilla d'Omarchy. La teva presentació és un únic fitxer Markdown amb les seves imatges i vídeos al costat: escriu cada diapositiva sota una vista prèvia en directe, arrossega les diapositives per ordenar-les i després presenta a pantalla completa o exporta a PDF i PowerPoint. Fins i tot adopta el teu tema d'Omarchy.

Obres Hype mitjançant el llançador d'aplicacions (`Super + Space`). Prem `?` a dins per veure totes les dreceres.

## Signed

[Signed](https://github.com/omacom/signed) és la manera extremadament senzilla d'Omarchy de signar PDF i emplenar-los. Col·loca la teva signatura desada, text i la data d'avui a qualsevol lloc d'una pàgina i després desa una còpia signada al costat de l'original. Consulta [Com emplenar PDF](27-filling-out-pdfs.md) per saber com fer-ho.

Obres Signed mitjançant el llançador d'aplicacions (`Super + Space`), o obre-hi un PDF des del gestor de fitxers.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) és el joc d'escacs en 3D d'Omarchy. Juga contra un amic al mateix ordinador o contra l'oponent integrat en tres nivells, amb quatre conjunts esculpits que es mouen cadascun a la seva manera: naus orbitals, fusta tallada i ivori, criatures del bosc i caramels. Les partides no tenen rellotge i es desen després de cada moviment.

Obres Checkmate mitjançant el llançador d'aplicacions (`Super + Space`), on apareix com a Chess. Prem `?` a dins per veure totes les dreceres.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) és la calculadora extremadament senzilla d'Omarchy, que s'obre en una finestra flotant.

Obres Omacalc amb `Super + Shift + Q` (o amb la tecla de calculadora, si el teu teclat en té una).

## Signal

[Signal](https://signal.org/) és el pioner de la missatgeria xifrada E2E i una opció de comunicació fantàstica per a qualsevol que prefereixi no passar per un dels grans conglomerats tecnològics.

Obres Signal amb `Super + Shift + G`. No forma part de la instal·lació base, així que la primera vegada que premis aquesta combinació, Omarchy t'oferirà instal·lar-te'l (també és a _Install > Service_ al menú d'Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) és el visualitzador d'imatges i reproductor multimèdia extremadament senzill d'Omarchy: una finestra per a les teves fotos, vídeos i música. Obre una foto i les tecles de fletxa recorren la resta de la seva carpeta, `N` i `P` ho fan per a qualsevol cosa, i `Ctrl + M` mostra tota la carpeta com una quadrícula. També mostra fotos HEIC, AVIF i JPEG XL, i reprèn allà on ho vas deixar en qualsevol contingut llarg.

Prem `F` per a pantalla completa, `E` per editar una imatge a Omasnap o retallar un vídeo a Omacut, `Ctrl + P` per imprimir una imatge i `Delete` per moure un fitxer a la Paperera (`Ctrl + Z` el recupera). Prem `?` a dins per veure totes les dreceres.

Obres Omaview com a _Media Viewer_ mitjançant el llançador d'aplicacions (`Super + Space`), o simplement fes doble clic en una imatge, un vídeo o una cançó al gestor de fitxers.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) és el retallador de vídeo extremadament senzill d'Omarchy. Quan tot el que necessites és retallar el principi i el final d'un clip, és millor que engegar un editor de vídeo complet.

Obres Omacut mitjançant el llançador d'aplicacions (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) és el gravador de càmera web extremadament senzill d'Omarchy. Tria la càmera i el micròfon una vegada i després prem `Space` per gravar, i de nou per posar en pausa i reprendre la mateixa presa. Sempre grava amb la resolució més alta de la teva càmera, amb un mesurador de micròfon en directe perquè puguis comprovar els nivells abans de començar.

Atura la presa i s'obre immediatament en un editor integrat. Fes doble clic en un clip per dividir-lo, arrossega les nanses per retallar cada fragment i elimina les parts que no vols. Després desa'l com a MP4. La gravació original es conserva fins que la descartis, així que sempre pots tornar i retallar-la d'una altra manera.

Obres Monologue mitjançant el llançador d'aplicacions (`Super + Space`).
