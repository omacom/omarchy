# GUIs

## Files

Files (Nautilus) és el gestor de fitxers gràfic. `Super + Shift + F` l'obre, i `Super + Shift + Alt + F` l'obre al directori on es troba el teu terminal, cosa que estalvia molts clics. `Ctrl + L` et permet escriure una ruta, i prémer `Space` sobre qualsevol fitxer et dona una vista prèvia ràpida sense obrir res.

Connecta una memòria USB o una targeta SD i es munta automàticament, de manera que apareix directament a la barra lateral. Per a qualsevol cosa més complexa — formatar una unitat, comprovar l'estat SMART, crear particions — obre _Disks_ des del llançador d'aplicacions (`Super + Space`).

El doble clic segueix uns valors per defecte sensats: les imatges, els vídeos i la música s'obren a Omaview, els PDF a Document Viewer, i el text sense format a Neovim.

## Disktree

Quan la unitat s'omple i no tens ni idea de què se l'està menjant, obre [Disktree](https://github.com/tobi/disktree) des del llançador d'aplicacions (`Super + Space`). Mostra un mapa d'arbre gràfic del teu directori personal. Els blocs més grans ocupen més espai; entra als directoris amb el teclat o el ratolí, marca el que ha de desaparèixer i revisa les teves seleccions abans d'eliminar res. Executa `disktree --disk` per escanejar tot el disc.

## Obsidian

[Obsidian](https://obsidian.md/) és una aplicació per prendre notes gratuïta i molt extensible que utilitza fitxers Markdown senzills per a l'emmagatzematge.

Obsidian és gratuït per a tots els usos, inclòs l'ús personal, comercial i sense ànim de lucre.

Obsidian també ofereix un [complement comercial per a la sincronització](https://obsidian.md/sync) amb aplicacions mòbils a iOS i Android. (https://obsidian.md/pricing).

Inicies Obsidian amb `Super + Shift + O`. Per utilitzar la sincronització de temes, has de seleccionar el tema `Omarchy` a la configuració.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) és l'aplicació d'escriptura Markdown d'Omarchy, d'allò més senzilla. Sense voltes, sense complements, només tu i les paraules.

Inicies Omawrite amb `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) és una eina d'edició d'imatges bàsica que és ideal per retallar, redimensionar i fer altres manipulacions bàsiques. No esperis una alternativa a Photoshop. Però tot i així té la Vareta Màgica i capes!

Inicies Pinta des del llançador d'aplicacions (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) és una aplicació de temes que pot extreure colors d'una imatge de fons i convertir-los en un tema complet i cohesionat. És la manera més fàcil de [crear el teu propi tema](43-making-your-own-theme.md).

Inicies Aether des del llançador d'aplicacions (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) et permet enviar fitxers a altres dispositius de la mateixa xarxa que executin l'aplicació, com l'AirDrop d'Apple. Això sí, és multiplataforma, de manera que pots enviar fitxers cap a i des de Windows, macOS, Android, iOS i, per descomptat, Linux.

Pots obrir el menú Share amb `Super + Ctrl + S` o a _Trigger > Share_ al menú d'Omarchy. Et dona quatre opcions:

- **Clipboard** envia tot el que hagis copiat com a fitxer de text. Perfecte per passar un enllaç o un fragment al teu telèfon sense haver d'enviar-te un correu.
- **File** obre un selector de fitxers on en pots seleccionar diversos alhora.
- **Folder** envia un directori sencer.
- **Receive** obre LocalSend pròpiament dit perquè un altre dispositiu et pugui enviar alguna cosa.

El mateix funciona des del terminal amb `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Si ometes la ruta, obtindràs el selector.

També pots enviar directament des del gestor de fitxers: fes clic amb el botó dret sobre qualsevol selecció a Nautilus i tria _Send via LocalSend_.

El tallafoc d'Omarchy està tancat per defecte excepte pel port de LocalSend, de manera que això funciona des del primer moment en una instal·lació nova. Consulta [seguretat](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) és un paquet ofimàtic complet amb processador de textos, full de càlcul, presentacions, aplicació de dibuix i molt més. És compatible amb fitxers de Microsoft Office, de manera que és una manera fantàstica de poder obrir aquells documents de Word.

Inicies LibreOffice des del llançador d'aplicacions (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) és l'aplicació de presentacions d'Omarchy, d'allò més senzilla. La teva presentació és un únic fitxer Markdown amb les seves imatges i vídeos al costat: escriu cada diapositiva sota una vista prèvia en directe, arrossega les diapositives per ordenar-les i després presenta a pantalla completa o exporta a PDF i PowerPoint. Fins i tot adopta el teu tema d'Omarchy.

Inicies Hype des del llançador d'aplicacions (`Super + Space`). Prem `?` un cop dins per veure totes les dreceres.

## Signed

[Signed](https://github.com/omacom/signed) és la manera d'Omarchy, d'allò més senzilla, de signar PDF i omplir-los. Posa la teva signatura desada, text i la data d'avui a qualsevol lloc d'una pàgina i després desa una còpia signada al costat de l'original. Consulta [Com omplir PDF](27-filling-out-pdfs.md) per saber com fer-ho.

Inicies Signed des del llançador d'aplicacions (`Super + Space`), o obres un PDF amb ell des del gestor de fitxers.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) és la calculadora d'Omarchy, d'allò més senzilla, que s'obre en una finestra flotant.

Inicies Omacalc amb `Super + Shift + Q` (o amb la tecla de la calculadora, si el teu teclat en té una).

## Signal

[Signal](https://signal.org/) és el pioner de la missatgeria xifrada E2E, i una opció de comunicació fantàstica per a qualsevol que prefereixi no passar per un dels grans conglomerats tecnològics.

Inicies Signal amb `Super + Shift + G`. No forma part de la instal·lació base, de manera que la primera vegada que premis això, Omarchy t'oferirà instal·lar-lo per tu (també el trobaràs a _Install > Service_ al menú d'Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) és el visualitzador d'imatges i reproductor multimèdia d'Omarchy, d'allò més senzill: una sola finestra per a les teves fotos, vídeos i música. Obre una foto i les tecles de fletxa recorren la resta de la seva carpeta, `N` i `P` ho fan per a qualsevol cosa, i `Ctrl + M` mostra tota la carpeta com una quadrícula. També mostra fotos HEIC, AVIF i JPEG XL, i reprèn allà on ho vas deixar en qualsevol cosa llarga.

Prem `F` per a pantalla completa, `E` per editar una imatge a Omasnap o retallar un vídeo a Omacut, `Ctrl + P` per imprimir una imatge i `Delete` per moure un fitxer a la Paperera (`Ctrl + Z` el recupera). Prem `?` un cop dins per veure totes les dreceres.

Inicies Omaview com a _Media Viewer_ des del llançador d'aplicacions (`Super + Space`), o simplement fas doble clic en una imatge, un vídeo o una cançó al gestor de fitxers.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) és el retallador de vídeo d'Omarchy, d'allò més senzill. Quan tot el que necessites és tallar el principi i el final d'un clip, supera de llarg obrir un editor de vídeo complet.

Inicies Omacut des del llançador d'aplicacions (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) és l'enregistrador de càmera web d'Omarchy, d'allò més senzill. Tria la càmera i el micròfon una vegada, després prem `Space` per gravar, i una altra vegada per posar en pausa i reprendre la mateixa presa. Sempre grava a la resolució més alta de la teva càmera, amb un indicador de micròfon en directe perquè puguis comprovar els nivells abans de començar.

Atura la presa i s'obre de seguida en un editor integrat. Fes doble clic en un clip per dividir-lo, arrossega les nanses per retallar cada fragment i elimina les parts que no vulguis. Després desa-ho com a MP4. L'enregistrament original es conserva fins que el descartis, de manera que sempre pots tornar i tallar-lo d'una altra manera.

Inicies Monologue des del llançador d'aplicacions (`Super + Space`).
