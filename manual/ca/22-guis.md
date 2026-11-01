# GUIs

## Files

Files (Nautilus) és el gestor de fitxers gràfic. `Super + Shift + F` l'obre, i `Super + Shift + Alt + F` l'obre al directori on es troba el teu terminal, cosa que estalvia molts clics. `Ctrl + L` et permet escriure un camí, i prémer `Space` sobre qualsevol fitxer et dona una vista prèvia ràpida sense obrir res.

Connecta una memòria USB o una targeta SD i es munta automàticament, de manera que apareix directament a la barra lateral. Per a qualsevol cosa més complexa — formatar una unitat, comprovar l'estat SMART, crear particions — obre _Disks_ des del llançador d'aplicacions (`Super + Space`).

Fer doble clic segueix uns valors per defecte sensats: les imatges s'obren a imv, el vídeo a mpv, els PDFs a Document Viewer i el text pla a Neovim.

## Disktree

Quan la unitat s'omple i no tens ni idea de què se l'està menjant, obre [Disktree](https://github.com/tobi/disktree) des del llançador d'aplicacions (`Super + Space`). Mostra un mapa d'arbre gràfic del teu directori personal. Els blocs més grans ocupen més espai; entra als directoris amb el teclat o el ratolí, marca el que ha de desaparèixer i revisa les teves seleccions abans d'eliminar res. Executa `disktree --disk` per escanejar tot el disc.

## Obsidian

[Obsidian](https://obsidian.md/) és una aplicació per prendre notes gratuïta i molt extensible que utilitza fitxers Markdown senzills per a l'emmagatzematge.

Obsidian és gratuït per a tots els usos, inclòs l'ús personal, comercial i sense ànim de lucre.

Obsidian també ofereix un [complement comercial per a la sincronització](https://obsidian.md/sync) amb aplicacions mòbils a iOS i Android. (https://obsidian.md/pricing).

Inicies Obsidian amb `Super + Shift + O`. Per utilitzar la sincronització de temes, has de seleccionar el tema `Omarchy` als ajustos.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) és la pròpia aplicació d'escriptura Markdown d'Omarchy, d'una simplicitat radical. Sense vaults, sense complements, només tu i les paraules.

Inicies Omawrite amb `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) és una eina bàsica d'edició d'imatges ideal per retallar, redimensionar i fer altres manipulacions bàsiques. No esperis una alternativa a Photoshop. Però tot i així té Magic Wand i capes!

Inicies Pinta mitjançant el llançador d'aplicacions (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) és una aplicació de temes que pot extreure colors d'una imatge de fons i convertir-los en un tema complet i cohesionat. És la manera més fàcil de [crear el teu propi tema](43-making-your-own-theme.md).

Inicies Aether mitjançant el llançador d'aplicacions (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) et permet enviar fitxers a altres dispositius de la mateixa xarxa que executin l'aplicació, com l'AirDrop d'Apple. Això sí, és multiplataforma, així que pots enviar fitxers cap a i des de Windows, macOS, Android, iOS i, per descomptat, Linux.

Pots obrir el menú Share amb `Super + Ctrl + S` o a _Trigger > Share_ al menú d'Omarchy. Et dona quatre opcions:

- **Clipboard** envia tot el que hagis copiat com a fitxer de text. Ideal per passar un enllaç o un fragment al telèfon sense enviar-te un correu a tu mateix.
- **File** obre un selector de fitxers on en pots seleccionar diversos alhora.
- **Folder** envia un directori sencer.
- **Receive** obre LocalSend pròpiament dit perquè un altre dispositiu et pugui enviar alguna cosa.

El mateix funciona des del terminal amb `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Omet el camí i obtindràs el selector.

També pots enviar directament des del gestor de fitxers: fes clic amb el botó dret sobre qualsevol selecció a Nautilus i tria _Send via LocalSend_.

El tallafocs d'Omarchy està tancat per defecte excepte pel port de LocalSend, així que això funciona des del primer moment en una instal·lació nova. Consulta [seguretat](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) és un paquet ofimàtic complet amb processador de textos, full de càlcul, presentacions, aplicació de dibuix i molt més. És compatible amb fitxers de Microsoft Office, així que és una manera excel·lent de poder obrir aquests documents de Word.

Inicies LibreOffice mitjançant el llançador d'aplicacions (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) és la pròpia aplicació de presentacions d'Omarchy, d'una simplicitat radical. La teva presentació és un únic fitxer Markdown amb les seves imatges i vídeos al costat: escriu cada diapositiva sota una vista prèvia en directe, arrossega les diapositives per ordenar-les i després presenta a pantalla completa o exporta a PDF i PowerPoint. Fins i tot adopta el teu tema d'Omarchy.

Inicies Hype mitjançant el llançador d'aplicacions (`Super + Space`). Prem `?` a dins per veure totes les dreceres.

## Signed

[Signed](https://github.com/omacom/signed) és la manera pròpia d'Omarchy, d'una simplicitat radical, de signar PDFs i omplir-los. Col·loca la teva signatura desada, text i la data d'avui a qualsevol lloc d'una pàgina i després desa una còpia signada al costat de l'original. Consulta [Omplir PDFs](27-filling-out-pdfs.md) per saber com fer-ho.

Inicies Signed mitjançant el llançador d'aplicacions (`Super + Space`), o obre-hi un PDF des del gestor de fitxers.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) és la pròpia calculadora d'Omarchy, d'una simplicitat radical, que s'obre en una finestra flotant.

Inicies Omacalc amb `Super + Shift + Q` (o la tecla de calculadora, si el teu teclat en té una).

## Signal

[Signal](https://signal.org/) és el pioner de la missatgeria xifrada E2E, i una opció de comunicació excel·lent per a qui prefereixi no passar per un dels grans conglomerats tecnològics.

Inicies Signal amb `Super + Shift + G`. No forma part de la instal·lació base, així que la primera vegada que premis aquesta combinació, Omarchy t'oferirà instal·lar-lo (també és a _Install > Service_ al menú d'Omarchy).

## mpv

[mpv](https://mpv.io/) és un reproductor multimèdia senzill i ràpid que reproduirà gairebé qualsevol cosa de qualsevol origen. Ideal per mirar vídeos.

Inicies mpv mitjançant el llançador d'aplicacions (`Super + Space`) o simplement fes doble clic sobre un vídeo al gestor de fitxers.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) és el propi tallador de vídeo d'Omarchy, d'una simplicitat radical. Quan l'únic que necessites és retallar l'inici i el final d'un clip, supera de llarg obrir un editor de vídeo complet.

Inicies Omacut mitjançant el llançador d'aplicacions (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) és el propi gravador de càmera web d'Omarchy, d'una simplicitat radical. Tria la càmera i el micròfon una vegada, després prem `Space` per gravar, i de nou per pausar i reprendre la mateixa presa. Sempre grava a la resolució més alta de la càmera, amb un mesurador de micròfon en directe perquè puguis comprovar els nivells abans de començar.

Atura la presa i s'obre immediatament en un editor integrat. Fes doble clic sobre un clip per dividir-lo, arrossega les nanses per retallar cada peça i elimina les parts que no vols. Després desa-ho com a MP4. La gravació original es conserva fins que la descartes, així que sempre pots tornar-hi i tallar-la d'una altra manera.

Inicies Monologue mitjançant el llançador d'aplicacions (`Super + Space`).
